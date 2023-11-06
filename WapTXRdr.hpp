// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WapTXRdr.pas' rev: 3.00

#ifndef WapTXRdrHPP
#define WapTXRdrHPP
#include <IpcConv.hpp>
#include <WIPCShrd.hpp>
#include <IPC.hpp>
#include <HWebApp.hpp>
#include <WapSchdl.hpp>
#include <AppSSI.hpp>
#include <HttpReq.hpp>
#include <Forms.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Waptxrdr
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS EWapRequestsReader;
class PASCALIMPLEMENTATION EWapRequestsReader : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ __fastcall EWapRequestsReader(const System::AnsiString Msg) : Sysutils::Exception(
		Msg) { }
	/* Exception.CreateFmt */ __fastcall EWapRequestsReader(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ __fastcall EWapRequestsReader(int Ident, Extended Dummy) : Sysutils::Exception(
		Ident, Dummy) { }
	/* Exception.CreateResFmt */ __fastcall EWapRequestsReader(int Ident, const System::TVarRec * Args, 
		const int Args_Size) : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ __fastcall EWapRequestsReader(const System::AnsiString Msg, int AHelpContext
		) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ __fastcall EWapRequestsReader(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext
		) { }
	/* Exception.CreateResHelp */ __fastcall EWapRequestsReader(int Ident, int AHelpContext) : Sysutils::
		Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ __fastcall EWapRequestsReader(int Ident, const System::TVarRec * Args
		, const int Args_Size, int AHelpContext) : Sysutils::Exception(Ident, Args, Args_Size, AHelpContext
		) { }
	
public:
	/* TObject.Destroy */ __fastcall virtual ~EWapRequestsReader(void) { }
	
};

class DELPHICLASS TWapRequestsReader;
class PASCALIMPLEMENTATION TWapRequestsReader : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	Hwebapp::TWapApp* FApp;
	Wapschdl::TWapScheduler* FScheduler;
	Hwebapp::TWapSessionList* FSessionList;
	Ipc::TSharedMemory* FHandshakeMem;
	Wipcshrd::THandshakeMemData *FHandshakeMemPtr;
	Ipc::TWin32Mutex* FHandshakeMemLock;
	Ipc::TWin32Event* FWapStubRequestWaitingEvent;
	Classes::TThread* FWorkerThread;
	Ipc::TWin32Event* FTerminateWorkerThread;
	int FStubTimeout;
	Forms::TExceptionEvent FOnException;
	Ipc::TSharedMemory* ConverstationsArrayMem;
	Wipcshrd::TConversationsArraySharedMem *ConverstationsArrayPtr;
	void __fastcall HandleRequest(Httpreq::TAbstractHttpRequestInterface* RequestInterface);
	void __fastcall HandleGetSessionCount(Ipcconv::TIpcConversation* Conversation);
	void __fastcall HandleTerminate(Ipcconv::TIpcConversation* Conversation);
	void __fastcall DoPostQuitMessage(void);
	void __fastcall ExecuteThread(void);
	System::AnsiString __fastcall InternalFormatSharedName(const System::AnsiString BaseName);
	void __fastcall SetStubTimeout(int Value);
	
protected:
	void __fastcall HandleException(Sysutils::Exception* E);
	
public:
	__fastcall TWapRequestsReader(Hwebapp::TWapApp* App, Wapschdl::TWapScheduler* Scheduler, Hwebapp::TWapSessionList* 
		SessionList);
	__fastcall virtual ~TWapRequestsReader(void);
	void __fastcall Start(void);
	void __fastcall Stop(void);
	__property Hwebapp::TWapApp* App = {read=FApp};
	__property Wapschdl::TWapScheduler* Scheduler = {read=FScheduler};
	__property Hwebapp::TWapSessionList* SessionList = {read=FSessionList};
	__property int StubTimeout = {read=FStubTimeout, write=SetStubTimeout, nodefault};
	__property Forms::TExceptionEvent OnException = {read=FOnException, write=FOnException};
};

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Waptxrdr */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Waptxrdr;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WapTXRdr
