unit DummySupport;

interface

uses Classes, SysUtils, Windows
    ,ISAPI
    ;

function IsapiGetExtensionVersion(var Ver : THSE_VERSION_INFO) : BOOL; export; stdcall;
function IsapiHttpExtensionProc(var ECB : TEXTENSION_CONTROL_BLOCK) : DWORD; export; stdcall;
function IsapiTerminateExtension(dwFlags : longint) : BOOL; export; stdcall;

implementation

uses DummyReq, StubUtils;

function IsapiGetExtensionVersion(var Ver : THSE_VERSION_INFO) : BOOL; 
begin
    ver.dwExtensionVersion := $00010000;  // 1.0 support
    ver.lpszExtensionDesc := 'HyperAct WebApp ISAPI Agent';
    result := True;
end;

function IsapiHttpExtensionProc(var ECB : TEXTENSION_CONTROL_BLOCK) : DWORD; 
var
    Request: TIsapiHttpRequestImp;
begin
    try
        log('IsapiHttpExtensionProc: ' + strPas(ecb.lpszQueryString) + ' ' + strPas(ecb.lpszPathInfo));
        result := HSE_STATUS_SUCCESS;
        Request := TIsapiHttpRequestImp.Create(@ECB);
        try
            try
                DispatchToWapStub(Request);
            except
                on e: exception do begin
                    HandleException(Request, e);
                    result := HSE_STATUS_ERROR;
                    ECB.dwHttpStatusCode := 500;    // internal server error
                    StrPLCopy(ECB.lpszLogData, 'WebApp Exception ' + e.className + ' : ' + e.message, SizeOf(ECB.lpszLogData) - 1);
                end;
            end;
        finally
            Request.Free;
        end;
    except
        on e: exception do begin
            log('Severe Exception, unable to report error to client');
            result := HSE_STATUS_ERROR;
            ecb.dwHttpStatusCode := 500;    // internal server error
            strPCopy(ecb.lpszLogData, 'WebApp Exception ' + e.className + ' : ' + e.message);
        end;
    end; { we do not want exception to get back to the server! }
end;

function IsapiTerminateExtension(dwFlags : longint) : BOOL; 
begin
    result := true;
end;

end.
