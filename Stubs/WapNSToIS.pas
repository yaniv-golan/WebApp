unit WapNSToIS;

// This code is copied from Delphi3's NSToIS unit. Changes are marked with !yg

interface

uses SysUtils, Windows, Classes, ISAPI2, NSAPI, SyncObjs;

type

  EISAPIException = class(Exception);

  TISAPISession = class
  private
    { ISAPI Interface }
    {FISAPIApplication: TISAPIApplication;} // !yg removed
    FPathTranslated: string;
    { NSAPI Interface }
    Fpb: PPblock;
    Fsn: PSession;
    Frq: PRequest;
    Fenv: PPCharArray;
    { HSE_REQ_DONE_WITH_SESSION event }
    FEvent: TEvent;

  public
  //!yg moved from private START
    FECB: TEXTENSION_CONTROL_BLOCK;
    { ISAPI Service functions }
    function GetServerVariable(VariableName: PChar; Buffer: Pointer; var Size: DWORD): Boolean;
    function WriteClient(Buffer: Pointer; var Bytes: DWORD): Boolean;
    function ReadClient(Buffer: Pointer; var Size: DWORD): Boolean;
    function ServerSupportFunction(HSERequest: DWORD; Buffer: Pointer;
      Size: LPDWORD; DataType: LPDWORD): Boolean;
  //!yg moved from private END
    constructor Create(pb: PPblock; sn: PSession; rq: PRequest{;
      ISAPIApplication: TISAPIApplication} {!yg removed});
    destructor Destroy; override;
    {procedure ProcessExtension;} //!yg
  end;


implementation

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

function UnixPathToDosPath(const Path: string): string;
begin
  Result := TranslateChar(Path, '/', '\');
end;

function DosPathToUnixPath(const Path: string): string;
begin
  Result := TranslateChar(Path, '\', '/');
end;

function GetServerVariableProc(ConnID: HConn; VariableName: PChar;
  Buffer: Pointer; var Size: DWORD): BOOL; stdcall;
begin
  if ConnID <> 0 then
    Result := TISAPISession(ConnID).GetServerVariable(VariableName, Buffer, Size)
  else
  begin
    Result := False;
    SetLastError(ERROR_INVALID_PARAMETER);
  end;
end;

function WriteClientProc(ConnID: HConn; Buffer: Pointer; var Bytes: DWORD;
  dwReserved: DWORD): BOOL; stdcall;
begin
  if ConnID <> 0 then
    Result := TISAPISession(ConnID).WriteClient(Buffer, Bytes)
  else
  begin
    Result := False;
    SetLastError(ERROR_INVALID_PARAMETER);
  end;
end;

function ReadClientProc(ConnID: HConn; Buffer: Pointer;
  var Size: DWORD): BOOL; stdcall;
begin
  if ConnID <> 0 then
    Result := TISAPISession(ConnID).ReadClient(Buffer, Size)
  else
  begin
    Result := False;
    SetLastError(ERROR_INVALID_PARAMETER);
  end;
end;

function ServerSupportProc(ConnID: HConn; HSERequest: DWORD; Buffer: Pointer;
  Size: LPDWORD; DataType: LPDWORD): BOOL; stdcall;
begin
  if ConnID <> 0 then
    Result := TISAPISession(ConnID).ServerSupportFunction(HSERequest, Buffer,
      Size, DataType)
  else
  begin
    Result := False;
    SetLastError(ERROR_INVALID_PARAMETER);
  end;
end;


function MakeValid(Str: PChar): PChar;
begin
  if Str = nil then
    Result := ''
  else Result := Str;
end;

procedure LogMessage(const Fmt: string; Params: array of const);
begin
  {ISAPIApplicationList.LogMessage(Fmt, Params);} // !yg
end;


const
  DocumentMoved =
    '<head><title>Document moved</title></head>' +
    '<body><h1>Object Moved</h1>' +
    'This document may be found <a HREF="%s">here</a></body>'#13#10;

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

{ TISAPISession }

constructor TISAPISession.Create(pb: PPblock; sn: PSession; rq: PRequest{;
  ISAPIApplication: TISAPIApplication} {!yg removed});
var
  Temp: PChar;
begin
  Fpb := pb;
  Fsn := sn;
  Frq := rq;
  // FISAPIApplication := ISAPIApplication; !yg
  FEvent := TSimpleEvent.Create;
  with FECB do
  begin
    cbSize := SizeOf(FECB);
    dwVersion := MAKELONG(HSE_VERSION_MINOR, HSE_VERSION_MAJOR);
    ConnID := THandle(Self);
    lpszMethod := MakeValid(pblock_findval('method', rq.reqpb));
    lpszQueryString := MakeValid(pblock_findval('query', rq.reqpb));
    lpszPathInfo := MakeValid(pblock_findval('path-info', rq.vars));
    FPathTranslated := UnixPathToDosPath(NSstr2String(
      pblock_findval('path-translated', rq.vars)));
    lpszPathTranslated := PChar(FPathTranslated);
    lpszContentType := MakeValid(pblock_findval('content-type', rq.headers));
    Temp := pblock_findval('content-length', rq.headers);
    try
      cbTotalBytes := StrToIntDef(MakeValid(Temp), 0);
    finally
      system_free(Temp);
    end;
    with Fsn.inbuf^ do
    begin
      while (inbuf[pos] in [#13,#10]) and (pos < cursize) do Inc(pos);
      cbAvailable := cursize - pos;
      if cbTotalBytes < cbAvailable then
        cbTotalBytes := cbAvailable;
      GetMem(lpbData, cbAvailable);
      Move(inbuf[pos], lpbData^, cbAvailable);
    end;
    GetServerVariable := GetServerVariableProc;
    WriteClient := WriteClientProc;
    ReadClient := ReadClientProc;
    ServerSupportFunction := ServerSupportProc;
  end;
end;

destructor TISAPISession.Destroy;

  procedure FreeStr(Str: PChar);
  begin
    if (Str <> nil) and (Str^ <> #0) then
      system_free(Str);
  end;

begin
  with FECB do
  begin
    FreeStr(lpszMethod);
    FreeStr(lpszQueryString);
    FreeStr(lpszPathInfo);
    FreeStr(lpszContentType);
    FreeMem(lpbData);
  end;
  if Fenv <> nil then util_env_free(Fenv);
  FEvent.Free;
  inherited Destroy;
end;

function TISAPISession.GetServerVariable(VariableName: PChar; Buffer: Pointer;
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
  begin
    InitEnv;
    P := Fenv;
    Result := '';
    I := 0;
    while P^[I] <> nil do
    begin
      Result := Format('%s%s'#13#10, [Result, TranslateChar(P^[I], '=', ':')]);
      Inc(I);
    end;
  end;

begin
  // Check if this is a request for an HTTP header
  if VariableName = nil then VariableName := 'BAD';
  LogMessage('GetServerVariable(%s, $%p, %d)'#13#10, [VariableName, Buffer, Size]); 
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
      HeaderValue := system_version
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
    else if CompareText('OBJECT_CONFIG', HeaderName) = 0 then
    begin
      CopyValue(PChar(Format('<pre>%s</pre><br>', [GetObjectConfig(Frq.os)])), Result);
      Exit;
    end else
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

function TISAPISession.WriteClient(Buffer: Pointer; var Bytes: DWORD): Boolean;
var
  nWritten: Integer;
begin
  LogMessage('WriteClient($%p, %d)'#13#10, [Buffer, Bytes]);
  nWritten := net_write(Fsn.csd, Buffer, Bytes);
  Result := not (nWritten < Bytes) and not (nWritten = IO_ERROR);
  Bytes := nWritten;
end;

function TISAPISession.ReadClient(Buffer: Pointer; var Size: DWORD): Boolean;
var
  nBuf, nRemaining: Integer;
begin
  LogMessage('ReadClient($%p, %d)'#13#10, [Buffer, Size]); 
  nRemaining := Size;
  while nRemaining > 0 do
  begin
    with Fsn.inbuf^ do
      if pos < cursize then
      begin
        nBuf := cursize - pos;
        if nBuf > Size then nBuf := Size;
        Move(inbuf[pos], Buffer, nBuf);
        Inc(pos, nBuf);
        Dec(nRemaining, nBuf);
        Inc(Integer(Buffer), nBuf);
      end else
      begin
        nBuf := net_read(Fsn.csd, Buffer, nRemaining, NET_READ_TIMEOUT);
        if nBuf = IO_ERROR then Break;
        Dec(nRemaining, nBuf);
      end;
  end;
  if nRemaining = 0 then
    Result := True
  else Result := False;
  Size := Size - nRemaining;
end;

function TISAPISession.ServerSupportFunction(HSERequest: DWORD; Buffer: Pointer;
  Size: LPDWORD; DataType: LPDWORD): Boolean;
var
  Content: PChar;
  ContentLen: Integer;
  ContentStr: string;

  // This function will parse out any ISAPI application supplied headers and
  // place them into the appropriate parameter block.
  function SkipHeaders(Content: PChar): PChar;
  var
    T: array[0..REQ_MAX_LINE - 1] of Char;
    pb: PPblock;
    NetBuf: TNetBuf;
  begin
    if Content <> nil then
    begin
      pb := pblock_create(10);
      try
        FillChar(NetBuf, SizeOf(NetBuf), 0);
        with NetBuf do
        begin
          cursize := StrLen(Content);
          maxSize := curSize;
          inbuf := Content;
        end;
        http_scan_headers(nil, @NetBuf, T, pb);
        pblock_copy(pb, Frq.srvhdrs);
        // Skip past the headers if present
        Inc(Content, NetBuf.pos);
        Result := Content;
      finally
        pblock_free(pb);
      end;
    end else Result := Content;
  end;

  procedure SetStatus(StatusStr: PChar);
  var
    StatusCode: Integer;
    I: Integer;
  begin
    if StatusStr = nil then
      StatusCode := PROTOCOL_OK
    else
    begin
      StatusCode := StrToIntDef(Copy(StatusStr, 1, 3), PROTOCOL_OK);
      for I := 0 to 3 do
      begin
        if StatusStr[0] = #0 then Break;
        Inc(StatusStr);
      end;
    end;
    http_status(Fsn, Frq, StatusCode, StatusStr);
  end;

begin
  case HSERequest of
    HSE_REQ_SEND_RESPONSE_HEADER:
      begin
        if DataType <> nil then
          Content := PChar(Datatype)
        else Content := '#0';
        if Size <> nil then
          LogMessage('ServerSupportFunction(HSE_REQ_SEND_RESPONSE_HEADER' +
            ', $%p, %d, %s)'#13#10, [Buffer, Size^, Content])
        else LogMessage('ServerSupportFunction(HSE_REQ_SEND_RESPONSE_HEADER' +
            ', $%p, nil, %s)'#13#10, [Buffer, Content]);
        SetStatus(PChar(Buffer));
        param_free(pblock_remove('content-type', Frq.srvhdrs));
        param_free(pblock_remove('content-length', Frq.srvhdrs));
        Content := SkipHeaders(PChar(DataType));
        ContentLen := StrLen(Content);
        Result := True;
        if http_start_response(Fsn, Frq) <> REQ_NOACTION then
        begin
          if (Content <> nil) and (Content[0] <> #0) then
            if net_write(Fsn.csd, Content, ContentLen) < ContentLen then
              Result := False;
        end else Result := False;
      end;
    HSE_REQ_SEND_URL_REDIRECT_RESP:
      begin
        if Size <> nil then
          LogMessage('ServerSupportFunction(HSE_REQ_SEND_URL_REDIRECT_RESP' +
            ', %s, %d)'#13#10, [PChar(Buffer), Size^])
        else LogMessage('ServerSupportFunction(HSE_REQ_SEND_URL_REDIRECT_RESP' +
            ', %s, nil)'#13#10, [PChar(Buffer)]);
        http_status(Fsn, Frq, PROTOCOL_REDIRECT, 'Object moved');
        param_free(pblock_remove('content-type', Frq.srvhdrs));
        param_free(pblock_remove('content-length', Frq.srvhdrs));
        if Buffer <> nil then
        begin
          pblock_nvinsert('Location', PChar(Buffer), Frq.srvhdrs);
          ContentStr := Format(DocumentMoved, [PChar(Buffer)]);
          ContentLen := Length(ContentStr);
          pblock_nvinsert('content-type', 'text/html', Frq.srvhdrs);
          pblock_nninsert('content-length', ContentLen, Frq.srvhdrs);
          Result := True;
          if http_start_response(Fsn, Frq) <> REQ_NOACTION then
          begin
            if net_write(Fsn.csd, PChar(ContentStr), ContentLen) < ContentLen then
              Result := False;
          end else Result := False;
        end else raise EISAPIException.Create('Invalid Redirect parameter');
      end;
    HSE_REQ_SEND_URL:
      begin
        Result := False;
      end;
    HSE_REQ_MAP_URL_TO_PATH:
      begin
        Result := True;
        Content := request_translate_uri(Buffer, Fsn);
        if Content <> nil then
        try
          StrPLCopy(Buffer, Content, Size^);
          if Size^ < StrLen(Content) + 1 then
          begin
            Result := False;
            SetLastError(ERROR_INSUFFICIENT_BUFFER);
          end;
        finally
          system_free(Content);
        end else
        begin
          Result := False;
          SetLastError(ERROR_NO_DATA);
        end;
      end;
    HSE_REQ_DONE_WITH_SESSION:
      begin
        FEvent.SetEvent;
        Result := True;
      end;
  else
    Result := False;
  end;
end;

(* !yg
procedure TISAPISession.ProcessExtension;
begin
  LogMessage('ProcessExtension -- Application: %s'#13#10, [FISAPIApplication.FFileName]);
  if Assigned(FISAPIApplication.HTTPExtensionProc) then
    case FISAPIApplication.HTTPExtensionProc(FECB) of
      HSE_STATUS_ERROR: raise EISAPIException.Create('ISAPI Application Error');
      HSE_STATUS_PENDING: FEvent.WaitFor(INFINITE);
    end;
end;
*)

end.
