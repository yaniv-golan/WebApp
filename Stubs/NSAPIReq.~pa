unit NSAPIReq;

interface

uses Classes, SysUtils, Windows, DynNSAPI, HttpReq, IPC
    ;

type

ENsapiHttpRequestImp = class(EAbstractHttpRequestInterface);

TNsapiHttpRequestImp = class(TAbstractHttpRequestInterface)
private
    FPB: PPblock;
    FSN: PSession;
    FRQ: Prequest;
    Fenv: PPCharArray;
    FHttpHeaders: TStringList;
    function InternalGetServerVariable(VariableName: PChar; Buffer: Pointer;
      var Size: DWORD): Boolean;
    procedure   readHttpHeaders;
public
    constructor Create(pb: PPblock; sn: PSession; rq: Prequest);
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

    property    PB: PPblock read FPb;
    property    SN: PSession read FSn;
    property    RQ: Prequest read FRq;
end;

implementation

function MakeValid(Str: PChar): PChar;
begin
  if Str = nil then
    Result := ''
  else Result := Str;
end;


constructor TNsapiHttpRequestImp.Create(pb: PPblock; sn: PSession; rq: Prequest);
begin
    inherited Create;
    LoadNSAPI;    
    FPb := pb;
    FSn := sn;
    FRq := rq;
end;

destructor  TNsapiHttpRequestImp.Destroy;
begin
    if Fenv <> nil then
        util_env_free(Fenv);
    FHttpHeaders.Free;
    inherited Destroy;
end;

function TNsapiHttpRequestImp.WriteToClient(const Buffer; Count: integer): integer;
begin
    Result := net_write(Fsn.csd, @Buffer, Count);
    if (Result = IO_ERROR) then
        Raise Exception.Create('WriteToClient failed');
end;

function    TNsapiHttpRequestImp.ReadFromClient(var Buffer; Count: integer): integer;
var
  nBuf, nRemaining: Integer;
begin
  nRemaining := Count;
  while nRemaining > 0 do
  begin
    with Fsn.inbuf^ do
      if pos < cursize then
      begin
        nBuf := cursize - pos;
        if nBuf > Count then
            nBuf := Count;
        Move(inbuf[pos], Buffer, nBuf);
        Inc(pos, nBuf);
        Dec(nRemaining, nBuf);
        Inc(Integer(Buffer), nBuf);
      end else
      begin
        nBuf := net_read(Fsn.csd, @Buffer, nRemaining, NET_READ_TIMEOUT);
        if nBuf = IO_ERROR then
            raise Exception.Create('ReadFromClient failed');
        Dec(nRemaining, nBuf);
      end;
  end;
  result := Count - nRemaining;
end;

function    TNsapiHttpRequestImp.GetInputSize: integer;
begin
    try
        result := StrToInt(StrPas(pblock_findval('content-length', Frq.headers)));
    except
        result := 0;
    end;
end;

function    TNsapiHttpRequestImp.GetInputContentType: string;
begin
    result := StrPas(pblock_findval('content-type', Frq.headers));
end;

function TranslateChar(const Str: string; FromChar, ToChar: Char): string;
var
  I: Integer;
begin
  Result := Str;
  for I := 1 to Length(Result) do
    if Result[I] = FromChar then
      Result[I] := ToChar
    else if Result[I] = '?' then Break;
end;

// Diagnostic purposes only... Do not resource these strings    
function GetObjectConfig(os: PHttpdObjSet): string;
var
  obj: PHttpdObject;
  dt: PDtable;
  dir: PDirective;
  I, J, K: Integer;
begin
  Result := Format('os: $%p'#13#10, [os]);
  try
    if os <> nil then
    begin
      K := 0;
      obj := PPointerList(os.obj)^[K];
      Result := Format('%sobj: $%p'#13#10, [Result, obj]);
      if obj <> nil then
      begin
        while obj <> nil do
        begin
          Result := Format('%sobj.name: $%p'#13#10, [Result, obj.name]);
          Result := Format('%sRoot Object: %s (%s)'#13#10, [Result, 'default',
            NSstr2String(pblock_pblock2str(obj.name, nil))]);
          dt := obj.dt;
          Result := Format('%sobj.dt: $%p'#13#10'obj.nd: %d'#13#10, [Result, dt, obj.nd]);
          for I := 0 to obj.nd - 1 do
          begin
            dir := dt.inst;
            Result := Format('%sdt.inst: $%p'#13#10'dt.ni: %d'#13#10, [Result, dir, dt.ni]);
            for J := 0 to dt.ni - 1 do
            begin
              if dir <> nil then
              begin
                if dir.param <> nil then
                  Result := Format('%s  Param: %s'#13#10, [Result,
                    NSstr2String(pblock_pblock2str(dir.param, nil))])
                else Result := Format('%s  Param:'#13#10, [Result]);
                if dir.client <> nil then
                  Result := Format('%s  Client: %s'#13#10, [Result,
                    NSstr2String(pblock_pblock2str(dir.client, nil))])
                else Result := Format('%s  Client:'#13#10, [Result]);
              end;
              Inc(dir);
            end;
            Inc(dt);
          end;
          Inc(K);
          obj := PPointerList(os.obj)^[K];
        end;
      end else Result := 'root_object not found';
    end else Result := 'std_os Objset not found';
  except
    on E: Exception do
      Result := Format('%sException %s: %s'#13#10, [Result, E.ClassName, E.Message]);
  end;
end;

function TNsapiHttpRequestImp.InternalGetServerVariable(VariableName: PChar; Buffer: Pointer;
  var Size: DWORD): Boolean;
var
  HeaderName: string;
  HeaderValue: PChar;

  procedure InitEnv;
  var
    Value: PChar;

    procedure AddToEnv(var Env: PPCharArray; Name, Value: PChar);
    var
      Pos: Integer;
    begin
      Env := util_env_create(Env, 1, Pos);
      Env[Pos] := util_env_str(Name, Value);
      Env[Pos+1] := nil;
    end;

  begin
    if Fenv = nil then
    begin
      Fenv := http_hdrs2env(Frq.headers);
      Value := pblock_findval('content-length', Frq.headers);
      try
        if Value <> nil then
          AddToEnv(Fenv, 'HTTP_CONTENT_LENGTH', Value);
      finally
        system_free(Value);
      end;
      Value := pblock_findval('content-type', Frq.headers);
      try
        if Value <> nil then
          AddToEnv(Fenv, 'HTTP_CONTENT_TYPE', Value);
      finally
        system_free(Value);
      end;
    end;
  end;

  procedure CopyValue(Value: PChar; var Result: Boolean);
  begin
    Result := False;
    PChar(Buffer)[0] := #0;
    if Value <> nil then
    begin
      StrLCopy(Buffer, Value, Size);
      if Size < StrLen(Value) then
        SetLastError(ERROR_INSUFFICIENT_BUFFER)
      else Result := True;
      Size := StrLen(Value) + 1;
    end else SetLastError(ERROR_NO_DATA);
  end;

  function AllHeaders: string;
  var
    P: PPCharArray;
    I: Integer;
    S: string;
    EqualPos: integer;
  begin
    InitEnv;
    P := Fenv;
    Result := '';
    I := 0;
    while P^[I] <> nil do
    begin
      // Seems like Netscape headers are formatted as name=value instead of name: value.
      // Fix this. Note - this is different from the original D3 code, which simply
      // replaced all "=" with ":".
      S := P^[I];
      EqualPos := Pos('=', S);
      if (EqualPos > 0) then
        S[EqualPos] := ':';
      Result := Format('%s%s'#13#10, [Result, S]);
      Inc(I);
    end;
  end;

begin
  // Check if this is a request for an HTTP header
  if VariableName = nil then VariableName := 'BAD';
  HeaderValue := nil;
  HeaderName := VariableName;
  if shexp_casecmp(VariableName, 'HTTP_*') = 0 then
  begin
    InitEnv;
    CopyValue(util_env_find(Fenv, VariableName), Result);
    Exit;
  end else
  begin
    if CompareText('CONTENT_LENGTH', HeaderName) = 0 then
      HeaderValue := pblock_findval('content-length', Frq.headers)
    else if CompareText('CONTENT_TYPE', HeaderName) = 0 then
      HeaderValue := pblock_findval('content-type', Frq.headers)
    else if CompareText('PATH_INFO', HeaderName) = 0 then
      HeaderValue := pblock_findval('path-info', Frq.vars)
    else if CompareText('PATH_TRANSLATED', HeaderName) = 0 then
      HeaderValue := pblock_findval('path-translated', Frq.vars)
    else if CompareText('QUERY_STRING', HeaderName) = 0 then
      HeaderValue := pblock_findval('query', Frq.reqpb)
    else if CompareText('REMOTE_ADDR', HeaderName) = 0 then
      HeaderValue := pblock_findval('ip', Fsn.client)
    else if CompareText('REMOTE_HOST', HeaderName) = 0 then
      HeaderValue := session_dns(Fsn)
    else if CompareText('REQUEST_METHOD', HeaderName) = 0 then
      HeaderValue := pblock_findval('method', Frq.reqpb)
    else if CompareText('SCRIPT_NAME', HeaderName) = 0 then
      HeaderValue := pblock_findval('uri', Frq.reqpb)
    else if CompareText('SERVER_NAME', HeaderName) = 0 then
      HeaderValue := server_hostname //!yg change from D3 code
    else if CompareText('SERVER_SOFTWARE', HeaderName) = 0 then
      HeaderValue := system_version //!yg change from D3 code
    else if CompareText('ALL_HTTP', HeaderName) = 0 then
    begin
      CopyValue(PChar(AllHeaders), Result);
      Exit;
    end else if CompareText('SERVER_PORT', HeaderName) = 0 then
    begin
      CopyValue(PChar(IntToStr(conf_getglobals.Vport)), Result);
      Exit
    end else if CompareText('SERVER_PROTOCOL', HeaderName) = 0 then
      HeaderValue := pblock_findval('protocol', Frq.reqpb)
    else if CompareText('URL', HeaderName) = 0 then
      HeaderValue := pblock_findval('uri', Frq.reqpb)
    {else if CompareText('OBJECT_CONFIG', HeaderName) = 0 then
    begin
      CopyValue(PChar(Format('<pre>%s</pre><br>', [GetObjectConfig(Frq.os)])), Result);
      Exit;
    end} else
    begin
      Result := False;
      SetLastError(ERROR_INVALID_INDEX);
    end;
  end;
  try
    CopyValue(HeaderValue, Result);
  finally
    system_free(HeaderValue);
  end;
end;

function    TNsapiHttpRequestImp.GetServerVariable(const VarName: string): string;

    procedure   DoGetServerVar(var buf: pchar; bufSize: dword; retry: boolean);
    var
        errCode: dword;
    begin
        if (not InternalGetServerVariable(pchar(varName), buf, bufSize)) then begin
            strCopy(buf, '');
            errCode := GetLastError;
            if (errCode = ERROR_INSUFFICIENT_BUFFER) then begin
                if (retry) then begin
                    // the buffer was too small :
                    StrDispose(buf);
                    buf := nil;
                    // realloc the required size
                    buf := StrAlloc(bufSize);
                    // try one last time with the bigger buffer (retry = false)
                    DoGetServerVar(buf, bufSize, false);
                end; { if }
            end; { if }
        end; { if }
    end; { DoGetServerVar }

var
    buf: pchar;
begin
    buf := StrAlloc(2 * 1024);
    try
        DoGetServerVar(buf, strBufSize(buf), true);
        result := strPas(buf);
    finally
        StrDispose(buf);
    end;
end;

procedure   TNsapiHttpRequestImp.readHttpHeaders;
var
    m: TMemoryStream;
    all_http: string;
    i: integer;
    name, value: string;
    p: integer;
begin
    FHttpHeaders := TStringList.Create;
    try
        all_http := GetServerVariable('ALL_HTTP');
        // we will use TStringList's ability to load a CRLF or CR-seperated
        // list of strings from a stream :
        m := TMemoryStream.Create;
        try
            m.Write(pointer(all_http)^, length(all_http));
            m.Seek(0, soFromBeginning);
            FHttpHeaders.loadFromStream(m);
        finally
            m.free;
        end;
        // Now FHttpHeaders contains the list of headers in the form "HTTP_header: value".
        // We want to change it to "header=value", so that we can access it
        // using the TStringList.Values property :
        for i := 0 to (FHttpHeaders.Count - 1) do begin
            p := pos(':', FHttpHeaders[i]);
            if (p > 0) then begin
                name := trim(copy(FHttpHeaders[i], 1, p - 1));
                value := trim(copy(FHttpHeaders[i], p + 1, maxInt));
                if (copy(name, 1, 5) = 'HTTP_') then
                    name := copy(name, 6, maxInt);
                FHttpHeaders[i] := name + '=' + value;
            end;
        end;
    except
        on E: Exception do begin
            FHttpHeaders.free;
            FHttpHeaders := nil;
            raise Exception.Create('TNsapiHttpRequestImp.readHttpHeaders : ' + E.Message);
        end;
    end;
end;

function    TNsapiHttpRequestImp.GetHttpHeader(const HeaderName: string): string;
begin
    if (FHttpHeaders = nil) then
        readHttpHeaders;
    result := FHttpHeaders.values[headerName];
end;

function    TNsapiHttpRequestImp.MapURLToPath(const LogicalURL: string): string;
var
    Content: pchar;
begin
    Content := request_translate_uri(PChar(LogicalURL), Fsn);
    if (Content = nil) then
        result := ''
    else begin
        try
            result := StrPas(Content);
        finally
            system_free(Content);
        end;
    end;
end;

function    TNsapiHttpRequestImp.GetQueryString: string;
begin
    result := NSStr2String(pblock_findval('query', rq.reqpb));
end;

function    TNsapiHttpRequestImp.GetMethod: string;
begin
    result := NSStr2String(pblock_findval('method', rq.reqpb));
end;

function    TNsapiHttpRequestImp.GetLogicalPath: string;
begin
    result := NSStr2String(pblock_findval('path-info', rq.vars));
end;

function UnixPathToDosPath(const Path: string): string;
begin
  Result := TranslateChar(Path, '/', '\');
end;

function DosPathToUnixPath(const Path: string): string;
begin
  Result := TranslateChar(Path, '\', '/');
end;


function    TNsapiHttpRequestImp.GetPhysicalPath: string;
begin
    result := UnixPathToDosPath(NSStr2String(
      pblock_findval('path-translated', rq.vars)));
end;

end.

