unit CIpcConversation;

interface

uses Classes, SysUtils, WIPCShrd;

type

TIpcConversation = class
private
    FSlot: PConversationSlot;
protected
    procedure InitializeSlot; virtual;
    procedure HandleRequest; virtual;
public
    property Slot: PConversationSlot read FSlot;
end;

implementation

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
                    raise exception.create('Timed out while waiting for server to make a request')
                else if (WaitResult = WAIT_ABANDONED) then
                    raise exception.create('Server abandoned')
                else
                    RaiseLastWin32Error;
            end;
        except
            on E: Exception do
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
            on E: Exception do
                raise ETracedException.Create('TWapAppStub.ProcessRequest.SignalStubResponseReady failed');
        end;
    end;

begin
    // This is outside the lock, so that if we need to start the wap server,
    // it can get access to the Handshake area. Yes, it introduces the chance
    // that 2 wap servers will access the same handshake area at same time,
    // or that the wap server will start while we're starting our own copy...

    try
        SavedProxyProcessId := GetProxyProcessId;


        InterlockedIncrement(HandshakePtr.WaitingRequests);
        // Lock handshake shared mem
        HandshakeMemMutex.WaitFor(INFINITE);
        // ********** HANDSHAKE MEM LOCKED ******************
        try
            ConversationIndex := AllocateConversationIndex;

            ConversationSlot := @ConverstationsArrayPtr^[ConversationIndex];
            InitializeConversationSlot(ConversationSlot, SavedProxyProcessId);

            HandshakePtr.ConversationIndex := ConversationIndex;

            ServerRequestTimeout := HandshakePtr.ServerRequestTimeout;

            SetupForInitiateConversation(RequestInterface, ConversationSlot^);

            // Tell the Wap server a request is waiting to be serviced
            ResetEvent(ConversationSlot.Stub_hServerRequestReadyEvent);
            WapStubRequestWaitingEvent.Signal;

            // Wait for the Wap server to initiate the conversation
            WaitForServerRequest;
            if (ConversationSlot.RequestId <> riInitiateConversion) then
                raise exception.create('Internal Error : Server did not initiate conversation properly (' + IntToStr(Ord(ConversationSlot.RequestId)) + ')');

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
                        HandleServerRequest(RequestInterface, ConversationSlot, SavedProxyProcessId);
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

        DeallocateConversationIndex(ConversationIndex);
    except
        on E: Exception do
            raise ETracedException.Create('TWapAppStub.ProcessRequest failed failed');
    end;
end;

end.
