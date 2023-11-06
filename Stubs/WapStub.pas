unit WapStub;

interface

uses Classes, SysUtils, IPC, Windows
    ,WIPCShrd, HttpReq, AppSSI, XcptTrc
    ;

type
EWapAppRequestServerStubNoServer = class(Exception);

TAppState = (asRunning, asSuspended, asTerminated);

EWapAppStub = class(ETracedException);

// handle all requests for a specific app
// Thread-safe, Execute can be called by multiple threads
TWapAppStub = class
private
    FAppId: string;
    FSuspended: boolean;
    FSuspendedURL: string;

    HandshakeMem: TSharedMemory;
    HandshakeMemMutex: TWin32Mutex;
    HandshakePtr: PHandshakeMemData;
    ProxyProcessLock: TWin32CriticalSection;

    ConverstationsArrayMem: TSharedMemory;
    ConverstationsArrayPtr: PConversationsArraySharedMem;

    WapStubRequestWaitingEvent: TWin32Event;

    function GetProxyProcessId: dword;
    procedure InitializeConversationSlot(Slot: PConversationSlot; WapProcessId: dword);
    procedure FinalizeConversationSlot(Index: integer);
    procedure HandleServerRequest(
        RequestInterface: TAbstractHttpRequestInterface;
        ConversationSlot: PConversationSlot
        );
    procedure SetupForInitiateConversation(
        Transaction: THttpTransaction;
        WapCmd: TWapCmd;
        var ConversationSlot: TConversationSlot
        );
    procedure HandleEndOfWapCmd(Transaction: THttpTransaction; ConversationSlot: PConversationSlot);
    function AllocateConversationIndex: integer;
    procedure DeallocateConversationIndex(ConversationIndex: integer);
    function GetAppState: string;
    procedure SendRequestToServer(Transaction: THttpTransaction; WapCmd: TWapCmd);
    function ValidateRemoteAdmin(Transaction: THttpTransaction; WapCmd: TWapCmd): boolean;
protected
    function FormatSharedName(const BaseName: string): string;
public
    constructor Create(const AppId: string);
    destructor Destroy; override;
    procedure ProcessRequest(Transaction: THttpTransaction);
    property AppId: string read FAppId;
end;

implementation

uses D3SysUtl, CWebAppConfig, AppSpawner, WapCmds;

procedure SafeStrPLCopy(Dest: PChar; Source: string; MaxLen: integer);
var
    p: PChar;
begin
    p := PChar(Source);
    StrLCopy(Dest, P, MaxLen);
end;

constructor TWapAppStub.Create(const AppId: string);
begin
    inherited Create;
    FAppId := AppId;
    HandshakeMem := TSharedMemory.Create(FormatSharedName(HandshakeMemName), sizeof(THandshakeMemData), @NoSecurityAttributes);
    HandshakeMemMutex := TWin32Mutex.Create(FormatSharedName(HandshakeMemLockName), @NoSecurityAttributes);
    WapStubRequestWaitingEvent := TWin32Event.Create(FormatSharedName(WapStubRequestWaitingEventName), false, @NoSecurityAttributes);
    HandshakePtr := PHandshakeMemData(HandshakeMem.Buffer);
    HandshakePtr.FormatVersion := HandshakeMemData_FormatVersion;
    HandshakePtr.StubProcessId := GetCurrentProcessId;

    ConverstationsArrayMem := TSharedMemory.Create(FormatSharedName(ConversationsArrayMemName), ConverstationsArraySize, @NoSecurityAttributes);
    ConverstationsArrayPtr := PConversationsArraySharedMem(ConverstationsArrayMem.Buffer);
    FillChar(ConverstationsArrayPtr^, ConverstationsArrayMem.Size, 0);

    ProxyProcessLock := TWin32CriticalSection.Create;
end;

destructor TWapAppStub.Destroy;
var
    i: integer;
begin
    for i := 0 to (ConverstationsArrayLength - 1) do
        FinalizeConversationSlot(i);
    ConverstationsArrayMem.Free;

    HandshakePtr.StubProcessId := 0;
    WapStubRequestWaitingEvent.Free;

    ProxyProcessLock.Free;

    HandshakeMemMutex.Free;
    HandshakeMem.Free;
    
    inherited Destroy;
end;

function TWapAppStub.FormatSharedName(const BaseName: string): string;
begin
    result := format(baseName, [UpperCase(FAppId)]);
end;

{$ifdef ver90}
// Following are from D3's Windows.pas, they are not defined in D2
const
PROCESS_DUP_HANDLE        = $0040;
DUPLICATE_SAME_ACCESS      = $00000002;
{$endif ver90}


// Given a handle in the current process context, create a duplicate handle which
// will be valid in the target process context
function    ExportHandle(SourceHandle: THandle; TargetProcessId: dword): THandle;
var
    TargetProcessHandle: THandle;
    TokenHandle: THandle;
begin
    try
        if OpenThreadToken(GetCurrentThread, TOKEN_ALL_ACCESS, true,  TokenHandle) then
            RevertToSelf
        else
            TokenHandle := 0;
        try
            TargetProcessHandle := OpenProcess(
                PROCESS_DUP_HANDLE,
                false,
                TargetProcessId
            );
            Win32Check(
                TargetProcessHandle <> 0
            );
        finally
            if (TokenHandle <> 0) then begin
                SetThreadToken(nil, TokenHandle);
                CloseHandle(TokenHandle);
            end;
        end;
        try
            Win32Check(
                DuplicateHandle(
                    GetCurrentProcess,
                    SourceHandle,
                    TargetProcessHandle,
                    @result,
                    0,
                    false,
                    DUPLICATE_SAME_ACCESS
                    )
            );
        finally
            CloseHandle(TargetProcessHandle);
        end;
    except
        raise ETracedException.Create('ExportHandle failed');
    end;
end;

function TWapAppStub.AllocateConversationIndex: integer;
begin
    for result := 0 to (ConverstationsArrayLength - 1) do begin
        if (not ConverstationsArrayPtr^[result].InUse) then begin
            ConverstationsArrayPtr^[result].InUse := true;
            exit;
        end;
    end;
    raise EWapAppStub.Create('No unallocated conversation slots available');
end;

procedure TWapAppStub.DeallocateConversationIndex(ConversationIndex: integer);
begin
    ConverstationsArrayPtr^[ConversationIndex].InUse := false;
end;

procedure TWapAppStub.InitializeConversationSlot(Slot: PConversationSlot; WapProcessId: dword);

    procedure ExportHandlesToWap;
    begin
        Slot.Wap_hServerRequestReadyEvent := ExportHandle(Slot.Stub_hServerRequestReadyEvent, WapProcessId);
        try
            Slot.Wap_hStubResponseReadyEvent := ExportHandle(Slot.Stub_hStubResponseReadyEvent, WapProcessId);
        except
            on E: Exception do begin
                // Can't close exported handle, we'll have to do with zero'ing it.
                Slot.Wap_hServerRequestReadyEvent := 0;
                raise ETracedException.Create('TWapAppStub.InitializeConversationSlot.ExportHandlesToWap failed');
            end;
        end;
    end;

begin
    try
        if (Slot.Initialized) then begin
            if (Slot.WapProcessId <> WapProcessId) then begin
                ExportHandlesToWap;
            end;
        end else begin
            Slot.FormatVersion := ConversationSlot_FormatVersion;
            // create the server-request-ready and stub-response-ready events, export their
            // handles to the wap process as well.
            Slot.Stub_hServerRequestReadyEvent := CreateEvent(@NoSecurityAttributes, false, false, nil);
            Win32Check(Slot.Stub_hServerRequestReadyEvent <> 0);
            try
                Slot.Stub_hStubResponseReadyEvent := CreateEvent(@NoSecurityAttributes, false, false, nil);
                Win32Check(Slot.Stub_hStubResponseReadyEvent <> 0);
                try
                    ExportHandlesToWap;
                except
                    CloseHandle(Slot.Stub_hStubResponseReadyEvent);
                    Slot.Stub_hStubResponseReadyEvent := 0;
                    raise;
                end;
            except
                CloseHandle(Slot.Stub_hServerRequestReadyEvent);
                Slot.Stub_hServerRequestReadyEvent := 0;
                raise;
            end;
        end;
        Slot.WapProcessId := WapProcessId;
        Slot.Initialized := true;
    except
        raise ETracedException.Create('TWapAppStub.InitializeConversationSlot failed');
    end;
end;

procedure TWapAppStub.FinalizeConversationSlot(Index: integer);
begin
    try
        with ConverstationsArrayPtr^[Index] do begin
            if (not Initialized) then
                exit;

            Win32Check(CloseHandle(Stub_hServerRequestReadyEvent));
            Win32Check(CloseHandle(Stub_hStubResponseReadyEvent));

            Initialized := false;
        end; // with
    except
        raise ETracedException.Create('TWapAppStub.FinalizeConversationSlot failed');
    end;
end;

function TWapAppStub.GetProxyProcessId: dword;
begin
    if (HandshakePtr.ProxyProcessId = 0) then begin
        StartProxyServer(AppId, HandshakePtr.ProxyProcessId);
    end;

    result := HandshakePtr.ProxyProcessId;
    
    if (result = 0) then
        raise EWapAppRequestServerStubNoServer.Create('The server for "' + FAppId + '" is not running');
end;

function TWapAppStub.ValidateRemoteAdmin(Transaction: THttpTransaction; WapCmd: TWapCmd): boolean;
var
    AppConfig: TAppConfig;
    DefaultAppConfig: TAppConfig;
    Password: string;
    RemoteAddr: string;
begin
    try
        result := true;
        
        if (not (WapCmd in [wcGetAppSessionCount, wcSuspendApp, wcResumeApp, wcTerminateApp, wcGetAppState])) then
            exit;

        WebAppConfig.Lock;
        try
            AppConfig := WebAppConfig.GetAppConfig(AppId);
            DefaultAppConfig := WebAppConfig.GetDefaultAppConfig;
            with Transaction do begin

                if (AppConfig.RemoteAdmin.RequireSecure or DefaultAppConfig.RemoteAdmin.RequireSecure) then begin
                    if (Request.ServerVariables['SERVER_PORT_SECURE'] <> '1') then begin
                        Writeln(Response.TextOut, 'ERROR Remote administration requires a secure connection');
                        result := false;
                        exit;
                    end;
                end;

                if (not (AppConfig.RemoteAdmin.Enable or DefaultAppConfig.RemoteAdmin.Enable)) then begin
                    Writeln(Response.TextOut, 'ERROR Remote administration not enabled');
                    result := false;
                    exit;
                end;

                RemoteAddr := AppConfig.RemoteAdmin.RemoteAddr;
                if (RemoteAddr = '') then
                    RemoteAddr := DefaultAppConfig.RemoteAdmin.RemoteAddr;
                if (RemoteAddr <> '') then
                    if (Request['REMOTE_ADDR'] <> RemoteAddr) then begin
                        Writeln(Response.TextOut, 'ERROR Remote administration not allowed from this host');
                        result := false;
                        exit;
                    end;

                Password := AppConfig.RemoteAdmin.Password;
                if (Password = '') then
                    Password := DefaultAppConfig.RemoteAdmin.Password;
                if (Password <> '') then
                    if (Request['Password'] <> Password) then begin
                        Writeln(Response.TextOut, 'ERROR Incorrect password');
                        result := false;
                        exit;
                    end;
            end; // with
        finally
            WebAppConfig.Unlock;
        end;
    except
        raise ETracedException.Create('TWapAppStub.ValidateRemoteAdmin failed');
    end;
end;

procedure TWapAppStub.ProcessRequest(Transaction: THttpTransaction);
var
    WapCmd: TWapCmd;
    NeedServerInteraction: boolean;
begin
    try
        WapCmd := ParseWapCmd(Transaction.Request.QueryString['WapCmd'].Value);
        if (WapCmd = wcBadWapCmd) then
            raise EWapAppStub.Create('Invalid WapCmd command');
            
        if (not ValidateRemoteAdmin(Transaction, WapCmd)) then
            exit;
        NeedServerInteraction :=
            ((WapCmd = wcNone) and (not FSuspended)) or
            (WapCmd in [wcGetAppSessionCount, wcTerminateApp])
            ;

        if (NeedServerInteraction) then begin
            SendRequestToServer(Transaction, WapCmd);
        end else begin
            case WapCmd of
                wcNone: begin
                    // will get here only if suspended
                    Transaction.Response.Redirect(FSuspendedURL);
                end;
                wcSuspendApp: begin
                    FSuspendedURL := Transaction.Request['SuspendedURL'];
                    if (FSuspendedURL = '') then
                        raise EWapAppStub.Create('SuspendedURL not specified');
                    FSuspended := true;
                    Writeln(Transaction.Response.TextOut, 'OK Suspended');
                end;
                wcResumeApp: begin
                    FSuspended := false;
                    Writeln(Transaction.Response.TextOut, 'OK Resumed');
                end;
                wcGetAppState: begin
                    Writeln(Transaction.Response.TextOut, 'OK ', GetAppState);
                end;
            end;
        end;
    except
        raise ETracedException.Create('TWapAppStub.ProcessRequest failed failed');
    end;
end;

procedure TWapAppStub.SendRequestToServer(Transaction: THttpTransaction; WapCmd: TWapCmd);
var
    ConversationIndex: integer;
    ConversationSlot: PConversationSlot;
    SavedProxyProcessId: dword;
    ServerRequestTimeout: integer;

    procedure WaitForServerRequest;
    var
        WaitResult: dword;
    begin
        try
            WaitResult := WaitForSingleObject(ConversationSlot.Stub_hServerRequestReadyEvent, ServerRequestTimeout);
            if (WaitResult <> WAIT_OBJECT_0) then begin
                if (WaitResult = WAIT_TIMEOUT) then
                    raise EWapAppStub.create('Timed out while waiting for server to make a request')
                else if (WaitResult = WAIT_ABANDONED) then
                    raise EWapAppStub.create('Server abandoned')
                else
                    RaiseLastWin32Error;
            end;
        except
            raise ETracedException.Create('TWapAppStub.ProcessRequest.WaitForServerRequest failed failed');
        end;
    end;

    procedure SignalStubResponseReady;
    begin
        try
            Win32Check(
                SetEvent(ConversationSlot.Stub_hStubResponseReadyEvent)
            );
        except
            raise ETracedException.Create('TWapAppStub.ProcessRequest.SignalStubResponseReady failed');
        end;
    end;

begin
    try
        // We need to do the following outside the handshake-area-lock, so
        // that if we need to start the wap server, it can get access to the
        // Handshake area.
        // The following prevent attempts to prevent us from starting more than
        // one server.
        ProxyProcessLock.Enter;
        try
            SavedProxyProcessId := GetProxyProcessId;
        finally
            ProxyProcessLock.Leave;
        end;

        InterlockedIncrement(HandshakePtr.WaitingRequests);
        // Lock handshake shared mem
        if (HandshakeMemMutex.WaitFor(30 * 1000) <> wrSignaled) then
            ;
        // ********** HANDSHAKE MEM LOCKED ******************
        try
            ConversationIndex := AllocateConversationIndex;

            ConversationSlot := @ConverstationsArrayPtr^[ConversationIndex];
            InitializeConversationSlot(ConversationSlot, SavedProxyProcessId);

            HandshakePtr.ConversationIndex := ConversationIndex;

            ServerRequestTimeout := HandshakePtr.ServerRequestTimeout;

            SetupForInitiateConversation(Transaction, WapCmd, ConversationSlot^);

            // Tell the Wap server a request is waiting to be serviced
            ResetEvent(ConversationSlot.Stub_hServerRequestReadyEvent);
            WapStubRequestWaitingEvent.Signal;

            // Wait for the Wap server to initiate the conversation
            WaitForServerRequest;
            if (ConversationSlot.RequestId <> riInitiateConversion) then
                raise EWapAppStub.create('Internal Error : Server did not initiate conversation properly (' + IntToStr(Ord(ConversationSlot.RequestId)) + ')');

        finally
            // END OF HANDSHAKE
            HandshakeMemMutex.Release;
            // ********** HANDSHAKE MEM UNLOCKED ******************
            InterlockedDecrement(HandshakePtr.WaitingRequests);
        end;

        SignalStubResponseReady;

        // Converse :
        repeat
            WaitForServerRequest;
            try
                if (ConversationSlot.RequestId <> riTerminateConversation) then begin
                    StrCopy(ConversationSlot.ErrorMessage, '');
                    try
                        HandleServerRequest(Transaction.RawHttpRequest, ConversationSlot);
                    except
                        on e: exception do
                            StrLCopy(ConversationSlot.ErrorMessage, pchar(E.Message), SizeOf(ConversationSlot.ErrorMessage));
                    end;
                end; // if
            finally
                // Note: riTerminateConversation does not require stub response
                if (ConversationSlot.RequestId <> riTerminateConversation) then
                    SignalStubResponseReady;
            end;
        until (ConversationSlot.RequestId = riTerminateConversation);

        if (ConversationSlot.ConversationType = ctWapCmd) then
            HandleEndOfWapCmd(Transaction, ConversationSlot);

        DeallocateConversationIndex(ConversationIndex);
    except
        raise ETracedException.Create('TWapAppStub.SendRequestToServer failed failed');
    end;
end;

procedure TWapAppStub.SetupForInitiateConversation(
    Transaction: THttpTransaction;
    WapCmd: TWapCmd;
    var ConversationSlot: TConversationSlot
    );
begin
    try
        if (WapCmd = wcNone) then begin
            ConversationSlot.ConversationType := ctHttpRequest;
            with ConversationSlot, Transaction do begin
                StrCopy(ErrorMessage, '');
                SafeStrPLCopy(PhysicalPath, PChar(RawHttpRequest.GetPhysicalPath), SizeOf(PhysicalPath) - 1);
                SafeStrPLCopy(LogicalPath, PChar(RawHttpRequest.GetLogicalPath), SizeOf(LogicalPath) - 1);
                SafeStrPLCopy(Method, PChar(RawHttpRequest.GetMethod), SizeOf(Method) - 1);
                SafeStrPLCopy(QueryString, PChar(RawHttpRequest.GetQueryString), SizeOf(QueryString) - 1);
            end;
        end else begin
            ConversationSlot.ConversationType := ctWapCmd;
            ConversationSlot.WapCmd := WapCmd;
        end;
    except
        raise ETracedException.Create('TWapAppStub.SetupForInitiateConversation failed');
    end;
end;

procedure TWapAppStub.HandleEndOfWapCmd(Transaction: THttpTransaction; ConversationSlot: PConversationSlot);
begin
    with Transaction do begin
        Write(Response.TextOut, 'OK');
        case ConversationSlot.WapCmd of
            wcGetAppSessionCount: Writeln(Response.TextOut, ' ', ConversationSlot.WapCmd_SessionCount);
            wcTerminateApp: Writeln(Response.TextOut, ' Terminating');
        end;
    end;
end;

function TWapAppStub.GetAppState: string;

    procedure AddState(const S: string);
    begin
        if (result <> '') then
            result := result + '; ';
        result := result + S;
    end;

begin
    result := '';
    if (FSuspended) then
        AddState('Suspended');
    if (HandshakePtr.ProxyProcessId = 0) then
        AddState('Terminated')
    else
        AddState('Running');
end;

procedure TWapAppStub.HandleServerRequest(
    RequestInterface: TAbstractHttpRequestInterface;
    ConversationSlot: PConversationSlot
    );

    procedure DoReadFromClient(var Count: integer; var Buffer; BufSize: integer);
    begin
        Assert(Count <= BufSize, 'Requested read count exceeds buffer size');
        try
            Count := RequestInterface.ReadFromClient(Buffer, Count);
        except
            raise ETracedException.create('TWapStub.HandleServerRequest.DoReadFromClient failed, client may have closed connection');
        end;
    end;

    procedure DoWriteToClient(var Count: integer; var Buffer; BufSize: integer);
    begin
        Assert(Count <= BufSize, 'Requested write count exceeds buffer size');
        try
            Count := RequestInterface.WriteToClient(Buffer, Count);
        except
            raise ETracedException.create('TWapStub.HandleServerRequest.DoWriteToClient failed, client may have closed connection');
        end;
    end;

begin
    try
        with ConversationSlot^ do begin
            Case RequestId of
                riInitiateConversion: raise EWapAppStub.create('Internal error: unexpected riInitiateConversion');
                riTerminateConversation: raise EWapAppStub.create('Internal error: unexpected riTerminateConversation');
                // ConversationType = ctHttpRequest
                riGetHttpHeader: SafeStrPLCopy(HeaderValue, PChar(RequestInterface.GetHttpHeader(HeaderName)), SizeOf(HeaderValue) - 1);
                riGetServerVariable: SafeStrPLCopy(VarValue, PChar(RequestInterface.GetServerVariable(VarName)), SizeOf(VarValue) - 1);
                riGetInputContentType: SafeStrPLCopy(InputContentType, PChar(RequestInterface.GetInputContentType), SizeOf(InputContentType) - 1);
                riGetInputSize: InputSize := RequestInterface.GetInputSize;
                riReadFromClient: DoReadFromClient(ReadCount, ReadBuffer, Sizeof(ReadBuffer));
                riWriteToClient: DoWriteToClient(WriteCount, WriteBuffer, Sizeof(WriteBuffer));
                riMapURLToPath: SafeStrPLCopy(MapURLToPath_Path, PChar(RequestInterface.MapURLToPath(MapURLToPath_Path)), SizeOf(MapURLToPath_Path) - 1);
            end; // case
        end; // with
    except
        raise ETracedException.Create('TWapAppStub.HandleServerRequest failed');
    end;
end;

end.
