unit WCgiReq;

interface

uses Classes, SysUtils, Windows, HttpReq, IniFiles;

type
TWinCgiHttpRequestImp = class(TAbstractHttpRequestInterface)
private
    FIniFile: TIniFile;
    FOutput: TStream;
    FInput: TStream;
    FDebugMode: boolean;
    FCachedAccept: string;
public
    constructor Create(CgiDataFilename: pchar);
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

uses D3SysUtl, XStrings
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

constructor TWinCgiHttpRequestImp.Create(CgiDataFilename: pchar);
var
    S: string;
begin
    inherited Create;
    FIniFile := TIniFile.Create(StrPas(CgiDataFilename));

    // Note : Netscape FastTrack server omits the drive from the input and output filenames,
    // therefore we will fail if the working directory is not in the same drive

    S := FIniFile.ReadString('System', 'Output File', '');
    if (S <> '') then begin
        // Create only if does not exists, to prevent sharing errors
        if FileExists(s) then
            FOutput := TFileStream.Create(S, fmOpenWrite or fmShareDenyNone)
        else
            FOutput := TFileStream.Create(S, fmCreate or fmOpenWrite or fmShareDenyNone);
    end;

    S := FIniFile.ReadString('System', 'Content File', '');
    if (S <> '') then begin
        FInput := TFileStream.Create(S, fmOpenRead + fmShareDenyNone);
    end;

    FDebugMode := (CompareText(FIniFile.ReadString('System', 'Debug Mode', ''), 'yes') = 0);
end;

destructor  TWinCgiHttpRequestImp.Destroy;
begin
    FInput.Free;
    FOutput.Free;
    FIniFile.Free;
    inherited Destroy;
end;

function    TWinCgiHttpRequestImp.GetQueryString: string;
begin
    result := FIniFile.ReadString('CGI', 'Query String', '');
end;

function    TWinCgiHttpRequestImp.GetMethod: string;
begin
    result := FIniFile.ReadString('CGI', 'Request Method', '');
end;

function    TWinCgiHttpRequestImp.GetLogicalPath: string;
begin
    result := FIniFile.ReadString('CGI', 'Logical Path', '');
end;

function    TWinCgiHttpRequestImp.GetPhysicalPath: string;
begin
    result := FIniFile.ReadString('CGI', 'Physical Path', '');
end;

function    TWinCgiHttpRequestImp.WriteToClient(const Buffer; Count: integer): integer;
begin
    if (FOutput = nil) then
        raise exception.create('Output file not opened');
    result := FOutput.Write(Buffer, Count);
end;

function    TWinCgiHttpRequestImp.ReadFromClient(var Buffer; Count: integer): integer;
begin
    if (FInput = nil) then
        raise exception.create('Input file not opened');
    result := FInput.Read(Buffer, Count);
end;

function    TWinCgiHttpRequestImp.GetInputSize: integer;
var
    s: string;
begin
    s := FIniFile.ReadString('CGI', 'Content Length', '');
    if (s = '') then
        result := 0
    else
        result := StrToInt(s);
end;

function    TWinCgiHttpRequestImp.GetInputContentType: string;
begin
    result := FIniFile.ReadString('CGI', 'Content Type', '');
end;

function    TWinCgiHttpRequestImp.GetServerVariable(const VarName: string): string;
var
    s: string;
    key: string;
    i: integer;
begin
    s := UpperCase(VarName);
    key := '';
    if (s = 'AUTH_TYPE') then
        key := 'Authentication Method'
    else if (s = 'CONTENT_LENGTH') then
        key := 'Content Length'
    else if (s = 'CONTENT_TYPE') then
        key := 'Content Type'
    else if (s = 'GATEWAY_INTERFACE') then
        key := 'CGI Version'
    else if (s = 'PATH_INFO') then
        key := 'Logical Path'
    else if (s = 'PATH_TRANSLATED') then
        key := 'Physical Path'
    else if (s = 'QUERY_STRING') then
        key := 'Query String'
    else if (s = 'REMOTE_ADDR') then
        key := 'Remote Address'
    else if (s = 'REMOTE_HOST') then
        key := 'Remote Host'
    else if (s = 'REMOTE_IDENT') then
        key := ''   // ???
    else if (s = 'REMOTE_USER') then
        key := 'Authenticated Username'  
    else if (s = 'REQUEST_METHOD') then
        key := 'Request Method'
    else if (s = 'SCRIPT_NAME') then
        key := 'Executable Path'
    else if (s = 'SERVER_NAME') then
        key := 'Server Name'
    else if (s = 'SERVER_PORT') then
        key := 'Server Port'
    else if (s = 'SERVER_PROTOCOL') then
        key := 'Request Protocol'
    else if (s = 'SERVER_SOFTWARE') then
        key := 'Server Software';
    if (key <> '') then begin
        result := FIniFile.ReadString('CGI', Key, '');
    end else begin
        if (copy(s, 1, 5) = 'HTTP_') then
            result := GetHttpHeader(copy(s, 6, maxInt))
        else begin
            for i := 1 to length(s) do
                if (s[i] = ' ') then
                    s[i] := '_';
            result := FIniFile.ReadString('Extra Headers', s, '');
        end;
    end;
end;

function UnderscoreToHyphen(const S: string): string;
var
    i: integer;
begin
    result := S;
    for i := 1 to length(result) do
        if (result[i] = '_') then
            result[i] := '-';
end;

function    TWinCgiHttpRequestImp.GetHttpHeader(const HeaderName: string): string;

    function ExtractAcceptValues: string;
    var
        Strings: TStrings;
        i: integer;
        Name, Value: string;
    begin
        if (FCachedAccept = '') then begin
            Strings := TStringList.Create;
            try
                FIniFile.ReadSectionValues('Accept', Strings);
                for i := 0 to (Strings.Count - 1) do begin
                    StringToNameAndValue(Strings[i], Name, Value);
                    if (i > 0) then
                        FCachedAccept := FCachedAccept + ', ';
                    FCachedAccept := FCachedAccept + Name;
                    if (Value <> '') and (CompareText(Value, 'YES') <> 0) then 
                        FCachedAccept := FCachedAccept + ' ;' + Value;
                end;
            finally
                Strings.Free;
            end;
        end;
        result := FCachedAccept;
    end;

begin
    if (compareText(headerName, 'USER_AGENT') = 0) then
        result := FIniFile.ReadString('CGI', 'User Agent', '')
    else if (compareText(headerName, 'ACCEPT') = 0) then
        result := ExtractAcceptValues
    else
        result := FIniFile.ReadString('Extra Headers', HeaderName, '');
    if (result = '') then
        result := FIniFile.ReadString('Extra Headers', UnderscoreToHyphen(HeaderName), '');
end;

function    TWinCgiHttpRequestImp.MapURLToPath(const LogicalURL: string): string;
begin
    // tbd
    result := '';
end;

end.
