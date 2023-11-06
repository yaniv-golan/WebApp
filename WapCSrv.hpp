// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WapCSrv.pas' rev: 3.00

#ifndef WapCSrvHPP
#define WapCSrvHPP
#include <ComObj.hpp>
#include <SysUtils.hpp>
#include <ActiveX.hpp>
#include <Windows.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Wapcsrv
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TWapComServer;
class PASCALIMPLEMENTATION TWapComServer : public Comobj::TComServerObject 
{
	typedef Comobj::TComServerObject inherited;
	
private:
	int FObjectCount;
	int FFactoryCount;
	_di_ITypeLib FTypeLib;
	System::AnsiString FServerName;
	System::AnsiString FHelpFileName;
	bool FIsInprocServer;
	void __fastcall FactoryFree(Comobj::TComObjectFactory* Factory);
	void __fastcall FactoryRegisterClassObject(Comobj::TComObjectFactory* Factory);
	
protected:
	virtual int __fastcall CountObject(bool Created);
	virtual int __fastcall CountFactory(bool Created);
	virtual System::AnsiString __fastcall GetHelpFileName();
	virtual System::AnsiString __fastcall GetServerFileName();
	virtual System::AnsiString __fastcall GetServerKey();
	virtual System::AnsiString __fastcall GetServerName();
	virtual _di_ITypeLib __fastcall GetTypeLib();
	
public:
	__fastcall TWapComServer(void);
	__fastcall virtual ~TWapComServer(void);
	void __fastcall Initialize(void);
	void __fastcall LoadTypeLib(void);
	void __fastcall SetServerName(const System::AnsiString Name);
	__property bool IsInprocServer = {read=FIsInprocServer, write=FIsInprocServer, nodefault};
	__property int ObjectCount = {read=FObjectCount, nodefault};
};

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TWapComServer* WapComServer;

}	/* namespace Wapcsrv */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Wapcsrv;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WapCSrv
