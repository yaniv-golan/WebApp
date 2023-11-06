// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WapWThrd.pas' rev: 3.00

#ifndef WapWThrdHPP
#define WapWThrdHPP
#include <HWebApp.hpp>
#include <AppSSI.hpp>
#include <IPC.hpp>
#include <SDS.hpp>
#include <Forms.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Wapwthrd
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TWapWorkerThread;
class PASCALIMPLEMENTATION TWapWorkerThread : public Ipc::TThreadEx 
{
	typedef Ipc::TThreadEx inherited;
	
private:
	int FSessionCount;
	Sds::TQueue* FQueue;
	Ipc::TWin32Event* FQueueNotEmpty;
	Classes::TComponent* FInternalComponent;
	int __fastcall GetWaitingJobs(void);
	void __fastcall SessionFreeNotification(Hwebapp::TWapSession* Session);
	void __fastcall ExecuteTopJob(void);
	void __fastcall QueueJob(System::TObject* Job);
	void __fastcall DoExecute(Ipc::TThreadEx* Thread);
	
public:
	__fastcall TWapWorkerThread(void);
	__fastcall virtual ~TWapWorkerThread(void);
	void __fastcall QueueForExecution(Hwebapp::TWapApp* App, Hwebapp::TWapSession* Session, Appssi::THttpTransaction* 
		Transaction);
	void __fastcall QueueForRemoval(Hwebapp::TWapSessionList* SessionList, Hwebapp::TWapSession* Session
		);
	__property int WaitingJobs = {read=GetWaitingJobs, nodefault};
	__property int SessionCount = {read=FSessionCount, nodefault};
};

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Wapwthrd */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Wapwthrd;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WapWThrd
