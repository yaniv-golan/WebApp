// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WIPCShrd.pas' rev: 3.00

#ifndef WIPCShrdHPP
#define WIPCShrdHPP
#include <Windows.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Wipcshrd
{
//-- type declarations -------------------------------------------------------
struct THandshakeMemData;
typedef THandshakeMemData *PHandshakeMemData;

#pragma pack(push, 1)
struct THandshakeMemData
{
	int FormatVersion;
	int StubProcessId;
	int ProxyProcessId;
	int ServerRequestTimeout;
	int ConversationIndex;
	int WaitingRequests;
} ;
#pragma pack(pop)

enum TRequestId { riDummy, riInitiateConversion, riTerminateConversation, riGetHttpHeader, riGetServerVariable, 
	riGetInputContentType, riGetInputSize, riReadFromClient, riWriteToClient, riMapURLToPath };

enum TWapCmd { wcNone, wcTest, wcRefreshConfig, wcMapURL, wcGetAppSessionCount, wcSuspendApp, wcResumeApp, 
	wcTerminateApp, wcGetAppState, wcBadWapCmd };

enum TConversationType { ctHttpRequest, ctWapCmd };

struct TConversationSlot;
typedef TConversationSlot *PConversationSlot;

#pragma pack(push, 1)
struct TConversationSlot
{
	int FormatVersion;
	bool Initialized;
	bool InUse;
	int WapProcessId;
	int Stub_hServerRequestReadyEvent;
	int Stub_hStubResponseReadyEvent;
	int Wap_hServerRequestReadyEvent;
	int Wap_hStubResponseReadyEvent;
	TConversationType ConversationType;
	TWapCmd WapCmd;
	int WapCmd_SessionCount;
	char ErrorMessage[513];
	TRequestId RequestId;
	union
	{
		char MapURLToPath_Path[1024];
		struct 
		{
			int WriteCount;
			char WriteBuffer[1024];
			
		};
		struct 
		{
			int ReadCount;
			char ReadBuffer[1024];
			
		};
		int InputSize;
		char InputContentType[51];
		struct 
		{
			char VarName[201];
			char VarValue[1025];
			
		};
		struct 
		{
			char HeaderName[201];
			char HeaderValue[1025];
			
		};
		struct 
		{
			char PhysicalPath[261];
			char LogicalPath[1201];
			char Method[31];
			char QueryString[1025];
			
		};
		
	};
} ;
#pragma pack(pop)

typedef TConversationSlot TConversationsArraySharedMem[21];

typedef TConversationsArraySharedMem *PConversationsArraySharedMem;

//-- var, const, procedure ---------------------------------------------------
#define HandshakeMemName "Wap_HandshakeMem_%s"
#define HandshakeMemLockName "Wap_HandshakeMemLock_%s"
#define WapStubRequestWaitingEventName "WapStubRequestWaiting_%s"
#define ConversationsArrayMemName "Wap_ConversationsArrayMem_%s"
#define AppInitializedEventName "Wap_AppInitialized_%s"
#define SharedCookieName "HyperAct"
#define HandshakeMemData_FormatVersion (Byte)(2)
#define ConversationSlot_FormatVersion (Byte)(2)
#define ReadWriteBufferMaxLen (Word)(2048)
#define ErrorMessageMaxLen (Word)(512)
#define ConversationsArrayMaxSize (Byte)(21)
#define ConverstationsArrayLength (Byte)(200)
#define ConverstationsArraySize (int)(612800)
extern PACKAGE System::AnsiString __fastcall FormatSharedName(const System::AnsiString BaseName, const 
	System::AnsiString AppId);

}	/* namespace Wipcshrd */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Wipcshrd;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WIPCShrd
