// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WScrImp.pas' rev: 3.00

#ifndef WScrImpHPP
#define WScrImpHPP
#include <WScr_TLB.hpp>
#include <BrowsCap.hpp>
#include <CookUtil.hpp>
#include <HWebApp.hpp>
#include <AppSSI.hpp>
#include <ComObj.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Wscrimp
{
//-- type declarations -------------------------------------------------------
typedef System::AnsiString __fastcall (__closure *TGetBlockFunction)(int BlockId);

typedef void __fastcall (__closure *TExecuteActionBlockFunction)(int BlockId);

typedef void __fastcall (__closure *TExecuteActionEvent)(System::TObject* Sender, const System::AnsiString 
	Action);

typedef void __fastcall (__closure *TStopProc)(void);

class DELPHICLASS THttpResponseAdapter;
class PASCALIMPLEMENTATION THttpResponseAdapter : public Comobj::TAutoObject 
{
	typedef Comobj::TAutoObject inherited;
	
private:
	void *__IHttpResponseAdapter;	/* Wscr_tlb::IHttpResponseAdapter */
	
public:
	operator IHttpResponseAdapter*(void) { return (IHttpResponseAdapter*)&__IHttpResponseAdapter; }
	
private:
	Appssi::THttpResponse* FResponse;
	TGetBlockFunction FGetBlockFunction;
	TExecuteActionBlockFunction FExecuteActionBlockFunction;
	TStopProc FSTopProc;
	
protected:
	HRESULT __safecall Write(const System::WideString Value);
	HRESULT __safecall WriteBlock(int BlockId);
	HRESULT __safecall Get_Status(System::WideString &Get_Status_result);
	HRESULT __safecall Set_Status(const System::WideString Value);
	HRESULT __safecall AddHeader(const System::WideString Name, const System::WideString Value);
	HRESULT __safecall Get_ContentType(System::WideString &Get_ContentType_result);
	HRESULT __safecall Set_ContentType(const System::WideString Value);
	HRESULT __safecall ClearBuffer(void);
	HRESULT __safecall FlushBuffer(void);
	HRESULT __safecall Get_Cookies(Wscr_tlb::_di_IHttpResponseCookieListAdapter &Get_Cookies_result);
	HRESULT __safecall BinaryWrite(const System::OleVariant Value);
	HRESULT __safecall Get_Expires(int &Get_Expires_result);
	HRESULT __safecall Get_ExpiresAbsolute(System::TDateTime &Get_ExpiresAbsolute_result);
	HRESULT __safecall Set_Expires(int Value);
	HRESULT __safecall Set_ExpiresAbsolute(System::TDateTime Value);
	HRESULT __safecall Get_Buffer(Word &Get_Buffer_result);
	HRESULT __safecall Get_ContentLength(int &Get_ContentLength_result);
	HRESULT __safecall Set_Buffer(Word Value);
	HRESULT __safecall Set_ContentLength(int Value);
	HRESULT __safecall Redirect(const System::WideString URL);
	HRESULT __safecall Stop(void);
	HRESULT __safecall EncodeAction(const System::WideString ActionMacro, System::WideString &EncodeAction_result
		);
	
public:
	__property Appssi::THttpResponse* Response = {read=FResponse, write=FResponse};
	__property TGetBlockFunction GetBlockFunction = {read=FGetBlockFunction, write=FGetBlockFunction};
	__property TExecuteActionBlockFunction ExecuteActionBlockFunction = {read=FExecuteActionBlockFunction
		, write=FExecuteActionBlockFunction};
	__property TStopProc StopProc = {read=FSTopProc, write=FSTopProc};
public:
	/* TComObject.Create */ __fastcall THttpResponseAdapter(void) : Comobj::TAutoObject() { }
	/* TComObject.CreateAggregated */ __fastcall THttpResponseAdapter(const _di_IUnknown Controller) : 
		Comobj::TAutoObject(Controller) { }
	/* TComObject.CreateFromFactory */ __fastcall THttpResponseAdapter(Comobj::TComObjectFactory* Factory
		, const _di_IUnknown Controller) : Comobj::TAutoObject(Factory, Controller) { }
	/* TComObject.Destroy */ __fastcall virtual ~THttpResponseAdapter(void) { }
	
};

class DELPHICLASS THttpResponseCookieListAdapter;
class PASCALIMPLEMENTATION THttpResponseCookieListAdapter : public Comobj::TAutoObject 
{
	typedef Comobj::TAutoObject inherited;
	
private:
	void *__IHttpResponseCookieListAdapter;	/* Wscr_tlb::IHttpResponseCookieListAdapter */
	
public:
	operator IHttpResponseCookieListAdapter*(void) { return (IHttpResponseCookieListAdapter*)&__IHttpResponseCookieListAdapter; }
		
	
private:
	Cookutil::THttpResponseCookieList* FRealCookies;
	
protected:
	HRESULT __safecall Exists(const System::WideString CookieName, Word &Exists_result);
	HRESULT __safecall Clear(void);
	HRESULT __safecall Delete(const System::WideString CookieName);
	HRESULT __safecall Get_Cookies(const System::WideString CookieName, Wscr_tlb::_di_IHttpResponseCookieAdapter &Get_Cookies_result
		);
	HRESULT __safecall Get_Count(int &Get_Count_result);
	HRESULT __safecall Get_CookieAt(int Index, Wscr_tlb::_di_IHttpResponseCookieAdapter &Get_CookieAt_result
		);
	
public:
	__property Cookutil::THttpResponseCookieList* RealCookies = {read=FRealCookies, write=FRealCookies}
		;
public:
	/* TComObject.Create */ __fastcall THttpResponseCookieListAdapter(void) : Comobj::TAutoObject() { }
		
	/* TComObject.CreateAggregated */ __fastcall THttpResponseCookieListAdapter(const _di_IUnknown Controller
		) : Comobj::TAutoObject(Controller) { }
	/* TComObject.CreateFromFactory */ __fastcall THttpResponseCookieListAdapter(Comobj::TComObjectFactory* 
		Factory, const _di_IUnknown Controller) : Comobj::TAutoObject(Factory, Controller) { }
	/* TComObject.Destroy */ __fastcall virtual ~THttpResponseCookieListAdapter(void) { }
	
};

class DELPHICLASS THttpResponseCookieAdapter;
class PASCALIMPLEMENTATION THttpResponseCookieAdapter : public Comobj::TAutoObject 
{
	typedef Comobj::TAutoObject inherited;
	
private:
	void *__IHttpResponseCookieAdapter;	/* Wscr_tlb::IHttpResponseCookieAdapter */
	
public:
	operator IHttpResponseCookieAdapter*(void) { return (IHttpResponseCookieAdapter*)&__IHttpResponseCookieAdapter; }
		
	
private:
	Cookutil::THttpResponseCookie* FRealCookie;
	
protected:
	HRESULT __safecall Get_Name(System::WideString &Get_Name_result);
	HRESULT __safecall Get_Value(System::OleVariant &Get_Value_result);
	HRESULT __safecall Get_Values(const System::WideString Index, System::OleVariant &Get_Values_result
		);
	HRESULT __safecall Set_Name(const System::WideString Value);
	HRESULT __safecall Set_Value(const System::OleVariant Value);
	HRESULT __safecall Set_Values(const System::WideString Index, const System::OleVariant Value);
	HRESULT __safecall Delete(const System::WideString Index);
	HRESULT __safecall Get_Domain(System::WideString &Get_Domain_result);
	HRESULT __safecall Get_ExpiresOnLocalTime(System::TDateTime &Get_ExpiresOnLocalTime_result);
	HRESULT __safecall Get_Path(System::WideString &Get_Path_result);
	HRESULT __safecall Get_Secure(Word &Get_Secure_result);
	HRESULT __safecall Set_Domain(const System::WideString Value);
	HRESULT __safecall Set_ExpiresOnLocalTime(System::TDateTime Value);
	HRESULT __safecall Set_Path(const System::WideString Value);
	HRESULT __safecall Set_Secure(Word Value);
	HRESULT __safecall GetFormattedValue(System::WideString &GetFormattedValue_result);
	
public:
	__property Cookutil::THttpResponseCookie* RealCookie = {read=FRealCookie, write=FRealCookie};
public:
		
	/* TComObject.Create */ __fastcall THttpResponseCookieAdapter(void) : Comobj::TAutoObject() { }
	/* TComObject.CreateAggregated */ __fastcall THttpResponseCookieAdapter(const _di_IUnknown Controller
		) : Comobj::TAutoObject(Controller) { }
	/* TComObject.CreateFromFactory */ __fastcall THttpResponseCookieAdapter(Comobj::TComObjectFactory* 
		Factory, const _di_IUnknown Controller) : Comobj::TAutoObject(Factory, Controller) { }
	/* TComObject.Destroy */ __fastcall virtual ~THttpResponseCookieAdapter(void) { }
	
};

class DELPHICLASS THttpRequestAdapter;
class PASCALIMPLEMENTATION THttpRequestAdapter : public Comobj::TAutoObject 
{
	typedef Comobj::TAutoObject inherited;
	
private:
	void *__IHttpRequestAdapter;	/* Wscr_tlb::IHttpRequestAdapter */
	
public:
	operator IHttpRequestAdapter*(void) { return (IHttpRequestAdapter*)&__IHttpRequestAdapter; }
	
private:
	Appssi::THttpRequest* FRealRequest;
	
protected:
	HRESULT __safecall Get_ContentType(System::WideString &Get_ContentType_result);
	HRESULT __safecall Get_Literals(const System::WideString Name, System::WideString &Get_Literals_result
		);
	HRESULT __safecall Get_QueryString(Wscr_tlb::_di_IRequestVariablesAdapter &Get_QueryString_result);
		
	HRESULT __safecall Get_Form(Wscr_tlb::_di_IRequestVariablesAdapter &Get_Form_result);
	HRESULT __safecall Get_Cookies(Wscr_tlb::_di_IRequestCookiesAdapter &Get_Cookies_result);
	HRESULT __safecall Get_ServerVariables(const System::WideString VarName, System::WideString &Get_ServerVariables_result
		);
	HRESULT __safecall Get_HTTPHeaders(const System::WideString HeaderName, System::WideString &Get_HTTPHeaders_result
		);
	HRESULT __safecall Get_LogicalPath(System::WideString &Get_LogicalPath_result);
	HRESULT __safecall Get_PhysicalPath(System::WideString &Get_PhysicalPath_result);
	HRESULT __safecall Get_Method(System::WideString &Get_Method_result);
	HRESULT __safecall Get_ScriptName(System::WideString &Get_ScriptName_result);
	HRESULT __safecall Get_RemoteUser(System::WideString &Get_RemoteUser_result);
	HRESULT __safecall MapPath(const System::WideString LogicalPath, System::WideString &MapPath_result
		);
	HRESULT __safecall Get_BrowserCaps(Wscr_tlb::_di_IBrowserTypeAdapter &Get_BrowserCaps_result);
	
public:
	__property Appssi::THttpRequest* RealRequest = {read=FRealRequest, write=FRealRequest};
public:
	/* TComObject.Create */ __fastcall THttpRequestAdapter(void) : Comobj::TAutoObject() { }
	/* TComObject.CreateAggregated */ __fastcall THttpRequestAdapter(const _di_IUnknown Controller) : Comobj::
		TAutoObject(Controller) { }
	/* TComObject.CreateFromFactory */ __fastcall THttpRequestAdapter(Comobj::TComObjectFactory* Factory
		, const _di_IUnknown Controller) : Comobj::TAutoObject(Factory, Controller) { }
	/* TComObject.Destroy */ __fastcall virtual ~THttpRequestAdapter(void) { }
	
};

class DELPHICLASS TRequestVariablesAdapter;
class PASCALIMPLEMENTATION TRequestVariablesAdapter : public Comobj::TAutoObject 
{
	typedef Comobj::TAutoObject inherited;
	
private:
	void *__IRequestVariablesAdapter;	/* Wscr_tlb::IRequestVariablesAdapter */
	
public:
	operator IRequestVariablesAdapter*(void) { return (IRequestVariablesAdapter*)&__IRequestVariablesAdapter; }
		
	
private:
	Appssi::TRequestVariables* FRealRequestVariables;
	
protected:
	HRESULT __safecall Get_AsString(System::WideString &Get_AsString_result);
	HRESULT __safecall Get_Count(int &Get_Count_result);
	HRESULT __safecall Get_Variables(const System::OleVariant Index, Wscr_tlb::_di_IRequestVariableAdapter &Get_Variables_result
		);
	HRESULT __safecall VariableExists(const System::WideString Index, Word &VariableExists_result);
	
public:
	__property Appssi::TRequestVariables* RealRequestVariables = {read=FRealRequestVariables, write=FRealRequestVariables
		};
public:
	/* TComObject.Create */ __fastcall TRequestVariablesAdapter(void) : Comobj::TAutoObject() { }
	/* TComObject.CreateAggregated */ __fastcall TRequestVariablesAdapter(const _di_IUnknown Controller
		) : Comobj::TAutoObject(Controller) { }
	/* TComObject.CreateFromFactory */ __fastcall TRequestVariablesAdapter(Comobj::TComObjectFactory* Factory
		, const _di_IUnknown Controller) : Comobj::TAutoObject(Factory, Controller) { }
	/* TComObject.Destroy */ __fastcall virtual ~TRequestVariablesAdapter(void) { }
	
};

class DELPHICLASS TRequestCookiesAdapter;
class PASCALIMPLEMENTATION TRequestCookiesAdapter : public Comobj::TAutoObject 
{
	typedef Comobj::TAutoObject inherited;
	
private:
	void *__IRequestCookiesAdapter;	/* Wscr_tlb::IRequestCookiesAdapter */
	
public:
	operator IRequestCookiesAdapter*(void) { return (IRequestCookiesAdapter*)&__IRequestCookiesAdapter; }
		
	
private:
	Appssi::TRequestCookies* FRealRequestCookies;
	
protected:
	HRESULT __safecall CookieExists(const System::WideString CookieName, Word &CookieExists_result);
	HRESULT __safecall Get_Cookies(const System::OleVariant Index, Wscr_tlb::_di_IRequestCookieAdapter &Get_Cookies_result
		);
	HRESULT __safecall Get_Count(int &Get_Count_result);
	
public:
	__property Appssi::TRequestCookies* RealRequestCookies = {read=FRealRequestCookies, write=FRealRequestCookies
		};
public:
	/* TComObject.Create */ __fastcall TRequestCookiesAdapter(void) : Comobj::TAutoObject() { }
	/* TComObject.CreateAggregated */ __fastcall TRequestCookiesAdapter(const _di_IUnknown Controller) : 
		Comobj::TAutoObject(Controller) { }
	/* TComObject.CreateFromFactory */ __fastcall TRequestCookiesAdapter(Comobj::TComObjectFactory* Factory
		, const _di_IUnknown Controller) : Comobj::TAutoObject(Factory, Controller) { }
	/* TComObject.Destroy */ __fastcall virtual ~TRequestCookiesAdapter(void) { }
	
};

class DELPHICLASS TBrowserTypeAdapter;
class PASCALIMPLEMENTATION TBrowserTypeAdapter : public Comobj::TAutoObject 
{
	typedef Comobj::TAutoObject inherited;
	
private:
	void *__IBrowserTypeAdapter;	/* Wscr_tlb::IBrowserTypeAdapter */
	
public:
	operator IBrowserTypeAdapter*(void) { return (IBrowserTypeAdapter*)&__IBrowserTypeAdapter; }
	
private:
	Browscap::TBrowserType* FRealBrowserType;
	
protected:
	HRESULT __safecall Get_ActiveXControls(Word &Get_ActiveXControls_result);
	HRESULT __safecall Get_BackgroundSounds(Word &Get_BackgroundSounds_result);
	HRESULT __safecall Get_Beta(Word &Get_Beta_result);
	HRESULT __safecall Get_Browser(System::WideString &Get_Browser_result);
	HRESULT __safecall Get_Cookies(Word &Get_Cookies_result);
	HRESULT __safecall Get_Count(int &Get_Count_result);
	HRESULT __safecall Get_Frames(Word &Get_Frames_result);
	HRESULT __safecall Get_JavaApplets(Word &Get_JavaApplets_result);
	HRESULT __safecall Get_JavaScript(Word &Get_JavaScript_result);
	HRESULT __safecall Get_Keys(int Index, System::WideString &Get_Keys_result);
	HRESULT __safecall Get_MajorVer(int &Get_MajorVer_result);
	HRESULT __safecall Get_MinorVer(int &Get_MinorVer_result);
	HRESULT __safecall Get_Platform(System::WideString &Get_Platform_result);
	HRESULT __safecall Get_Tables(Word &Get_Tables_result);
	HRESULT __safecall Get_Values(const System::OleVariant Index, System::OleVariant &Get_Values_result
		);
	HRESULT __safecall Get_VBScript(Word &Get_VBScript_result);
	HRESULT __safecall Get_Version(System::WideString &Get_Version_result);
	
public:
	__property Browscap::TBrowserType* RealBrowserType = {read=FRealBrowserType, write=FRealBrowserType
		};
public:
	/* TComObject.Create */ __fastcall TBrowserTypeAdapter(void) : Comobj::TAutoObject() { }
	/* TComObject.CreateAggregated */ __fastcall TBrowserTypeAdapter(const _di_IUnknown Controller) : Comobj::
		TAutoObject(Controller) { }
	/* TComObject.CreateFromFactory */ __fastcall TBrowserTypeAdapter(Comobj::TComObjectFactory* Factory
		, const _di_IUnknown Controller) : Comobj::TAutoObject(Factory, Controller) { }
	/* TComObject.Destroy */ __fastcall virtual ~TBrowserTypeAdapter(void) { }
	
};

class DELPHICLASS TRequestCookieAdapter;
class PASCALIMPLEMENTATION TRequestCookieAdapter : public Comobj::TAutoObject 
{
	typedef Comobj::TAutoObject inherited;
	
private:
	void *__IRequestCookieAdapter;	/* Wscr_tlb::IRequestCookieAdapter */
	
public:
	operator IRequestCookieAdapter*(void) { return (IRequestCookieAdapter*)&__IRequestCookieAdapter; }
	
private:
	Appssi::TRequestCookie* FRealRequestCookie;
	
protected:
	HRESULT __safecall Get_Count(int &Get_Count_result);
	HRESULT __safecall Get_Name(System::WideString &Get_Name_result);
	HRESULT __safecall Get_Value(System::WideString &Get_Value_result);
	HRESULT __safecall Get_Values(const System::OleVariant Index, System::WideString &Get_Values_result
		);
	HRESULT __safecall ValueExists(const System::WideString Index, Word &ValueExists_result);
	
public:
	__property Appssi::TRequestCookie* RealRequestCookie = {read=FRealRequestCookie, write=FRealRequestCookie
		};
public:
	/* TComObject.Create */ __fastcall TRequestCookieAdapter(void) : Comobj::TAutoObject() { }
	/* TComObject.CreateAggregated */ __fastcall TRequestCookieAdapter(const _di_IUnknown Controller) : 
		Comobj::TAutoObject(Controller) { }
	/* TComObject.CreateFromFactory */ __fastcall TRequestCookieAdapter(Comobj::TComObjectFactory* Factory
		, const _di_IUnknown Controller) : Comobj::TAutoObject(Factory, Controller) { }
	/* TComObject.Destroy */ __fastcall virtual ~TRequestCookieAdapter(void) { }
	
};

class DELPHICLASS TRequestVariableAdapter;
class PASCALIMPLEMENTATION TRequestVariableAdapter : public Comobj::TAutoObject 
{
	typedef Comobj::TAutoObject inherited;
	
private:
	void *__IRequestVariableAdapter;	/* Wscr_tlb::IRequestVariableAdapter */
	
public:
	operator IRequestVariableAdapter*(void) { return (IRequestVariableAdapter*)&__IRequestVariableAdapter; }
		
	
private:
	Appssi::TRequestVariable* FRealRequestVariable;
	
protected:
	HRESULT __safecall Get_Count(int &Get_Count_result);
	HRESULT __safecall Get_Value(System::WideString &Get_Value_result);
	HRESULT __safecall Get_Values(int Index, System::WideString &Get_Values_result);
	
public:
	__property Appssi::TRequestVariable* RealRequestVariable = {read=FRealRequestVariable, write=FRealRequestVariable
		};
public:
	/* TComObject.Create */ __fastcall TRequestVariableAdapter(void) : Comobj::TAutoObject() { }
	/* TComObject.CreateAggregated */ __fastcall TRequestVariableAdapter(const _di_IUnknown Controller)
		 : Comobj::TAutoObject(Controller) { }
	/* TComObject.CreateFromFactory */ __fastcall TRequestVariableAdapter(Comobj::TComObjectFactory* Factory
		, const _di_IUnknown Controller) : Comobj::TAutoObject(Factory, Controller) { }
	/* TComObject.Destroy */ __fastcall virtual ~TRequestVariableAdapter(void) { }
	
};

class DELPHICLASS TWapAppAdapter;
class PASCALIMPLEMENTATION TWapAppAdapter : public Comobj::TAutoObject 
{
	typedef Comobj::TAutoObject inherited;
	
private:
	void *__IWapAppAdapter;	/* Wscr_tlb::IWapAppAdapter */
	
public:
	operator IWapAppAdapter*(void) { return (IWapAppAdapter*)&__IWapAppAdapter; }
	
private:
	Hwebapp::TWapApp* FRealWapApp;
	
protected:
	HRESULT __safecall Get_AppId(System::WideString &Get_AppId_result);
	HRESULT __safecall Get_MultiSession(Word &Get_MultiSession_result);
	HRESULT __safecall Get_Values(const System::WideString Index, System::OleVariant &Get_Values_result
		);
	HRESULT __safecall _Set_Values(const System::WideString Index, const System::OleVariant Value);
	HRESULT __safecall Set_Values(const System::WideString Index, System::OleVariant &Value);
	HRESULT __safecall Lock(void);
	HRESULT __safecall Unlock(void);
	HRESULT __safecall Clear(void);
	
public:
	__property Hwebapp::TWapApp* RealWapApp = {read=FRealWapApp, write=FRealWapApp};
public:
	/* TComObject.Create */ __fastcall TWapAppAdapter(void) : Comobj::TAutoObject() { }
	/* TComObject.CreateAggregated */ __fastcall TWapAppAdapter(const _di_IUnknown Controller) : Comobj::
		TAutoObject(Controller) { }
	/* TComObject.CreateFromFactory */ __fastcall TWapAppAdapter(Comobj::TComObjectFactory* Factory, const 
		_di_IUnknown Controller) : Comobj::TAutoObject(Factory, Controller) { }
	/* TComObject.Destroy */ __fastcall virtual ~TWapAppAdapter(void) { }
	
};

class DELPHICLASS TWapSessionAdapter;
class PASCALIMPLEMENTATION TWapSessionAdapter : public Comobj::TAutoObject 
{
	typedef Comobj::TAutoObject inherited;
	
private:
	void *__IWapSessionAdapter;	/* Wscr_tlb::IWapSessionAdapter */
	
public:
	operator IWapSessionAdapter*(void) { return (IWapSessionAdapter*)&__IWapSessionAdapter; }
	
private:
	Hwebapp::TWapSession* FRealWapSession;
	TExecuteActionEvent FOnExecuteAction;
	
protected:
	HRESULT __safecall Get_Values(const System::WideString Index, System::OleVariant &Get_Values_result
		);
	HRESULT __safecall _Set_Values(const System::WideString Index, const System::OleVariant Value);
	HRESULT __safecall Set_Values(const System::WideString Index, System::OleVariant &Value);
	HRESULT __safecall Get_SessionId(System::WideString &Get_SessionId_result);
	HRESULT __safecall Get_LastAccess(System::TDateTime &Get_LastAccess_result);
	HRESULT __safecall Get_Timeout(int &Get_Timeout_result);
	HRESULT __safecall Set_Timeout(int Value);
	HRESULT __safecall Abandon(void);
	HRESULT __safecall Clear(void);
	HRESULT __safecall ExecuteAction(const System::WideString Action);
	
public:
	__property Hwebapp::TWapSession* RealWapSession = {read=FRealWapSession, write=FRealWapSession};
	__property TExecuteActionEvent OnExecuteAction = {read=FOnExecuteAction, write=FOnExecuteAction};
public:
		
	/* TComObject.Create */ __fastcall TWapSessionAdapter(void) : Comobj::TAutoObject() { }
	/* TComObject.CreateAggregated */ __fastcall TWapSessionAdapter(const _di_IUnknown Controller) : Comobj::
		TAutoObject(Controller) { }
	/* TComObject.CreateFromFactory */ __fastcall TWapSessionAdapter(Comobj::TComObjectFactory* Factory
		, const _di_IUnknown Controller) : Comobj::TAutoObject(Factory, Controller) { }
	/* TComObject.Destroy */ __fastcall virtual ~TWapSessionAdapter(void) { }
	
};

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Wscrimp */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Wscrimp;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WScrImp
