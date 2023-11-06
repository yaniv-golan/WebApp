unit CgiReq;

interface

uses Classes, SysUtils, Windows, HttpReq;

type
TCgiHttpRequestImp = class(TAbstractHttpRequestInterface)
private
    FStdIn, FStdOut: THandle;
    FDebugMode: boolean;
    FDebugOutput: TStream;
    FParsed: boolean;
    FCachedAccept: string;
    function    GetFromEnv(const Name: string): string;
    procedure   DumpEnvStrings(const Filename: string);
    procedure   DumpEnvStringsToTempFile;
public
    constructor Create(hStdIn, hStdOut: THandle; Parsed: boolean);
    destructor  Destroy; override;
    function    GetQueryString: string; override;
    function    GetMethod: string; override;
    function    GetLogicalPath: string; override;
    function    GetPhysicalPath: string; override;
    function    WriteToClient(const Buffer; Count: integer): integer; override;
    function    ReadFromClient(var Buffer; Count: integer): integer; override;
    function    GetInputSize: integer; override;
    function    GetInputContentType: string; override;
    function    GetServerVariable(const VarName: string): string; override;
    function    GetHttpHeader(const HeaderName: string): string; override;
    function    MapURLToPath(const LogicalURL: string): string; override;
end;

implementation

uses D3SysUtl, XcptTrc
    ;

(*procedure log(fn: string; s: string);
var
    f: textFile;
begin
    assign(f, fn);
    if (fileExists(fn)) then
        append(f)
    else
        rewrite(f);
    try
        writeln(f,s);
    finally
        closeFile(f);
    end;
end;*)

function    CreateTempFilename(const Prefix: string): string;
var
    TempPath: string;
begin
    try
        SetLength(TempPath, MAX_PATH);
        SetLength(TempPath, GetTempPath(MAX_PATH, PChar(TempPath)));
        if (TempPath = '') then
            RaiseLastWin32Error;
        SetLength(Result, MAX_PATH);
        If (GetTempFilename(PChar(TempPath), PChar(Prefix), 0, PChar(Result)) = 0) then
            RaiseLastWin32Error;
        SetLength(Result, StrLen(PChar(Result)));
    except
        on E: Exception do begin
            raise ETracedException.Create('Unable to create temporary file');
        end;
    end;
end;

constructor TCgiHttpRequestImp.Create(hStdIn, hStdOut: THandle; Parsed: boolean);
begin
    inherited Create;
    FStdIn := hStdIn;
    FStdOut := hStdOut;
    FDebugMode := (CompareText(GetFromEnv('DEBUG_MODE'), 'YES') = 0);
    FDebugMode := true;
    if (FDebugMode) then begin
        DumpEnvStringsToTempFile;
        FDebugOutput := TFileStream.Create(CreateTempFilename('OUT'), fmCreate or fmOpenWrite);
    end;
    FParsed := Parsed;
end;

destructor  TCgiHttpRequestImp.Destroy;
begin
    FDebugOutput.Free;
    inherited Destroy;
end;

// for debugging
procedure   TCgiHttpRequestImp.DumpEnvStringsToTempFile;
begin
    DumpEnvStrings(CreateTempFilename('ENV'));
end;

// for debugging
procedure   TCgiHttpRequestImp.DumpEnvStrings(const Filename: string);
var
    p: pchar;
    f: textFile;
begin
    assignFile(f, Filename);
    rewrite(f);
    try
        p := GetEnvironmentStrings;
        while (p^ <> #0) do begin
            writeln(f, p);
            p := StrEnd(p);
            inc(p);
        end;
    finally
        closeFile(f);
    end;
end;

function    TCgiHttpRequestImp.GetFromEnv(const Name : string): string;

    procedure   DoGetFromEnv(var buf: pchar; bufSize: dword; retry: boolean; var result: string);
    var
        retVal: dword;
    begin
        retVal := GetEnvironmentVariable(pchar(Name), buf, bufSize);
        if (retVal = 0) then begin
            // not found
            result := '';
        end else if (retVal > bufSize) then begin
            // the buffer was too small :
            if (retry) then begin
                StrDispose(buf);
                buf := nil;
                // realloc the required size
                buf := StrAlloc(retVal);
                // try one last time with the bigger buffer (retry = false)
                DoGetFromEnv(buf, retVal, false, result);
            end; { if }
        end else begin
            SetString(result, buf, retVal);
        end;
    end; { DoGetFromEnv }

var
    buf: pchar;
begin
    buf := StrAlloc(2 * 1024);
    try
        DoGetFromEnv(buf, strBufSize(buf), true, result);
    finally
        StrDispose(buf);
    end;
end;

function    TCgiHttpRequestImp.GetQueryString: string;
begin
    result := GetFromEnv('QUERY_STRING');
end;

function    TCgiHttpRequestImp.GetMethod: string;
begin
    result := GetFromEnv('REQUEST_METHOD');
end;

function    TCgiHttpRequestImp.GetLogicalPath: string;
begin
    result := GetFromEnv('PATH_INFO');
end;

function    TCgiHttpRequestImp.GetPhysicalPath: string;
begin
    result := GetFromEnv('PATH_TRANSLATED');
end;

function    TCgiHttpRequestImp.WriteToClient(const Buffer; Count: integer): integer;
begin
    result := FileWrite(FStdOut, Buffer, Count);
    Win32Check(result <> -1);
    if (FDebugOutput <> nil) then
        FDebugOutput.Write(Buffer, Count);
end;

function    TCgiHttpRequestImp.ReadFromClient(var Buffer; Count: integer): integer;
begin
    result := FileRead(FStdIn, Buffer, Count);
    Win32Check(result <> -1);
end;

function    TCgiHttpRequestImp.GetInputSize: integer;
var
    s: string;
begin
    s := GetFromEnv('CONTENT_LENGTH');
    if (s = '') then
        result := 0
    else
        result := StrToInt(s);
end;

function    TCgiHttpRequestImp.GetInputContentType: string;
begin
    result := GetFromEnv('CONTENT_TYPE');
end;

function    TCgiHttpRequestImp.GetServerVariable(const VarName: string): string;
begin
    result := GetFromEnv(VarName);    
end;

function    TCgiHttpRequestImp.GetHttpHeader(const HeaderName: string): string;

    function GetHttpAcceptHeader: string;
    var
        Strings: TStrings;
        i: integer;
    begin
        if (FCachedAccept = '') then begin
            // WebSite sends the name of a file containing the values instead of
            // the actual value...
            if (pos('WEBSITE', upperCase(GetServerVariable('SERVER_NAME'))) > 0) then begin
                Strings := TStringList.Create;
                try
                    Strings.LoadFromFile(GetFromEnv('HTTP_ACCEPT'));
                    for i := 0 to (Strings.Count - 1) do begin
                        if (i > 0) then
                            FCachedAccept := FCachedAccept + ', ';
                        FCachedAccept := FCachedAccept + Strings[i];
                    end;
                finally
                    Strings.Free;
                end;
            end else begin
                FCachedAccept := GetFromEnv('HTTP_ACCEPT');
            end;
        end;
        result := FCachedAccept;
    end;

begin
    if (CompareText(HeaderName, 'ACCEPT') = 0) then
        result := GetHttpAcceptHeader
    else
        result := GetFromEnv('HTTP_' + HeaderName);
    if (result = '') then
        result := GetFromEnv(HeaderName);
end;

function    TCgiHttpRequestImp.MapURLToPath(const LogicalURL: string): string;
begin
    // tbd
    result := '';
end;

end.
