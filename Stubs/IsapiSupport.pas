unit IsapiSupport;

interface

uses Classes, SysUtils, Windows
    ,ISAPI2
    ;

function IsapiGetExtensionVersion(var Ver : THSE_VERSION_INFO) : BOOL; export; stdcall;
function IsapiHttpExtensionProc(var ECB : TEXTENSION_CONTROL_BLOCK) : DWORD; export; stdcall;
function IsapiTerminateExtension(dwFlags : longint) : BOOL; export; stdcall;

implementation

uses IsapiReq, StubUtils;

procedure SafeStrPLCopy(Dest: PChar; Source: string; MaxLen: integer);
var
    p: PChar;
begin
    p := PChar(Source);
    StrLCopy(Dest, P, MaxLen);
end;

function IsapiGetExtensionVersion(var Ver : THSE_VERSION_INFO) : BOOL;
begin
    ver.dwExtensionVersion := $00010000;  // 1.0 support
    ver.lpszExtensionDesc := 'HyperAct WebApp ISAPI Agent';
    result := true;
end;

function IsapiHttpExtensionProc(var ECB : TEXTENSION_CONTROL_BLOCK) : DWORD;
var
    Request: TIsapiHttpRequestImp;
begin
    try
        result := HSE_STATUS_SUCCESS;
        Request := TIsapiHttpRequestImp.Create(@ECB);
        try
            try
                DispatchToWapStub(Request);
            except
                on e: exception do begin
                    HandleException(Request, e, 'IsapiHttpExtensionProc');
                    result := HSE_STATUS_ERROR;
                    ECB.dwHttpStatusCode := 500;    // internal server error
                    SafeStrPLCopy(ECB.lpszLogData, 'WebApp Exception ' + e.className + ' : ' + e.message, HSE_LOG_BUFFER_LEN);
                end;
            end;
        finally
            Request.Free;
        end;
    except
        on e: exception do begin
            result := HSE_STATUS_ERROR;
            ecb.dwHttpStatusCode := 500;    // internal server error
            SafeStrPLCopy(ecb.lpszLogData, 'WebApp Exception ' + e.className + ' : ' + e.message, HSE_LOG_BUFFER_LEN);
        end;
    end; { we do not want exception to get back to the server! }
end;

function IsapiTerminateExtension(dwFlags : longint) : BOOL;
begin
    result := true;
end;

end.
