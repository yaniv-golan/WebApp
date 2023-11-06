library HAWebApp;

Uses
  SysUtils,
  StubUtils,
  CIsapiFilter,
  IsapiSupport in 'IsapiSupport.pas',
  CgiSupport in 'CgiSupport.pas',
  WinCGISupport in 'WinCGISupport.pas',
  WsapiSupport in 'WsapiSupport.pas',
  NsapiSupport2 in 'NsapiSupport2.pas',
  AppSpawner in 'AppSpawner.pas',
  CWebAppIsapiFilter in 'CWebAppIsapiFilter.pas';

{$R *.RES}

exports
    WapCheckVersion,

    IsapiGetExtensionVersion,
    IsapiTerminateExtension,
    IsapiHttpExtensionProc,

    GetFilterVersion,
    HttpFilterProc,

    CgiRun,

    WinCgiRun,

    WsapiInit,
    WsapiProcess,

    NsapiService,
    NsapiPathCheck,
    NsapiLog,
    NsapiInit,
    NsapiNameTrans
    ;

begin
end.
