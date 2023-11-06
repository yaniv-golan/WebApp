unit NsapiSupport2;

interface

uses Classes, SysUtils, Windows,
  DynNSAPI
  ;

function NsapiInit(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
function NsapiService(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
function NsapiPathCheck(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
function NsapiLog(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
function NsapiNameTrans(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;

implementation

uses
    StubUtils,
    NSAPIReq
  ;

function GetDocumentRoot(os: PHttpdObjSet): string;
var
  obj: PHttpdObject;
  dt: PDtable;
  dir: PDirective;
  I, J: Integer;
begin
  Result := '';
  if os <> nil then
  begin
    obj := objset_findbyname('default', nil, os);
    if obj <> nil then
    begin
      dt := obj.dt;
      for I := 0 to obj.nd - 1 do
      begin
        dir := dt.inst;
        for J := 0 to dt.ni - 1 do
        begin
          if (dir <> nil) and (dir.param <> nil) then
            if CompareText(NSstr2String(pblock_findval('fn', dir.param)), 'document-root') = 0 then
            begin
              Result := NSstr2String(pblock_findval('root', dir.param));
              Exit;
            end;
          Inc(dir);
        end;
        Inc(dt);
      end;
    end;
  end;
end;

procedure   HandleNsapiException(Request: TNsapiHttpRequestImp; E: Exception);
begin
    param_free(pblock_remove('content-type', Request.RQ.srvhdrs));
    pblock_nvinsert('content-type', 'text/html', Request.RQ.srvhdrs);
    HandleException(Request, E, 'HandleNsapiException');
end;

const
  sInternalServerError = '<html><title>Internal Server Error 500</title>'#13#10 +
    '<h1>Internal Server Error 500</h1><hr>'#13#10 +
    'Exception: %s<br>'#13#10 +
    'Message: %s<br></html>'#13#10;



function HandleServerException(E: Exception; pb: PPblock; sn: PSession; rq: Prequest): Integer;
var
    ResultText: string;
    ContentLen: Integer;
begin
    http_status(sn, rq, PROTOCOL_SERVER_ERROR, PChar(E.Message));
    ResultText := Format(sInternalServerError, [E.ClassName, E.Message]);
    ContentLen := Length(ResultText);
    param_free(pblock_remove('content-type', rq.srvhdrs));
    pblock_nvinsert('content-type', 'text/html', rq.srvhdrs);
    pblock_nninsert('content-length', ContentLen, rq.srvhdrs);
    if http_start_response(sn, rq) <> REQ_NOACTION then
        net_write(sn.csd, PChar(ResultText), ContentLen);
    Result := REQ_ABORTED;
end;

// for debugging
procedure dumpPBlock(block: pblock; const fn: String);
var
    f: textFile;
    entry: PPbEntry;
begin
    assignFile(f, fn);
    rewrite(f);
    try
        if (@block = nil) then begin
            writeln(f, 'block is nil');
            exit;
        end;
        entry := block.ht^;
        while (entry <> nil) do begin
            if (entry.param = nil) then begin
                writeln(f, 'entry param is nil');
            end else begin
                writeln(f, entry.param.name, ' = ', entry.param.value);
            end;
            entry := entry.next;
        end;
    finally
        closeFile(f);
    end;
end;

procedure terminate_webapp(parameter: Pointer); cdecl; export;
begin
    LoadNSAPI;
end;

function NsapiInit(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
begin
    LoadNSAPI;
    magnus_atrestart(terminate_webapp, nil);
    Result := REQ_PROCEED;
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

function UnixPathToDosPath(const Path: string): string;
begin
  Result := TranslateChar(Path, '/', '\');
end;

function DosPathToUnixPath(const Path: string): string;
begin
  Result := TranslateChar(Path, '\', '/');
end;

function NsapiService(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
var
    Request: TNsapiHttpRequestImp;
begin
    result := REQ_PROCEED;
    try
        LoadNSAPI;
        Request := TNsapiHttpRequestImp.Create(pb, sn, rq);
        try
            try
                DispatchToWapStub(Request);
            except
                on e: exception do begin
                    HandleNsapiException(Request, e);
                    protocol_status(sn, rq, PROTOCOL_SERVER_ERROR, 'Internal Server Error');
                end;
            end;
        finally
            Request.Free;
        end;
    except
        on e: exception do begin
            protocol_status(sn, rq, PROTOCOL_SERVER_ERROR, 'Internal Server Error');
        end;
    end; { we do not want exception to get back to the server! }
end;

function NsapiNameTrans(pb: PPblock; sn: PSession; rq: Prequest): Integer;
begin
    try
        LoadNSAPI;
        param_free(pblock_remove('ppath', rq.vars));
        pblock_nvinsert('ppath', 'c:\autoexec.bat', rq.vars);
        Result := REQ_PROCEED;
    except
        on e: exception do begin
            HandleServerException(E, pb, sn, rq);
            protocol_status(sn, rq, PROTOCOL_SERVER_ERROR, 'Internal Server Error');
            Result := REQ_ABORTED;
        end;
    end;
end;

function NsapiPathCheck(pb: PPblock; sn: PSession; rq: Prequest): Integer;
var
  PathInfo: string;
begin
    try
        LoadNSAPI;
        PathInfo := NSstr2String(pblock_findval('path-info', rq.vars));
        pblock_nvinsert('path-translated', PChar(GetDocumentRoot(rq.os) + PathInfo), rq.vars);
        Result := REQ_PROCEED;
    except
        on e: exception do begin
            HandleServerException(E, pb, sn, rq);
            protocol_status(sn, rq, PROTOCOL_SERVER_ERROR, 'Internal Server Error');
            Result := REQ_ABORTED;
        end;
    end;
end;

function NsapiLog(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
begin
    LoadNSAPI;
    result := REQ_PROCEED;
end;

end.
