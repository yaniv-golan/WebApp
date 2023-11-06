unit CgiSupport;

interface

uses  Classes, SysUtils, Windows
    ,CgiReq
    ;

procedure CgiRun; 

implementation

uses StubUtils;

procedure CgiRun; 
var
    Request: TCgiHttpRequestImp;
begin
    try
        Request := TCgiHttpRequestImp.Create(GetStdHandle(STD_INPUT_HANDLE), GetStdHandle(STD_OUTPUT_HANDLE), false);
        try
            try
                DispatchToWapStub(Request);
            except
                on e: exception do begin
                    HandleException(Request, e, 'CgiRun');
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
