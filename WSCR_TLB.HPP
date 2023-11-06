// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WScr_TLB.pas' rev: 3.00

#ifndef WScr_TLBHPP
#define WScr_TLBHPP
#include <StdVCL.hpp>
#include <OleCtrls.hpp>
#include <Graphics.hpp>
#include <Classes.hpp>
#include <ActiveX.hpp>
#include <Windows.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Wscr_tlb
{
//-- type declarations -------------------------------------------------------
__interface IHttpResponseAdapter;
typedef System::DelphiInterface<IHttpResponseAdapter> _di_IHttpResponseAdapter;
__interface IHttpResponseCookieListAdapter;
typedef System::DelphiInterface<IHttpResponseCookieListAdapter> _di_IHttpResponseCookieListAdapter;
__interface IHttpResponseAdapter : public IDispatch /* __guid="{5238F2D1-D38B-11D0-9CDD-6AEA77000000}" */
	
{
	
public:
	virtual HRESULT __safecall Write(const System::WideString Value) = 0;
	virtual HRESULT __safecall WriteBlock(int BlockId) = 0;
	virtual HRESULT __safecall Get_Status(System::WideString &Get_Status_result) = 0;
	virtual HRESULT __safecall Set_Status(const System::WideString Value) = 0;
	virtual HRESULT __safecall AddHeader(const System::WideString Name, const System::WideString Value)
		 = 0;
	virtual HRESULT __safecall Get_ContentType(System::WideString &Get_ContentType_result) = 0;
	virtual HRESULT __safecall Set_ContentType(const System::WideString Value) = 0;
	virtual HRESULT __safecall ClearBuffer(void) = 0;
	virtual HRESULT __safecall FlushBuffer(void) = 0;
	virtual HRESULT __safecall Get_Cookies(_di_IHttpResponseCookieListAdapter &Get_Cookies_result) = 0;
		
	virtual HRESULT __safecall BinaryWrite(const System::OleVariant Value) = 0;
	virtual HRESULT __safecall Get_Expires(int &Get_Expires_result) = 0;
	virtual HRESULT __safecall Set_Expires(int Value) = 0;
	virtual HRESULT __safecall Get_ExpiresAbsolute(System::TDateTime &Get_ExpiresAbsolute_result) = 0;
	virtual HRESULT __safecall Set_ExpiresAbsolute(System::TDateTime Value) = 0;
	virtual HRESULT __safecall Get_ContentLength(int &Get_ContentLength_result) = 0;
	virtual HRESULT __safecall Set_ContentLength(int Value) = 0;
	virtual HRESULT __safecall Get_Buffer(Word &Get_Buffer_result) = 0;
	virtual HRESULT __safecall Set_Buffer(Word Value) = 0;
	virtual HRESULT __safecall Redirect(const System::WideString URL) = 0;
	virtual HRESULT __safecall Stop(void) = 0;
	virtual HRESULT __safecall EncodeAction(const System::WideString ActionMacro, System::WideString &EncodeAction_result
		) = 0;
	/* safecall wrapper */ System::WideString _scw_Get_Status() { System::WideString r; HRESULT hr = Get_Status(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString Status = {read=_scw_Get_Status, write=Set_Status};
	/* safecall wrapper */ System::WideString _scw_Get_ContentType() { System::WideString r; HRESULT hr = Get_ContentType(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString ContentType = {read=_scw_Get_ContentType, write=Set_ContentType};
	/* safecall wrapper */ _di_IHttpResponseCookieListAdapter _scw_Get_Cookies() { _di_IHttpResponseCookieListAdapter r; HRESULT hr = Get_Cookies(
		r); System::CheckSafecallResult(hr); return r; }
	__property _di_IHttpResponseCookieListAdapter Cookies = {read=_scw_Get_Cookies};
	/* safecall wrapper */ int _scw_Get_Expires() { int r; HRESULT hr = Get_Expires(r); System::CheckSafecallResult(hr); return r; }
		
	__property int Expires = {read=_scw_Get_Expires, write=Set_Expires};
	/* safecall wrapper */ System::TDateTime _scw_Get_ExpiresAbsolute() { System::TDateTime r; HRESULT hr = Get_ExpiresAbsolute(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::TDateTime ExpiresAbsolute = {read=_scw_Get_ExpiresAbsolute, write=Set_ExpiresAbsolute
		};
	/* safecall wrapper */ int _scw_Get_ContentLength() { int r; HRESULT hr = Get_ContentLength(r); System::CheckSafecallResult(hr); return r; }
		
	__property int ContentLength = {read=_scw_Get_ContentLength, write=Set_ContentLength};
	/* safecall wrapper */ Word _scw_Get_Buffer() { Word r; HRESULT hr = Get_Buffer(r); System::CheckSafecallResult(hr); return r; }
		
	__property Word Buffer = {read=_scw_Get_Buffer, write=Set_Buffer};
};
typedef IHttpResponseAdapter HttpResponseAdapter;

typedef IHttpResponseCookieListAdapter HttpResponseCookieListAdapter;
;

__interface IHttpResponseCookieAdapter;
typedef System::DelphiInterface<IHttpResponseCookieAdapter> _di_IHttpResponseCookieAdapter;
__interface IHttpResponseCookieAdapter : public IDispatch /* __guid="{2483A206-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
public:
	virtual HRESULT __safecall Get_Name(System::WideString &Get_Name_result) = 0;
	virtual HRESULT __safecall Set_Name(const System::WideString Value) = 0;
	virtual HRESULT __safecall Get_Value(System::OleVariant &Get_Value_result) = 0;
	virtual HRESULT __safecall Set_Value(const System::OleVariant Value) = 0;
	virtual HRESULT __safecall Get_Values(const System::WideString ndex, System::OleVariant &Get_Values_result
		) = 0;
	virtual HRESULT __safecall Set_Values(const System::WideString ndex, const System::OleVariant Value
		) = 0;
	virtual HRESULT __safecall Delete(const System::WideString Index) = 0;
	virtual HRESULT __safecall Get_Path(System::WideString &Get_Path_result) = 0;
	virtual HRESULT __safecall Set_Path(const System::WideString Value) = 0;
	virtual HRESULT __safecall Get_Domain(System::WideString &Get_Domain_result) = 0;
	virtual HRESULT __safecall Set_Domain(const System::WideString Value) = 0;
	virtual HRESULT __safecall Get_Secure(Word &Get_Secure_result) = 0;
	virtual HRESULT __safecall Set_Secure(Word Value) = 0;
	virtual HRESULT __safecall Get_ExpiresOnLocalTime(System::TDateTime &Get_ExpiresOnLocalTime_result)
		 = 0;
	virtual HRESULT __safecall Set_ExpiresOnLocalTime(System::TDateTime Value) = 0;
	virtual HRESULT __safecall GetFormattedValue(System::WideString &GetFormattedValue_result) = 0;
	/* safecall wrapper */ System::WideString _scw_Get_Name() { System::WideString r; HRESULT hr = Get_Name(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString Name = {read=_scw_Get_Name, write=Set_Name};
	/* safecall wrapper */ System::OleVariant _scw_Get_Value() { System::OleVariant r; HRESULT hr = Get_Value(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::OleVariant Value = {read=_scw_Get_Value, write=Set_Value};
	/* safecall wrapper */ System::OleVariant _scw_Get_Values(const System::WideString ndex) { System::OleVariant r; HRESULT hr = Get_Values(
		ndex, r); System::CheckSafecallResult(hr); return r; }
	__property System::OleVariant Values[System::WideString ndex] = {read=_scw_Get_Values, write=Set_Values
		/*, default*/};
	/* safecall wrapper */ System::WideString _scw_Get_Path() { System::WideString r; HRESULT hr = Get_Path(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString Path = {read=_scw_Get_Path, write=Set_Path};
	/* safecall wrapper */ System::WideString _scw_Get_Domain() { System::WideString r; HRESULT hr = Get_Domain(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString Domain = {read=_scw_Get_Domain, write=Set_Domain};
	/* safecall wrapper */ Word _scw_Get_Secure() { Word r; HRESULT hr = Get_Secure(r); System::CheckSafecallResult(hr); return r; }
		
	__property Word Secure = {read=_scw_Get_Secure, write=Set_Secure};
	/* safecall wrapper */ System::TDateTime _scw_Get_ExpiresOnLocalTime() { System::TDateTime r; HRESULT hr = Get_ExpiresOnLocalTime(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::TDateTime ExpiresOnLocalTime = {read=_scw_Get_ExpiresOnLocalTime, write=Set_ExpiresOnLocalTime
		};
};
typedef IHttpResponseCookieAdapter HttpResponseCookieAdapter;

__interface IHttpRequestAdapter;
typedef System::DelphiInterface<IHttpRequestAdapter> _di_IHttpRequestAdapter;
__interface IRequestVariablesAdapter;
typedef System::DelphiInterface<IRequestVariablesAdapter> _di_IRequestVariablesAdapter;
__interface IRequestCookiesAdapter;
typedef System::DelphiInterface<IRequestCookiesAdapter> _di_IRequestCookiesAdapter;
__interface IBrowserTypeAdapter;
typedef System::DelphiInterface<IBrowserTypeAdapter> _di_IBrowserTypeAdapter;
__interface IHttpRequestAdapter : public IDispatch /* __guid="{2483A208-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
public:
	virtual HRESULT __safecall Get_ContentType(System::WideString &Get_ContentType_result) = 0;
	virtual HRESULT __safecall Get_Literals(const System::WideString Name, System::WideString &Get_Literals_result
		) = 0;
	virtual HRESULT __safecall Get_QueryString(_di_IRequestVariablesAdapter &Get_QueryString_result) = 0
		;
	virtual HRESULT __safecall Get_Form(_di_IRequestVariablesAdapter &Get_Form_result) = 0;
	virtual HRESULT __safecall Get_Cookies(_di_IRequestCookiesAdapter &Get_Cookies_result) = 0;
	virtual HRESULT __safecall Get_ServerVariables(const System::WideString VarName, System::WideString &Get_ServerVariables_result
		) = 0;
	virtual HRESULT __safecall Get_HTTPHeaders(const System::WideString HeaderName, System::WideString &Get_HTTPHeaders_result
		) = 0;
	virtual HRESULT __safecall Get_LogicalPath(System::WideString &Get_LogicalPath_result) = 0;
	virtual HRESULT __safecall Get_PhysicalPath(System::WideString &Get_PhysicalPath_result) = 0;
	virtual HRESULT __safecall Get_Method(System::WideString &Get_Method_result) = 0;
	virtual HRESULT __safecall Get_ScriptName(System::WideString &Get_ScriptName_result) = 0;
	virtual HRESULT __safecall Get_RemoteUser(System::WideString &Get_RemoteUser_result) = 0;
	virtual HRESULT __safecall MapPath(const System::WideString LogicalPath, System::WideString &MapPath_result
		) = 0;
	virtual HRESULT __safecall Get_BrowserCaps(_di_IBrowserTypeAdapter &Get_BrowserCaps_result) = 0;
	/* safecall wrapper */ System::WideString _scw_Get_ContentType() { System::WideString r; HRESULT hr = Get_ContentType(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString ContentType = {read=_scw_Get_ContentType};
	/* safecall wrapper */ System::WideString _scw_Get_Literals(const System::WideString Name) { System::WideString r; HRESULT hr = Get_Literals(
		Name, r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString Literals[System::WideString Name] = {read=_scw_Get_Literals/*, default
		*/};
	/* safecall wrapper */ _di_IRequestVariablesAdapter _scw_Get_QueryString() { _di_IRequestVariablesAdapter r; HRESULT hr = Get_QueryString(
		r); System::CheckSafecallResult(hr); return r; }
	__property _di_IRequestVariablesAdapter QueryString = {read=_scw_Get_QueryString};
	/* safecall wrapper */ _di_IRequestVariablesAdapter _scw_Get_Form() { _di_IRequestVariablesAdapter r; HRESULT hr = Get_Form(
		r); System::CheckSafecallResult(hr); return r; }
	__property _di_IRequestVariablesAdapter Form = {read=_scw_Get_Form};
	/* safecall wrapper */ _di_IRequestCookiesAdapter _scw_Get_Cookies() { _di_IRequestCookiesAdapter r; HRESULT hr = Get_Cookies(
		r); System::CheckSafecallResult(hr); return r; }
	__property _di_IRequestCookiesAdapter Cookies = {read=_scw_Get_Cookies};
	/* safecall wrapper */ System::WideString _scw_Get_ServerVariables(const System::WideString VarName
		) { System::WideString r; HRESULT hr = Get_ServerVariables(VarName, r); System::CheckSafecallResult(hr); return r; }
		
	__property System::WideString ServerVariables[System::WideString VarName] = {read=_scw_Get_ServerVariables
		};
	/* safecall wrapper */ System::WideString _scw_Get_HTTPHeaders(const System::WideString HeaderName) { System::WideString r; HRESULT hr = Get_HTTPHeaders(
		HeaderName, r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString HTTPHeaders[System::WideString HeaderName] = {read=_scw_Get_HTTPHeaders
		};
	/* safecall wrapper */ System::WideString _scw_Get_LogicalPath() { System::WideString r; HRESULT hr = Get_LogicalPath(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString LogicalPath = {read=_scw_Get_LogicalPath};
	/* safecall wrapper */ System::WideString _scw_Get_PhysicalPath() { System::WideString r; HRESULT hr = Get_PhysicalPath(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString PhysicalPath = {read=_scw_Get_PhysicalPath};
	/* safecall wrapper */ System::WideString _scw_Get_Method() { System::WideString r; HRESULT hr = Get_Method(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString Method = {read=_scw_Get_Method};
	/* safecall wrapper */ System::WideString _scw_Get_ScriptName() { System::WideString r; HRESULT hr = Get_ScriptName(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString ScriptName = {read=_scw_Get_ScriptName};
	/* safecall wrapper */ System::WideString _scw_Get_RemoteUser() { System::WideString r; HRESULT hr = Get_RemoteUser(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString RemoteUser = {read=_scw_Get_RemoteUser};
	/* safecall wrapper */ _di_IBrowserTypeAdapter _scw_Get_BrowserCaps() { _di_IBrowserTypeAdapter r; HRESULT hr = Get_BrowserCaps(
		r); System::CheckSafecallResult(hr); return r; }
	__property _di_IBrowserTypeAdapter BrowserCaps = {read=_scw_Get_BrowserCaps};
};
typedef IHttpRequestAdapter HttpRequestAdapter;

typedef IRequestVariablesAdapter RequestVariablesAdapter;
;

typedef IRequestCookiesAdapter RequestCookiesAdapter;
;

typedef IBrowserTypeAdapter BrowserTypeAdapter;
;

__interface IRequestCookieAdapter;
typedef System::DelphiInterface<IRequestCookieAdapter> _di_IRequestCookieAdapter;
__interface IRequestCookieAdapter : public IDispatch /* __guid="{2483A210-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
public:
	virtual HRESULT __safecall Get_Name(System::WideString &Get_Name_result) = 0;
	virtual HRESULT __safecall Get_Value(System::WideString &Get_Value_result) = 0;
	virtual HRESULT __safecall Get_Count(int &Get_Count_result) = 0;
	virtual HRESULT __safecall Get_Values(const System::OleVariant Index, System::WideString &Get_Values_result
		) = 0;
	virtual HRESULT __safecall ValueExists(const System::WideString Index, Word &ValueExists_result) = 0
		;
	/* safecall wrapper */ System::WideString _scw_Get_Name() { System::WideString r; HRESULT hr = Get_Name(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString Name = {read=_scw_Get_Name};
	/* safecall wrapper */ System::WideString _scw_Get_Value() { System::WideString r; HRESULT hr = Get_Value(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString Value = {read=_scw_Get_Value};
	/* safecall wrapper */ int _scw_Get_Count() { int r; HRESULT hr = Get_Count(r); System::CheckSafecallResult(hr); return r; }
		
	__property int Count = {read=_scw_Get_Count};
	/* safecall wrapper */ System::WideString _scw_Get_Values(const System::OleVariant Index) { System::WideString r; HRESULT hr = Get_Values(
		Index, r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString Values[System::OleVariant Index] = {read=_scw_Get_Values/*, default*/
		};
};
typedef IRequestCookieAdapter RequestCookieAdapter;

__interface IRequestVariableAdapter;
typedef System::DelphiInterface<IRequestVariableAdapter> _di_IRequestVariableAdapter;
__interface IRequestVariableAdapter : public IDispatch /* __guid="{2483A212-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
public:
	virtual HRESULT __safecall Get_Count(int &Get_Count_result) = 0;
	virtual HRESULT __safecall Get_Values(int Index, System::WideString &Get_Values_result) = 0;
	virtual HRESULT __safecall Get_Value(System::WideString &Get_Value_result) = 0;
	/* safecall wrapper */ int _scw_Get_Count() { int r; HRESULT hr = Get_Count(r); System::CheckSafecallResult(hr); return r; }
		
	__property int Count = {read=_scw_Get_Count};
	/* safecall wrapper */ System::WideString _scw_Get_Values(int Index) { System::WideString r; HRESULT hr = Get_Values(
		Index, r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString Values[int Index] = {read=_scw_Get_Values/*, default*/};
	/* safecall wrapper */ System::WideString _scw_Get_Value() { System::WideString r; HRESULT hr = Get_Value(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString Value = {read=_scw_Get_Value};
};
typedef IRequestVariableAdapter RequestVariableAdapter;

__interface IWapSessionAdapter;
typedef System::DelphiInterface<IWapSessionAdapter> _di_IWapSessionAdapter;
__interface IWapSessionAdapter : public IDispatch /* __guid="{DFEAAB50-D42C-11D0-9CDE-8898FB000000}" */
	
{
	
public:
	virtual HRESULT __safecall Get_Values(const System::WideString Index, System::OleVariant &Get_Values_result
		) = 0;
	virtual HRESULT __safecall _Set_Values(const System::WideString Index, const System::OleVariant Value
		) = 0;
	virtual HRESULT __safecall Set_Values(const System::WideString Index, System::OleVariant &Value) = 0
		;
	virtual HRESULT __safecall Get_SessionId(System::WideString &Get_SessionId_result) = 0;
	virtual HRESULT __safecall Get_LastAccess(System::TDateTime &Get_LastAccess_result) = 0;
	virtual HRESULT __safecall Get_Timeout(int &Get_Timeout_result) = 0;
	virtual HRESULT __safecall Set_Timeout(int Value) = 0;
	virtual HRESULT __safecall Abandon(void) = 0;
	virtual HRESULT __safecall Clear(void) = 0;
	virtual HRESULT __safecall ExecuteAction(const System::WideString Action) = 0;
	/* safecall wrapper */ System::OleVariant _scw_Get_Values(const System::WideString Index) { System::OleVariant r; HRESULT hr = Get_Values(
		Index, r); System::CheckSafecallResult(hr); return r; }
	__property System::OleVariant Values[System::WideString Index] = {read=_scw_Get_Values, write=Set_Values
		/*, default*/};
	/* safecall wrapper */ System::WideString _scw_Get_SessionId() { System::WideString r; HRESULT hr = Get_SessionId(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString SessionId = {read=_scw_Get_SessionId};
	/* safecall wrapper */ System::TDateTime _scw_Get_LastAccess() { System::TDateTime r; HRESULT hr = Get_LastAccess(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::TDateTime LastAccess = {read=_scw_Get_LastAccess};
	/* safecall wrapper */ int _scw_Get_Timeout() { int r; HRESULT hr = Get_Timeout(r); System::CheckSafecallResult(hr); return r; }
		
	__property int Timeout = {read=_scw_Get_Timeout, write=Set_Timeout};
};
typedef IWapSessionAdapter WapSessionAdapter;

__interface IWapAppAdapter;
typedef System::DelphiInterface<IWapAppAdapter> _di_IWapAppAdapter;
__interface IWapAppAdapter : public IDispatch /* __guid="{DFEAAB54-D42C-11D0-9CDE-8898FB000000}" */
{
	
public:
	virtual HRESULT __safecall Get_AppId(System::WideString &Get_AppId_result) = 0;
	virtual HRESULT __safecall Get_MultiSession(Word &Get_MultiSession_result) = 0;
	virtual HRESULT __safecall Clear(void) = 0;
	virtual HRESULT __safecall Get_Values(const System::WideString Index, System::OleVariant &Get_Values_result
		) = 0;
	virtual HRESULT __safecall _Set_Values(const System::WideString Index, const System::OleVariant Value
		) = 0;
	virtual HRESULT __safecall Set_Values(const System::WideString Index, System::OleVariant &Value) = 0
		;
	virtual HRESULT __safecall Lock(void) = 0;
	virtual HRESULT __safecall Unlock(void) = 0;
	/* safecall wrapper */ System::WideString _scw_Get_AppId() { System::WideString r; HRESULT hr = Get_AppId(
		r); System::CheckSafecallResult(hr); return r; }
	__property System::WideString AppId = {read=_scw_Get_AppId};
	/* safecall wrapper */ Word _scw_Get_MultiSession() { Word r; HRESULT hr = Get_MultiSession(r); System::CheckSafecallResult(hr); return r; }
		
	__property Word MultiSession = {read=_scw_Get_MultiSession};
	/* safecall wrapper */ System::OleVariant _scw_Get_Values(const System::WideString Index) { System::OleVariant r; HRESULT hr = Get_Values(
		Index, r); System::CheckSafecallResult(hr); return r; }
	__property System::OleVariant Values[System::WideString Index] = {read=_scw_Get_Values, write=Set_Values
		/*, default*/};
};
typedef IWapAppAdapter WapAppAdapter;

__dispinterface IHttpResponseAdapterDisp;
typedef System::DelphiInterface<IHttpResponseAdapterDisp> _di_IHttpResponseAdapterDisp;
__dispinterface IHttpResponseAdapterDisp: public IDispatch /* __guid="{5238F2D1-D38B-11D0-9CDD-6AEA77000000}" */
	
{
	
};

__dispinterface IHttpResponseCookieListAdapterDisp;
typedef System::DelphiInterface<IHttpResponseCookieListAdapterDisp> _di_IHttpResponseCookieListAdapterDisp;
	
__dispinterface IHttpResponseCookieListAdapterDisp: public IDispatch /* __guid="{2483A204-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
};

__dispinterface IHttpResponseCookieAdapterDisp;
typedef System::DelphiInterface<IHttpResponseCookieAdapterDisp> _di_IHttpResponseCookieAdapterDisp;
__dispinterface IHttpResponseCookieAdapterDisp: public IDispatch /* __guid="{2483A206-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
};

__dispinterface IHttpRequestAdapterDisp;
typedef System::DelphiInterface<IHttpRequestAdapterDisp> _di_IHttpRequestAdapterDisp;
__dispinterface IHttpRequestAdapterDisp: public IDispatch /* __guid="{2483A208-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
};

__dispinterface IRequestVariablesAdapterDisp;
typedef System::DelphiInterface<IRequestVariablesAdapterDisp> _di_IRequestVariablesAdapterDisp;
__dispinterface IRequestVariablesAdapterDisp: public IDispatch /* __guid="{2483A20A-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
};

__dispinterface IRequestCookiesAdapterDisp;
typedef System::DelphiInterface<IRequestCookiesAdapterDisp> _di_IRequestCookiesAdapterDisp;
__dispinterface IRequestCookiesAdapterDisp: public IDispatch /* __guid="{2483A20C-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
};

__dispinterface IBrowserTypeAdapterDisp;
typedef System::DelphiInterface<IBrowserTypeAdapterDisp> _di_IBrowserTypeAdapterDisp;
__dispinterface IBrowserTypeAdapterDisp: public IDispatch /* __guid="{2483A20E-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
};

__dispinterface IRequestCookieAdapterDisp;
typedef System::DelphiInterface<IRequestCookieAdapterDisp> _di_IRequestCookieAdapterDisp;
__dispinterface IRequestCookieAdapterDisp: public IDispatch /* __guid="{2483A210-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
};

__dispinterface IRequestVariableAdapterDisp;
typedef System::DelphiInterface<IRequestVariableAdapterDisp> _di_IRequestVariableAdapterDisp;
__dispinterface IRequestVariableAdapterDisp: public IDispatch /* __guid="{2483A212-D3F5-11D0-9CDE-8898FB000000}" */
	
{
	
};

__dispinterface IWapSessionAdapterDisp;
typedef System::DelphiInterface<IWapSessionAdapterDisp> _di_IWapSessionAdapterDisp;
__dispinterface IWapSessionAdapterDisp: public IDispatch /* __guid="{DFEAAB50-D42C-11D0-9CDE-8898FB000000}" */
	
{
	
};

__dispinterface IWapAppAdapterDisp;
typedef System::DelphiInterface<IWapAppAdapterDisp> _di_IWapAppAdapterDisp;
__dispinterface IWapAppAdapterDisp: public IDispatch /* __guid="{DFEAAB54-D42C-11D0-9CDE-8898FB000000}" */
	
{
	
};

class DELPHICLASS CoHttpResponseAdapter;
class PASCALIMPLEMENTATION CoHttpResponseAdapter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static _di_IHttpResponseAdapter __fastcall Create(System::TMetaClass* vmt
		);
	/*         class method */ static _di_IHttpResponseAdapter __fastcall CreateRemote(System::TMetaClass* vmt
		, const System::AnsiString MachineName);
public:
	/* TObject.Create */ __fastcall CoHttpResponseAdapter(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~CoHttpResponseAdapter(void) { }
	
};

class DELPHICLASS CoHttpResponseCookieListAdapter;
class PASCALIMPLEMENTATION CoHttpResponseCookieListAdapter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static _di_IHttpResponseCookieListAdapter __fastcall Create(System::TMetaClass* vmt
		);
	/*         class method */ static _di_IHttpResponseCookieListAdapter __fastcall CreateRemote(System::TMetaClass* vmt
		, const System::AnsiString MachineName);
public:
	/* TObject.Create */ __fastcall CoHttpResponseCookieListAdapter(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~CoHttpResponseCookieListAdapter(void) { }
	
};

class DELPHICLASS CoHttpResponseCookieAdapter;
class PASCALIMPLEMENTATION CoHttpResponseCookieAdapter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static _di_IHttpResponseCookieAdapter __fastcall Create(System::TMetaClass* vmt
		);
	/*         class method */ static _di_IHttpResponseCookieAdapter __fastcall CreateRemote(System::TMetaClass* vmt
		, const System::AnsiString MachineName);
public:
	/* TObject.Create */ __fastcall CoHttpResponseCookieAdapter(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~CoHttpResponseCookieAdapter(void) { }
	
};

class DELPHICLASS CoHttpRequestAdapter;
class PASCALIMPLEMENTATION CoHttpRequestAdapter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static _di_IHttpRequestAdapter __fastcall Create(System::TMetaClass* vmt
		);
	/*         class method */ static _di_IHttpRequestAdapter __fastcall CreateRemote(System::TMetaClass* vmt
		, const System::AnsiString MachineName);
public:
	/* TObject.Create */ __fastcall CoHttpRequestAdapter(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~CoHttpRequestAdapter(void) { }
	
};

class DELPHICLASS CoRequestVariablesAdapter;
class PASCALIMPLEMENTATION CoRequestVariablesAdapter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static _di_IRequestVariablesAdapter __fastcall Create(System::TMetaClass* vmt
		);
	/*         class method */ static _di_IRequestVariablesAdapter __fastcall CreateRemote(System::TMetaClass* vmt
		, const System::AnsiString MachineName);
public:
	/* TObject.Create */ __fastcall CoRequestVariablesAdapter(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~CoRequestVariablesAdapter(void) { }
	
};

class DELPHICLASS CoRequestCookiesAdapter;
class PASCALIMPLEMENTATION CoRequestCookiesAdapter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static _di_IRequestCookiesAdapter __fastcall Create(System::TMetaClass* vmt
		);
	/*         class method */ static _di_IRequestCookiesAdapter __fastcall CreateRemote(System::TMetaClass* vmt
		, const System::AnsiString MachineName);
public:
	/* TObject.Create */ __fastcall CoRequestCookiesAdapter(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~CoRequestCookiesAdapter(void) { }
	
};

class DELPHICLASS CoBrowserTypeAdapter;
class PASCALIMPLEMENTATION CoBrowserTypeAdapter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static _di_IBrowserTypeAdapter __fastcall Create(System::TMetaClass* vmt
		);
	/*         class method */ static _di_IBrowserTypeAdapter __fastcall CreateRemote(System::TMetaClass* vmt
		, const System::AnsiString MachineName);
public:
	/* TObject.Create */ __fastcall CoBrowserTypeAdapter(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~CoBrowserTypeAdapter(void) { }
	
};

class DELPHICLASS CoRequestCookieAdapter;
class PASCALIMPLEMENTATION CoRequestCookieAdapter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static _di_IRequestCookieAdapter __fastcall Create(System::TMetaClass* vmt
		);
	/*         class method */ static _di_IRequestCookieAdapter __fastcall CreateRemote(System::TMetaClass* vmt
		, const System::AnsiString MachineName);
public:
	/* TObject.Create */ __fastcall CoRequestCookieAdapter(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~CoRequestCookieAdapter(void) { }
	
};

class DELPHICLASS CoRequestVariableAdapter;
class PASCALIMPLEMENTATION CoRequestVariableAdapter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static _di_IRequestVariableAdapter __fastcall Create(System::TMetaClass* vmt
		);
	/*         class method */ static _di_IRequestVariableAdapter __fastcall CreateRemote(System::TMetaClass* vmt
		, const System::AnsiString MachineName);
public:
	/* TObject.Create */ __fastcall CoRequestVariableAdapter(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~CoRequestVariableAdapter(void) { }
	
};

class DELPHICLASS CoWapSessionAdapter;
class PASCALIMPLEMENTATION CoWapSessionAdapter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static _di_IWapSessionAdapter __fastcall Create(System::TMetaClass* vmt)
		;
	/*         class method */ static _di_IWapSessionAdapter __fastcall CreateRemote(System::TMetaClass* vmt
		, const System::AnsiString MachineName);
public:
	/* TObject.Create */ __fastcall CoWapSessionAdapter(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~CoWapSessionAdapter(void) { }
	
};

class DELPHICLASS CoWapAppAdapter;
class PASCALIMPLEMENTATION CoWapAppAdapter : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	/*         class method */ static _di_IWapAppAdapter __fastcall Create(System::TMetaClass* vmt);
	/*         class method */ static _di_IWapAppAdapter __fastcall CreateRemote(System::TMetaClass* vmt
		, const System::AnsiString MachineName);
public:
	/* TObject.Create */ __fastcall CoWapAppAdapter(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~CoWapAppAdapter(void) { }
	
};

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE GUID LIBID_WScr;
extern PACKAGE GUID Class_HttpResponseAdapter;
extern PACKAGE GUID Class_HttpResponseCookieListAdapter;
extern PACKAGE GUID Class_HttpResponseCookieAdapter;
extern PACKAGE GUID Class_HttpRequestAdapter;
extern PACKAGE GUID Class_RequestVariablesAdapter;
extern PACKAGE GUID Class_RequestCookiesAdapter;
extern PACKAGE GUID Class_BrowserTypeAdapter;
extern PACKAGE GUID Class_RequestCookieAdapter;
extern PACKAGE GUID Class_RequestVariableAdapter;
extern PACKAGE GUID Class_WapSessionAdapter;
extern PACKAGE GUID Class_WapAppAdapter;

}	/* namespace Wscr_tlb */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Wscr_tlb;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WScr_TLB
