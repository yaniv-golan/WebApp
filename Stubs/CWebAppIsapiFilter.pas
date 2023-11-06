unit CWebAppIsapiFilter;

interface

implementation

uses Classes, SysUtils, CIsapiFilter, CWebAppConfig, StubUtils, Windows;

type

TWebAppFilterContext = class(TIsapiFilterContext)
protected
    procedure NotifyPreProcHeaders(PreProcHeaders: TPreProcHeaders; var Result : dword); override;
end;

procedure TWebAppFilterContext.NotifyPreProcHeaders(PreProcHeaders: TPreProcHeaders; var Result : dword);
var
    Url: string;
    AppId: string;
    AppConfig: TAppConfig;
    StubLogicalPath: string;
begin
    Url := PreProcHeaders.GetHeader('url');
    AppId := AppIdFromMapping(Url);
    if (AppId = '') then
        exit;
    WebAppConfig.Lock;
    try
        AppConfig := WebAppConfig.GetAppConfig(AppId);
        if (AppConfig.URLMap.StubLogicalPath = '') then begin
            AppConfig := WebAppConfig.GetDefaultAppConfig;
        end;
        StubLogicalPath := AppConfig.URLMap.StubLogicalPath;
        if (StubLogicalPath <> '') then begin
            PreProcHeaders.SetHeader('url', StubLogicalPath + Url);
        end;
    finally
        WebAppConfig.Unlock;
    end;
end;


initialization
begin
    IsapiFilter.ContextClass := TWebAppFilterContext;
    IsapiFilter.Description := 'WebApp ISAPI Filter';
    IsapiFilter.NotificationFlags := [sfNotifyPreProcHeaders];
end;

end.
