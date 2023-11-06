/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////
unit WapCPAdp;

interface

{$INCLUDE WAPDEF.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HTTPApp, HWebApp;

type
TWebDispatcherAdapter = class(TWebDispatcher)
private
    FSession: TWapSession;
    procedure SetSession(Value: TWapSession);
protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
public
    destructor Destroy; override;
    function Execute: boolean;
published    
    property Session: TWapSession read FSession write SetSession;
end;

TWebModuleAdapter = class(TWebDispatcher)
private
    FSession: TWapSession;
    procedure SetSession(Value: TWapSession);
protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
public
    destructor Destroy; override;
    function Execute: boolean;
published    
    property Session: TWapSession read FSession write SetSession;
end;

implementation

type

TRequestAdapter = class(TWebRequest)
private
    FWebAppRequest: THttpRequest;
    FWebAppResponse: THttpResponse;
protected
    function GetStringVariable(Index: Integer): string; override;
    function GetDateVariable(Index: Integer): TDateTime; override;
    function GetIntegerVariable(Index: Integer): Integer; override;
public
    constructor Create(WebAppRequest: THttpRequest; WebAppResponse: THttpResponse);
    function GetFieldByName(const Name: string): string; override;
    function ReadClient(var Buffer; Count: Integer): Integer; override;
    function ReadString(Count: Integer): string; override;
    function TranslateURI(const URI: string): string; override;
    function WriteClient(var Buffer; Count: Integer): Integer; override;
    function WriteString(const AString: string): Boolean; override;
end;

TResponseAdapter = class(TWebResponse)
private
    FWebAppRequest: THttpRequest;
    FWebAppResponse: THttpResponse;

    FStatusCode: Integer;
    FStringVariables: array[0..MAX_STRINGS - 1] of string;
    FIntegerVariables: array[0..MAX_INTEGERS - 1] of Integer;
    FDateVariables: array[0..MAX_DATETIMES - 1] of TDateTime;
    FContent: string;
    FSent: Boolean;
protected
    function GetContent: string; override;
    function GetDateVariable(Index: Integer): TDateTime; override;
    function GetIntegerVariable(Index: Integer): Integer; override;
    function GetLogMessage: string; override;
    function GetStatusCode: Integer; override;
    function GetStringVariable(Index: Integer): string; override;
    function Sent: Boolean; override;
    procedure SetContent(const Value: string); override;
    procedure SetDateVariable(Index: Integer; const Value: TDateTime); override;
    procedure SetIntegerVariable(Index: Integer; Value: Integer); override;
    procedure SetLogMessage(const Value: string); override;
    procedure SetStatusCode(Value: Integer); override;
    procedure SetStringVariable(Index: Integer; const Value: string); override;
public
    constructor Create(HTTPRequest: TWebRequest; WebAppRequest: THttpRequest; WebAppResponse: THttpResponse);
    procedure SendResponse; override;
    procedure SendRedirect(const URI: string); override;
    procedure SendStream(AStream: TStream); override;
end;

///////////////////////////////////////////////////////////////////////
//
// TWebDispatcherAdapter
//
///////////////////////////////////////////////////////////////////////

destructor TWebDispatcherAdapter.Destroy;
begin
    SetSession(nil);
    inherited;
end;

procedure TWebDispatcherAdapter.SetSession(Value: TWapSession);
begin
    if (Value <> FSession) then begin
{        if (FSession <> nil) then
            FSession.RemoveNotificationHandler(SessionNotificationHandler);}
        FSession := Value;
        if (FSession <> nil) then begin
{            FSession.AddNotificationHandler(SessionNotificationHandler);}
            FSession.FreeNotification(Self);
        end;
    end;
end;

procedure TWebDispatcherAdapter.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited;
    if (AComponent = FSession) and (Operation = opRemove) then
        FSession := nil;
end;

function TWebDispatcherAdapter.Execute: boolean;
var
    RequestAdapter: TRequestAdapter;
    ResponseAdapter: TResponseAdapter;
begin
    if (FSession = nil) then
        raise Exception.Create('Session not assigned');
    RequestAdapter := TRequestAdapter.Create(FSession.Request, FSession.Response);
    ResponseAdapter := TResponseAdapter.Create(RequestAdapter, FSession.Request, FSession.Response);
    try
        Result := DispatchAction(RequestAdapter, ResponseAdapter);
        if Result and not ResponseAdapter.Sent then
            ResponseAdapter.SendResponse;
    finally
        ResponseAdapter.Free;
        RequestAdapter.Free;
    end;
end;

///////////////////////////////////////////////////////////////////////
//
// TWebModuleAdapter
//
///////////////////////////////////////////////////////////////////////

destructor TWebModuleAdapter.Destroy;
begin
    SetSession(nil);
    inherited;
end;

procedure TWebModuleAdapter.SetSession(Value: TWapSession);
begin
    if (Value <> FSession) then begin
{        if (FSession <> nil) then
            FSession.RemoveNotificationHandler(SessionNotificationHandler);}
        FSession := Value;
        if (FSession <> nil) then begin
{            FSession.AddNotificationHandler(SessionNotificationHandler);}
            FSession.FreeNotification(Self);
        end;
    end;
end;

procedure TWebModuleAdapter.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited;
    if (AComponent = FSession) and (Operation = opRemove) then
        FSession := nil;
end;

function TWebModuleAdapter.Execute: boolean;
var
    RequestAdapter: TRequestAdapter;
    ResponseAdapter: TResponseAdapter;
begin
    if (FSession = nil) then
        raise Exception.Create('Session not assigned');
    RequestAdapter := TRequestAdapter.Create(FSession.Request, FSession.Response);
    ResponseAdapter := TResponseAdapter.Create(RequestAdapter, FSession.Request, FSession.Response);
    try
        Result := DispatchAction(RequestAdapter, ResponseAdapter);
        if Result and not ResponseAdapter.Sent then
            ResponseAdapter.SendResponse;
    finally
        ResponseAdapter.Free;
        RequestAdapter.Free;
    end;
end;


constructor TRequestAdapter.Create(WebAppRequest: THttpRequest; WebAppResponse: THttpResponse);
begin
    FWebAppRequest := WebAppRequest;
    FWebAppResponse := WebAppResponse;
    inherited Create;
end;

function TRequestAdapter.GetFieldByName(const Name: string): string;
begin
    result := FWebAppRequest.ServerVariables[Name];
end;

const
  ServerVariables: array[0..28] of string = (
    'REQUEST_METHOD',
    'SERVER_PROTOCOL',
    'URL',
    'QUERY_STRING',
    'PATH_INFO',
    'PATH_TRANSLATED',
    'HTTP_CACHE_CONTROL',
    'HTTP_DATE',
    'HTTP_ACCEPT',
    'HTTP_FROM',
    'HTTP_HOST',
    'HTTP_IF_MODIFIED_SINCE',
    'HTTP_REFERER',
    'HTTP_USER_AGENT',
    'HTTP_CONTENT_ENCODING',
    'HTTP_CONTENT_TYPE',
    'HTTP_CONTENT_LENGTH',
    'HTTP_CONTENT_VERSION',
    'HTTP_DERIVED_FROM',
    'HTTP_EXPIRES',
    'HTTP_TITLE',
    'REMOTE_ADDR',
    'REMOTE_HOST',
    'SCRIPT_NAME',
    'SERVER_PORT',
    '',
    'HTTP_CONNECTION',
    'HTTP_COOKIE',
    'HTTP_AUTHORIZATION');

function TRequestAdapter.GetStringVariable(Index: Integer): string;
begin
  case Index of
    0: Result := FWebAppRequest.Method;
    3: Result := FWebAppRequest.QueryString.AsString;
    4: Result := FWebAppRequest.LogicalPath;
    5: Result := FWebAppRequest.PhysicalPath;
    1..2, 6..24, 26..28: Result := GetFieldByName(ServerVariables[Index]);
    25: result := FWebAppRequest.Form.AsString;
  end;
end;

function TRequestAdapter.GetDateVariable(Index: Integer): TDateTime;
var
  Value: string;
begin
  Value := GetStringVariable(Index);
  if Value <> '' then
    Result := ParseDate(Value)
  else Result := -1;
end;

function TRequestAdapter.GetIntegerVariable(Index: Integer): Integer;
var
  Value: string;
begin
  Value := GetStringVariable(Index);
  if Value <> '' then
    Result := StrToInt(Value)
  else Result := -1;
end;

function TRequestAdapter.ReadClient(var Buffer; Count: Integer): Integer;
begin
    result := FWebAppRequest.InputStream.Read(Buffer, Count);
end;

function TRequestAdapter.ReadString(Count: Integer): string;
var
  Len: Integer;
begin
  SetLength(Result, Count);
  Len := ReadClient(Pointer(Result)^, Count);
  if Len > 0 then
    SetLength(Result, Len)
  else Result := '';
end;

function TRequestAdapter.TranslateURI(const URI: string): string;
begin
    result := FWebAppRequest.MapPath(URI);
end;

function TRequestAdapter.WriteClient(var Buffer; Count: Integer): Integer;
begin
    result := FWebAppResponse.OutputStream.Write(Buffer, Count);
end;

function TRequestAdapter.WriteString(const AString: string): Boolean;
begin
  Result := WriteClient(Pointer(AString)^, Length(AString)) = Length(AString);
end;

{ TResponseAdapter }

constructor TResponseAdapter.Create(HTTPRequest: TWebRequest; WebAppRequest: THttpRequest; WebAppResponse: THttpResponse);
begin
    FWebAppRequest := WebAppRequest;
    FWebAppResponse := WebAppResponse;
    inherited Create(HTTPRequest);
end;

function TResponseAdapter.GetContent: string;
begin
  Result := FContent;
end;

function TResponseAdapter.GetDateVariable(Index: Integer): TDateTime;
begin
  if (Index >= Low(FDateVariables)) and (Index <= High(FDateVariables)) then
    Result := FDateVariables[Index]
  else Result := 0.0;
end;

function TResponseAdapter.GetIntegerVariable(Index: Integer): Integer;
begin
  if (Index >= Low(FIntegerVariables)) and (Index <= High(FIntegerVariables)) then
    Result := FIntegerVariables[Index]
  else Result := -1;
end;

function TResponseAdapter.GetLogMessage: string;
begin
    // tbd
end;

function TResponseAdapter.GetStatusCode: Integer;
begin
  Result := FStatusCode;
end;

function TResponseAdapter.GetStringVariable(Index: Integer): string;
begin
  if (Index >= Low(FStringVariables)) and (Index <= High(FStringVariables)) then
    Result := FStringVariables[Index];
end;

function TResponseAdapter.Sent: Boolean;
begin
  Result := FSent;
end;

procedure TResponseAdapter.SetContent(const Value: string);
begin
  FContent := Value;
  ContentLength := Length(FContent);
end;

procedure TResponseAdapter.SetDateVariable(Index: Integer; const Value: TDateTime);
begin
  if (Index >= Low(FDateVariables)) and (Index <= High(FDateVariables)) then
    if Value <> FDateVariables[Index] then
      FDateVariables[Index] := Value;
end;

procedure TResponseAdapter.SetIntegerVariable(Index: Integer; Value: Integer);
begin
  if (Index >= Low(FIntegerVariables)) and (Index <= High(FIntegerVariables)) then
    if Value <> FIntegerVariables[Index] then
      FIntegerVariables[Index] := Value;
end;

procedure TResponseAdapter.SetLogMessage(const Value: string);
begin
    // tbd
end;

{!! Strings not to be resourced !!}
procedure TResponseAdapter.SetStatusCode(Value: Integer);
begin
  if FStatusCode <> Value then
  begin
    FStatusCode := Value;
    ReasonString := StatusString(Value);
  end;
end;

procedure TResponseAdapter.SetStringVariable(Index: Integer; const Value: string);
begin
  if (Index >= Low(FStringVariables)) and (Index <= High(FStringVariables)) then
    FStringVariables[Index] := Value;
end;

procedure TResponseAdapter.SendResponse;
var
  StatusString: string;
  Headers: string;
  I: Integer;

  procedure AddHeaderItem(const Item, FormatStr: string);
  begin
    if Item <> '' then
      FWebAppResponse.Headers.Add(Format(FormatStr, [Item]));
  end;

begin
  if HTTPRequest.ProtocolVersion <> '' then
  begin
    if (ReasonString <> '') and (StatusCode > 0) then
      StatusString := Format('%d %s', [StatusCode, ReasonString])
    else StatusString := '200 OK';
    FWEbAppResponse.Status := StatusString;
    AddHeaderItem(Allow, 'Allow: %s');
    for I := 0 to Cookies.Count - 1 do
      AddHeaderItem(Cookies[I].HeaderValue, 'Set-Cookie: %s');
    AddHeaderItem(DerivedFrom, 'Derived-From: %s');
    if Expires > 0 then
        FWebAppResponse.ExpiresAbsolute := Expires;
    if LastModified > 0 then
      Headers := Headers +
{$ifdef wap_delphi_4}
        FormatDateTime('"Last-Modified: "' + sDateFormat + ' "GMT"', LastModified);
{$else}
        FormatDateTime('"Last-Modified: "' + DateFormat + ' "GMT"', LastModified);
{$endif wap_delphi_4}
    AddHeaderItem(Title, 'Title: %s');
    AddHeaderItem(WWWAuthenticate, 'WWW-Authenticate: %s');
    AddCustomHeaders(Headers);
    AddHeaderItem(ContentVersion, 'Content-Version: %s');
    AddHeaderItem(ContentEncoding, 'Content-Encoding: %s');
    if (ContentType <> '') then
        FWebAppResponse.ContentType := ContentType;
    if (Content <> '') or (ContentStream <> nil) then
        FWebAppResponse.ContentLength := ContentLength;
  end;
  if ContentStream = nil then
    HTTPRequest.WriteString(Content)
  else if ContentStream <> nil then
  begin
    SendStream(ContentStream);
    ContentStream := nil; // Drop the stream
  end;
  FSent := True;
end;

procedure TResponseAdapter.SendRedirect(const URI: string);
begin
    FWebAppResponse.Redirect(URI);
  FSent := True;
end;

procedure TResponseAdapter.SendStream(AStream: TStream);
begin
    FWebAppResponse.OutputStream.CopyFrom(AStream, 0);
end;

end.
