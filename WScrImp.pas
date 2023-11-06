/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////
unit WScrImp;

interface

uses
  ComObj, AppSSI, HWebApp, CookUtil, BrowsCap, WScr_TLB;

type
  TGetBlockFunction = function(BlockId: integer): string of object;
  TExecuteActionBlockFunction  = procedure(BlockId: integer) of object;
  TExecuteActionEvent = procedure(Sender: TObject; const Action: string) of object;
  TStopProc = procedure of object;

  THttpResponseAdapter = class(TAutoObject, IHttpResponseAdapter)
  private
    FResponse: THttpResponse;
    FGetBlockFunction: TGetBlockFunction;
    FExecuteActionBlockFunction: TExecuteActionBlockFunction;
    FSTopProc: TStopProc;
  protected
    procedure Write(const Value: WideString); safecall;
    procedure WriteBlock(BlockId: Integer); safecall;
    function Get_Status: WideString; safecall;
    procedure Set_Status(const Value: WideString); safecall;
    procedure AddHeader(const Name, Value: WideString); safecall;
    function Get_ContentType: WideString; safecall;
    procedure Set_ContentType(const Value: WideString); safecall;
    procedure ClearBuffer; safecall;
    procedure FlushBuffer; safecall;
    function Get_Cookies: IHttpResponseCookieListAdapter; safecall;
    procedure BinaryWrite(Value: OleVariant); safecall;
    function Get_Expires: Integer; safecall;
    function Get_ExpiresAbsolute: TDateTime; safecall;
    procedure Set_Expires(Value: Integer); safecall;
    procedure Set_ExpiresAbsolute(Value: TDateTime); safecall;
    function Get_Buffer: WordBool; safecall;
    function Get_ContentLength: Integer; safecall;
    procedure Set_Buffer(Value: WordBool); safecall;
    procedure Set_ContentLength(Value: Integer); safecall;
    procedure Redirect(const URL: WideString); safecall;
    procedure Stop; safecall;
    function EncodeAction(const ActionMacro: WideString): WideString; safecall;
  public
    property Response: THttpResponse read FResponse write FResponse;
    property GetBlockFunction: TGetBlockFunction read FGetBlockFunction write FGetBlockFunction;
    property ExecuteActionBlockFunction: TExecuteActionBlockFunction read FExecuteActionBlockFunction write FExecuteActionBlockFunction;
    property StopProc: TStopProc read FStopProc write FStopProc;
  end;

  THttpResponseCookieListAdapter = class(TAutoObject, IHttpResponseCookieListAdapter)
  private
    FRealCookies:  THttpResponseCookieList;
  protected
    function Exists(const CookieName: WideString): WordBool; safecall;
    procedure Clear; safecall;
    procedure Delete(const CookieName: WideString); safecall;
    function Get_Cookies(const CookieName: WideString): IHttpResponseCookieAdapter;
      safecall;
    function Get_Count: Integer; safecall;
    function Get_CookieAt(Index: Integer): IHttpResponseCookieAdapter;
      safecall;
  public
    property RealCookies: THttpResponseCookieList read FRealCookies write FRealCookies;
  end;


  THttpResponseCookieAdapter = class(TAutoObject, IHttpResponseCookieAdapter)
  private
    FRealCookie: THttpResponseCookie;
  protected
    function Get_Name: WideString; safecall;
    function Get_Value: OleVariant; safecall;
    function Get_Values(const Index: WideString): OleVariant; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    procedure Set_Value(Value: OleVariant); safecall;
    procedure Set_Values(const Index: WideString; Value: OleVariant); safecall;
    procedure Delete(const Index: WideString); safecall;
    function Get_Domain: WideString; safecall;
    function Get_ExpiresOnLocalTime: TDateTime; safecall;
    function Get_Path: WideString; safecall;
    function Get_Secure: WordBool; safecall;
    procedure Set_Domain(const Value: WideString); safecall;
    procedure Set_ExpiresOnLocalTime(Value: TDateTime); safecall;
    procedure Set_Path(const Value: WideString); safecall;
    procedure Set_Secure(Value: WordBool); safecall;
    function GetFormattedValue: WideString; safecall;
  public
    property RealCookie: THttpResponseCookie read FRealCookie write FRealCookie;
  end;

  THttpRequestAdapter = class(TAutoObject, IHttpRequestAdapter)
  private
    FRealRequest: THttpRequest;
  protected
    function Get_ContentType: WideString; safecall;
    function Get_Literals(const Name: WideString): WideString; safecall;
    function Get_QueryString: IRequestVariablesAdapter; safecall;
    function Get_Form: IRequestVariablesAdapter; safecall;
    function Get_Cookies: IRequestCookiesAdapter; safecall;
    function Get_ServerVariables(const VarName: WideString): WideString; safecall;
    function Get_HTTPHeaders(const HeaderName: WideString): WideString; safecall;
    function Get_LogicalPath: WideString; safecall;
    function Get_PhysicalPath: WideString; safecall;
    function Get_Method: WideString; safecall;
    function Get_ScriptName: WideString; safecall;
    function Get_RemoteUser: WideString; safecall;
    function MapPath(const LogicalPath: WideString): WideString; safecall;
    function Get_BrowserCaps: IBrowserTypeAdapter; safecall;
  public
    property RealRequest: THttpRequest read FRealRequest write FRealRequest;
  end;

  TRequestVariablesAdapter = class(TAutoObject, IRequestVariablesAdapter)
  private
    FRealRequestVariables: TRequestVariables;
  protected
    function Get_AsString: WideString; safecall;
    function Get_Count: Integer; safecall;
    function Get_Variables(Index: OleVariant): IRequestVariableAdapter;
      safecall;
    function VariableExists(const Index: WideString): WordBool; safecall;
  public
    property RealRequestVariables: TRequestVariables read FRealRequestVariables write FRealRequestVariables;
  end;

  TRequestCookiesAdapter = class(TAutoObject, IRequestCookiesAdapter)
  private
    FRealRequestCookies: TRequestCookies;
  protected
    function CookieExists(const CookieName: WideString): WordBool; safecall;
    function Get_Cookies(Index: OleVariant): IRequestCookieAdapter; safecall;
    function Get_Count: Integer; safecall;
  public
    property RealRequestCookies: TRequestCookies read FRealRequestCookies write FRealRequestCookies;
  end;

  TBrowserTypeAdapter = class(TAutoObject, IBrowserTypeAdapter)
  private
    FRealBrowserType: TBrowserType;
  protected
    function Get_ActiveXControls: WordBool; safecall;
    function Get_BackgroundSounds: WordBool; safecall;
    function Get_Beta: WordBool; safecall;
    function Get_Browser: WideString; safecall;
    function Get_Cookies: WordBool; safecall;
    function Get_Count: Integer; safecall;
    function Get_Frames: WordBool; safecall;
    function Get_JavaApplets: WordBool; safecall;
    function Get_JavaScript: WordBool; safecall;
    function Get_Keys(Index: Integer): WideString; safecall;
    function Get_MajorVer: Integer; safecall;
    function Get_MinorVer: Integer; safecall;
    function Get_Platform: WideString; safecall;
    function Get_Tables: WordBool; safecall;
    function Get_Values(Index: OleVariant): OleVariant; safecall;
    function Get_VBScript: WordBool; safecall;
    function Get_Version: WideString; safecall;
  public
    property RealBrowserType: TBrowserType read FRealBrowserType write FRealBrowserType;
  end;

  TRequestCookieAdapter = class(TAutoObject, IRequestCookieAdapter)
  private
    FRealRequestCookie: TRequestCookie;
  protected
    function Get_Count: Integer; safecall;
    function Get_Name: WideString; safecall;
    function Get_Value: WideString; safecall;
    function Get_Values(Index: OleVariant): WideString; safecall;
    function ValueExists(const Index: WideString): WordBool; safecall;
  public
    property RealRequestCookie: TRequestCookie read FRealRequestCookie write FRealRequestCookie;
  end;

  TRequestVariableAdapter = class(TAutoObject, IRequestVariableAdapter)
  private
    FRealRequestVariable: TRequestVariable;
  protected
    function Get_Count: Integer; safecall;
    function Get_Value: WideString; safecall;
    function Get_Values(Index: Integer): WideString; safecall;
  public
    property RealRequestVariable: TRequestVariable read FRealRequestVariable write FRealRequestVariable;
  end;

  TWapAppAdapter = class(TAutoObject, IWapAppAdapter)
  private
    FRealWapApp: TWapApp;
  protected
    function Get_AppId: WideString; safecall;
    function Get_MultiSession: WordBool; safecall;
    function Get_Values(const Index: WideString): OleVariant; safecall;
    procedure _Set_Values(const Index: WideString; Value: OleVariant); safecall;
    procedure Set_Values(const Index: WideString; var Value: OleVariant); safecall;
    procedure Lock; safecall;
    procedure Unlock; safecall;
    procedure Clear; safecall;
  public
    property RealWapApp: TWapApp read FRealWapApp write FRealWapApp;
  end;

  TWapSessionAdapter = class(TAutoObject, IWapSessionAdapter)
  private
    FRealWapSession: TWapSession;
    FOnExecuteAction: TExecuteActionEvent;
  protected
    function Get_Values(const Index: WideString): OleVariant; safecall;
    procedure _Set_Values(const Index: WideString; Value: OleVariant); safecall;
    procedure Set_Values(const Index: WideString; var Value: OleVariant); safecall;
    function Get_SessionId: WideString; safecall;
    function Get_LastAccess: TDateTime; safecall;
    function Get_Timeout: Integer; safecall;
    procedure Set_Timeout(Value: Integer); safecall;
    procedure Abandon; safecall;
    procedure Clear; safecall;
    procedure ExecuteAction(const Action: WideString); safecall;
  public
    property RealWapSession: TWapSession read FRealWapSession write FRealWapSession;
    property OnExecuteAction: TExecuteActionEvent read FOnExecuteAction write FOnExecuteAction;
  end;

implementation

uses WapCSrv, WapTmplt;

procedure THttpResponseAdapter.Write(const Value: WideString);
begin
    System.Write(Response.TextOut, string(value));
end;

procedure THttpResponseAdapter.WriteBlock(BlockId: Integer);
begin
    if assigned(FGetBlockFunction) then begin
        if (BlockId > 0) then begin
            System.Write(Response.TextOut, FGetBlockFunction(BlockId));
        end else begin
            FExecuteActionBlockFunction(BlockId);
        end;
    end;
end;

function THttpResponseAdapter.Get_Status: WideString;
begin
    result := Response.Status;
end;

procedure THttpResponseAdapter.Set_Status(const Value: WideString);
begin
    Response.Status := string(Value);
end;

procedure THttpResponseAdapter.AddHeader(const Name, Value: WideString);
begin
    Response.AddHeader(string(Name), string(Value));
end;

function THttpResponseAdapter.Get_ContentType: WideString;
begin
    result := Response.ContentType;
end;

procedure THttpResponseAdapter.Set_ContentType(const Value: WideString);
begin
    Response.ContentType := Value;
end;

procedure THttpResponseAdapter.ClearBuffer;
begin
    Response.ClearBuffer;
end;

procedure THttpResponseAdapter.FlushBuffer;
begin
    Response.FlushBuffer;
end;

function THttpResponseAdapter.Get_Cookies: IHttpResponseCookieListAdapter;
var
    p: THttpResponseCookieListAdapter;
begin
    p := THttpResponseCookieListAdapter.Create;
    p.RealCookies := Response.Cookies;
    result := p as IHttpResponseCookieListAdapter;
end;

procedure THttpResponseAdapter.BinaryWrite(Value: OleVariant);
var
    p: pointer;
begin
    p := VarArrayLock(Value);
    try
        Response.OutputStream.WriteBuffer(p^, VarArrayHighBound(Value, 1));
    finally
        VarArrayUnlock(Value);
    end;
end;

function THttpResponseAdapter.Get_Expires: Integer;
begin
    result := Response.Expires;
end;

function THttpResponseAdapter.Get_ExpiresAbsolute: TDateTime;
begin
    result := Response.ExpiresAbsolute;
end;

procedure THttpResponseAdapter.Set_Expires(Value: Integer);
begin
    Response.Expires := Value;
end;

procedure THttpResponseAdapter.Set_ExpiresAbsolute(Value: TDateTime);
begin
    Response.ExpiresAbsolute := Value;
end;

function THttpResponseAdapter.Get_Buffer: WordBool;
begin
    result := Response.Buffer;
end;

function THttpResponseAdapter.Get_ContentLength: Integer;
begin
    result := Response.ContentLength;
end;

procedure THttpResponseAdapter.Set_Buffer(Value: WordBool);
begin
    Response.Buffer := Value;
end;

procedure THttpResponseAdapter.Set_ContentLength(Value: Integer);
begin
    Response.ContentLength := Value;
end;

procedure THttpResponseAdapter.Redirect(const URL: WideString);
begin
    Response.Redirect(URL);
end;

function THttpResponseCookieListAdapter.Exists(
  const CookieName: WideString): WordBool;
begin
    result := FRealCookies.Exists(CookieName);
end;

procedure THttpResponseCookieListAdapter.Clear;
begin
    FRealCookies.Clear;
end;

procedure THttpResponseCookieListAdapter.Delete(const CookieName: WideString);
begin
    FRealCookies.Delete(CookieName);
end;

function THttpResponseCookieListAdapter.Get_Cookies(
  const CookieName: WideString): IHttpResponseCookieAdapter;
var
    p: THttpResponseCookieAdapter;
begin
    p := THttpResponseCookieAdapter.Create;
    p.RealCookie := FRealCookies.Cookies[CookieName];
    result := p as IHttpResponseCookieAdapter;
end;

function THttpResponseCookieListAdapter.Get_Count: Integer;
begin
    result := FRealCookies.Count;
end;

function THttpResponseCookieListAdapter.Get_CookieAt(
  Index: Integer): IHttpResponseCookieAdapter;
var
    p: THttpResponseCookieAdapter;
begin
    p := THttpResponseCookieAdapter.Create;
    p.RealCookie := FRealCookies.CookieAt[Index];
    result := p as IHttpResponseCookieAdapter;
end;

function THttpResponseCookieAdapter.Get_Name: WideString;
begin
    result := FRealCookie.Name;
end;

function THttpResponseCookieAdapter.Get_Value: OleVariant;
begin
    result := FRealCookie.Value; 
end;

function VariantToOleVariant(const V: Variant): OleVariant;
begin
    if varType(V) = varString then
        result := varAsType(V, varOleStr)
    else
        result := V;
end;

function THttpResponseCookieAdapter.Get_Values(
  const Index: WideString): OleVariant;
begin
    result := VariantToOleVariant(FRealCookie.Values[Index]);
end;

procedure THttpResponseCookieAdapter.Set_Name(const Value: WideString);
begin
    FRealCookie.Name := Value;
end;

procedure THttpResponseCookieAdapter.Set_Value(Value: OleVariant);
begin
    FRealCookie.Value := Value;
end;

procedure THttpResponseCookieAdapter.Set_Values(const Index: WideString;
  Value: OleVariant);
begin
    FRealCookie.Values[Index] := Value;
end;

procedure THttpResponseCookieAdapter.Delete(const Index: WideString);
begin
    FRealCookie.Delete(Index);
end;

function THttpResponseCookieAdapter.Get_Domain: WideString;
begin
    result := FRealCookie.Domain;
end;

function THttpResponseCookieAdapter.Get_ExpiresOnLocalTime: TDateTime;
begin
    result := FRealCookie.ExpiresOnLocalTime;
end;

function THttpResponseCookieAdapter.Get_Path: WideString;
begin
    result := FRealCookie.Path;
end;

function THttpResponseCookieAdapter.Get_Secure: WordBool;
begin
    result := FRealCookie.Secure;
end;

procedure THttpResponseCookieAdapter.Set_Domain(const Value: WideString);
begin
    FRealCookie.Domain := value;
end;

procedure THttpResponseCookieAdapter.Set_ExpiresOnLocalTime(
  Value: TDateTime);
begin
    FRealCookie.ExpiresOnLocalTime := Value;
end;

procedure THttpResponseCookieAdapter.Set_Path(const Value: WideString);
begin
    FRealCookie.Path := Value;
end;

procedure THttpResponseCookieAdapter.Set_Secure(Value: WordBool);
begin
    FRealCookie.Secure := Value;
end;

function THttpResponseCookieAdapter.GetFormattedValue: WideString;
begin
    result := FRealCookie.GetFormattedValue;
end;

function THttpRequestAdapter.Get_ContentType: WideString;
begin
    result := RealRequest.ContentType;
end;

function THttpRequestAdapter.Get_Literals(const Name: WideString): WideString;
begin
    result := RealRequest.Literals[Name];
end;

function THttpRequestAdapter.Get_QueryString: IRequestVariablesAdapter;
var
    p: TRequestVariablesAdapter;
begin
    p := TRequestVariablesAdapter.Create;
    p.RealRequestVariables := RealRequest.QueryString;
    result := p as IRequestVariablesAdapter;
end;

function THttpRequestAdapter.Get_Form: IRequestVariablesAdapter;
var
    p: TRequestVariablesAdapter;
begin
    p := TRequestVariablesAdapter.Create;
    p.RealRequestVariables := RealRequest.Form;
    result := p as IRequestVariablesAdapter;
end;

function THttpRequestAdapter.Get_Cookies: IRequestCookiesAdapter;
var
    p: TRequestCookiesAdapter;
begin
    p := TRequestCookiesAdapter.Create;
    p.RealRequestCookies := RealRequest.Cookies;
    result := p as IRequestCookiesAdapter;
end;

function THttpRequestAdapter.Get_ServerVariables(
  const VarName: WideString): WideString;
begin
    result := RealRequest.ServerVariables[VarName];
end;

function THttpRequestAdapter.Get_HTTPHeaders(
  const HeaderName: WideString): WideString;
begin
    result := RealRequest.HTTPHeaders[HeaderName];
end;

function THttpRequestAdapter.Get_LogicalPath: WideString;
begin
    result := RealRequest.LogicalPath;
end;

function THttpRequestAdapter.Get_PhysicalPath: WideString;
begin
    result := RealRequest.PhysicalPath;
end;

function THttpRequestAdapter.Get_Method: WideString;
begin
    result := RealRequest.Method;
end;

function THttpRequestAdapter.Get_ScriptName: WideString;
begin
    result := RealRequest.ScriptName;
end;

function THttpRequestAdapter.Get_RemoteUser: WideString;
begin
    result := RealRequest.RemoteUser;
end;

function THttpRequestAdapter.MapPath(const LogicalPath: WideString): WideString;
begin
    result := RealRequest.MapPath(LogicalPath);
end;

function THttpRequestAdapter.Get_BrowserCaps: IBrowserTypeAdapter;
var
    p: TBrowserTypeAdapter;
begin
    p := TBrowserTypeAdapter.Create;
    p.RealBrowserType := RealRequest.BrowserCaps;
    result := p as IBrowserTypeAdapter;
end;

function TRequestVariablesAdapter.Get_AsString: WideString;
begin
    result := RealRequestVariables.AsString;
end;

function TRequestVariablesAdapter.Get_Count: Integer;
begin
    result := RealRequestVariables.Count;
end;

function TRequestVariablesAdapter.Get_Variables(
  Index: OleVariant): IRequestVariableAdapter;
var
    p: TRequestVariableAdapter;
begin
    p := TRequestVariableAdapter.Create;
    p.RealRequestVariable := RealRequestVariables.Variables[Index];
    result := p as IRequestVariableAdapter;
end;

function TRequestVariablesAdapter.VariableExists(
  const Index: WideString): WordBool;
begin
    result := RealRequestVariables.VariableExists(Index);
end;

function TRequestCookiesAdapter.CookieExists(
  const CookieName: WideString): WordBool;
begin
    result := FRealRequestCookies.CookieExists(CookieName);
end;

function TRequestCookiesAdapter.Get_Cookies(
  Index: OleVariant): IRequestCookieAdapter;
var
    p: TRequestCookieAdapter;
begin
    p := TRequestCookieAdapter.Create;
    p.RealRequestCookie := FRealRequestCookies.Cookies[Index];
    result := p as IRequestCookieAdapter;
end;

function TRequestCookiesAdapter.Get_Count: Integer;
begin
    result := FRealRequestCookies.Count;
end;

function TBrowserTypeAdapter.Get_ActiveXControls: WordBool;
begin
    result := RealBrowserType.ActiveXControls;
end;

function TBrowserTypeAdapter.Get_BackgroundSounds: WordBool;
begin
    result := RealBrowserType.BackgroundSounds;
end;

function TBrowserTypeAdapter.Get_Beta: WordBool;
begin
    result := RealBrowserType.Beta;
end;

function TBrowserTypeAdapter.Get_Browser: WideString;
begin
    result := RealBrowserType.Browser;
end;

function TBrowserTypeAdapter.Get_Cookies: WordBool;
begin
    result := RealBrowserType.Cookies
end;

function TBrowserTypeAdapter.Get_Count: Integer;
begin
    result := RealBrowserType.Count
end;

function TBrowserTypeAdapter.Get_Frames: WordBool;
begin
    result := RealBrowserType.Frames
end;

function TBrowserTypeAdapter.Get_JavaApplets: WordBool;
begin
    result := RealBrowserType.JavaApplets
end;

function TBrowserTypeAdapter.Get_JavaScript: WordBool;
begin
    result := RealBrowserType.JavaScript
end;

function TBrowserTypeAdapter.Get_Keys(Index: Integer): WideString;
begin
    result := RealBrowserType.Keys[Index];
end;

function TBrowserTypeAdapter.Get_MajorVer: Integer;
begin
    result := RealBrowserType.MajorVer
end;

function TBrowserTypeAdapter.Get_MinorVer: Integer;
begin
    result := RealBrowserType.MinorVer
end;

function TBrowserTypeAdapter.Get_Platform: WideString;
begin
    result := RealBrowserType.Platform
end;

function TBrowserTypeAdapter.Get_Tables: WordBool;
begin
    result := RealBrowserType.Tables;
end;

function TBrowserTypeAdapter.Get_Values(Index: OleVariant): OleVariant;
begin
    result := VariantToOleVariant(RealBrowserType.Values[Index]);
end;

function TBrowserTypeAdapter.Get_VBScript: WordBool;
begin
    result := RealBrowserType.VBScript
end;

function TBrowserTypeAdapter.Get_Version: WideString;
begin
    result := RealBrowserType.Version
end;

function TRequestCookieAdapter.Get_Count: Integer;
begin
    result := FRealRequestCookie.Count;
end;

function TRequestCookieAdapter.Get_Name: WideString;
begin
    result := FRealRequestCookie.Name;
end;

function TRequestCookieAdapter.Get_Value: WideString;
begin
    result := FRealRequestCookie.Value;
end;

function TRequestCookieAdapter.Get_Values(Index: OleVariant): WideString;
begin
    result := FRealRequestCookie.Values[Index];
end;

function TRequestCookieAdapter.ValueExists(const Index: WideString): WordBool;
begin
    result := FRealRequestCookie.ValueExists(Index);
end;

function TRequestVariableAdapter.Get_Count: Integer;
begin
    result := RealRequestVariable.Count;
end;

function TRequestVariableAdapter.Get_Value: WideString;
begin
    result := RealRequestVariable.Value;
end;

function TRequestVariableAdapter.Get_Values(Index: Integer): WideString;
begin
    result := RealRequestVariable.Values[Index];
end;


function TWapAppAdapter.Get_AppId: WideString;
begin
    result := FRealWapApp.AppId;
end;

function TWapAppAdapter.Get_MultiSession: WordBool;
begin
    result := FRealWapApp.MultiSession;
end;

function TWapAppAdapter.Get_Values(const Index: WideString): OleVariant;
begin
    result := VariantToOleVariant(FRealWapApp.Values[Index]);
end;

procedure TWapAppAdapter._Set_Values(const Index: WideString; Value: OleVariant);
begin
    FRealWapApp.Values[Index] := Value;
end;

procedure TWapAppAdapter.Set_Values(const Index: WideString; var Value: OleVariant); 
begin
    FRealWapApp.Values[Index] := Value;
end;

procedure TWapAppAdapter.Lock; 
begin
    FRealWapApp.Lock;
end;

procedure TWapAppAdapter.Unlock;
begin
    FRealWapApp.UnLock;
end;

procedure TWapAppAdapter.Clear;
begin
    FRealWapApp.Clear
end;

function TWapSessionAdapter.Get_Values(const Index: WideString): OleVariant; safecall;
begin
    result := VariantToOleVariant(RealWapSession.Values[Index]);
end;

procedure TWapSessionAdapter._Set_Values(const Index: WideString; Value: OleVariant); safecall;
begin
    RealWapSession.Values[Index] := Value;
end;

procedure TWapSessionAdapter.Set_Values(const Index: WideString; var Value: OleVariant); safecall;
begin
    RealWapSession.Values[Index] := Value;
end;

function TWapSessionAdapter.Get_SessionId: WideString;
begin
    result := RealWapSession.SessionId;
end;

function TWapSessionAdapter.Get_LastAccess: TDateTime;
begin
    result := RealWapSession.LastAccess;
end;

function TWapSessionAdapter.Get_Timeout: Integer;
begin
    result := RealWapSession.TimeOut;
end;

procedure TWapSessionAdapter.Set_Timeout(Value: Integer);
begin
    RealWapSession.TimeOut := Value;
end;

procedure TWapSessionAdapter.Abandon;
begin
    RealWapSession.Abandon;
end;

procedure TWapSessionAdapter.Clear;
begin
    RealWapSession.Clear;
end;

procedure TWapSessionAdapter.ExecuteAction(const Action: WideString);
begin
    if assigned(FOnExecuteAction) then
        FOnExecuteAction(Self, Action);
end;


procedure THttpResponseAdapter.Stop;
begin
    FStopProc;
end;

function THttpResponseAdapter.EncodeAction(const ActionMacro: WideString): WideString;
begin
    result := WapTmplt.EncodeAction(ActionMacro);
end;

initialization
  TAutoObjectFactory.Create(WapComServer, THttpResponseAdapter, Class_HttpResponseAdapter, ciMultiInstance);
  TAutoObjectFactory.Create(WapComServer, THttpResponseCookieListAdapter, Class_HttpResponseCookieListAdapter, ciMultiInstance);
  TAutoObjectFactory.Create(WapComServer, THttpResponseCookieAdapter, Class_HttpResponseCookieAdapter, ciMultiInstance);
  TAutoObjectFactory.Create(WapComServer, THttpRequestAdapter, Class_HttpRequestAdapter, ciMultiInstance);
  TAutoObjectFactory.Create(WapComServer, TRequestVariablesAdapter, Class_RequestVariablesAdapter, ciMultiInstance);
  TAutoObjectFactory.Create(WapComServer, TRequestCookiesAdapter, Class_RequestCookiesAdapter, ciMultiInstance);
  TAutoObjectFactory.Create(WapComServer, TBrowserTypeAdapter, Class_BrowserTypeAdapter, ciMultiInstance);
  TAutoObjectFactory.Create(WapComServer, TRequestCookieAdapter, Class_RequestCookieAdapter, ciMultiInstance);
  TAutoObjectFactory.Create(WapComServer, TRequestVariableAdapter, Class_RequestVariableAdapter, ciMultiInstance);
  TAutoObjectFactory.Create(WapComServer, TWapAppAdapter, Class_WapAppAdapter, ciMultiInstance);
  TAutoObjectFactory.Create(WapComServer, TWapSessionAdapter, Class_WapSessionAdapter, ciMultiInstance);
end.
