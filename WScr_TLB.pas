unit WScr_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ ActiveScripting interface to the HyperAct WebApp objects }
{ Version 1.0 }

{ Conversion log:
  Warning: IHttpResponseAdapter.BinaryWrite parameter Value of type TSafeArray(Byte) was written as OleVariant.
  Warning: IHttpResponseAdapter.BinaryWrite parameter Value of type TSafeArray(Byte) was written as OleVariant.
 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_WScr: TGUID = '{5238F2D0-D38B-11D0-9CDD-6AEA77000000}';

const

{ Component class GUIDs }
  Class_HttpResponseAdapter: TGUID = '{5238F2D2-D38B-11D0-9CDD-6AEA77000000}';
  Class_HttpResponseCookieListAdapter: TGUID = '{2483A205-D3F5-11D0-9CDE-8898FB000000}';
  Class_HttpResponseCookieAdapter: TGUID = '{2483A207-D3F5-11D0-9CDE-8898FB000000}';
  Class_HttpRequestAdapter: TGUID = '{2483A209-D3F5-11D0-9CDE-8898FB000000}';
  Class_RequestVariablesAdapter: TGUID = '{2483A20B-D3F5-11D0-9CDE-8898FB000000}';
  Class_RequestCookiesAdapter: TGUID = '{2483A20D-D3F5-11D0-9CDE-8898FB000000}';
  Class_BrowserTypeAdapter: TGUID = '{2483A20F-D3F5-11D0-9CDE-8898FB000000}';
  Class_RequestCookieAdapter: TGUID = '{2483A211-D3F5-11D0-9CDE-8898FB000000}';
  Class_RequestVariableAdapter: TGUID = '{2483A213-D3F5-11D0-9CDE-8898FB000000}';
  Class_WapSessionAdapter: TGUID = '{DFEAAB51-D42C-11D0-9CDE-8898FB000000}';
  Class_WapAppAdapter: TGUID = '{DFEAAB55-D42C-11D0-9CDE-8898FB000000}';

type

{ Forward declarations: Interfaces }
  IHttpResponseAdapter = interface;
  IHttpResponseAdapterDisp = dispinterface;
  IHttpResponseCookieListAdapter = interface;
  IHttpResponseCookieListAdapterDisp = dispinterface;
  IHttpResponseCookieAdapter = interface;
  IHttpResponseCookieAdapterDisp = dispinterface;
  IHttpRequestAdapter = interface;
  IHttpRequestAdapterDisp = dispinterface;
  IRequestVariablesAdapter = interface;
  IRequestVariablesAdapterDisp = dispinterface;
  IRequestCookiesAdapter = interface;
  IRequestCookiesAdapterDisp = dispinterface;
  IBrowserTypeAdapter = interface;
  IBrowserTypeAdapterDisp = dispinterface;
  IRequestCookieAdapter = interface;
  IRequestCookieAdapterDisp = dispinterface;
  IRequestVariableAdapter = interface;
  IRequestVariableAdapterDisp = dispinterface;
  IWapSessionAdapter = interface;
  IWapSessionAdapterDisp = dispinterface;
  IWapAppAdapter = interface;
  IWapAppAdapterDisp = dispinterface;

{ Forward declarations: CoClasses }
  HttpResponseAdapter = IHttpResponseAdapter;
  HttpResponseCookieListAdapter = IHttpResponseCookieListAdapter;
  HttpResponseCookieAdapter = IHttpResponseCookieAdapter;
  HttpRequestAdapter = IHttpRequestAdapter;
  RequestVariablesAdapter = IRequestVariablesAdapter;
  RequestCookiesAdapter = IRequestCookiesAdapter;
  BrowserTypeAdapter = IBrowserTypeAdapter;
  RequestCookieAdapter = IRequestCookieAdapter;
  RequestVariableAdapter = IRequestVariableAdapter;
  WapSessionAdapter = IWapSessionAdapter;
  WapAppAdapter = IWapAppAdapter;

{ Dispatch interface for WapScriptingResponse Object }

  IHttpResponseAdapter = interface(IDispatch)
    ['{5238F2D1-D38B-11D0-9CDD-6AEA77000000}']
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
    procedure Set_Expires(Value: Integer); safecall;
    function Get_ExpiresAbsolute: TDateTime; safecall;
    procedure Set_ExpiresAbsolute(Value: TDateTime); safecall;
    function Get_ContentLength: Integer; safecall;
    procedure Set_ContentLength(Value: Integer); safecall;
    function Get_Buffer: WordBool; safecall;
    procedure Set_Buffer(Value: WordBool); safecall;
    procedure Redirect(const URL: WideString); safecall;
    procedure Stop; safecall;
    function EncodeAction(const ActionMacro: WideString): WideString; safecall;
    property Status: WideString read Get_Status write Set_Status;
    property ContentType: WideString read Get_ContentType write Set_ContentType;
    property Cookies: IHttpResponseCookieListAdapter read Get_Cookies;
    property Expires: Integer read Get_Expires write Set_Expires;
    property ExpiresAbsolute: TDateTime read Get_ExpiresAbsolute write Set_ExpiresAbsolute;
    property ContentLength: Integer read Get_ContentLength write Set_ContentLength;
    property Buffer: WordBool read Get_Buffer write Set_Buffer;
  end;

{ DispInterface declaration for Dual Interface IHttpResponseAdapter }

  IHttpResponseAdapterDisp = dispinterface
    ['{5238F2D1-D38B-11D0-9CDD-6AEA77000000}']
    procedure Write(const Value: WideString); dispid 1;
    procedure WriteBlock(BlockId: Integer); dispid 2;
    property Status: WideString dispid 3;
    procedure AddHeader(const Name, Value: WideString); dispid 4;
    property ContentType: WideString dispid 5;
    procedure ClearBuffer; dispid 6;
    procedure FlushBuffer; dispid 7;
    property Cookies: IHttpResponseCookieListAdapter readonly dispid 8;
    procedure BinaryWrite(Value: OleVariant); dispid 9;
    property Expires: Integer dispid 10;
    property ExpiresAbsolute: TDateTime dispid 11;
    property ContentLength: Integer dispid 12;
    property Buffer: WordBool dispid 13;
    procedure Redirect(const URL: WideString); dispid 14;
    procedure Stop; dispid 15;
    function EncodeAction(const ActionMacro: WideString): WideString; dispid 16;
  end;

{ Dispatch interface for HttpResponseCookieListAdapter Object }

  IHttpResponseCookieListAdapter = interface(IDispatch)
    ['{2483A204-D3F5-11D0-9CDE-8898FB000000}']
    procedure Delete(const CookieName: WideString); safecall;
    function Exists(const CookieName: WideString): WordBool; safecall;
    procedure Clear; safecall;
    function Get_Cookies(const CookieName: WideString): IHttpResponseCookieAdapter; safecall;
    function Get_Count: Integer; safecall;
    function Get_CookieAt(Index: Integer): IHttpResponseCookieAdapter; safecall;
    property Cookies[const CookieName: WideString]: IHttpResponseCookieAdapter read Get_Cookies; default;
    property Count: Integer read Get_Count;
    property CookieAt[Index: Integer]: IHttpResponseCookieAdapter read Get_CookieAt;
  end;

{ DispInterface declaration for Dual Interface IHttpResponseCookieListAdapter }

  IHttpResponseCookieListAdapterDisp = dispinterface
    ['{2483A204-D3F5-11D0-9CDE-8898FB000000}']
    procedure Delete(const CookieName: WideString); dispid 1;
    function Exists(const CookieName: WideString): WordBool; dispid 2;
    procedure Clear; dispid 3;
    property Cookies[const CookieName: WideString]: IHttpResponseCookieAdapter readonly dispid 0; default;
    property Count: Integer readonly dispid 5;
    property CookieAt[Index: Integer]: IHttpResponseCookieAdapter readonly dispid 6;
  end;

{ Dispatch interface for HttpResponseCookieAdapter Object }

  IHttpResponseCookieAdapter = interface(IDispatch)
    ['{2483A206-D3F5-11D0-9CDE-8898FB000000}']
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Value: OleVariant; safecall;
    procedure Set_Value(Value: OleVariant); safecall;
    function Get_Values(const ndex: WideString): OleVariant; safecall;
    procedure Set_Values(const ndex: WideString; Value: OleVariant); safecall;
    procedure Delete(const Index: WideString); safecall;
    function Get_Path: WideString; safecall;
    procedure Set_Path(const Value: WideString); safecall;
    function Get_Domain: WideString; safecall;
    procedure Set_Domain(const Value: WideString); safecall;
    function Get_Secure: WordBool; safecall;
    procedure Set_Secure(Value: WordBool); safecall;
    function Get_ExpiresOnLocalTime: TDateTime; safecall;
    procedure Set_ExpiresOnLocalTime(Value: TDateTime); safecall;
    function GetFormattedValue: WideString; safecall;
    property Name: WideString read Get_Name write Set_Name;
    property Value: OleVariant read Get_Value write Set_Value;
    property Values[const ndex: WideString]: OleVariant read Get_Values write Set_Values; default;
    property Path: WideString read Get_Path write Set_Path;
    property Domain: WideString read Get_Domain write Set_Domain;
    property Secure: WordBool read Get_Secure write Set_Secure;
    property ExpiresOnLocalTime: TDateTime read Get_ExpiresOnLocalTime write Set_ExpiresOnLocalTime;
  end;

{ DispInterface declaration for Dual Interface IHttpResponseCookieAdapter }

  IHttpResponseCookieAdapterDisp = dispinterface
    ['{2483A206-D3F5-11D0-9CDE-8898FB000000}']
    property Name: WideString dispid 1;
    property Value: OleVariant dispid 2;
    property Values[const ndex: WideString]: OleVariant dispid 0; default;
    procedure Delete(const Index: WideString); dispid 4;
    property Path: WideString dispid 5;
    property Domain: WideString dispid 6;
    property Secure: WordBool dispid 7;
    property ExpiresOnLocalTime: TDateTime dispid 8;
    function GetFormattedValue: WideString; dispid 9;
  end;

{ Dispatch interface for HttpRequestAdapter Object }

  IHttpRequestAdapter = interface(IDispatch)
    ['{2483A208-D3F5-11D0-9CDE-8898FB000000}']
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
    property ContentType: WideString read Get_ContentType;
    property Literals[const Name: WideString]: WideString read Get_Literals; default;
    property QueryString: IRequestVariablesAdapter read Get_QueryString;
    property Form: IRequestVariablesAdapter read Get_Form;
    property Cookies: IRequestCookiesAdapter read Get_Cookies;
    property ServerVariables[const VarName: WideString]: WideString read Get_ServerVariables;
    property HTTPHeaders[const HeaderName: WideString]: WideString read Get_HTTPHeaders;
    property LogicalPath: WideString read Get_LogicalPath;
    property PhysicalPath: WideString read Get_PhysicalPath;
    property Method: WideString read Get_Method;
    property ScriptName: WideString read Get_ScriptName;
    property RemoteUser: WideString read Get_RemoteUser;
    property BrowserCaps: IBrowserTypeAdapter read Get_BrowserCaps;
  end;

{ DispInterface declaration for Dual Interface IHttpRequestAdapter }

  IHttpRequestAdapterDisp = dispinterface
    ['{2483A208-D3F5-11D0-9CDE-8898FB000000}']
    property ContentType: WideString readonly dispid 1;
    property Literals[const Name: WideString]: WideString readonly dispid 0; default;
    property QueryString: IRequestVariablesAdapter readonly dispid 3;
    property Form: IRequestVariablesAdapter readonly dispid 4;
    property Cookies: IRequestCookiesAdapter readonly dispid 5;
    property ServerVariables[const VarName: WideString]: WideString readonly dispid 6;
    property HTTPHeaders[const HeaderName: WideString]: WideString readonly dispid 7;
    property LogicalPath: WideString readonly dispid 8;
    property PhysicalPath: WideString readonly dispid 9;
    property Method: WideString readonly dispid 10;
    property ScriptName: WideString readonly dispid 11;
    property RemoteUser: WideString readonly dispid 12;
    function MapPath(const LogicalPath: WideString): WideString; dispid 13;
    property BrowserCaps: IBrowserTypeAdapter readonly dispid 14;
  end;

{ Dispatch interface for RequestVariablesAdapter Object }

  IRequestVariablesAdapter = interface(IDispatch)
    ['{2483A20A-D3F5-11D0-9CDE-8898FB000000}']
    function Get_Count: Integer; safecall;
    function Get_Variables(Index: OleVariant): IRequestVariableAdapter; safecall;
    function VariableExists(const Index: WideString): WordBool; safecall;
    function Get_AsString: WideString; safecall;
    property Count: Integer read Get_Count;
    property Variables[Index: OleVariant]: IRequestVariableAdapter read Get_Variables; default;
    property AsString: WideString read Get_AsString;
  end;

{ DispInterface declaration for Dual Interface IRequestVariablesAdapter }

  IRequestVariablesAdapterDisp = dispinterface
    ['{2483A20A-D3F5-11D0-9CDE-8898FB000000}']
    property Count: Integer readonly dispid 1;
    property Variables[Index: OleVariant]: IRequestVariableAdapter readonly dispid 0; default;
    function VariableExists(const Index: WideString): WordBool; dispid 3;
    property AsString: WideString readonly dispid 4;
  end;

{ Dispatch interface for RequestCookiesAdapter Object }

  IRequestCookiesAdapter = interface(IDispatch)
    ['{2483A20C-D3F5-11D0-9CDE-8898FB000000}']
    function Get_Count: Integer; safecall;
    function Get_Cookies(Index: OleVariant): IRequestCookieAdapter; safecall;
    function CookieExists(const CookieName: WideString): WordBool; safecall;
    property Count: Integer read Get_Count;
    property Cookies[Index: OleVariant]: IRequestCookieAdapter read Get_Cookies; default;
  end;

{ DispInterface declaration for Dual Interface IRequestCookiesAdapter }

  IRequestCookiesAdapterDisp = dispinterface
    ['{2483A20C-D3F5-11D0-9CDE-8898FB000000}']
    property Count: Integer readonly dispid 1;
    property Cookies[Index: OleVariant]: IRequestCookieAdapter readonly dispid 0; default;
    function CookieExists(const CookieName: WideString): WordBool; dispid 4;
  end;

{ Dispatch interface for BrowserTypeAdapter Object }

  IBrowserTypeAdapter = interface(IDispatch)
    ['{2483A20E-D3F5-11D0-9CDE-8898FB000000}']
    function Get_Browser: WideString; safecall;
    function Get_Version: WideString; safecall;
    function Get_MajorVer: Integer; safecall;
    function Get_MinorVer: Integer; safecall;
    function Get_Frames: WordBool; safecall;
    function Get_Tables: WordBool; safecall;
    function Get_Cookies: WordBool; safecall;
    function Get_BackgroundSounds: WordBool; safecall;
    function Get_VBScript: WordBool; safecall;
    function Get_JavaScript: WordBool; safecall;
    function Get_JavaApplets: WordBool; safecall;
    function Get_Platform: WideString; safecall;
    function Get_ActiveXControls: WordBool; safecall;
    function Get_Beta: WordBool; safecall;
    function Get_Count: Integer; safecall;
    function Get_Keys(Index: Integer): WideString; safecall;
    function Get_Values(Index: OleVariant): OleVariant; safecall;
    property Browser: WideString read Get_Browser;
    property Version: WideString read Get_Version;
    property MajorVer: Integer read Get_MajorVer;
    property MinorVer: Integer read Get_MinorVer;
    property Frames: WordBool read Get_Frames;
    property Tables: WordBool read Get_Tables;
    property Cookies: WordBool read Get_Cookies;
    property BackgroundSounds: WordBool read Get_BackgroundSounds;
    property VBScript: WordBool read Get_VBScript;
    property JavaScript: WordBool read Get_JavaScript;
    property JavaApplets: WordBool read Get_JavaApplets;
    property Platform: WideString read Get_Platform;
    property ActiveXControls: WordBool read Get_ActiveXControls;
    property Beta: WordBool read Get_Beta;
    property Count: Integer read Get_Count;
    property Keys[Index: Integer]: WideString read Get_Keys;
    property Values[Index: OleVariant]: OleVariant read Get_Values; default;
  end;

{ DispInterface declaration for Dual Interface IBrowserTypeAdapter }

  IBrowserTypeAdapterDisp = dispinterface
    ['{2483A20E-D3F5-11D0-9CDE-8898FB000000}']
    property Browser: WideString readonly dispid 1;
    property Version: WideString readonly dispid 2;
    property MajorVer: Integer readonly dispid 3;
    property MinorVer: Integer readonly dispid 4;
    property Frames: WordBool readonly dispid 5;
    property Tables: WordBool readonly dispid 6;
    property Cookies: WordBool readonly dispid 7;
    property BackgroundSounds: WordBool readonly dispid 8;
    property VBScript: WordBool readonly dispid 9;
    property JavaScript: WordBool readonly dispid 10;
    property JavaApplets: WordBool readonly dispid 11;
    property Platform: WideString readonly dispid 12;
    property ActiveXControls: WordBool readonly dispid 13;
    property Beta: WordBool readonly dispid 14;
    property Count: Integer readonly dispid 15;
    property Keys[Index: Integer]: WideString readonly dispid 16;
    property Values[Index: OleVariant]: OleVariant readonly dispid 0; default;
  end;

{ Dispatch interface for RequestCookieAdapter Object }

  IRequestCookieAdapter = interface(IDispatch)
    ['{2483A210-D3F5-11D0-9CDE-8898FB000000}']
    function Get_Name: WideString; safecall;
    function Get_Value: WideString; safecall;
    function Get_Count: Integer; safecall;
    function Get_Values(Index: OleVariant): WideString; safecall;
    function ValueExists(const Index: WideString): WordBool; safecall;
    property Name: WideString read Get_Name;
    property Value: WideString read Get_Value;
    property Count: Integer read Get_Count;
    property Values[Index: OleVariant]: WideString read Get_Values; default;
  end;

{ DispInterface declaration for Dual Interface IRequestCookieAdapter }

  IRequestCookieAdapterDisp = dispinterface
    ['{2483A210-D3F5-11D0-9CDE-8898FB000000}']
    property Name: WideString readonly dispid 1;
    property Value: WideString readonly dispid 2;
    property Count: Integer readonly dispid 3;
    property Values[Index: OleVariant]: WideString readonly dispid 0; default;
    function ValueExists(const Index: WideString): WordBool; dispid 5;
  end;

{ Dispatch interface for RequestVariableAdapter Object }

  IRequestVariableAdapter = interface(IDispatch)
    ['{2483A212-D3F5-11D0-9CDE-8898FB000000}']
    function Get_Count: Integer; safecall;
    function Get_Values(Index: Integer): WideString; safecall;
    function Get_Value: WideString; safecall;
    property Count: Integer read Get_Count;
    property Values[Index: Integer]: WideString read Get_Values; default;
    property Value: WideString read Get_Value;
  end;

{ DispInterface declaration for Dual Interface IRequestVariableAdapter }

  IRequestVariableAdapterDisp = dispinterface
    ['{2483A212-D3F5-11D0-9CDE-8898FB000000}']
    property Count: Integer readonly dispid 1;
    property Values[Index: Integer]: WideString readonly dispid 0; default;
    property Value: WideString readonly dispid 3;
  end;

{ Dispatch interface for WapSessionAdapter Object }

  IWapSessionAdapter = interface(IDispatch)
    ['{DFEAAB50-D42C-11D0-9CDE-8898FB000000}']
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
    property Values[const Index: WideString]: OleVariant read Get_Values write Set_Values; default;
    property SessionId: WideString read Get_SessionId;
    property LastAccess: TDateTime read Get_LastAccess;
    property Timeout: Integer read Get_Timeout write Set_Timeout;
  end;

{ DispInterface declaration for Dual Interface IWapSessionAdapter }

  IWapSessionAdapterDisp = dispinterface
    ['{DFEAAB50-D42C-11D0-9CDE-8898FB000000}']
    property Values[const Index: WideString]: OleVariant dispid 0; default;
    property SessionId: WideString readonly dispid 2;
    property LastAccess: TDateTime readonly dispid 3;
    property Timeout: Integer dispid 4;
    procedure Abandon; dispid 5;
    procedure Clear; dispid 6;
    procedure ExecuteAction(const Action: WideString); dispid 1;
  end;

{ Dispatch interface for WapAppAdapter Object }

  IWapAppAdapter = interface(IDispatch)
    ['{DFEAAB54-D42C-11D0-9CDE-8898FB000000}']
    function Get_AppId: WideString; safecall;
    function Get_MultiSession: WordBool; safecall;
    procedure Clear; safecall;
    function Get_Values(const Index: WideString): OleVariant; safecall;
    procedure _Set_Values(const Index: WideString; Value: OleVariant); safecall;
    procedure Set_Values(const Index: WideString; var Value: OleVariant); safecall;
    procedure Lock; safecall;
    procedure Unlock; safecall;
    property AppId: WideString read Get_AppId;
    property MultiSession: WordBool read Get_MultiSession;
    property Values[const Index: WideString]: OleVariant read Get_Values write Set_Values; default;
  end;

{ DispInterface declaration for Dual Interface IWapAppAdapter }

  IWapAppAdapterDisp = dispinterface
    ['{DFEAAB54-D42C-11D0-9CDE-8898FB000000}']
    property AppId: WideString readonly dispid 1;
    property MultiSession: WordBool readonly dispid 2;
    procedure Clear; dispid 3;
    property Values[const Index: WideString]: OleVariant dispid 0; default;
    procedure Lock; dispid 5;
    procedure Unlock; dispid 6;
  end;

{ WapScriptingResponseObject }

  CoHttpResponseAdapter = class
    class function Create: IHttpResponseAdapter;
    class function CreateRemote(const MachineName: string): IHttpResponseAdapter;
  end;

{ HttpResponseCookieListAdapterObject }

  CoHttpResponseCookieListAdapter = class
    class function Create: IHttpResponseCookieListAdapter;
    class function CreateRemote(const MachineName: string): IHttpResponseCookieListAdapter;
  end;

{ HttpResponseCookieAdapterObject }

  CoHttpResponseCookieAdapter = class
    class function Create: IHttpResponseCookieAdapter;
    class function CreateRemote(const MachineName: string): IHttpResponseCookieAdapter;
  end;

{ HttpRequestAdapterObject }

  CoHttpRequestAdapter = class
    class function Create: IHttpRequestAdapter;
    class function CreateRemote(const MachineName: string): IHttpRequestAdapter;
  end;

{ RequestVariablesAdapterObject }

  CoRequestVariablesAdapter = class
    class function Create: IRequestVariablesAdapter;
    class function CreateRemote(const MachineName: string): IRequestVariablesAdapter;
  end;

{ RequestCookiesAdapterObject }

  CoRequestCookiesAdapter = class
    class function Create: IRequestCookiesAdapter;
    class function CreateRemote(const MachineName: string): IRequestCookiesAdapter;
  end;

{ BrowserTypeAdapterObject }

  CoBrowserTypeAdapter = class
    class function Create: IBrowserTypeAdapter;
    class function CreateRemote(const MachineName: string): IBrowserTypeAdapter;
  end;

{ RequestCookieAdapterObject }

  CoRequestCookieAdapter = class
    class function Create: IRequestCookieAdapter;
    class function CreateRemote(const MachineName: string): IRequestCookieAdapter;
  end;

{ RequestVariableAdapterObject }

  CoRequestVariableAdapter = class
    class function Create: IRequestVariableAdapter;
    class function CreateRemote(const MachineName: string): IRequestVariableAdapter;
  end;

{ WapSessionAdapterObject }

  CoWapSessionAdapter = class
    class function Create: IWapSessionAdapter;
    class function CreateRemote(const MachineName: string): IWapSessionAdapter;
  end;

{ WapAppAdapterObject }

  CoWapAppAdapter = class
    class function Create: IWapAppAdapter;
    class function CreateRemote(const MachineName: string): IWapAppAdapter;
  end;



implementation

uses ComObj;

class function CoHttpResponseAdapter.Create: IHttpResponseAdapter;
begin
  Result := CreateComObject(Class_HttpResponseAdapter) as IHttpResponseAdapter;
end;

class function CoHttpResponseAdapter.CreateRemote(const MachineName: string): IHttpResponseAdapter;
begin
  Result := CreateRemoteComObject(MachineName, Class_HttpResponseAdapter) as IHttpResponseAdapter;
end;

class function CoHttpResponseCookieListAdapter.Create: IHttpResponseCookieListAdapter;
begin
  Result := CreateComObject(Class_HttpResponseCookieListAdapter) as IHttpResponseCookieListAdapter;
end;

class function CoHttpResponseCookieListAdapter.CreateRemote(const MachineName: string): IHttpResponseCookieListAdapter;
begin
  Result := CreateRemoteComObject(MachineName, Class_HttpResponseCookieListAdapter) as IHttpResponseCookieListAdapter;
end;

class function CoHttpResponseCookieAdapter.Create: IHttpResponseCookieAdapter;
begin
  Result := CreateComObject(Class_HttpResponseCookieAdapter) as IHttpResponseCookieAdapter;
end;

class function CoHttpResponseCookieAdapter.CreateRemote(const MachineName: string): IHttpResponseCookieAdapter;
begin
  Result := CreateRemoteComObject(MachineName, Class_HttpResponseCookieAdapter) as IHttpResponseCookieAdapter;
end;

class function CoHttpRequestAdapter.Create: IHttpRequestAdapter;
begin
  Result := CreateComObject(Class_HttpRequestAdapter) as IHttpRequestAdapter;
end;

class function CoHttpRequestAdapter.CreateRemote(const MachineName: string): IHttpRequestAdapter;
begin
  Result := CreateRemoteComObject(MachineName, Class_HttpRequestAdapter) as IHttpRequestAdapter;
end;

class function CoRequestVariablesAdapter.Create: IRequestVariablesAdapter;
begin
  Result := CreateComObject(Class_RequestVariablesAdapter) as IRequestVariablesAdapter;
end;

class function CoRequestVariablesAdapter.CreateRemote(const MachineName: string): IRequestVariablesAdapter;
begin
  Result := CreateRemoteComObject(MachineName, Class_RequestVariablesAdapter) as IRequestVariablesAdapter;
end;

class function CoRequestCookiesAdapter.Create: IRequestCookiesAdapter;
begin
  Result := CreateComObject(Class_RequestCookiesAdapter) as IRequestCookiesAdapter;
end;

class function CoRequestCookiesAdapter.CreateRemote(const MachineName: string): IRequestCookiesAdapter;
begin
  Result := CreateRemoteComObject(MachineName, Class_RequestCookiesAdapter) as IRequestCookiesAdapter;
end;

class function CoBrowserTypeAdapter.Create: IBrowserTypeAdapter;
begin
  Result := CreateComObject(Class_BrowserTypeAdapter) as IBrowserTypeAdapter;
end;

class function CoBrowserTypeAdapter.CreateRemote(const MachineName: string): IBrowserTypeAdapter;
begin
  Result := CreateRemoteComObject(MachineName, Class_BrowserTypeAdapter) as IBrowserTypeAdapter;
end;

class function CoRequestCookieAdapter.Create: IRequestCookieAdapter;
begin
  Result := CreateComObject(Class_RequestCookieAdapter) as IRequestCookieAdapter;
end;

class function CoRequestCookieAdapter.CreateRemote(const MachineName: string): IRequestCookieAdapter;
begin
  Result := CreateRemoteComObject(MachineName, Class_RequestCookieAdapter) as IRequestCookieAdapter;
end;

class function CoRequestVariableAdapter.Create: IRequestVariableAdapter;
begin
  Result := CreateComObject(Class_RequestVariableAdapter) as IRequestVariableAdapter;
end;

class function CoRequestVariableAdapter.CreateRemote(const MachineName: string): IRequestVariableAdapter;
begin
  Result := CreateRemoteComObject(MachineName, Class_RequestVariableAdapter) as IRequestVariableAdapter;
end;

class function CoWapSessionAdapter.Create: IWapSessionAdapter;
begin
  Result := CreateComObject(Class_WapSessionAdapter) as IWapSessionAdapter;
end;

class function CoWapSessionAdapter.CreateRemote(const MachineName: string): IWapSessionAdapter;
begin
  Result := CreateRemoteComObject(MachineName, Class_WapSessionAdapter) as IWapSessionAdapter;
end;

class function CoWapAppAdapter.Create: IWapAppAdapter;
begin
  Result := CreateComObject(Class_WapAppAdapter) as IWapAppAdapter;
end;

class function CoWapAppAdapter.CreateRemote(const MachineName: string): IWapAppAdapter;
begin
  Result := CreateRemoteComObject(MachineName, Class_WapAppAdapter) as IWapAppAdapter;
end;


end.
