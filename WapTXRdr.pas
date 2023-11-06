unit WapTXRdr;

interface

uses Classes, SysUtils, Forms, HttpReq, AppSSI, WapSchdl, HWebApp, IPC, WIPCShrd, IpcConv;

type

EWapRequestsReader = class(Exception);

TWapRequestsReader = class
private
    FApp: TWapApp;
    FScheduler: TWapScheduler;
    FSessionList: TWapSessionList;
    FHandshakeMem: TSharedMemory;
    FHandshakeMemPtr: PHandshakeMemData;
    FHandshakeMemLock: TWin32Mutex;
    FWapStubRequestWaitingEvent: TWin32Event;
    FWorkerThread: TThread;
    FTerminateWorkerThread: TWin32Event;
    FStubTimeout: integer;
    FOnException: TExceptionEvent;
    ConverstationsArrayMem: TSharedMemory;
    ConverstationsArrayPtr: PConversationsArraySharedMem;

    procedure HandleRequest(RequestInterface: TAbstractHttpRequestInterface);
    procedure HandleGetSessionCount(Conversation: TIpcConversation);
    procedure HandleTerminate(Conversation: TIpcConversation);
    procedure DoPostQuitMessage;
    procedure ExecuteThread;
    function InternalFormatSharedName(const BaseName: string): string;
    procedure SetStubTimeout(Value: integer);
protected
    procedure HandleException(E: Exception);
public
    constructor Create(App: TWapApp; Scheduler: TWapScheduler; SessionList: TWapSessionList);
    destructor Destroy; override;

    procedure Start;
    procedure Stop;

    property App: TWapApp read FApp;
    property Scheduler: TWapScheduler read FScheduler;
    property SessionList: TWapSessionList read FSessionList;
    property StubTimeout: integer read FStubTimeout write SetStubTimeout;

    property OnException: TExceptionEvent read FOnException write FOnException;
end;

implementation

uses IpcRqst, Windows, WCP;

{$include wcp.inc}

type

///////////////////////////////////////////////////////////////////////
//
// TWorkerThread
//
///////////////////////////////////////////////////////////////////////

TWorkerThread = class(TThread)
private
    FReader: TWapRequestsReader;
public
    constructor Create(Reader: TWapRequestsReader);
    procedure Execute; override;
end;

constructor TWorkerThread.Create(Reader: TWapRequestsReader);
begin
    inherited Create(true);
    FreeOnTerminate := true;
    FReader := Reader;
    Resume;
end;

procedure TWorkerThread.Execute;
begin
    // Reflect back to the reader object
    FReader.ExecuteThread;
end;

///////////////////////////////////////////////////////////////////////
//
// TWapRequestsReader
//
///////////////////////////////////////////////////////////////////////

constructor TWapRequestsReader.Create(App: TWapApp; Scheduler: TWapScheduler; SessionList: TWapSessionList);
begin
    inherited Create;
    FApp := App;
    FScheduler := Scheduler;
    FSessionList := SessionList;

    FHandshakeMem := TSharedMemory.Create(InternalFormatSharedName(HandshakeMemName), sizeof(THandshakeMemData), @NoSecurityAttributes);
    FHandshakeMemPtr := FHandshakeMem.Buffer;
    FHandshakeMemLock := TWin32Mutex.Create(InternalFormatSharedName(HandshakeMemLockName), @NoSecurityAttributes);
    FWapStubRequestWaitingEvent := TWin32Event.Create(InternalFormatSharedName(WapStubRequestWaitingEventName), false, @NoSecurityAttributes);

    ConverstationsArrayMem := TSharedMemory.Create(InternalFormatSharedName(ConversationsArrayMemName), ConverstationsArraySize, @NoSecurityAttributes);
    ConverstationsArrayPtr := PConversationsArraySharedMem(ConverstationsArrayMem.Buffer);

    FTerminateWorkerThread := TWin32Event.Create('', true, nil);

    // Set the default timeout to 60 seconds, it might change later
    StubTimeout := 60;
end;

destructor TWapRequestsReader.Destroy;
begin
    Stop;

    ConverstationsArrayMem.Free;

    FTerminateWorkerThread.Free;
    FWapStubRequestWaitingEvent.Free;
    FHandshakeMemLock.Free;
    FHandshakeMem.Free;
    inherited;
end;

procedure TWapRequestsReader.Start;
begin
    FHandshakeMemPtr.ProxyProcessId := GetCurrentProcessId;
    FWorkerThread := TWorkerThread.Create(Self);
end;

procedure TWapRequestsReader.Stop;
var
    WorkerThreadHandle: THandle;
begin
    if (FWorkerThread <> nil) then begin
        WorkerThreadHandle := FWorkerThread.Handle;
        if (FTerminateWorkerThread <> nil) then
            FTerminateWorkerThread.Signal;
        if (WaitForSingleObject(WorkerThreadHandle, 500) <> WAIT_OBJECT_0) then
            ;
        FWorkerThread := nil; // The thread will automatically free itself on termination
    end;
    if (FHandshakeMem <> nil) then
        FHandshakeMemPtr.ProxyProcessId := 0;
end;

procedure TWapRequestsReader.HandleRequest(RequestInterface: TAbstractHttpRequestInterface);
var
    Transaction: THttpTransaction;
    Session: TWapSession;
    SessionId: string;
begin
    {$ifdef cp_on}cp(1, '<TWapRequestsReader.HandleRequest');{$endif cp_on}
    Transaction := THttpTransaction.Create(RequestInterface, true);

    SessionId := Transaction.Request.Cookies[sharedCookieName]['WA_SID'];

    if (SessionId <> '') then begin
        // even though the browser already has a Session with us,
        // this is a Request to start a new Session
        if Transaction.Request.QueryString.VariableExists('NewSession') then
            SessionId := '';
    end;

    if (SessionId = '') then
        Session := nil
    else
        Session := FSessionList.GetSession(SessionId);   // could result in nil if invalid (expired) Session id

    // This will put the request into a queue and return ASAP
    Scheduler.ScheduleForExecution(App, Session, Transaction);
    {$ifdef cp_on}cp(-1, 'TWapRequestsReader.HandleRequest>');{$endif cp_on}
end;

procedure TWapRequestsReader.HandleGetSessionCount(Conversation: TIpcConversation);
begin
    Conversation.InitiateConversation;
    try
        Conversation.Slot.WapCmd_SessionCount := App.Sessions.Count;
    finally
        Conversation.Free;
    end;
end;

// Called in the main application thread
procedure TWapRequestsReader.DoPostQuitMessage;
begin
    PostQuitMessage(0);
end;

procedure TWapRequestsReader.HandleTerminate(Conversation: TIpcConversation);
begin
    try
        Conversation.InitiateConversation;
    finally
        Conversation.Free;
    end;
    CallInMainThread(DoPostQuitMessage);
end;

// This method is executed by the *worker thread*
procedure TWapRequestsReader.ExecuteThread;
var
    Request: TIpcRequest;
    ConversationSlot: PConversationSlot;
    Conversation: TIpcConversation;
begin
    while (true) do begin
        try
            // wait for a request from the stub, or for terminate event
            if (WaitForOneOfTwoObjects(
                    FWapStubRequestWaitingEvent.Handle,
                    FTerminateWorkerThread.Handle,
                    false,
                    INFINITE
                ) = WAIT_OBJECT_0 + 1)
            then
                exit;

            if (FHandshakeMemPtr.FormatVersion <> HandshakeMemData_FormatVersion) then
                raise EWapRequestsReader.CreateFmt(
                    'Handshake area format version mismatch. Expecting version %d, found version %d',
                    [HandshakeMemData_FormatVersion, FHandshakeMemPtr.FormatVersion]
                );
                
            ConversationSlot := @ConverstationsArrayPtr^[FHandshakeMemPtr.ConversationIndex];
            if (ConversationSlot.FormatVersion <> ConversationSlot_FormatVersion) then
                raise EWapRequestsReader.CreateFmt(
                    'Conversation slot format version mismatch. Expecting version %d, found version %d',
                    [ConversationSlot_FormatVersion, ConversationSlot.FormatVersion]
                );
            Conversation := TIpcConversation.Create(ConversationSlot);
            case Conversation.Slot.ConversationType of
                ctHttpRequest: begin
                    // TIpcRequest's ctor releases our hold on the handshake mem, through the InitiateConversation method.
                    // Ownership of the Conversation object is given to the Request object.
                    Request := TIpcRequest.Create(Conversation);
                    HandleRequest(Request);
                end;
                ctWapCmd: begin
                    case Conversation.Slot.WapCmd of
                        wcGetAppSessionCount: HandleGetSessionCount(Conversation);
                        wcTerminateApp: HandleTerminate(Conversation);
                    end;
                end;
            end;
        except
            on E: Exception do
                HandleException(E);
        end;
    end; // while
end;

function TWapRequestsReader.InternalFormatSharedName(const BaseName: string): string;
begin
    result := FormatSharedName(BaseName, FApp.AppId);
end;

procedure TWapRequestsReader.HandleException(E: Exception);
begin
    if assigned(FOnException) then
        FOnException(Self, E);
end;

procedure TWapRequestsReader.SetStubTimeout(Value: integer);
begin
    if (FStubTimeout <> Value) then begin
        FStubTimeout := Value;
        if (FHandshakeMemLock.WaitFor(30 * 1000) <> wrSignaled) then
            raise EWapRequestsReader.Create('Timed out while attempting to access the HandshakeMem area');
        try
            FHandshakeMemPtr.ServerRequestTimeout := Value * 1000;
        finally
            FHandshakeMemLock.Release;
        end;
    end;
end;

end.
