unit WapThNtf;

interface

uses Classes, SysUtils, MthdsLst, IPC, WapWThrd;

type

TThreadNotification = (tnThreadInitialization, tnThreadFinalization);

TThreadNotificationEvent = procedure(Thread: TWapWorkerThread; Notification: TThreadNotification) of object;

procedure AddOnThreadNotification(Handler: TThreadNotificationEvent);
procedure RemoveOnThreadNotification(Handler: TThreadNotificationEvent);

// For internal use only
procedure NotifyThreadNotification(Thread: TWapWorkerThread; Notification: TThreadNotification);

implementation

////////////////////////////////////////////////////////////////////////////
//
// TThreadNotificationEventList
//
////////////////////////////////////////////////////////////////////////////

type

TThreadNotificationEventList = class(TNotificationList)
protected
    FLock: TWin32CriticalSection;
    procedure   DispatchNotification(const Method: TMethod; Params: TObject; var Continue: boolean); override;
public
    constructor Create;
    destructor Destroy; override;
    procedure Notify(Thread: TWapWorkerThread; Notification: TThreadNotification);
    procedure Lock;
    procedure Unlock;
    procedure   Add(Event: TThreadNotificationEvent);
    procedure   Delete(Event: TThreadNotificationEvent);
end;

TThreadNotificationEventListParams = class
public
    Thread: TWapWorkerThread;
    Notification: TThreadNotification
end;

constructor TThreadNotificationEventList.Create;
begin
    inherited;
    FLock := TWin32CriticalSection.Create;
end;

destructor TThreadNotificationEventList.Destroy;
begin
    FLock.Free;
    inherited;
end;

procedure TThreadNotificationEventList.Notify(Thread: TWapWorkerThread; Notification: TThreadNotification);
var
    p: TThreadNotificationEventListParams;
begin
    p := TThreadNotificationEventListParams.Create;
    p.Thread := Thread;
    p.Notification := Notification;
    DoNotify(p);
end;

procedure TThreadNotificationEventList.Lock;
begin
    FLock.Enter;
end;

procedure TThreadNotificationEventList.Unlock;
begin
    FLock.Leave;
end;

procedure   TThreadNotificationEventList.DispatchNotification(const Method: TMethod; Params: TObject; var Continue: boolean);
var
    Handler: TMethod;
begin
    Handler := Method;
    with TThreadNotificationEventListParams(Params) do
        TThreadNotificationEvent(Handler)(Thread, Notification);
end;

procedure   TThreadNotificationEventList.Add(Event: TThreadNotificationEvent);
var
    m: TMethod;
begin
    m := TMethod(event);
    DoAdd(m);
end;

procedure   TThreadNotificationEventList.Delete(Event: TThreadNotificationEvent);
var
    m: TMethod;
begin
    m := TMethod(event);
    DoRemove(m);
end;

var ThreadNotificationEventList: TThreadNotificationEventList = nil;

procedure AddOnThreadNotification(Handler: TThreadNotificationEvent);
begin
    ThreadNotificationEventList.Lock;
    try
        ThreadNotificationEventList.Add(Handler);
    finally
        ThreadNotificationEventList.Unlock;
    end;
end;

procedure RemoveOnThreadNotification(Handler: TThreadNotificationEvent);
begin
    if (ThreadNotificationEventList = nil) then
        exit;
    ThreadNotificationEventList.Lock;
    try
        ThreadNotificationEventList.Delete(Handler);
    finally
        ThreadNotificationEventList.Unlock;
    end;
end;

procedure NotifyThreadNotification(Thread: TWapWorkerThread; Notification: TThreadNotification);
begin
    ThreadNotificationEventList.Lock;
    try
        ThreadNotificationEventList.Notify(Thread, Notification);
    finally
        ThreadNotificationEventList.Unlock;
    end;
end;

initialization
begin
    ThreadNotificationEventList := TThreadNotificationEventList.Create;
end;

finalization
begin
    ThreadNotificationEventList.Free;
    ThreadNotificationEventList := nil;
end;

end.
