library formdump;
{
    This is a port of the FORMDUMP example program included
    in the WSAPI developer's kit (as shipped with WebSite Pro).
    Port by Paul Gallagher, 1996 <paulpg@ozemail.com.au>
}

//========================================================================
// COPYRIGHT NOTICE:
//				Copyright (C) 1996, Robert B. Denny, Pasadena, California
//				All Rights Reserved
// PROPRIETARY RIGHTS NOTICE: 
//				This source code is the property of Robert B. Denny of
//				Pasadena, California, and is furnished under license only.
//========================================================================
// TITLE:		FORMDUMP.C
//
// FACILITY:	WSAPI form decoding example
//
// ABSTRACT:	This WSAPI "CGI" extension demonstrates the use of
//				the forms decoder. It will enumerate all of the fields
//				in a form and return information about each, in HTML
//				format. Both the application/x-www-form-urlencoded
//				and multipart-form-data encodings are supported by 
//				the WSAPI decoder, so either type will work.
//
// INSTALLING:	To install this WSAPI extension add a registry KEY (e.g.)
//
//		HKEY_LOCAL_MACHINE\SOFTWARE\Denny\WebServer\CurrentVersion\CGI\DLL\formdump
//
//				and under this key, add a value "ExtCgiDll", a REG_SZ, 
//				with  the name of the DLL (if it is located in the same
//				directory as the server httpd.exe, or the full physical 
//				pathname of the DLL (if it is located elsewhere). Also add
//				another value "ExtCgiEntry", a REG_SZ, with the string
//				'DumpForm' (the action routine's entry point name).
//
//
// USING:		Create a form with method=POST and set the action URL to
//
//					/~wsapi/formdump
//
//				Both URL-encoded (common) and multipart/form-data (new)
//				form encodings are supported.
//
// ENVIRONMENT:	WebSite Professional 1.0 or later, WSAPI 1.0 (or later)
//				Microsoft Windows Windows NT 3.5x, Windows 95
//				Developed under Microsoft Visual C++ Version 4.0
//
// AUTHOR:		Robert B. Denny
//
// Edit Log:
//
// When			Who		What
//----------	---		--------------------------------------------------
// 07-Mar-96	rbd		Initial edit
// 13-Apr-96	rbd		Action routine -> Process() for server-side applet
//						"clear" content-length and turn off keep-alive.
// 01-Aug-96    paulg           Port to Delphi
// 26-Jan-97    paulg           Cleanup DLL entry handling
//========================================================================

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  View-Project Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the DELPHIMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using DELPHIMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  Windows,
  WsapiReq, dialogs,
  DynWSAPI;

//
// The maximum amount of a form field to dump. Mostly useful
// for limiting the dump output size for uploaded files.
//
const
  MAX_DUMP_SIZE = 1024;

function display(b : BYTE) : Char; forward;
procedure dump_field(fp : PFIELD; tp : PTCTX); forward;

procedure writeString(reqInt: TWsapiHttpRequestImp; s: string);
begin
    ShowMessage('zzz = ' + intToStr(integer(reqInt.ftp)));
    reqInt.WriteToClient(pchar(s)^, length(s));
    nwrite(PChar(s), length(s), pointer(reqInt.ftp));
//    reqInt.WriteToClient(pchar(s)^, length(s));
end;


//========================================================================
//
// DumpForm() - Generate a dump for the given form
//
// Return TRUE if all went well, else call die() with some reasonable
// HTTP status code	depending on what happened.	NOTE: This is really
// minimalist error handling and reporting. It _is_ an example...
//========================================================================
function Process(tp : PTCTX) : Boolean; export; cdecl;
var
  fdata : PBYTE;
  ctx : FORM_CTX; // Sentinel
  fp : PFIELD;
    reqInt: TWsapiHttpRequestImp;
begin
reqInt := TWsapiHttpRequestImp.Create(pointer(tp));
  try
    tp^.keep_alive:= FALSE;				// We don't know content-length!!
    tp^.content_length := -1;
    StrPCopy(tp^.content_type,'text/html');
    writeString(reqInt, 'HTTP/1.0 200 OK'#13#10#13#10#13#10);

    writeString(reqInt, '<br>1 WSAPI ample'#13#10);
    writeString(reqInt, '<br>2 Delphi port by Paul Gallagher (gallagher.paul.p@bhp.com.au)'#13#10);
    writeString(reqInt, '<br>3 ZZZZZZ'#13#10);
    writeString(reqInt, '<br>4 ==========================================================='#13#10#13#10);
    writeString(reqInt, '<br>5 this is a test');
    //
    // Always finish with a flush!
    //
    nflush(tp);
  finally
    reqInt.free;
  end;

  Result:=True;
end;

(*
      reqInt := TWsapiHttpRequestImp.Create(pointer(tp));
    req := THttpRequest.Create(reqInt);
    res := THttpResponse.Create(req, reqInt);
  try
    writeln(res.textOut, 'hello');
  finally
    res.free;
    req.free;
    reqInt.Free;
  end;

*)

//------------------------------------------------------------------------
//
// dump_field() - Dump contents of a form field, mainframe style
//
// Limit dump size to MAX_DUMP_DATA
//------------------------------------------------------------------------
procedure dump_field(fp : PFIELD; tp : PTCTX);
var
  buf, bufr, sTemp : string;
  dlen : DWORD;
  i, j, k : integer;
  d : BYTE;
begin

  if (fp^.len > MAX_DUMP_SIZE) then dlen:=MAX_DUMP_SIZE
  else dlen:=fp^.len;

  Str(fp^.len,sTemp);
  buf :='Field "' + fp^.name + '" (' + Format('%d',[fp^.len]) +', ';
  buf:=buf + Format('0x%4.4x',[fp^.len]) + ')'#13#10;
  nputs(PChar(buf), tp);

  if (fp^.ctype[0] <> #0) then begin
    buf:='  Content-Type: ' + fp^.ctype[0] + ''#13#10;
    nputs(PChar(buf), tp);
  end;
  if (fp^.xftype[0] <> #0) then begin
    buf:='  Content-Transfer-Encoding: ' + fp^.xftype + ''#13#10;
    nputs(PChar(buf), tp);
  end;
  if (fp^.fname[0] <> #0) then begin
    buf:='  Original filename: ' + fp^.fname + ''#13#10;
    nputs(PChar(buf), tp);
  end;

  nputs(PChar('---------|-------------------------------------------------|----------------'#13#10), tp);

  i := 0;

  while (i < dlen) do begin			// While there are still bytes left
    buf:='';				// point to start of output buffer
    bufr:='';

    //
    // Print the offset leader
    //
    buf := Format('%8.8x  ',[i]);

    //
    // Print 16 bytes per row. i is index to buffer, j is
    // byte-in-row counter.
    //
    j:=16;
    while ((i < dlen) and (j > 0)) do begin
      d:= BYTE(PChar(fp^.data)[i]);
      buf:=buf + Format('%02x ',[d]);
      bufr:=bufr + display(d);
      i:=i+1;
      j:=j-1;
    end;

    //
    // If there are fewer than 16 bytes to dump on this line,
    // pad the rest of the hex field with spaces.
    //
    if j> 0 then		// j = bytes left on this line
      for k:=1 to j do buf:=buf + '   ';

    nputs(PChar(buf + '  ' + bufr + #13#10), tp);
  end;

  if (dlen < fp^.len) then begin				// Advise if dump truncated
    buf:='...dump intentionally truncated to %d (%X) bytes'#13#10;
    nputs(PChar(buf), tp);
  end;
  nputs(PChar(#13#10), tp);			// Leave space after

end;

//------------------------------------------------------------------------
//
// display() - Return safe display ascii character for byte
//
//------------------------------------------------------------------------
function display(b : BYTE) : Char;
begin
  if ((b < 32) or ((b > 127) and (b < 160)) or (b > 254)) then Result:='.'
  else Result:=char(b);
end;

exports
  Process;

{$E wsa}

begin
    LoadWSAPI;
  // module initialisation
  if not bind_wsapi(MAJOR_VERSION, MINOR_VERSION, FALSE) then
    ExitCode:=1; // cause DLL load to fail
end.
