unit WapCmds;

interface

uses WIPCShrd;

const
    wcString_None = '';
    wcString_Test = 'TEST';
    wcString_RefreshConfig = 'REFRESHCONFIG';
    wcString_MapURL = 'MAPURL';
    wcString_GetAppSessionCount = 'GETAPPSESSIONCOUNT';
    wcString_TerminateApp = 'TERMINATEAPP';
    wcString_GetAppState = 'GETAPPSTATE';
    wcString_SuspendApp = 'SUSPENDAPP';
    wcString_ResumeApp = 'RESUMEAPP';

function ParseWapCmd(const WapCmd: string): TWapCmd;

implementation

uses SysUtils;

function ParseWapCmd(const WapCmd: string): TWapCmd;
var
    S: string;
begin
    S := UpperCase(WapCmd);
    if (S = wcString_None) then
        result := wcNone
    else if (S = wcString_Test) then
        result := wcTest
    else if (S = wcString_RefreshConfig) then
        result := wcRefreshConfig
    else if (S = wcString_MapURL) then
        result := wcMapURL
    else if (S = wcString_GetAppSessionCount) then
        result := wcGetAppSessionCount
    else if (S = wcString_TerminateApp) then
        result := wcTerminateApp
    else if (S = wcString_GetAppState) then
        result := wcGetAppState
    else if (S = wcString_SuspendApp) then
        result := wcSuspendApp
    else if (S = wcString_ResumeApp) then
        result := wcResumeApp
    else
        result := wcBadWapCmd;
end;

end.
