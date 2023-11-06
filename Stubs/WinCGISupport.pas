unit WinCGISupport;

interface

uses Classes, SysUtils, Windows
    ,WCgiReq
;

procedure WinCGIRun(CgiDataFilename: pchar); export; stdcall; 

implementation

uses StubUtils;

procedure WinCGIRun(CgiDataFilename: pchar); 
var
    Request: TWinCgiHttpRequestImp;
begin
    try
        Request := TWinCgiHttpRequestImp.Create(CgiDataFilename);
        try
            try
                DispatchToWapStub(Request);
            except
                on e: exception do begin
                    HandleException(Request, e, 'WinCGIRun');
                end;
            end;
        finally
            Request.Free;
        end;
    except
        on e: exception do begin
        end;
    end; { we do not want exception to get back to the server! }
end;


end.
