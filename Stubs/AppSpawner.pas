unit AppSpawner;

interface

uses Windows;

procedure StartProxyServer(const AppId: string; var ProxyProcessId: dword);

implementation

uses Classes, SysUtils, CWebAppConfig, NTSecUtl, IPC, XcptTrc, WIPCShrd, wcp;

function GetRunAsUserHandle(const AppId: string): THandle;
var
    AppConfig: TAppConfig;
    UserName: string;
    Password: string;
begin
    WebAppConfig.Lock;
    try
        AppConfig := WebAppConfig.GetAppConfig(AppId);
        UserName := AppConfig.AutoStart.RunAsUser;
        Password := AppConfig.AutoStart.RunAsPassword;
        if (UserName = '') then begin
            with WebAppConfig.GetDefaultAppConfig do begin
                UserName := AutoStart.RunAsUser;
                Password := AutoStart.RunAsPassword;
            end;
        end;
        if (UserName = '') then begin
            result := 0;
        end else begin
            try
                Win32Check(LogonUser(
                    PChar(UserName),
                    nil,
                    PChar(Password),
                    LOGON32_LOGON_INTERACTIVE,
                    LOGON32_PROVIDER_DEFAULT,
                    result));
            except
                raise ETracedException.Create('Unable to logon user');
            end;
        end;
    finally
        WebAppConfig.Unlock;
    end;
end;

procedure MyCreateProcessAsUser(hToken: THandle; lpApplicationName: PChar;
  lpCommandLine: PChar; lpProcessAttributes: PSecurityAttributes;
  lpThreadAttributes: PSecurityAttributes; bInheritHandles: BOOL;
  dwCreationFlags: DWORD; lpEnvironment: Pointer; lpCurrentDirectory: PChar;
  const lpStartupInfo: TStartupInfo; var lpProcessInformation: TProcessInformation);
begin
    if (hToken = 0) then
        Win32Check(CreateProcess(lpApplicationName, lpCommandLine,
            lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags,
            lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation))
    else
        Win32Check(CreateProcessAsUser(hToken, lpApplicationName, lpCommandLine,
            lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags,
            lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation))
    ;
end;

procedure StartProxyServer(const AppId: string; var ProxyProcessId: dword);
var
    CommandLine: string;
    StartupInfo: TStartupInfo;
    ProcessInformation: TProcessInformation;
    TokenHandle: THandle;
    RunAsUserHandle: THandle;
    HDesktop: HDesk;
    hWindowStation: HWinSta;
    DeskTopName: string;
    WinStaName: string;
    S: string;
    AppInitializeEvent: TWin32Event;
    i: integer;
const
    DEFWINSTATION: string = 'WinSta0';
    DEFDESKTOP: string = 'Default';
    WaitTimeout = 20; // wait max 20 seconds for the app to start
    SleepBetweenChecks = 100; // num of msecs to sleep between checks 
const
    InteractiveDesktop: pchar = 'WinSta0\Default';    
begin
    try
        ProxyProcessId := 0;
        commandLine := '';
        with WebAppConfig.GetAppConfig(AppId)do begin
            if (AutoStart.Enable) then
                CommandLine := AutoStart.CommandLine;
        end; // with
        if (CommandLine = '') then
            exit;

        cp(0, 'CommandLine = ' + CommandLine);

        if OpenThreadToken(GetCurrentThread, TOKEN_ALL_ACCESS, true,  TokenHandle) then
            RevertToSelf
        else
            TokenHandle := 0;
        try
            cp(0, 'TokenHandle = ' + IntToStr(TokenHandle));

(*            hWindowStation:= GetProcessWindowStation;
            Win32Check(hWindowStation <> 0);
            SetUserObjectAllAccess(hWindowStation);
            cp(0, 'hWindowStation = ' + IntToStr(hWindowStation));

            if not GetUserObjectName(hWindowStation, WinStaName) then
                WinStaName:= DEFWINSTATION;

            HDesktop := GetThreadDesktop(GetCurrentThreadId);
            SetUserObjectAllAccess(HDesktop);

            cp(0, 'hDesktop = ' + IntToStr(hDesktop));

            if not GetUserObjectName(HDesktop, DeskTopName) then
                DeskTopName:= DEFDESKTOP;

            cp(0, 'desktopname = ' + desktopname);
            cp(0, 'WinStaName = ' + WinStaName);

//            WinStaName := 'WinSta0';
*)
            FillChar(StartupInfo, Sizeof(StartupInfo), 0);
            StartupInfo.cb := sizeof(StartupInfo);
            S:= WinStaName + '\' + DeskTopName;
            StartupInfo.lpDesktop := InteractiveDesktop;

            cp(0, 'StartupInfo.lpDesktop = ' + strpas(StartupInfo.lpDesktop));

            RunAsUserHandle := GetRunAsUserHandle(AppId);
            try
                try
                    cp(0, 'RunAsUserHandle = ' + inttostr(RunAsUserHandle));
                    MyCreateProcessAsUser(
                        RunAsUserHandle,
                        nil, // lpApplicationName
                        pchar(CommandLine), // lpCommandLine
                        @NoSecurityAttributes, // lpProcessAttributes
                        @NoSecurityAttributes, // lpThreadAttributes
                        false, // bInheritHandles
                        CREATE_NEW_CONSOLE or CREATE_NEW_PROCESS_GROUP, // wCreationFlags
                        nil, // pEnvironment
                        nil, // lpCurrentDirectory
                        StartupInfo,
                        ProcessInformation
                    );
                    Win32Check(CloseHandle(ProcessInformation.hThread));
                    Win32Check(CloseHandle(ProcessInformation.hProcess));
                except
                    raise ETracedException.Create('Unable to create process');
                end;
            finally
                if (RunAsUserHandle <> 0) then
                    Win32Check(CloseHandle(RunAsUserHandle));
            end;
        finally
            if (TokenHandle <> 0) then begin
                SetThreadToken(nil, TokenHandle);
                Win32Check(CloseHandle(TokenHandle));
            end;
        end;


        for i := 0 to ((WaitTimeout * 1000) div SleepBetweenChecks) do begin
            if (ProxyProcessId <> 0) then
                break;
            Sleep(SleepBetweenChecks);
        end; 
//        AppInitializeEvent := TWin32Event.Create(FormatSharedName(AppInitializedEventName, AppId), true, @NoSecurityAttributes);
//        try
//            AppInitializeEvent.WaitFor(20 * 1000);
//            if (AppInitializeEvent.WaitFor(20 * 1000) <> wrSignaled) then
//                raise ETracedException.Create('Application did not initialize');
//        finally
//            AppInitializeEvent.Free;
//        end;
    except
        on E: Exception do
            raise ETracedException.Create('StartProxyServer failed');
    end;
end;


end.
