unit WapSSLst;

interface

uses Classes, SysUtils, SDS, HWebApp, IPC;

type

// - Garbage collected
// - Thread safe

TWapSessionList = class(TComponent)
private
    FSessions: TStringList;
    FLock: TWin32CriticalSection;
    FOldSessionsCleanerThread: TThread;
    function GetCount: integer;
    function GetSessionByIndex(Index: integer): TWapSession;
protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Lock;
    procedure Unlock;

    procedure Add(Session: TWapSession);
    procedure Delete(Session: TWapSession);
    function GetSession(const SessionId: string): TWapSession;

    // Use this instead of Session.Free to free the Session container (Owner)
    // as well
    procedure FreeSession(Session: TWapSession);

    property Count: integer read GetCount;
    property Sessions[Index: integer]: TWapSession read GetSessionByIndex;
end;

implementation

uses Windows, TimeUtil;

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// TOldSessionsCleanerThread
//
// The thread is used internally by the list to dispose of expired sessions.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
type
TOldSessionsCleanerThread = class(TThread)
private
    FSessionList: TWapSessionList;
protected
    procedure   Execute; override;
public
    constructor Create(SessionList: TWapSessionList);
end;

constructor TOldSessionsCleanerThread.Create(SessionList: TWapSessionList);
begin
    inherited Create(true);
    FSessionList := SessionList;
    Priority := tpLower;
    Resume;
end;

procedure   TOldSessionsCleanerThread.Execute;
var
    i: integer;
    Session: TWapSession;
begin
    while (not terminated) do begin
        i := 0;
        while (true) do begin
            Sleep(1);   // give up time slice
            if (Terminated) then
                BREAK;
            FSessionList.Lock;
            try
                // end of Sessions list ?
                if (i >= FSessionList.Count) then
                    BREAK;
                Session := TWapSession(FSessionList.Sessions[i]);
                // Session expired ?
                if ((Session.lastAccess + (Session.TimeOut * MinutesToDateTime)) < now) then
                    FSessionList.FreeSession(Session);
                inc(i);
            finally
                FSessionList.Unlock;
            end;
        end; // while forever
    end; // while not terminated
end;

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//      TWapSessionList
//
////////////////////////////////////////////////////////////////////////////////////////////////////

constructor TWapSessionList.Create(AOwner: TComponent);
begin
    inherited;

    FLock := TWin32CriticalSection.Create;

    FSessions := TStringList.Create;
    // we want to be able to search on it :
    TStringList(FSessions).sorted := true;
    TStringList(FSessions).duplicates := dupError;

    FOldSessionsCleanerThread := TOldSessionsCleanerThread.Create(self);
end;

destructor TWapSessionList.Destroy;
begin
    // First we need to dispose of the cleaner thread, so that it doesn't
    // try to do stuff while we are cleaning up.
    // Locking the Sessions list will prevent a possible dead-Lock
    if (FOldSessionsCleanerThread <> nil) then begin
        Lock;
        try
            // ask the thread to terminate
            FOldSessionsCleanerThread.terminate;
            // wait for the thread to terminate
            FOldSessionsCleanerThread.waitFor;
            FOldSessionsCleanerThread.Free;
            FOldSessionsCleanerThread := nil;
        finally
            Unlock;
        end;
    end;

    Lock;
    try
        while (Count > 0) do
            FreeSession(Sessions[0]);
        FSessions.Free;
        FSessions := nil;
    finally
        Unlock;
    end;

    FLock.Free;

    inherited Destroy;
end;

procedure   TWapSessionList.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if ((AComponent is TWapSession) and (Operation = opRemove)) then
        Delete(TWapSession(AComponent));
end;

procedure TWapSessionList.Lock;
begin
    FLock.Enter;
end;

procedure TWapSessionList.Unlock;
begin
    FLock.Leave;
end;

procedure TWapSessionList.Add(Session: TWapSession);
begin
    Session.FreeNotification(self);
    Lock;
    try
        FSessions.AddObject(Session.SessionId, Session);
    finally
        Unlock;
    end;
end;

procedure TWapSessionList.Delete(Session: TWapSession);
var
    i: integer;
begin
    Lock;
    try
        i := FSessions.indexOf(Session.SessionId);
        if (i <> -1) then
            FSessions.Delete(i);
    finally
        Unlock;
    end;
end;

function TWapSessionList.GetCount: integer;
begin
    Lock;
    try
        result := FSessions.Count;
    finally
        Unlock;
    end;
end;

function TWapSessionList.GetSession(const SessionId: string): TWapSession;
var
    i: integer;
begin
    Lock;
    try
        i := FSessions.indexOf(SessionId);
        if (i = -1) then
            result := nil
        else
            result := TWapSession(FSessions.objects[i]);
    finally
        UnLock;
    end;
end;

function TWapSessionList.GetSessionByIndex(Index: integer): TWapSession;
begin
    Lock;
    try
        result := TWapSession(FSessions.objects[Index]);
    finally
        Unlock;
    end;
end;

procedure TWapSessionList.FreeSession(Session: TWapSession);
begin
    // a hack : to support the common case where the TWapSession is placed
    // on a TDataModule or other container:
    // If the Session has an owner, we will free the owner instead of
    // freeing the Session component directly.
    if (Session.Owner <> nil) then
        Session.Owner.Free
    else
        Session.Free;
end;

end.
