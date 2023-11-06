// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'DBWap.pas' rev: 3.00

#ifndef DBWapHPP
#define DBWapHPP
#include <WapWThrd.hpp>
#include <WapThNtf.hpp>
#include <DBTables.hpp>
#include <Db.hpp>
#include <Classes.hpp>
#include <SysUtils.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Dbwap
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EDBAutoSession;
class PASCALIMPLEMENTATION EDBAutoSession : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ __fastcall EDBAutoSession(const System::AnsiString Msg) : Sysutils::Exception(
		Msg) { }
	/* Exception.CreateFmt */ __fastcall EDBAutoSession(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ __fastcall EDBAutoSession(int Ident, Extended Dummy) : Sysutils::Exception(
		Ident, Dummy) { }
	/* Exception.CreateResFmt */ __fastcall EDBAutoSession(int Ident, const System::TVarRec * Args, const 
		int Args_Size) : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ __fastcall EDBAutoSession(const System::AnsiString Msg, int AHelpContext
		) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ __fastcall EDBAutoSession(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext
		) { }
	/* Exception.CreateResHelp */ __fastcall EDBAutoSession(int Ident, int AHelpContext) : Sysutils::Exception(
		Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ __fastcall EDBAutoSession(int Ident, const System::TVarRec * Args, 
		const int Args_Size, int AHelpContext) : Sysutils::Exception(Ident, Args, Args_Size, AHelpContext)
		 { }
	
public:
	/* TObject.Destroy */ __fastcall virtual ~EDBAutoSession(void) { }
	
};

class DELPHICLASS TDBAutoSession;
class PASCALIMPLEMENTATION TDBAutoSession : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	Dbtables::TSession* FSession;
	void __fastcall SetSessionNames(void);
	/*         class method */ static void __fastcall HandleSessionOnPassword(System::TMetaClass* vmt, 
		System::TObject* Sender, bool &Continue);
	/*         class method */ static void __fastcall ThreadNotification(System::TMetaClass* vmt, Wapwthrd::TWapWorkerThread* 
		Thread, Wapthntf::TThreadNotification Notification);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation
		);
	virtual void __fastcall Loaded(void);
	
public:
	__fastcall virtual TDBAutoSession(Classes::TComponent* AOwner);
	__fastcall virtual ~TDBAutoSession(void);
	__property Dbtables::TSession* Session = {read=FSession};
};

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Dbtables::TSession* __fastcall GetSessionForThreadId(int ThreadId);
extern PACKAGE Dbtables::TSession* __fastcall GetSessionForCurrentThread(void);
extern PACKAGE void __fastcall Register(void);

}	/* namespace Dbwap */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Dbwap;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// DBWap
