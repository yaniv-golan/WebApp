unit WapDIntf;

interface

uses windows, isapi, DynNSAPI
    ;

const
    WapProtocolMajorVer = 1;
    WapProtocolMinorVer = 0;

// WebApp internal, call with Major = WapProtocolMajorVer, Minor = WapProtocolMinorVer
function WapCheckVersion(Major, Minor: integer): bool; stdcall;

// ISAPI
function IsapiGetExtensionVersion(var Ver : THSE_VERSION_INFO) : BOOL; stdcall;
function IsapiHttpExtensionProc(var ECB : TEXTENSION_CONTROL_BLOCK) : DWORD; stdcall;
function IsapiTerminateExtension(dwFlags : longint) : BOOL; stdcall;

// CGI
procedure CgiRun; stdcall;

// Win-CGI
procedure WinCGIRun(CgiDataFilename: pchar); stdcall;

// WSAPI
function WsapiInit: bool; stdcall;
// TP's type is actually PTCTX, but we won't to avoid having to use WSAPI here
function WsapiProcess(TP: pointer): boolean; stdcall;

// NSAPI
function NsapiInit(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl;
function NsapiService(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl;
function NsapiPathCheck(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl;
function NsapiLog(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl;
function NsapiNameTrans(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; 

implementation

const
    WebAppDll = 'HAWEBAPP.DLL';

function WapCheckVersion; external WebAppDll;

function IsapiGetExtensionVersion; external WebAppDll;
function IsapiHttpExtensionProc; external WebAppDll;
function IsapiTerminateExtension; external WebAppDll;

procedure CgiRun; external WebAppDll;

procedure WinCGIRun; external WebAppDll;

function WsapiInit; external WebAppDll;
function WsapiProcess; external WebAppDll;

function NsapiInit; external WebAppDll;
function NsapiService; external WebAppDll;
function NsapiPathCheck; external WebAppDll;
function NsapiLog; external WebAppDll;
function NsapiNameTrans; external WebAppDll;

end.
