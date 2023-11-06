unit StubUtils;

interface

uses Classes, SysUtils, Windows,
  HttpReq, AppSSI
  ;

procedure   DispatchToWapStub(RequestInterface: TAbstractHttpRequestInterface);

function    AppIdFromMapping(const LogicalPath: string): string;

procedure   HandleException(RequestInterface: TAbstractHttpRequestInterface; E: Exception; const Context: string);
function    WapCheckVersion(Major, Minor: integer): bool; stdcall; export;

implementation

uses SDS, IPC, WapStub,
  CWebAppConfig, WapCmds, WIPCShrd,
  XStrings,
  Masks,
  XcptTrc
    ;

function WapCheckVersion(Major, Minor: integer): bool; stdcall; export;
begin
    // supports Wap protocol v1.0
    result := ((Major = 1) and (Minor = 0));
end;

procedure   InternalHandleException(Transaction: THttpTransaction; E: Exception; const Context: string);

    procedure WriteGenericErrorMessage(
        const QueryString: string;
        const ExceptionClass: string;
        const ExceptionMessage: string;
        const ErrorFileFailure: string);
    var
        i: integer;
    begin
        with Transaction.Response do begin
            Status := FormatStatusString(hsInternalServerError);
            Writeln(TextOut, '<head><title>WebApp Error</title></head>');
            Writeln(TextOut, '<body>');
            Writeln(TextOut, '<h1>', FormatStatusString(hsInternalServerError), '</h1>');
            Writeln(TextOut, '<h2>Error executing WebApp request</h2>');
            Writeln(TextOut, '<p>');
            Writeln(TextOut, 'Request : ' + QueryString + '<br>');
            Writeln(TextOut, 'Error type : ' + ExceptionClass + '<br>');
            Writeln(TextOut, 'Error Message : ' + ExceptionMessage + '<br>');
            Writeln(TextOut, 'Error Context : ' + Context + '<br>');
            Writeln(TextOut, 'Error Module : WebApp DLL');
            Writeln(TextOut, '<p>');
            Writeln(TextOut, 'Exceptions trace :<hr>');
            for i := (Exceptions.Count - 1) downto 0 do begin
                with Exceptions[i] do
                    Writeln(TextOut, Format('%s : %s<br>', [Exception.ClassName, (ExceptionObject as Exception).Message]));
            end;
            Exceptions.Clear;
            Writeln(TextOut, '<hr>End of Exceptions trace');
            Writeln(TextOut, '<p>');
            if (ErrorFileFailure <> '') then begin
                Writeln(TextOut, '<p>(Could not load error file : ' + ErrorFileFailure + ')');
            end;
            Writeln(TextOut, '</body>');
        end;
    end;

    function ExpandErrorFileLine(const S: string): string;
    begin
        result := ReplaceSubStringInString(S, '%QueryString%', Transaction.Request.QueryString.AsString, true);
        result := ReplaceSubStringInString(result, '%ExceptionClass%', E.ClassName, true);
        result := ReplaceSubStringInString(result, '%ExceptionMessage%', E.Message, true);
        result := ReplaceSubStringInString(result, '%Context%', E.Message, true);
    end;

var
    ErrorFn: string;
    ErrorFileLines: TStringList;
    i: integer;
begin
    try
        try
            ErrorFn := WebAppConfig.GetErrorFile;
            if (ErrorFn <> '') then begin
                ErrorFileLines := TStringList.Create;
                try
                    ErrorFileLines.LoadFromFile(ErrorFn);
                    for i := 0 to (ErrorFileLines.Count - 1) do
                        Writeln(Transaction.Response.TextOut, ExpandErrorFileLine(ErrorFileLines[i]));
                finally
                    ErrorFileLines.Free;
                end;
            end else begin
                WriteGenericErrorMessage(Transaction.Request.QueryString.AsString, E.ClassName, E.Message, '');
            end;
        except
            on NewException: Exception do
                WriteGenericErrorMessage(Transaction.Request.QueryString.AsString, E.ClassName, E.Message, NewException.Message);
        end;
    finally
        Exceptions.Clear;
    end;
end;

procedure   HandleException(RequestInterface: TAbstractHttpRequestInterface; E: Exception; const Context: string);
var
    Transaction: THttpTransaction;
begin
    Transaction := THttpTransaction.Create(RequestInterface, false);
    try
        InternalHandleException(Transaction, E, Context);
    finally
        Transaction.Free;
    end;
end;

(*procedure   WriteBetaExpired(Request: TAbstractHttpRequestInterface);
begin
    WriteLineToClient(Request, 'HTTP/1.0 500 Internal Server Error');
    WriteLineToClient(Request, 'Content-Type: text/html');
    WriteLineToClient(Request, '');
    WriteLineToClient(Request, 'The beta version of <b>HyperAct WebApp</b> has expired. Please visit the ' +
        'HyperAct Web Site at <a href="http://www.hyperact.com">http://www.hyperact.com</a> ' +
        'to download a newer version.');
end;*)

procedure   WriteTestOK(Transaction: THttpTransaction);
begin
    Writeln(Transaction.Response.TextOut, 'OK WebApp test succeeded.');
end;

procedure RefreshConfig(Transaction: THttpTransaction);
begin
    try
        WebAppConfig.Refresh;
        Writeln(Transaction.Response.TextOut, 'OK Configuration refreshed.');
    except
        on e: Exception do
            InternalHandleException(Transaction, e, 'RefreshConfig');
    end;
end;

function HandleWapCmd(Transaction: THttpTransaction): boolean;
var
    WapCmd: TWapCmd;
begin
    result := true;
    WapCmd := ParseWapCmd(Transaction.Request.QueryString['WapCmd'].Value);
    case WapCmd of
        wcTest: begin
            WriteTestOk(Transaction);
        end;
        wcRefreshConfig: begin
            RefreshConfig(Transaction);
        end;
        wcMapURL: begin
            // tbd
        end;
        wcBadWapCmd: begin
            raise ETracedException.Create('Invalid WapCmd command');
        end;
        else
            result := false;
    end;
end;

function AppIdFromMapping(const LogicalPath: string): string;
var
    Mapping: TStringList;
    Mask, AppId: string;
    i: integer;
begin
    Mapping := TStringList.Create;
    try
        WebAppConfig.GetMapping(Mapping);
        for i := 0 to (Mapping.Count - 1) do begin
            StringToNameAndValue(Mapping[i], Mask, AppId);
            if MatchesMask(LogicalPath, Mask) then begin
                result := AppId;
                exit;
            end;
        end;
    finally
        Mapping.Free;
    end;
    result := '';
end;


var
    StubsList: TExStringList;
    StubsListLock: TWin32CriticalSection;

procedure   DispatchToWapStub(RequestInterface: TAbstractHttpRequestInterface);
var
    Transaction: THttpTransaction;
    AppId: string;
    I: integer;
    Stub: TWapAppStub;
begin
    try
    {     if (Now > EncodeDate(1997, 8, 31)) then begin
            WriteBetaExpired(RequestInterface);
            exit;
        end;}
        Transaction := THttpTransaction.Create(RequestInterface, false);
        try
            try
                if HandleWapCmd(Transaction) then
                    exit;

                with Transaction do begin
                    AppId := Request.QueryString['APP'].Value;
                    if (AppId = '') then
                        AppId := Request.Cookies['HyperAct']['WA_APPID'];
                    if (AppId = '') then
                        AppId := AppIdFromMapping(Request.LogicalPath);
                    if (AppId = '') then
                        AppId := WebAppConfig.GetDefaultAppId;
                    if (AppId = '') then
                        raise exception.create('No AppId');
                end;
            except
                on E: Exception do
                    raise ETracedException.Create('Could not retrieve AppId');
            end;

            try
                StubsListLock.Enter;
                try
                    I := StubsList.IndexOf(UpperCase(AppId));
                    if (I = -1) then begin
                        Stub := TWapAppStub.Create(AppId);
                        StubsList.AddObject(UpperCase(AppId), Stub);
                    end else begin
                        Stub := StubsList.Objects[I] as TWapAppStub;
                    end;
                finally
                    StubsListLock.Leave;
                end;
            except
                on E: Exception do
                    raise ETracedException.Create('Could not locate stub object');
            end;

            Stub.ProcessRequest(Transaction);
        finally
            Transaction.Free;
        end;
    except
        on E: Exception do
            raise ETracedException.Create('DispatchToWapStub failed');
    end;
end;



initialization
begin
    StubsListLock := TWin32CriticalSection.Create;
    StubsList := TExStringList.Create;
end;

finalization
begin
    StubsList.Free;
    StubsListLock.Free;
end;

end.
