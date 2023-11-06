unit trc;

interface

procedure   trace(const s: string);

implementation

uses classes, sysUtils, messages, windows;

procedure   trace(const s: string);
var
    h: HWnd;
    cds: TCopyDataStruct;
    t: string;
begin
    exit;
    h := FindWindow(nil, 'Debugger');
    if (h <> 0) then begin
        cds.dwData := 0;
        t := IntToStr(GetCurrentThreadId) + ' ' + s;
        cds.cbData := length(t) + 1;
        cds.lpData := pchar(t);
        SendMessage(h, wm_copyData, 0, longint(@cds));
    end;
end;

end.
