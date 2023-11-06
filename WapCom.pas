unit WapCom;

interface

// Add this unit to your USES clause for COM support

implementation

uses ActiveX, WapThNtf, WapWThrd;

type

TWapCom = class
public
    class procedure ThreadNotification(Thread: TWapWorkerThread; Notification: TThreadNotification);
end;

class procedure TWapCom.ThreadNotification(Thread: TWapWorkerThread; Notification: TThreadNotification);
begin
    case Notification of
        tnThreadInitialization: CoInitialize(nil);
        tnThreadFinalization: CoUninitialize;
    end;
end;

initialization
begin
    AddOnThreadNotification(TWapCom.ThreadNotification);
end;

finalization
begin
    try
        RemoveOnThreadNotification(TWapCom.ThreadNotification);
    except
        ;
    end;
end;

end.

