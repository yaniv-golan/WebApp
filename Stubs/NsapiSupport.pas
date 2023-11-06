unit NsapiSupport;

interface

uses Classes, SysUtils, Windows,
  DynNSAPI
  ;

function NsapiExecute(pb: PPblock; sn: PSession; rq: Prequest): Integer; export; stdcall;

implementation

uses StubUtils,
  NSAPIReq
  ;


function NsapiExecute(pb: PPblock; sn: PSession; rq: Prequest): Integer; 
var
    Request: TNsapiHttpRequestImp;
begin
    result := REQ_PROCEED;
    try
        Request := TNsapiHttpRequestImp.Create(pb, sn, rq);
        try
            try
                DispatchToWapStub(Request);
            except
                on e: exception do begin
                    HandleException(Request, e);
                    protocol_status(sn, rq, PROTOCOL_SERVER_ERROR, 'Internal Server Error');
                end;
            end;
        finally
            Request.Free;
        end;
    except
        on e: exception do begin
            log('Severe Exception, unable to report error to client');
            protocol_status(sn, rq, PROTOCOL_SERVER_ERROR, 'Internal Server Error');
        end;
    end; { we do not want exception to get back to the server! }
end;


end.
