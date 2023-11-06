unit WsapiSupport;

interface

uses Classes, SysUtils, Windows,
  DynWSAPI
  ;

function WsapiInit: bool; export; stdcall;
function WsapiProcess(TP: PTCTX): boolean; export; stdcall;

implementation

uses StubUtils,
  WsapiReq
  ;

function WsapiInit: bool; 
begin
    LoadWSAPI;
    result := bind_wsapi(MAJOR_VERSION, MINOR_VERSION, false);
end;

function WsapiProcess(TP: PTCTX): boolean; 
var
    Request: TWsapiHttpRequestImp;
begin
    try
        result := true;
        Request := TWsapiHttpRequestImp.Create(TP);
        try
            try
                DispatchToWapStub(Request);
            except
                on e: exception do begin
                    HandleException(Request, e, 'WsapiProcess');
                    result := false;
                end;
            end;
        finally
            Request.Free;
        end;
    except
        on e: exception do begin
            result := false;
        end;
    end; { we do not want exception to get back to the server! }
end;


end.
