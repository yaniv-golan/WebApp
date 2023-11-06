// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'HttpReq.pas' rev: 3.00

#ifndef HttpReqHPP
#define HttpReqHPP
#include <SysUtils.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Httpreq
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EAbstractHttpRequestInterface;
class PASCALIMPLEMENTATION EAbstractHttpRequestInterface : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ __fastcall EAbstractHttpRequestInterface(const System::AnsiString Msg) : Sysutils::
		Exception(Msg) { }
	/* Exception.CreateFmt */ __fastcall EAbstractHttpRequestInterface(const System::AnsiString Msg, const 
		System::TVarRec * Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ __fastcall EAbstractHttpRequestInterface(int Ident, Extended Dummy) : Sysutils::
		Exception(Ident, Dummy) { }
	/* Exception.CreateResFmt */ __fastcall EAbstractHttpRequestInterface(int Ident, const System::TVarRec 
		* Args, const int Args_Size) : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ __fastcall EAbstractHttpRequestInterface(const System::AnsiString Msg, int 
		AHelpContext) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ __fastcall EAbstractHttpRequestInterface(const System::AnsiString Msg
		, const System::TVarRec * Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, 
		Args, Args_Size, AHelpContext) { }
	/* Exception.CreateResHelp */ __fastcall EAbstractHttpRequestInterface(int Ident, int AHelpContext)
		 : Sysutils::Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ __fastcall EAbstractHttpRequestInterface(int Ident, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Ident, Args, Args_Size, AHelpContext
		) { }
	
public:
	/* TObject.Destroy */ __fastcall virtual ~EAbstractHttpRequestInterface(void) { }
	
};

class DELPHICLASS TAbstractHttpRequestInterface;
class PASCALIMPLEMENTATION TAbstractHttpRequestInterface : public System::TObject 
{
	typedef System::TObject inherited;
	
public:
	virtual System::AnsiString __fastcall GetQueryString(void) = 0;
	virtual System::AnsiString __fastcall GetMethod(void) = 0;
	virtual System::AnsiString __fastcall GetLogicalPath(void) = 0;
	virtual System::AnsiString __fastcall GetPhysicalPath(void) = 0;
	virtual int __fastcall WriteToClient(const void *Buffer, int Count) = 0;
	virtual int __fastcall ReadFromClient(void *Buffer, int Count) = 0;
	virtual int __fastcall GetInputSize(void) = 0;
	virtual System::AnsiString __fastcall GetInputContentType(void) = 0;
	virtual System::AnsiString __fastcall GetServerVariable(const System::AnsiString VarName) = 0;
	virtual System::AnsiString __fastcall GetHttpHeader(const System::AnsiString HeaderName) = 0;
	virtual System::AnsiString __fastcall MapURLToPath(const System::AnsiString LogicalURL) = 0;
public:
		
	/* TObject.Create */ __fastcall TAbstractHttpRequestInterface(void) : System::TObject() { }
	/* TObject.Destroy */ __fastcall virtual ~TAbstractHttpRequestInterface(void) { }
	
};

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Httpreq */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Httpreq;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// HttpReq
