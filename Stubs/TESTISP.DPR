library testisp;

Uses Windows, ISAPI, WapDIntf;

function GetExtensionVersion(var Ver : THSE_VERSION_INFO) : BOOL; stdcall;
begin
    result := IsapiGetExtensionVersion(Ver);
end;

function HttpExtensionProc(var ECB : TEXTENSION_CONTROL_BLOCK) : DWORD; stdcall;
begin
    result := IsapiHttpExtensionProc(ECB);
end;

function TerminateExtension(dwFlags : longint) : BOOL; stdcall;
begin
    result := IsapiTerminateExtension(dwFlags);
end; 

exports
   GetExtensionVersion,
   TerminateExtension,
   HttpExtensionProc
   ;

begin
end.
