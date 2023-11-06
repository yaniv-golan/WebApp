// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Unit2.pas' rev: 3.00

#ifndef Unit2HPP
#define Unit2HPP
#include <HtmlTxt.hpp>
#include <AppSSI.hpp>
#include <HWebApp.hpp>
#include <Dialogs.hpp>
#include <Forms.hpp>
#include <Controls.hpp>
#include <Graphics.hpp>
#include <Classes.hpp>
#include <SysUtils.hpp>
#include <Messages.hpp>
#include <Windows.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Unit2
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TSessionModule;
class PASCALIMPLEMENTATION TSessionModule : public Forms::TDataModule 
{
	typedef Forms::TDataModule inherited;
	
__published:
	Hwebapp::TWapSession* WapSession1;
	void __fastcall WapSession1Start(Hwebapp::TWapSession* Session);
	void __fastcall WapSession1Execute(Hwebapp::TWapSession* Session);
	void __fastcall WapSession1End(Hwebapp::TWapSession* Session);
	
private:
	int FCounter;
	Appssi::THttpRequest* __fastcall GetRequest(void);
	Appssi::THttpResponse* __fastcall GetResponse(void);
	
public:
	__property Appssi::THttpRequest* Request = {read=GetRequest};
	__property Appssi::THttpResponse* Response = {read=GetResponse};
public:
	/* TDataModule.Create */ __fastcall virtual TSessionModule(Classes::TComponent* AOwner) : Forms::TDataModule(
		AOwner) { }
	/* TDataModule.CreateNew */ __fastcall TSessionModule(Classes::TComponent* AOwner, int Dummy) : Forms::
		TDataModule(AOwner, Dummy) { }
	/* TDataModule.Destroy */ __fastcall virtual ~TSessionModule(void) { }
	
};

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TSessionModule* SessionModule;

}	/* namespace Unit2 */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Unit2;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// Unit2
