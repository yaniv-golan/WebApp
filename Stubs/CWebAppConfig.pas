unit CWebAppConfig;

interface

uses Classes, SysUtils, IPC, Registry, SDS;

type

TAppConfig = class
public
    URLMap: record
        StubLogicalPath: string;
    end;
    AutoStart: record
        Enable: boolean;
        CommandLine: string;
        RunAsUser: string;
        RunAsPassword: string;
    end;
    RemoteAdmin: record
        Enable: boolean;
        Password: string;
        RemoteAddr: string;
        RequireSecure: boolean;
    end;
end;

TWebAppConfig = class
private
    FLock: TWin32CriticalSection;
    Reg: TRegistry;

    FErrorFile: string;
    FDefaultAppId: string;
    FMapping: TStringList;
    FAppConfigs: TExStringList;
    FAppIds: TStringList;

    constructor Create;
    destructor Destroy; override;
    procedure ReadAppConfigs;
    procedure ReadMapping;
public
    procedure Lock;
    procedure Unlock;

    procedure Refresh;

    function GetErrorFile: string;
    function GetDefaultAppId: string;
    procedure GetMapping(Mapping: TStrings);
    function GetAppConfig(const AppId: string): TAppConfig;
    procedure GetAppIds(AppIds: TStrings);
    function GetDefaultAppConfig: TAppConfig;
end;

const
    DefaultAppId = '.Default';
    
var
    WebAppConfig: TWebAppConfig = nil;

implementation

uses Windows;

const BaseKey = 'Software\HyperAct\WebApp';

constructor TWebAppConfig.Create;
begin
    inherited;
    FLock := TWin32CriticalSection.Create;
    Reg := TRegistry.Create;
    Reg.RootKey := HKEY_LOCAL_MACHINE;

    FMapping := TStringList.Create;
    FAppConfigs := TExStringList.Create;
    FAppIds := TStringList.Create;

    Refresh;
end;

destructor TWebAppConfig.Destroy;
begin
    FMapping.Free;
    FAppConfigs.Free;
    FAppIds.Free;
    Reg.Free;
    FLock.Free;
    inherited;
end;

procedure TWebAppConfig.Lock;
begin
    FLock.Enter;
end;

procedure TWebAppConfig.Unlock;
begin
    FLock.Leave;
end;

procedure TWebAppConfig.ReadAppConfigs;
var
    i: integer;
    AppConfig: TAppConfig;
begin
    FAppConfigs.Clear;
    if Reg.OpenKey(BaseKey + '\Applications', false) then begin
        try
            Reg.GetKeyNames(FAppConfigs);
        finally
            Reg.CloseKey;
        end;
    end;

    for i := 0 to (FAppConfigs.Count - 1) do begin
        AppConfig := GetAppConfig(FAppConfigs[i]);
        try
            if Reg.OpenKey(Format('%s\Applications\%s\URLMap', [BaseKey, FAppConfigs[i]]), false) then begin
                try
                    AppConfig.URLMap.StubLogicalPath := Reg.ReadString('StubLogicalPath');
                finally
                    Reg.CloseKey;
                end;
            end;
            if Reg.OpenKey(Format('%s\Applications\%s\AutoStart', [BaseKey, FAppConfigs[i]]), false) then begin
                try
                    AppConfig.AutoStart.Enable := (Reg.ReadString('Enable') = '1');
                    AppConfig.AutoStart.CommandLine := Reg.ReadString('CommandLine');
                    AppConfig.AutoStart.RunAsUser := Reg.ReadString('RunAsUser');
                    AppConfig.AutoStart.RunAsPassword := Reg.ReadString('RunAsPassword');
                finally
                    Reg.CloseKey;
                end;
            end;
            if Reg.OpenKey(Format('%s\Applications\%s\RemoteAdmin', [BaseKey, FAppConfigs[i]]), false) then begin
                try
                    AppConfig.RemoteAdmin.Enable := (Reg.ReadString('Enable') = '1');
                    AppConfig.RemoteAdmin.Password := Reg.ReadString('Password');
                    AppConfig.RemoteAdmin.RemoteAddr := Reg.ReadString('RemoteAddr');
                    AppConfig.RemoteAdmin.RequireSecure := (Reg.ReadString('RequireSecure') = '1');
                finally
                    Reg.CloseKey;
                end;
            end;
        except
            AppConfig.Free;
            raise;
        end;
        FAppConfigs.Objects[i] := AppConfig;
    end;
end;

procedure TWebAppConfig.ReadMapping;
var
    i: integer;
begin
    if Reg.OpenKey(Format('%s\Mapping', [BaseKey]), false) then begin
        try
            Reg.GetValueNames(FMapping);
            for i := 0 to (FMapping.Count - 1) do
                FMapping[i] := FMapping[i] + '=' + Reg.ReadString(FMapping[i]);
        finally
            Reg.CloseKey;
        end;
    end;
end;

procedure TWebAppConfig.Refresh;
begin
    Lock;
    try
        FErrorFile := '';
        FDefaultAppId := '';
        FMapping.Clear;
        FAppConfigs.Clear;
        FAppIds.Clear;

        if Reg.OpenKey(BaseKey, false) then begin
            try
                FErrorFile := Reg.ReadString('ErrorFile');
                FDefaultAppId := Reg.ReadString('DefaultAppId');
            finally
                Reg.CloseKey;
            end;
        end else begin
            FErrorFile := '';
            FDefaultAppId := '';
        end;
        ReadMapping;
        ReadAppConfigs;

        if Reg.OpenKey(BaseKey + '\Applications', false) then begin
            try
                Reg.GetKeyNames(FAppIds);
            finally
                Reg.CloseKey;
            end;
        end;


    finally
        Unlock;
    end;
end;

function TWebAppConfig.GetErrorFile: string;
begin
    Lock;
    try
        result := FErrorFile;
    finally
        Unlock;
    end;
end;

function TWebAppConfig.GetDefaultAppId: string;
begin
    Lock;
    try
        result := FDefaultAppId;
    finally
        Unlock;
    end;
end;

procedure TWebAppConfig.GetMapping(Mapping: TStrings);
begin
    Lock;
    try
        Mapping.Assign(FMapping);
    finally
        Unlock;
    end;
end;

procedure TWebAppConfig.GetAppIds(AppIds: TStrings);
begin
    Lock;
    try
        AppIds.Assign(FAppIds);
    finally
        Unlock;
    end;
end;


function TWebAppConfig.GetAppConfig(const AppId: string): TAppConfig;
var
    i: integer;
begin
    Lock;
    try
        i := FAppConfigs.IndexOf(UpperCase(AppId));
        if (i = -1) then begin
            i := FAppConfigs.Add(UpperCase(AppId));
        end;
        if (FAppConfigs.Objects[i] = nil) then
            FAppConfigs.Objects[i] := TAppConfig.Create;
        result := TAppConfig(FAppConfigs.Objects[i]);
    finally
        Unlock;
    end;
end;

function TWebAppConfig.GetDefaultAppConfig: TAppConfig;
begin
    result := GetAppConfig(DefaultAppId);
end;


initialization
begin
    WebAppConfig := TWebAppConfig.Create;
end;

finalization
begin
    WebAppConfig.Free;
end;

end.
