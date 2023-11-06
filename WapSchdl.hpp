// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WapSchdl.pas' rev: 3.00

#ifndef WapSchdlHPP
#define WapSchdlHPP
#include <WapWThrd.hpp>
#include <AppSSI.hpp>
#include <HWebApp.hpp>
#include <Windows.hpp>
#include <IPC.hpp>
#include <SDS.hpp>
#include <D3SysUtl.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Wapschdl
{
//-- type declarations -------------------------------------------------------
enum TBusyFactor { btBySessions, btByJobs };

class DELPHICLASS TWapScheduler;
class PASCALIMPLEMENTATION TWapScheduler : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	Classes::TList* FThreads;
	int FInitialThreadCount;
	Wapwthrd::TWapWorkerThread* __fastcall FindLeastBusyThread(TBusyFactor Factor);
	int __fastcall GetThreadCount(void);
	
public:
	__fastcall virtual TWapScheduler(Classes::TComponent* AOwner);
	__fastcall virtual ~TWapScheduler(void);
	void __fastcall Start(void);
	bool __fastcall Stop(int Timeout);
	void __fastcall ScheduleForExecution(Hwebapp::TWapApp* App, Hwebapp::TWapSession* Session, Appssi::THttpTransaction* 
		Transaction);
	void __fastcall ScheduleForRemoval(Hwebapp::TWapSessionList* SessionList, Hwebapp::TWapSession* Session
		);
	__property int InitialThreadCount = {read=FInitialThreadCount, write=FInitialThreadCount, nodefault
		};
	__property int ThreadCount = {read=GetThreadCount, nodefault};
	/*         class method */ static int __fastcall GetMaxThreadsPerCPU(System::TMetaClass* vmt);
	/*         class method */ static void __fastcall SetMaxThreadsPerCPU(System::TMetaClass* vmt, int 
		Value);
	/*         class method */ static int __fastcall GetMaxThreads(System::TMetaClass* vmt);
	/*         class method */ static void __fastcall SetMaxThreads(System::TMetaClass* vmt, int Value)
		;
};

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Wapschdl */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Wapschdl;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WapSchdl
