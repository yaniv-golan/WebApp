/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////
unit HttpReq;

interface

uses SysUtils;

type

EAbstractHttpRequestInterface = class(Exception);

TAbstractHttpRequestInterface = class
public
    function    GetQueryString: string; virtual; abstract;
    function    GetMethod: string; virtual; abstract;
    function    GetLogicalPath: string; virtual; abstract;
    function    GetPhysicalPath: string; virtual; abstract;
    function    WriteToClient(const Buffer; Count: integer): integer; virtual; abstract;
    function    ReadFromClient(var Buffer; Count: integer): integer; virtual; abstract;
    function    GetInputSize: integer; virtual; abstract;
    function    GetInputContentType: string; virtual; abstract;
    function    GetServerVariable(const VarName: string): string; virtual; abstract;
    function    GetHttpHeader(const HeaderName: string): string; virtual; abstract;
    function    MapURLToPath(const LogicalURL: string): string; virtual; abstract;
end;

implementation

end.
