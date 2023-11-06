// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'AppSSI.pas' rev: 3.00

#ifndef AppSSIHPP
#define AppSSIHPP
#include <Graphics.hpp>
#include <Windows.hpp>
#include <HttpReq.hpp>
#include <SDS.hpp>
#include <BrowsCap.hpp>
#include <CookUtil.hpp>
#include <VirtText.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Appssi
{
//-- type declarations -------------------------------------------------------
enum THttpMethodType { mtGet, mtPut, mtPost, mtHead, mtAny };

class DELPHICLASS THttpTransaction;
class DELPHICLASS THttpRequest;
class DELPHICLASS TRequestVariables;
class DELPHICLASS TRequestVariable;
class PASCALIMPLEMENTATION TRequestVariables : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	System::AnsiString FAsString;
	Classes::TStrings* FVariables;
	TRequestVariable* __fastcall getVariable(const System::Variant &index);
	int __fastcall getCount(void);
	
public:
	__fastcall TRequestVariables(const System::AnsiString QueryString);
	__fastcall virtual ~TRequestVariables(void);
	__property int Count = {read=getCount, nodefault};
	__property TRequestVariable* Variables[System::Variant Index] = {read=getVariable/*, default*/};
	bool __fastcall VariableExists(System::AnsiString Index);
	__property System::AnsiString AsString = {read=FAsString};
};

class DELPHICLASS TRequestCookies;
class DELPHICLASS TRequestCookie;
class PASCALIMPLEMENTATION TRequestCookies : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	Classes::TStrings* FCookies;
	Classes::TStrings* FDummyCookies;
	__fastcall TRequestCookies(const System::AnsiString HeaderCookie);
	TRequestCookie* __fastcall getCookie(const System::Variant &index);
	int __fastcall getCount(void);
	
public:
	__fastcall virtual ~TRequestCookies(void);
	__property int Count = {read=getCount, nodefault};
	__property TRequestCookie* Cookies[System::Variant Index] = {read=getCookie/*, default*/};
	bool __fastcall CookieExists(const System::AnsiString CookieName);
public:
	/* TObject.Create */ __fastcall TRequestCookies(void) : System::TObject() { }
	
};

class PASCALIMPLEMENTATION THttpRequest : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	Httpreq::TAbstractHttpRequestInterface* FHttpInterface;
	Classes::TStream* FInputStream;
	System::AnsiString FLogicalPath;
	System::AnsiString FPhysicalPath;
	System::AnsiString FMethod;
	THttpMethodType FMethodType;
	System::AnsiString FContentType;
	System::AnsiString FCachedLiteralName;
	System::AnsiString FCachedLiteralValue;
	TRequestVariables* FQueryString;
	TRequestVariables* FForm;
	TRequestCookies* FCookies;
	Browscap::TBrowserType* FBrowserCaps;
	System::AnsiString __fastcall GetServerVariable(const System::AnsiString varName);
	System::AnsiString __fastcall GetHttpHeader(const System::AnsiString headerName);
	TRequestCookies* __fastcall GetCookies(void);
	void __fastcall RetrieveCookies(void);
	System::AnsiString __fastcall GetScriptName();
	System::AnsiString __fastcall GetRemoteUser();
	Browscap::TBrowserType* __fastcall GetBrowserCaps(void);
	TRequestVariables* __fastcall GetForm(void);
	System::AnsiString __fastcall GetLiteral(const System::AnsiString name);
	
public:
	__fastcall THttpRequest(Httpreq::TAbstractHttpRequestInterface* HttpInterface);
	__fastcall virtual ~THttpRequest(void);
	__property Classes::TStream* InputStream = {read=FInputStream};
	__property System::AnsiString ContentType = {read=FContentType};
	__property System::AnsiString Literals[System::AnsiString Name] = {read=GetLiteral/*, default*/};
	__property TRequestVariables* QueryString = {read=FQueryString};
	__property TRequestVariables* Form = {read=GetForm};
	__property TRequestCookies* Cookies = {read=GetCookies};
	__property System::AnsiString ServerVariables[System::AnsiString VarName] = {read=GetServerVariable
		};
	__property System::AnsiString HTTPHeaders[System::AnsiString HeaderName] = {read=GetHttpHeader};
	__property System::AnsiString LogicalPath = {read=FLogicalPath};
	__property System::AnsiString PhysicalPath = {read=FPhysicalPath};
	__property System::AnsiString Method = {read=FMethod};
	__property THttpMethodType MethodType = {read=FMethodType, nodefault};
	__property System::AnsiString ScriptName = {read=GetScriptName};
	__property System::AnsiString RemoteUser = {read=GetRemoteUser};
	System::AnsiString __fastcall MapPath(const System::AnsiString LogicalPath);
	__property Browscap::TBrowserType* BrowserCaps = {read=GetBrowserCaps};
};

class DELPHICLASS THttpResponse;
class PASCALIMPLEMENTATION THttpResponse : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	Httpreq::TAbstractHttpRequestInterface* FHttpInterface;
	THttpRequest* FRequest;
	System::AnsiString FStatus;
	System::AnsiString FContentType;
	int FContentLength;
	int FExpires;
	System::TDateTime FExpiresAbsolute;
	Classes::TStrings* FHeaders;
	Cookutil::THttpResponseCookieList* FCookies;
	bool FBuffer;
	Classes::TStream* FBufferStream;
	Classes::TStream* FOutputStream;
	int FOutputStreamPosition;
	int FBytesSent;
	Virttext::TCustomTextFileDriver* TextFileDriver;
	bool statusLineWritten;
	bool inWriteHeader;
	bool headerWritten;
	int __fastcall rawOutputWrite(const void *Buffer, int Count);
	void __fastcall rawWriteString(const System::AnsiString S);
	void __fastcall rawWritelnString(const System::AnsiString S);
	int __fastcall rawBodyOutputWrite(const void *Buffer, int Count);
	int __fastcall streamOutputRead(void *Buffer, int Count);
	int __fastcall streamOutputWrite(const void *Buffer, int Count);
	int __fastcall streamOutputSeek(int Offset, Word Origin);
	void __fastcall addCookiesToHeaders(void);
	void __fastcall writeHeader(void);
	void __fastcall verifyHeaderNotWritten(void);
	void __fastcall verifyBuffered(void);
	void __fastcall setBuffer(bool value);
	
public:
	System::TextFile TextOut;
	__fastcall THttpResponse(THttpRequest* Request, Httpreq::TAbstractHttpRequestInterface* RequestInterface
		);
	__fastcall virtual ~THttpResponse(void);
	__property System::AnsiString Status = {read=FStatus, write=FStatus};
	void __fastcall AddHeader(const System::AnsiString Name, const System::AnsiString Value);
	void __fastcall RequestBasicAuthentication(const System::AnsiString Realm);
	void __fastcall ClearBuffer(void);
	void __fastcall FlushBuffer(void);
	__property Cookutil::THttpResponseCookieList* Cookies = {read=FCookies};
	__property Classes::TStream* OutputStream = {read=FOutputStream};
	__property int Expires = {read=FExpires, write=FExpires, nodefault};
	__property System::TDateTime ExpiresAbsolute = {read=FExpiresAbsolute, write=FExpiresAbsolute};
	__property System::AnsiString ContentType = {read=FContentType, write=FContentType};
	__property int ContentLength = {read=FContentLength, write=FContentLength, nodefault};
	__property Classes::TStrings* Headers = {read=FHeaders};
	__property bool Buffer = {read=FBuffer, write=setBuffer, nodefault};
	void __fastcall WriteStatusLine(void);
	void __fastcall WriteHeaders(void);
	int __fastcall SendFile(const System::AnsiString Filename);
	int __fastcall SendBitmapAsGIF(Graphics::TBitmap* Bitmap);
	int __fastcall SendBitmapAsJPEG(Graphics::TBitmap* Bitmap);
	__property int BytesSent = {read=FBytesSent, nodefault};
	void __fastcall Redirect(const System::AnsiString URL);
	System::TDateTime __fastcall GetExpirationTime(void);
};

class PASCALIMPLEMENTATION THttpTransaction : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	Httpreq::TAbstractHttpRequestInterface* FRequestInterface;
	bool FOwnRequestInterface;
	THttpRequest* FRequest;
	THttpResponse* FResponse;
	
public:
	__fastcall THttpTransaction(Httpreq::TAbstractHttpRequestInterface* RequestInterface, bool OwnRequestInterface
		);
	__fastcall virtual ~THttpTransaction(void);
	__property Httpreq::TAbstractHttpRequestInterface* RawHttpRequest = {read=FRequestInterface};
	__property THttpRequest* Request = {read=FRequest};
	__property THttpResponse* Response = {read=FResponse};
};

class PASCALIMPLEMENTATION TRequestVariable : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	Classes::TStrings* FValues;
	System::AnsiString FName;
	int __fastcall getCount(void);
	System::Variant __fastcall getSubValue(int index);
	System::Variant __fastcall getValue();
	
public:
	__fastcall TRequestVariable(const System::AnsiString Name);
	__fastcall virtual ~TRequestVariable(void);
	__property System::AnsiString Name = {read=FName};
	__property int Count = {read=getCount, nodefault};
	__property System::Variant Values[int Index] = {read=getSubValue/*, default*/};
	bool __fastcall ValueExists(const System::Variant &Value);
	__property System::Variant Value = {read=getValue};
};

class PASCALIMPLEMENTATION TRequestCookie : public Classes::TPersistent 
{
	typedef Classes::TPersistent inherited;
	
private:
	Classes::TStrings* FValues;
	System::AnsiString FName;
	System::Variant FValue;
	__fastcall TRequestCookie(const System::AnsiString CookieName, const System::AnsiString CookieValue
		);
	System::Variant __fastcall getValue(const System::Variant &index);
	int __fastcall getCount(void);
	
protected:
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	
public:
	__fastcall virtual ~TRequestCookie(void);
	__property System::AnsiString Name = {read=FName};
	__property System::Variant Value = {read=FValue};
	__property int Count = {read=getCount, nodefault};
	__property System::Variant Values[System::Variant Index] = {read=getValue/*, default*/};
	bool __fastcall ValueExists(const System::AnsiString Index);
public:
	/* TObject.Create */ __fastcall TRequestCookie(void) : Classes::TPersistent() { }
	
};

class DELPHICLASS EHttpResponse;
class PASCALIMPLEMENTATION EHttpResponse : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ __fastcall EHttpResponse(const System::AnsiString Msg) : Sysutils::Exception(
		Msg) { }
	/* Exception.CreateFmt */ __fastcall EHttpResponse(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ __fastcall EHttpResponse(int Ident, Extended Dummy) : Sysutils::Exception(
		Ident, Dummy) { }
	/* Exception.CreateResFmt */ __fastcall EHttpResponse(int Ident, const System::TVarRec * Args, const 
		int Args_Size) : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ __fastcall EHttpResponse(const System::AnsiString Msg, int AHelpContext)
		 : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ __fastcall EHttpResponse(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext
		) { }
	/* Exception.CreateResHelp */ __fastcall EHttpResponse(int Ident, int AHelpContext) : Sysutils::Exception(
		Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ __fastcall EHttpResponse(int Ident, const System::TVarRec * Args, 
		const int Args_Size, int AHelpContext) : Sysutils::Exception(Ident, Args, Args_Size, AHelpContext)
		 { }
	
public:
	/* TObject.Destroy */ __fastcall virtual ~EHttpResponse(void) { }
	
};

class DELPHICLASS EResponseBuffer;
class PASCALIMPLEMENTATION EResponseBuffer : public Appssi::EHttpResponse 
{
	typedef Appssi::EHttpResponse inherited;
	
public:
	/* Exception.Create */ __fastcall EResponseBuffer(const System::AnsiString Msg) : Appssi::EHttpResponse(
		Msg) { }
	/* Exception.CreateFmt */ __fastcall EResponseBuffer(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size) : Appssi::EHttpResponse(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ __fastcall EResponseBuffer(int Ident, Extended Dummy) : Appssi::EHttpResponse(
		Ident, Dummy) { }
	/* Exception.CreateResFmt */ __fastcall EResponseBuffer(int Ident, const System::TVarRec * Args, const 
		int Args_Size) : Appssi::EHttpResponse(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ __fastcall EResponseBuffer(const System::AnsiString Msg, int AHelpContext
		) : Appssi::EHttpResponse(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ __fastcall EResponseBuffer(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Appssi::EHttpResponse(Msg, Args, Args_Size, AHelpContext
		) { }
	/* Exception.CreateResHelp */ __fastcall EResponseBuffer(int Ident, int AHelpContext) : Appssi::EHttpResponse(
		Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ __fastcall EResponseBuffer(int Ident, const System::TVarRec * Args
		, const int Args_Size, int AHelpContext) : Appssi::EHttpResponse(Ident, Args, Args_Size, AHelpContext
		) { }
	
public:
	/* TObject.Destroy */ __fastcall virtual ~EResponseBuffer(void) { }
	
};

class DELPHICLASS EResponseHeader;
class PASCALIMPLEMENTATION EResponseHeader : public Appssi::EHttpResponse 
{
	typedef Appssi::EHttpResponse inherited;
	
public:
	/* Exception.Create */ __fastcall EResponseHeader(const System::AnsiString Msg) : Appssi::EHttpResponse(
		Msg) { }
	/* Exception.CreateFmt */ __fastcall EResponseHeader(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size) : Appssi::EHttpResponse(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ __fastcall EResponseHeader(int Ident, Extended Dummy) : Appssi::EHttpResponse(
		Ident, Dummy) { }
	/* Exception.CreateResFmt */ __fastcall EResponseHeader(int Ident, const System::TVarRec * Args, const 
		int Args_Size) : Appssi::EHttpResponse(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ __fastcall EResponseHeader(const System::AnsiString Msg, int AHelpContext
		) : Appssi::EHttpResponse(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ __fastcall EResponseHeader(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Appssi::EHttpResponse(Msg, Args, Args_Size, AHelpContext
		) { }
	/* Exception.CreateResHelp */ __fastcall EResponseHeader(int Ident, int AHelpContext) : Appssi::EHttpResponse(
		Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ __fastcall EResponseHeader(int Ident, const System::TVarRec * Args
		, const int Args_Size, int AHelpContext) : Appssi::EHttpResponse(Ident, Args, Args_Size, AHelpContext
		) { }
	
public:
	/* TObject.Destroy */ __fastcall virtual ~EResponseHeader(void) { }
	
};

typedef int __fastcall (*TBitmapToJPEGStreamProc)(Graphics::TBitmap* Bitmap, Classes::TStream* Stream
	);

typedef int __fastcall (*TBitmapToGIFStreamProc)(Graphics::TBitmap* Bitmap, Classes::TStream* Stream
	);

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TBitmapToGIFStreamProc BitmapToGIFStreamProc;
extern PACKAGE TBitmapToJPEGStreamProc BitmapToJPEGStreamProc;
#define hsContinue (Byte)(100)
#define hsSwitchingProtocols (Byte)(101)
#define hsOK (Byte)(200)
#define hsCreated (Byte)(201)
#define hsAccepted (Byte)(202)
#define hsNonAuthoritativeInformation (Byte)(203)
#define hsNoContent (Byte)(204)
#define hsResetContent (Byte)(205)
#define hsPartialContent (Byte)(206)
#define hsMultipleChoices (Word)(300)
#define hsMovedPermanently (Word)(301)
#define hsMovedTemporarily (Word)(302)
#define hsSeeOther (Word)(303)
#define hsNotModified (Word)(304)
#define hsUseProxy (Word)(305)
#define hsBadRequest (Word)(400)
#define hsUnauthorized (Word)(401)
#define hsPaymentRequired (Word)(402)
#define hsForbidden (Word)(403)
#define hsNotFound (Word)(404)
#define hsMethodNotAllowed (Word)(405)
#define hsNoneAcceptable (Word)(406)
#define hsProxyAuthenticationRequired (Word)(407)
#define hsRequestTimeout (Word)(408)
#define hsConflict (Word)(409)
#define hsGone (Word)(410)
#define hsLengthRequired (Word)(411)
#define hsUnlessTrue (Word)(412)
#define hsInternalServerError (Word)(500)
#define hsNotImplemented (Word)(501)
#define hsBadGateway (Word)(502)
#define hsServiceUnavailable (Word)(503)
#define hsGatewayTimeout (Word)(504)
extern PACKAGE System::AnsiString __fastcall StatusCodeToReason(int StatusCode);
extern PACKAGE System::AnsiString __fastcall FormatStatusString(int StatusCode);
extern PACKAGE bool __fastcall DecodeBasicAuthorization(const System::AnsiString AuthorizationHeader
	, System::AnsiString &UserName, System::AnsiString &Password);

}	/* namespace Appssi */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Appssi;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// AppSSI
