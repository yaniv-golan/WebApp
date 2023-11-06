/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996, 1997 by HyperAct, Inc.
// All Rights Reserved.
//
// This is a subset of the \Delphi\Source\Rtl\Win\NSAPI.PAS unit.
// This version links dynamically to ns-httpd20.dll
/////////////////////////////////////////////////////////////////////////////
unit DynNSAPI;

interface

uses Windows, WinSock;

// Call before accessing procs!
procedure LoadNSAPI;

{*****************************************************************************}
{* From net.h                                                                 }
{*****************************************************************************}
{
  system specific networking definitions
}

const
{* This should be a user-given parameter later *}
  NET_BUFFERSIZE = 8192;
{* So should this. *}
  NET_READ_TIMEOUT = 120;
  NET_WRITE_TIMEOUT = 300;
  NET_INFINITE_TIMEOUT = 0;
  NET_ZERO_TIMEOUT = -1;

  SSL_HANDSHAKE_TIMEOUT = 300;

{* ------------------------------ Data types ------------------------------ *}
type
  SYS_NETFD = Integer;

const
  SYS_NET_ERRORFD = (-1);



{*****************************************************************************}
{* From pblock.h                                                              }
{*****************************************************************************}
{
  pblock.h: Header for Parameter Block handling functions

  A parameter block is a set of name=value pairs which are generally used
  as parameters, but can be anything. They are kept in a hash table for
  reasonable speed, but if you are doing any intensive modification or
  access of them you should probably make a local copy of each parameter
  while working.

  When creating a pblock, you specify the hash table size for that pblock.
  You should set this size larger if you know that many items will be in
  that pblock, and smaller if only a few will be used or if speed is not
  a concern.

  The hashing function is very simple right now, and only looks at the
  first character of name.

}

{* ------------------------------ Structures ------------------------------ *}


type
  PPbParam = ^TPbParam;
  TPbParam = record
    name: PChar;
    value: PChar;
  end;
  pb_param = TPbParam;

  PPbEntry = ^TPbEntry;
  TPbEntry = record
    param: PPbParam;
    next: PPbEntry;
  end;
  pb_entry = TPbEntry;
  PPPbEntry = ^PPbEntry;

  PPblock = ^TPblock;
  TPblock = record
    hsize: Integer;
    ht: PPPbEntry;
  end;
  pblock = TPblock;

  TPCharArray = array[0..MaxInt div 16 - 1] of PChar;
  PPCharArray = ^TPCharArray;

{*****************************************************************************}
{* From sem.h                                                                 }
{*****************************************************************************}
{
  Attempt to provide multi-process semaphores across platforms
}

type
  Semaphore = THandle;

const
  SEM_ERROR    = 0;
  {* That oughta hold them (I hope) *}
  SEM_MAXVALUE = 32767;

  
{*****************************************************************************}
{* From file.h                                                                }
{*****************************************************************************}
{
  system specific functions for reading/writing files
}

{
  I cheat: These are set up such that system_read can be a macro for read
  under UNIX. IO_OKAY is anything positive.
}

const
  IO_OKAY = 1;
  IO_ERROR = -1;
  IO_EOF = 0;

{* -------------------------- File related defs --------------------------- *}

{* The disk page size on this machine. *}
  FILE_BUFFERSIZE = 4096;

{
  The fd data type for this system.
}

type
  SYS_FILE = ^TFile;
  TFile = record
    fh: THandle;
	fname: PChar;
    flsem: Semaphore;
  end;
  file_s = TFile;

const
  SYS_ERROR_FD = nil;
  SYS_STDERR = nil;

type
  pid_t = THandle;
  TPid = pid_t;

const
  ERROR_PIPE = ERROR_BROKEN_PIPE or ERROR_BAD_PIPE or ERROR_PIPE_BUSY or
    ERROR_PIPE_LISTENING or ERROR_PIPE_NOT_CONNECTED;

{!!! uses errno from C RTL }
{ #define rtfile_notfound() ((errno == ENOENT) || (errno == ESRCH)) }

const
  FILE_PATHSEP = '/';
  FILE_PARENT  = '..\';

{
  Wrapper for stat system call
}
type
  PStat = ^TStat;
  TStat = record
    st_dev: Word;
    st_ino: Word;
    st_mode: Word;
    st_nlink: SmallInt;
    st_uid: SmallInt;
    st_gid: SmallInt;
    st_rdev: Word;
    st_size: Longint;
    st_atime: Longint;
    st_mtime: Longint;
    st_ctime: Longint;
  end;
  Stat = TStat;

  
{*****************************************************************************}
{* From buffer.h                                                              }
{*****************************************************************************}
{
  For performing buffered I/O on a file or socket descriptor.

  This is an abstraction to allow I/O to be performed regardless of the
  current system. That way, an integer file descriptor can be used under
  UNIX but a stdio FILE structure could be used on systems which don't
  support that or don't support it as efficiently.

  Two abstractions are defined: A file buffer, and a network buffer. A
  distinction is made so that mmap() can be used on files (but is not
  required). Also, the file buffer takes a file name as the object to
  open instead of a file descriptor. A lot of the network buffering
  is almost an exact duplicate of the non-mmap file buffering.

  If an error occurs, system-independent means to obtain an error string
  are also provided. However, if the underlying system is UNIX the error
  may not be accurate in a threaded environment.
}

{* ------------------------------ Structures ------------------------------ *}

type
  PFileBuffer = ^TFileBuffer;
  TFileBuffer = record
    fd: SYS_FILE;
    fdmap: THandle;
    fp: PChar;
    len: Integer;
    inbuf: PChar;   // for buffer_grab
    cursize: Integer;
    pos: Integer;
    errmsg: PChar;
  end;
  filebuffer = TFileBuffer;
  filebuf = filebuffer;

  PNetBuf = ^TNetBuf;
  TNetBuf = record
    sd: SYS_NETFD;
    pos,
    cursize,
    maxsize,
    rdtimeout: Integer;
    address: array[0..63] of Char;
    inbuf: PChar;
    errmsg: PChar;
  end;
  netbuf = TNetBuf;

{*****************************************************************************}
{* From pool.h                                                                }
{*****************************************************************************}
{
  Module for handling memory allocations.

  Notes:
  This module is used instead of the NSPR prarena module because the prarenas
  did not fit as cleanly into the existing server.
}

type
  pool_handle_t = Pointer;
  TPoolHandle = pool_handle_t;
  PPoolHandle = ^TPoolHandle;

{*****************************************************************************}
{* From object.h                                                              }
{*****************************************************************************}
{
  Handle httpd objects

  Manages information about a document from config. files. Called mainly
  by objset.c.

  This module does not assume anything about the directives being parsed.
  That is handled by objset.c.

  This module requires the pblock module from the base library.
}

{* ------------------------------ Structures ------------------------------ *}

{
  Hierarchy of httpd_object

  An object contains dtables.

  Each dtable is a table of directives that were entered of a certain type.
  There is one dtable for each unique type of directive.

  Each dtable contains an array of directives, each of which is equivalent
  to one directive that occurred in a config. file.

  It is up to the caller to determine how many dtables will be allocated
  and to keep track of which of their directive types maps to which dtable
  number.
}

type
{
  directive is a structure containing the protection and parameters to an
  instance of a directive within an httpd_object.

  param is the parameters, client is the protection.
}
  PDirective = ^TDirective;
  TDirective = record
    param: PPblock;
    client: PPblock;
  end;
  directive = TDirective;

{
  dtable is a structure for creating tables of directives
}
  PDtable = ^TDtable;
  TDtable = record
    ni: Integer;
    inst: PDirective;
  end;
  dtable = TDtable;

{
  The httpd_object structure.

  The name pblock array contains the names for this object, such as its
  virtual location, its physical location, or its identifier.

  tmpl contains any templates allocated to this object.
}
  PHttpdObject = ^THttpdObject;
  THttpdObject = record
    name: PPblock;
    nd: Integer;
    dt: PDtable;
  end;
  httpd_object = THttpdObject;
  
{*****************************************************************************}
{* From objset.h                                                              }
{*****************************************************************************}
{
  Handles object sets

  Each object is produced by reading a config file of some form. See the
  server documentation for descriptions of the directives that are
  recognized, what they do, and how they are parsed.

  This module requires the pblock and buffer modules from the base library.
}

{* ------------------------------ Constants ------------------------------- *}

const
{
  The default number of objects to leave room for in an object set,
  and the number of new entries by which to increase the size when that
  room is filled.
}
  OBJSET_INCSIZE = 8;

{
  When parsing config. files, httpd will put a limit on how long
  the parameters to a directive can be (in characters).

  Currently set to 10 lines (80 chars/line).
}
  MAX_DIRECTIVE_LEN = 800;

{
  The size of the hash tables that store a directive's parameters
}
  PARAMETER_HASH_SIZE = 3;

{* ------------------------------ Structures ------------------------------ *}

{
  httpd_objset is a container for a bunch of objects. obj is a
  NULL-terminated array of objects. pos points to the entry after the last
  one in the array. You should not mess with pos, but can read it to find
  the last entry.

  The initfns array is a NULL-terminated array of the Init functions
  associated with this object set. If there are no Init functions associated
  with this object set, initfns can be NULL. Each pblock specifies the
  parameters which are passed to the function when it's executed.
}

type
  PHttpdObjSet = ^THttpdObjSet;
  THttpdObjSet = record
    pos: Integer;
    obj: ^PHttpdObject;
    initfns: ^PPblock;
  end;
  httpd_objset = THttpdObjSet;

  
{*****************************************************************************}
{* From session.h                                                             }
{*****************************************************************************}
{
  Deals with virtual sessions

  A session is the time between when a client connects and when it
  disconnects. Several requests may be handled in one session.
}

{* ------------------------------ Structures ------------------------------ *}

const
  SESSION_HASHSIZE = 5;

type
  PSession = ^TSession;
  TSession = record
    {* Client-specific information *}
    client: PPblock;
    csd: SYS_NETFD;
    inbuf: PNetBuf;
    csd_open: Integer;
    iaddr: TInAddr;
    pool: PPoolHandle;
    clauth: Pointer;   {* ACL client authentication information *}
  end;
  Session = TSession;

{*****************************************************************************}
{* From req.h                                                                 }
{*****************************************************************************}
{
  Request-specific data structures and functions
}

{* ------------------------------ Constants ------------------------------- *}

const
  REQ_HASHSIZE = 10;
  REQ_MAX_LINE = 4096;

{
  The REQ_ return codes. These codes are used to determine what the server
  should do after a particular module completes its task.

  Func type functions return these as do many internal functions.
}

{* The function performed its task, proceed with the request *}
  REQ_PROCEED = 0;
{* The entire request should be aborted: An error occurred *}
  REQ_ABORTED = -1;
{* The function performed no task, but proceed anyway. *}
  REQ_NOACTION = -2;
{* Tear down the session and exit *}
  REQ_EXIT = -3;
{* Restart the entire request-response process *}
  REQ_RESTART = -4;


{* ------------------------------ Structures ------------------------------ *}


type
  PRequest = ^TRequest;
  TRequest = record
    {* Server working variables *}
    vars: PPblock;
    {* The method, URI, and protocol revision of this request *}
    reqpb: PPblock;
    {* Protocol specific headers *}
    loadhdrs: Integer;
    headers: PPblock;
    {* Server's response headers *}
    senthdrs: Integer;
    srvhdrs: PPblock;
    {* The object set constructed to fulfill this request *}
    os: PHttpdObjSet;
    {* Array of objects that were created from .nsconfig files *}
    tmpos: PHttpdObjSet;
    {* The stat last returned by request_stat_path *}
    statpath: PChar;
    staterr: PChar;
    finfo: PStat;
    {* access control state *}
    aclstate: Integer;	{* ACL decision state *}
    acldirno: Integer;	{* deciding ACL directive number *}
    aclname: PChar;		{* name of deciding ACL *}
    aclpb: PPblock;     {* parameter block for ACL PathCheck *}
    request_is_cacheable: BOOL;   {* default TRUE *}
    directive_is_cacheable: BOOL; {* default FALSE *}

    cached_headers: PChar;
    cached_headers_len: Integer;  {* length of the valid headers *}
    cached_date_header: PChar;
  end;
  Request = TRequest;
const

{*****************************************************************************}
{* From systems.h                                                             }
{*****************************************************************************}
{
  Lists of defines for systems
  This sets what general flavor the system is (UNIX, etc.),
  and defines what extra functions your particular system needs.
}

  DAEMON_LISTEN_SIZE = 100;

type
  PASSWD = Pointer;
  PPASSWD = ^PASSWD;
  TCAddr = PChar; {caddr_t}
  caddr_t = TCAddr;
  TAtRestart = procedure (Data: Pointer) cdecl;
  TMagnusAtRestart = TAtRestart;
  TDaemonAtRestart = TAtRestart;

  
{*****************************************************************************}
{* From conf.h                                                                }
{*****************************************************************************}
{
  conf.h: Deals with the server configuration file.

  Object configuration is an entirely different matter. This deals with
  things like what port the server runs on, how many children it spawns,
  and other server-related issues. Information related configuration is
  handled by the object conf.
}

{* ------------------------------ Constants ------------------------------- *}

const
{* The longest line in the configuration file *}
  CONF_MAXLEN = 16384;
  DEFAULT_PORT = 80;
  DEFAULT_POOL_MAX = 50;

{* ------------------------------- Globals -------------------------------- *}

{
  These server parameters are made global because they really don't
  belong anywhere else.
}

{* These can't be macros because they're used in daemon.h. */
extern char *pidfn;
extern int port;
extern char *chr;

#ifdef NET_SSL
extern char *secure_keyfn;
extern char *secure_certfn;
extern int secure_auth;
#endif}

type
  PConfGlobalVars = ^TConfGlobalVars;
  TConfGlobalVars = record
    {* What port we listen to *}
    Vport: Integer;
    {* What address to bind to *}
    Vaddr: PChar;
    {* User to run as *}
    Vuserpw: PPASSWD;
    {* Directory to chroot to *}
    Vchr: PChar;
    {* Where to log our pid to *}
    Vpidfn: PChar;
    {* The maximum number of processes to keep in the pool *}
    Vpool_max: Integer;
    {* The minimum number of processes to keep in the pool *}
    Vpool_min: Integer;
    {* The maximum number of requests each process should handle. -1=default *}
    Vpool_life: Integer;
    {* For multiprocess UNIX servers, the maximum threads per process *}
    Vpool_maxthreads: Integer;
    {* For multiprocess UNIX servers, the minimum threads per process *}
    Vpool_minthreads: Integer;
{$ifdef NET_SSL}
    Vsecure_keyfn: PChar;
    Vsecure_certfn: PChar;
    Vsecurity_active: Integer;
    Vssl3_active: Integer;
    Vssl2_active: Integer;
    Vsecure_auth: Integer;
    Vsecurity_session_timeout: Integer;
    Vssl3_session_timeout: Longint;
{$endif} {* NET_SSL *}
    {* The server's hostname as should be reported in self-ref URLs *}
    Vserver_hostname: PChar;
    {* The main object from which all are derived *}
    Vroot_object: PChar;
    {* The object set the administrator has asked us to load *}
    Vstd_os: PHttpdObjSet;
    {* The root of ACL data structures *}
    Vacl_root: Pointer;
    {* The main error log, where all errors are logged *}
    Vmaster_error_log: PChar;
    {* The server root ( in which the server sits while executing ) *}
    Vserver_root: PChar;
    {* This server's id *}
    Vserver_id: PChar;
  end;
  conf_global_vars_s = TConfGlobalVars;
  
{*****************************************************************************}
{* From http.h                                                                }
{*****************************************************************************}
{
  Deals with HTTP-related issues
}

{* ------------------------------ Constants ------------------------------- *}

const
  HTTP_DATE_LEN = 128;
  HTTP_DATE_FMT = '%A, %d-%b-%y %H:%M:%S GMT';

{ Number of seconds to allow a second request to come over a persistent
  connection, zero to disable *}
  HTTP_DEFAULT_KEEPALIVE_TIMEOUT = 15;

{* The maximum number of RFC-822 headers we'll allow *}
{* This would be smaller if a certain browser wasn't so damn stupid. *}
  HTTP_MAX_HEADERS = 200;

{* HTTP status codes *}
  PROTOCOL_OK = 200;
  PROTOCOL_CREATED = 201;
  PROTOCOL_NO_RESPONSE = 204;
  PROTOCOL_PARTIAL_CONTENT = 206;
  PROTOCOL_REDIRECT = 302;
  PROTOCOL_NOT_MODIFIED = 304;
  PROTOCOL_BAD_REQUEST = 400;
  PROTOCOL_UNAUTHORIZED = 401;
  PROTOCOL_FORBIDDEN = 403;
  PROTOCOL_NOT_FOUND = 404;
  PROTOCOL_PROXY_UNAUTHORIZED = 407;
  PROTOCOL_SERVER_ERROR = 500;
  PROTOCOL_NOT_IMPLEMENTED = 501;

{$ifdef NET_SSL}
  HTTPS_PORT = 443;
  HTTPS_URL = 'https';
{$endif}
  HTTP_PORT = 80;
  HTTP_URL = 'http';

var
http_start_response: function (sn: PSession; rq: PRequest): Integer; cdecl;
util_env_free: procedure (env: PPCharArray); cdecl;
net_read: function (sd: SYS_NETFD; buf: PChar; sz, timeout: Integer): Integer; cdecl;
net_isalive: function (sd: SYS_NETFD): BOOL; cdecl;
net_write: function (sd: SYS_NETFD; buf: PChar; sz: Integer): Integer; cdecl;
param_free: function (pp: PPbParam): Integer; cdecl;
pblock_findval: function (name: PChar; pb: PPblock): PChar; cdecl;
system_free: procedure (ptr: Pointer); cdecl;
pblock_pblock2str: function (pb: PPblock; str: PChar): PChar; cdecl;
util_env_create: function (env: PPCharArray; n: Integer; var pos: Integer): PPCharArray; cdecl;
util_env_str: function (name, value: PChar): PChar; cdecl;
http_hdrs2env: function (pb: PPblock): PPCharArray; cdecl;
shexp_cmp: function (str, exp: PChar): Integer; cdecl;
shexp_casecmp: function (str, exp: PChar): Integer; cdecl;
util_env_find: function (env: PPCharArray; name: PChar): PChar; cdecl;
conf_getglobals: function : PConfGlobalVars; cdecl;
system_version: function : PChar; cdecl;
request_translate_uri: function (uri: PChar; sn: PSession): PChar; cdecl; //
http_status: procedure (sn: PSession; rq: PRequest; n: Integer; r: PChar); cdecl;
protocol_status: procedure (sn: PSession; rq: PRequest; n: Integer; r: PChar); cdecl; //
pblock_nvinsert: function (name, value: PChar; pb: PPblock): PPbParam; cdecl;
pblock_nninsert: function (name: PChar; value: Integer; pb: PPblock): PPbParam; cdecl;
magnus_atrestart: procedure (fn: TMagnusAtRestart; data: Pointer); cdecl;
objset_findbyname: function (name: PChar; ign, os: PHttpdObjSet): PHttpdObject; cdecl;
_pblock_fr: function (name: PChar; pb: PPblock; remove: BOOL): PPbParam; cdecl;
session_dns_lookup: function (sn: PSession; verify: BOOL): PChar; cdecl;

function session_dns(sn: PSession): PChar; cdecl;
function pblock_remove(name: PChar; pb: PPblock): PPbParam; cdecl; //

function NSstr2String(nsStr: PChar): string;

function server_hostname: PChar;

implementation

uses SysUtils, XcptTrc;

function NSstr2String(nsStr: PChar): string;
begin
  Result := nsStr;
  system_free(nsStr);
end;

function pblock_remove(name: PChar; pb: PPblock): PPbParam;
begin
  Result := _pblock_fr(name,pb,True);
end;

function server_hostname: PChar;
begin
  Result := conf_getglobals.Vserver_hostname;
end;

function session_dns(sn: PSession): PChar;
begin
  Result := session_dns_lookup(sn, False);
end;

var
    ModuleHandle: THandle = 0;

procedure LoadNsapiDLL;
var
    Ver20Err: dword;
    Ver30Err: dword;
begin
    try
        ModuleHandle := GetModuleHandle('ns-httpd30.dll');
        if (ModuleHandle = 0) then begin
            Ver30Err := GetLastError;
            ModuleHandle := GetModuleHandle('ns-httpd20.dll');
            if (ModuleHandle = 0) then begin
                Ver20Err := GetLastError;
                raise Exception.Create('Unable to load NSAPI DLL. ' + #13#10 +
                    'Error ' + IntToStr(Ver30Err) + ' trying to load ns-httpd30.dll : ' + SysErrorMessage(Ver30Err) + #13#10 +
                    'Error ' + IntToStr(Ver20Err) + ' trying to load ns-httpd20.dll : ' + SysErrorMessage(Ver20Err));
            end;
        end;
    except
        on E: exception do begin
            ModuleHandle := 0;
            raise ETracedException.Create('Unable to load NSAPI DLL');
        end;
    end;
end;

procedure LoadNSAPI;
begin
    if (ModuleHandle <> 0) then
        exit;

    LoadNsapiDLL;

    magnus_atrestart := GetProcAddress(ModuleHandle, 'magnus_atrestart');
    assert(@magnus_atrestart <> nil);

    http_start_response := GetProcAddress(ModuleHandle, 'http_start_response');
    assert(@http_start_response <> nil);

    pblock_nninsert := GetProcAddress(ModuleHandle, 'pblock_nninsert');
    assert(@pblock_nninsert <> nil);

    pblock_nvinsert := GetProcAddress(ModuleHandle, 'pblock_nvinsert');
    assert(@pblock_nvinsert <> nil);

    util_env_free := GetProcAddress(ModuleHandle, 'util_env_free');
    assert(@util_env_free <> nil);

    net_read := GetProcAddress(ModuleHandle, 'net_read');
    assert(@net_read <> nil);

    net_write := GetProcAddress(ModuleHandle, 'net_write');
    assert(@net_write <> nil);

    net_isalive := GetProcAddress(ModuleHandle, 'net_isalive');
    assert(@net_isalive <> nil);

    param_free := GetProcAddress(ModuleHandle, 'param_free');
    assert(@param_free <> nil);

    pblock_findval := GetProcAddress(ModuleHandle, 'pblock_findval');
    assert(@pblock_findval <> nil);

    system_free := GetProcAddress(ModuleHandle, 'system_free');
    assert(@system_free <> nil);

    pblock_pblock2str := GetProcAddress(ModuleHandle, 'pblock_pblock2str');
    assert(@pblock_pblock2str <> nil);

    util_env_create := GetProcAddress(ModuleHandle, 'util_env_create');
    assert(@util_env_create <> nil);

    util_env_str := GetProcAddress(ModuleHandle, 'util_env_str');
    assert(@util_env_str <> nil);

    http_hdrs2env := GetProcAddress(ModuleHandle, 'http_hdrs2env');
    assert(@http_hdrs2env <> nil);

    shexp_cmp := GetProcAddress(ModuleHandle, 'shexp_cmp');
    assert(@shexp_cmp <> nil);

    shexp_casecmp := GetProcAddress(ModuleHandle, 'shexp_casecmp');
    assert(@shexp_casecmp <> nil);

    util_env_find := GetProcAddress(ModuleHandle, 'util_env_find');
    assert(@util_env_find <> nil);

    conf_getglobals := GetProcAddress(ModuleHandle, 'conf_getglobals');
    assert(@conf_getglobals <> nil);

    system_version := GetProcAddress(ModuleHandle, 'system_version');
    assert(@system_version <> nil);

    request_translate_uri := GetProcAddress(ModuleHandle, 'servact_translate_uri');
    assert(@request_translate_uri <> nil);

    http_status := GetProcAddress(ModuleHandle, 'http_status');
    assert(@http_status <> nil);

    protocol_status := GetProcAddress(ModuleHandle, 'http_status');
    assert(@protocol_status <> nil);

    objset_findbyname := GetProcAddress(ModuleHandle, 'objset_findbyname');
    assert(@objset_findbyname <> nil);

    _pblock_fr := GetProcAddress(ModuleHandle, '_pblock_fr');
    assert(@_pblock_fr <> nil);

    session_dns_lookup := GetProcAddress(ModuleHandle, 'session_dns_lookup');
    assert(@session_dns_lookup <> nil);
end;

initialization
begin
    ModuleHandle := 0;
end;

finalization
begin
    if (ModuleHandle <> 0) then begin
        FreeLibrary(ModuleHandle);
        ModuleHandle := 0;
    end;
end;


end.
