unit WIPCShrd;

interface

uses Windows
    ;

const
    HandshakeMemName = 'Wap_HandshakeMem_%s';
    HandshakeMemLockName = 'Wap_HandshakeMemLock_%s';
    WapStubRequestWaitingEventName = 'WapStubRequestWaiting_%s';
    ConversationsArrayMemName = 'Wap_ConversationsArrayMem_%s';
    AppInitializedEventName = 'Wap_AppInitialized_%s';

    SharedCookieName = 'HyperAct';

    HandshakeMemData_FormatVersion = 2;
    ConversationSlot_FormatVersion = 2;

type

PHandshakeMemData = ^THandshakeMemData;
THandshakeMemData = packed record
    // Initialized by the stub, checked by the wap server
    FormatVersion: integer;
    StubProcessId: dword;
    // Initialized by the wap server process on startup, set to zero on shutdown of wap process
    ProxyProcessId: dword;
    // Specified by the wap server process on startup. Indicates the number of MILLISECONDS that
    // the stub should wait for the server to make a request during conversation before timing out.
    ServerRequestTimeout: integer;
    // created by the stub, for use by the wap server. Should be closed by the
    // server when done :
    ConversationIndex: integer;
    // maintained by the stub - count of requests waiting to be handled
    WaitingRequests: integer;
end;

TRequestId = (
    riDummy,    // mainly to catch errors..
    riInitiateConversion,
    riTerminateConversation,
    // ConversationType = ctHttpRequest
    riGetHttpHeader,
    riGetServerVariable,
    riGetInputContentType,
    riGetInputSize,
    riReadFromClient,
    riWriteToClient,
    riMapURLToPath
    );

const ReadWriteBufferMaxLen = 2048;
const ErrorMessageMaxLen = 512;

type

TWapCmd = (
    wcNone,
    wcTest,
    wcRefreshConfig,
    wcMapURL,
    wcGetAppSessionCount,
    wcSuspendApp,
    wcResumeApp,
    wcTerminateApp,
    wcGetAppState,
    wcBadWapCmd
);

TConversationType = (ctHttpRequest, ctWapCmd);

PConversationSlot = ^TConversationSlot;
TConversationSlot = packed record
    // Initialized by the stub, checked by the wap server
    FormatVersion: integer;
    // Used by stub - BEGIN
    Initialized: boolean;
    InUse: boolean;
    WapProcessId: dword;

    Stub_hServerRequestReadyEvent: THandle;
    Stub_hStubResponseReadyEvent: THandle;
    // Used by stub - END

    Wap_hServerRequestReadyEvent: THandle;
    Wap_hStubResponseReadyEvent: THandle;

    ConversationType: TConversationType;
    WapCmd: TWapCmd; // only for ConversationType = ctWapCmd
    WapCmd_SessionCount: integer; // used by wcReportSessionCount

    { If ErrorMessage <> '', raise exception }
    ErrorMessage: array[0 .. ErrorMessageMaxLen] of char;

    case RequestId: TRequestId of
        riInitiateConversion: (
            // should be copied and saved away at initialization
            PhysicalPath: array[0 .. MAX_PATH] of char;
            LogicalPath: array[0 .. 1200] of char;
            Method: array[0 .. 30] of char;
            QueryString: array[0 .. 1024] of char;
        );
        riGetHttpHeader: (
            HeaderName: array[0 .. 200] of char;
            HeaderValue: array[0 .. 1024] of char
        );
        riGetServerVariable: (
            VarName: array[0 .. 200] of char;
            VarValue: array[0 .. 1024] of char;
        );
        riGetInputContentType: (
            InputContentType: array[0 .. 50] of char;
        );
        riGetInputSize: (
            InputSize: integer;
        );
        riReadFromClient: (
            ReadCount: integer; // in-out
            ReadBuffer: array[0..1023] of char;
        );
        riWriteToClient : (
            WriteCount: integer; // in-out
            WriteBuffer: array[0..1023] of char;
        );
        riMapURLToPath : (
            MapURLToPath_Path: array [0..1023] of char; // in-out
        );
end;

const ConversationsArrayMaxSize = 65000 div sizeof(TConversationSlot);

type
TConversationsArraySharedMem = array [0 .. (ConversationsArrayMaxSize - 1)] of TConversationSlot;
PConversationsArraySharedMem = ^TConversationsArraySharedMem;

const ConverstationsArrayLength = 200;
const ConverstationsArraySize = ConverstationsArrayLength * SizeOf(TConversationSlot);

function FormatSharedName(const BaseName: string; const AppId: string): string;

implementation

uses SysUtils;

function FormatSharedName(const BaseName: string; const AppId: string): string;
begin
    result := Format(BaseName, [UpperCase(AppId)]);
end;

end.
