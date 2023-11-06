// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WapThNtf.pas' rev: 3.00

#ifndef WapThNtfHPP
#define WapThNtfHPP
#include <WapWThrd.hpp>
#include <IPC.hpp>
#include <MthdsLst.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Wapthntf
{
//-- type declarations -------------------------------------------------------
enum TThreadNotification { tnThreadInitialization, tnThreadFinalization };

typedef void __fastcall (__closure *TThreadNotificationEvent)(Wapwthrd::TWapWorkerThread* Thread, TThreadNotification 
	Notification);

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall AddOnThreadNotification(TThreadNotificationEvent Handler);
extern PACKAGE void __fastcall RemoveOnThreadNotification(TThreadNotificationEvent Handler);
extern PACKAGE void __fastcall NotifyThreadNotification(Wapwthrd::TWapWorkerThread* Thread, TThreadNotification 
	Notification);

}	/* namespace Wapthntf */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Wapthntf;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WapThNtf
