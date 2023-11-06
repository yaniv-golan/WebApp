unit WapWThrd;

interface

uses Classes, SysUtils, Forms, SDS, IPC, AppSSI, HWebApp;

type

TWapWorkerThread = class(TThreadEx)
private
    FSessionCount: integer;
    FQueue: TQueue;
    FQueueNotEmpty: TWin32Event;
    FInternalComponent: TComponent;
    function GetWaitingJobs: integer;
    procedure SessionFreeNotification(Session: TWapSession);
    procedure ExecuteTopJob;
    procedure QueueJob(Job: TObject);
    procedure DoExecute(Thread: TThreadEx);
public
    constructor Create;
    destructor Destroy; override;
    procedure QueueForExecution(App: TWapApp; Session: TWapSession; Transaction: THttpTransaction);
    procedure QueueForRemoval(SessionList: TWapSessionList; Session: TWapSession);
    property WaitingJobs: integer read GetWaitingJobs;
    property SessionCount: integer read FSessionCount;
end;

implementation

uses Windows, WCP, WapThNtf;

{$include wcp.inc}

////////////////////////////////////////////////////////////////////////////
//
// TQueueJob
//
////////////////////////////////////////////////////////////////////////////

type

TQueueJob = class
public
    Thread: TWapWorkerThread;
    constructor Create(AThread: TWapWorkerThread);
    procedure Execute; virtual; abstract;
end;

constructor TQueueJob.Create(AThread: TWapWorkerThread);
begin
    inherited Create;
    Thread := AThread;
end;

////////////////////////////////////////////////////////////////////////////
//
// TRemovalJob
//
////////////////////////////////////////////////////////////////////////////

type

TRemovalJob = class(TQueueJob)
    SessionList: TWapSessionList;
    Session: TWapSession;
    constructor Create(AThread: TWapWorkerThread; ASessionList: TWapSessionList; ASession: TWapSession);
    procedure Execute; override;
end;

constructor TRemovalJob.Create(AThread: TWapWorkerThread; ASessionList: TWapSessionList; ASession: TWapSession);
begin
    inherited Create(AThread);
    SessionList := ASessionlist;
    Session := ASession;
end;

procedure TRemovalJob.Execute;
var
    App: TWapApp;
begin
    {$ifdef cp_on}cp(1, '<TRemovalJob.Execute');{$endif cp_on}
    App := Session.Application;
    try
        SessionList.FreeSession(Session);
    except
        on E: Exception do
            App.HandleException(Session, nil, nil);
    end;
    {$ifdef cp_on}cp(-1, 'TRemovalJob.Execute>');{$endif cp_on}
end;

////////////////////////////////////////////////////////////////////////////
//
// TExecutionJob
//
////////////////////////////////////////////////////////////////////////////

type

TExecutionJob = class(TQueueJob)
    App: TWapApp;
    Session: TWapSession;
    Transaction: THttpTransaction;
    constructor Create(AThread: TWapWorkerThread; AApp: TWapApp; ASession: TWapSession; ATransaction: THttpTransaction);
    procedure Execute; override;
end;

constructor TExecutionJob.Create(AThread: TWapWorkerThread; AApp: TWapApp; ASession: TWapSession; ATransaction: THttpTransaction);
begin
    inherited Create(AThread);
    App := AApp;
    Session := ASession;
    Transaction := ATransaction;
end;

procedure TExecutionJob.Execute;
var
    NewSession: boolean;
begin
    {$ifdef cp_on}cp(1, '<TExecutionJob.Execute');{$endif cp_on}
    NewSession := (Session = nil);
    try
        App.InternalExecute(longint(Thread), Session, Transaction.Request, Transaction.Response);
    except
        on E: Exception do
            App.HandleException(Self, Transaction.Request, Transaction.Response);
    end;
    if NewSession then begin
        if (Session = nil) then
            InterlockedDecrement(Thread.FSessionCount) // Session was not created after all ...
        else
            Session.FreeNotification(Thread.FInternalComponent);
    end;
    Transaction.Free;
    {$ifdef cp_on}cp(-1, 'TExecutionJob.Execute>');{$endif cp_on}
end;


////////////////////////////////////////////////////////////////////////////
//
// TInternalComponent
//
////////////////////////////////////////////////////////////////////////////

type
TInternalComponent = class(TComponent)
private
    FThread: TWapWorkerThread;
protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
end;

procedure TInternalComponent.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited;
    if ((AComponent is TWapSession) and (Operation = opRemove)) then
        FThread.SessionFreeNotification(TWapSession(AComponent));
end;

////////////////////////////////////////////////////////////////////////////
//
// TWapWorkerThread
//
////////////////////////////////////////////////////////////////////////////

constructor TWapWorkerThread.Create;
begin
    inherited Create(true, DoExecute);
    FreeOnTerminate := false;
    FQueue := TQueue.Create(nil);
    FQueueNotEmpty := TWin32Event.Create('', false, nil);
    FInternalComponent := TInternalComponent.Create(nil);
    TInternalComponent(FInternalComponent).FThread := Self;
end;

destructor TWapWorkerThread.Destroy;
begin
    FInternalComponent.Free;
    FQueueNotEmpty.Free;
    FQueue.Free;
    inherited Destroy;
end;

function TWapWorkerThread.GetWaitingJobs: integer;
begin
    FQueue.Lock;
    try
        result := FQueue.Count;
    finally
        FQueue.Unlock;
    end;
end;

procedure TWapWorkerThread.QueueForExecution(App: TWapApp; Session: TWapSession; Transaction: THttpTransaction);
var
    Job: TQueueJob;
begin
    Job := TExecutionJob.Create(Self, App, Session, Transaction);
    InterlockedIncrement(FSessionCount);
    QueueJob(Job);
end;

procedure TWapWorkerThread.QueueForRemoval(SessionList: TWapSessionList; Session: TWapSession);
var
    Job: TQueueJob;
begin
    Job := TRemovalJob.Create(Self, SessionList, Session);
    QueueJob(Job);
end;

procedure TWapWorkerThread.QueueJob(Job: TObject);
begin
    FQueue.Lock;
    try
        FQueue.Queue(Job);
    finally
        FQueue.Unlock;
    end;

    FQueueNotEmpty.Signal;
end;

procedure TWapWorkerThread.ExecuteTopJob;
var
    TopJob: TQueueJob;
begin
    FQueue.Lock;
    try
        TopJob := TQueueJob(FQueue.Top);
    finally
        FQueue.Unlock;
    end;
    try
        try
            TopJob.Execute;
        except
            on E: Exception do begin
                {$ifdef cp_on}CP(0, 'TWapWorkerThread.ExecuteTopJob.Exception = ' + E.Message);{$endif cp_on}
                if assigned(Application.OnException) then
                    Application.OnException(Self, E);
            end;
        end;
    finally
        FQueue.Lock;
        try
            FQueue.Dequeue;
        finally
            FQueue.Unlock;
        end;
    end;
end;

procedure TWapWorkerThread.DoExecute(Thread: TThreadEx);
begin
    {$ifdef cp_on}cp(1, '<TWapWorkerThread.DoExecute');{$endif cp_on}
    NotifyThreadNotification(Self, tnThreadInitialization);
    try
        while (true) do begin
            try
                {$ifdef cp_on}cp(1, '<TWapWorkerThread.DoExecute.WaitForSingleObjectCheckTerminate');{$endif cp_on}
                // wait for the something to be queued, or for terminate event
                if (WaitForSingleObject(FQueueNotEmpty.Handle, INFINITE) <> wrSignaled) then
                    break;

                {$ifdef cp_on}cp(-1, 'TWapWorkerThread.DoExecute.WaitForSingleObjectCheckTerminate>');{$endif cp_on}

                while (WaitingJobs > 0) do begin
                    ExecuteTopJob;
                end;
            except
                on EThreadTerminate do begin
                    {$ifdef cp_on}cp(0, 'TWapWorkerThread.DoExecute.EThreadTerminate');{$endif cp_on}
                    raise;
                end;
                on E : Exception do begin
                    {$ifdef cp_on}cp(0, 'TWapWorkerThread.DoExecute.Exception = ' + E.Message);{$endif cp_on}
                    if assigned(Application.OnException) then
                        Application.OnException(Self, E);
                end;
            end;
        end; // while
    finally
        NotifyThreadNotification(Self, tnThreadFinalization);
    end;
    {$ifdef cp_on}cp(-1, 'TWapWorkerThread.DoExecute>');{$endif cp_on}
end;

procedure TWapWorkerThread.SessionFreeNotification(Session: TWapSession);
begin
    InterlockedDecrement(FSessionCount);
end;

end.
