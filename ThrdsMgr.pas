unit ThrdsMgr;

interface

uses Classses, SysUtils, D3SysUtl, SDS, IPC;

type

TWapScheduler = class(TComponent)
private
    FThreads: TObjectList;
    FInitialThreadCount: integer;
    FActiveThreadCount: integer;
    FTerminateThreadsEvent: TWin32Event;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Start;
    function Stop(Timeout: dword): boolean;
    procedure Schedule(Session: TWapSession; Request: THttpRequest; Response: THttpResponse);
    property InitialThreadCount: integer read FInitialThreadCount write FInitialThreadCount;
    property ActiveThreadCount: integer read GetActiveThreadCount;
end;

implementation

////////////////////////////////////////////////////////////////////////
//
// TSchedulingInfo
//
////////////////////////////////////////////////////////////////////////

type

TSchedulingInfo = class
public
    Session: TWapSession;
    Request: THttpRequest;
    Response: THttpResponse;
    constructor Create(ASession: TWapSession; ARequest: THttpRequest; AResponse: THttpResponse);
end;

constructor TSchedulingInfo.Create(ASession: TWapSession; ARequest: THttpRequest; AResponse: THttpResponse);
begin
    inherited Create;
    Session := ASession;
    Request := ARequest;
    Response := AResponse;
end;


////////////////////////////////////////////////////////////////////////
//
// TWapScheduler
//
////////////////////////////////////////////////////////////////////////

constructor TWapScheduler.Create(AOwner: TComponent);
begin
    inherited;
    FTerminateThreadsEvent := TWin32Event.Create('', true, nil);
end;

destructor TWapScheduler.Destroy;
begin
    FTerminateThreadsEvent.Free;
    inherited;
end;

procedure TWapScheduler.Schedule(Session: TWapSession; Request: THttpRequest; Response: THttpResponse);
begin
    if (Session = nil) then begin
        // SelectedThread := least-busy thread
    end else begin
        if (Session.ThreadToken = 0) then begin
            // SelectedThread := least-busy thread
            // Session.ThreadToken := SelectedThread
        end;
        SelectedThread.Queue(TSchedulingInfo.Create(Session, Request, Response));
    end;
end;

end.
