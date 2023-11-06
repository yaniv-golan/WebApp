// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'IpcRqst.pas' rev: 3.00

#ifndef IpcRqstHPP
#define IpcRqstHPP
#include <IpcConv.hpp>
#include <WIPCShrd.hpp>
#include <IPC.hpp>
#include <HttpReq.hpp>
#include <Windows.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Ipcrqst
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TIpcRequest;
class PASCALIMPLEMENTATION TIpcRequest : public Httpreq::TAbstractHttpRequestInterface 
{
	typedef Httpreq::TAbstractHttpRequestInterface inherited;
	
private:
	Ipcconv::TIpcConversation* FConversation;
	bool FWriteToClientFailed;
	System::AnsiString FPhysicalPath;
	System::AnsiString FLogicalPath;
	System::AnsiString FMethod;
	System::AnsiString FQueryString;
	void __fastcall InitiateConversation(void);
	
public:
	__fastcall TIpcRequest(Ipcconv::TIpcConversation* Conversation);
	__fastcall virtual ~TIpcRequest(void);
	virtual System::AnsiString __fastcall GetQueryString();
	virtual System::AnsiString __fastcall GetMethod();
	virtual System::AnsiString __fastcall GetLogicalPath();
	virtual System::AnsiString __fastcall GetPhysicalPath();
	virtual int __fastcall WriteToClient(const void *Buffer, int Count);
	virtual int __fastcall ReadFromClient(void *Buffer, int Count);
	virtual int __fastcall GetInputSize(void);
	virtual System::AnsiString __fastcall GetInputContentType();
	virtual System::AnsiString __fastcall GetServerVariable(const System::AnsiString VarName);
	virtual System::AnsiString __fastcall GetHttpHeader(const System::AnsiString HeaderName);
	virtual System::AnsiString __fastcall MapURLToPath(const System::AnsiString LogicalURL);
};

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Ipcrqst */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Ipcrqst;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// IpcRqst
