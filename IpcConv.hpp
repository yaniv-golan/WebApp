// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'IpcConv.pas' rev: 3.00

#ifndef IpcConvHPP
#define IpcConvHPP
#include <WIPCShrd.hpp>
#include <IPC.hpp>
#include <Windows.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Ipcconv
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TIpcConversation;
class PASCALIMPLEMENTATION TIpcConversation : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	Wipcshrd::TConversationSlot *FConversationSlot;
	bool FStubGone;
	void __fastcall TerminateConversation(void);
	
public:
	__fastcall TIpcConversation(Wipcshrd::PConversationSlot ConversationSlot);
	__fastcall virtual ~TIpcConversation(void);
	void __fastcall InitiateConversation(void);
	void __fastcall SendRequest(Wipcshrd::TRequestId RequestId);
	__property Wipcshrd::PConversationSlot Slot = {read=FConversationSlot};
	__property bool StubGone = {read=FStubGone, nodefault};
};

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Ipcconv */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Ipcconv;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// IpcConv
