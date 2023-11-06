// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'HWebApp.pas' rev: 3.00

#ifndef HWebAppHPP
#define HWebAppHPP
#include <SDS.hpp>
#include <MthdsLst.hpp>
#include <WapActns.hpp>
#include <WVarDict.hpp>
#include <HttpReq.hpp>
#include <AppSSI.hpp>
#include <IPC.hpp>
#include <Graphics.hpp>
#include <Controls.hpp>
#include <Forms.hpp>
#include <Windows.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------
// FreeModule is defined in winbase.h as an alias for FreeLibrary.
// This definition conflicts with the definition of TWapSession.FreeModule.
// We will un-define FreeModule here :
#undef FreeModule

namespace Hwebapp
{
//-- type declarations -------------------------------------------------------
enum TWapAppNotification { wnApplicationStart, wnApplicationEnd, wnSessionStart, wnSessionEnd, wnRequestStart, 
	wnRequestEnd };

typedef void __fastcall (__closure *TWapAppExceptionEvent)(System::TObject* Sender, Sysutils::Exception* 
	E, Appssi::THttpRequest* Request, Appssi::THttpResponse* Response);

class DELPHICLASS TWapApp;
typedef void __fastcall (__closure *TWapAppNotifyEvent)(TWapApp* App);

typedef void __fastcall (__closure *TWapAppExecuteEvent)(System::TObject* Sender, Appssi::THttpRequest* 
	Request, Appssi::THttpResponse* Response);

class DELPHICLASS TWapSession;
typedef void __fastcall (__closure *TCreateSessionEvent)(System::TObject* Sender, TWapSession* &Session
	);

typedef void __fastcall (__closure *TWapSessionNotifyEvent)(TWapSession* Session);

typedef void __fastcall (__closure *TWapAppNotificationEvent)(System::TObject* Sender, TWapAppNotification 
	Notification);

class DELPHICLASS TWapSessionState;
typedef void __fastcall (__closure *TSaveStateEvent)(System::TObject* Sender, TWapSessionState* State
	);

class DELPHICLASS EWapApp;
class PASCALIMPLEMENTATION EWapApp : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ __fastcall EWapApp(const System::AnsiString Msg) : Sysutils::Exception(Msg) { }
		
	/* Exception.CreateFmt */ __fastcall EWapApp(const System::AnsiString Msg, const System::TVarRec * 
		Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ __fastcall EWapApp(int Ident, Extended Dummy) : Sysutils::Exception(Ident
		, Dummy) { }
	/* Exception.CreateResFmt */ __fastcall EWapApp(int Ident, const System::TVarRec * Args, const int 
		Args_Size) : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ __fastcall EWapApp(const System::AnsiString Msg, int AHelpContext) : Sysutils::
		Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ __fastcall EWapApp(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext
		) { }
	/* Exception.CreateResHelp */ __fastcall EWapApp(int Ident, int AHelpContext) : Sysutils::Exception(
		Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ __fastcall EWapApp(int Ident, const System::TVarRec * Args, const 
		int Args_Size, int AHelpContext) : Sysutils::Exception(Ident, Args, Args_Size, AHelpContext) { }
	
public:
	/* TObject.Destroy */ __fastcall virtual ~EWapApp(void) { }
	
};

class DELPHICLASS EWapSession;
class PASCALIMPLEMENTATION EWapSession : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ __fastcall EWapSession(const System::AnsiString Msg) : Sysutils::Exception(Msg
		) { }
	/* Exception.CreateFmt */ __fastcall EWapSession(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ __fastcall EWapSession(int Ident, Extended Dummy) : Sysutils::Exception(Ident
		, Dummy) { }
	/* Exception.CreateResFmt */ __fastcall EWapSession(int Ident, const System::TVarRec * Args, const 
		int Args_Size) : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ __fastcall EWapSession(const System::AnsiString Msg, int AHelpContext) : 
		Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ __fastcall EWapSession(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext
		) { }
	/* Exception.CreateResHelp */ __fastcall EWapSession(int Ident, int AHelpContext) : Sysutils::Exception(
		Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ __fastcall EWapSession(int Ident, const System::TVarRec * Args, const 
		int Args_Size, int AHelpContext) : Sysutils::Exception(Ident, Args, Args_Size, AHelpContext) { }
	
public:
	/* TObject.Destroy */ __fastcall virtual ~EWapSession(void) { }
	
};

class DELPHICLASS TWapSessionList;
class PASCALIMPLEMENTATION TWapSessionList : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	Classes::TStringList* FSessions;
	Ipc::TWin32CriticalSection* FLock;
	Ipc::TWin32Event* FEmptyEvent;
	int __fastcall GetCount(void);
	TWapSession* __fastcall GetSessionByIndex(int Index);
	__property Ipc::TWin32Event* EmptyEvent = {read=FEmptyEvent, write=FEmptyEvent};
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation
		);
	
public:
	__fastcall virtual TWapSessionList(Classes::TComponent* AOwner);
	__fastcall virtual ~TWapSessionList(void);
	void __fastcall Lock(void);
	void __fastcall Unlock(void);
	void __fastcall Add(TWapSession* Session);
	void __fastcall Delete(TWapSession* Session);
	TWapSession* __fastcall GetSession(const System::AnsiString SessionId);
	void __fastcall FreeSession(TWapSession* Session);
	__property int Count = {read=GetCount, nodefault};
	__property TWapSession* Sessions[int Index] = {read=GetSessionByIndex/*, default*/};
};

class PASCALIMPLEMENTATION TWapApp : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	System::AnsiString FAppId;
	bool FMultiSession;
	int FActiveRequests;
	bool FDebugMode;
	bool FActive;
	TWapAppExecuteEvent FOnExecute;
	TWapAppNotifyEvent FOnStart;
	TWapAppNotifyEvent FOnEnd;
	TCreateSessionEvent FOnCreateSession;
	TWapAppExceptionEvent FOnException;
	TWapAppNotificationEvent FOnNotify;
	System::TObject* FScheduler;
	System::TObject* FRequestsReader;
	TWapSessionList* FSessionList;
	Ipc::TWin32Event* FAppInitializedEvent;
	bool FIsFirstRequest;
	Ipc::TThreadEx* FOldSessionsCleanerThread;
	int FWebAppModuleHandle;
	System::AnsiString FAppRoot;
	Wvardict::TVariantList* FValues;
	System::Variant __fastcall GetValue(System::AnsiString Index);
	void __fastcall SetValue(System::AnsiString Index, const System::Variant &Value);
	void __fastcall SetAppId(const System::AnsiString value);
	void __fastcall DispatchToSession(int ThreadToken, TWapSession* &Session, Appssi::THttpRequest* Request
		, Appssi::THttpResponse* Response);
	void __fastcall InitSharedCookie(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response);
	void __fastcall SetDebugMode(bool Value);
	int __fastcall GetThreadCount(void);
	void __fastcall InternalOnExceptionHandler(System::TObject* Sender, Sysutils::Exception* E);
	
protected:
	virtual void __fastcall AppIdChanged(void);
	void __fastcall HandleRequestsReaderException(System::TObject* Sender, Sysutils::Exception* E);
	virtual TWapSession* __fastcall CreateSession(void);
	virtual void __fastcall AppStart(void);
	virtual void __fastcall AppEnd(void);
	virtual void __fastcall Execute(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response);
	virtual void __fastcall Notify(TWapAppNotification Notification);
	
public:
	__fastcall virtual TWapApp(Classes::TComponent* AOwner);
	__fastcall virtual ~TWapApp(void);
	virtual void __fastcall HandleException(System::TObject* Sender, Appssi::THttpRequest* Request, Appssi::THttpResponse* 
		Response);
	virtual void __fastcall ReportException(System::TObject* Sender, Sysutils::Exception* E, Appssi::THttpRequest* 
		Request, Appssi::THttpResponse* Response);
	void __fastcall Clear(void);
	void __fastcall Lock(void);
	void __fastcall Unlock(void);
	void __fastcall Start(void);
	void __fastcall Stop(void);
	__property bool Active = {read=FActive, nodefault};
	__property int ActiveRequests = {read=FActiveRequests, nodefault};
	__property System::Variant Values[System::AnsiString Index] = {read=GetValue, write=SetValue/*, default
		*/};
	__property TWapSessionList* Sessions = {read=FSessionList};
	__property bool DebugMode = {read=FDebugMode, write=SetDebugMode, nodefault};
	__property int ThreadCount = {read=GetThreadCount, nodefault};
	/*         class method */ static int __fastcall GetMaxThreadsPerCPU(System::TMetaClass* vmt);
	/*         class method */ static void __fastcall SetMaxThreadsPerCPU(System::TMetaClass* vmt, int 
		Value);
	/*         class method */ static int __fastcall GetMaxThreads(System::TMetaClass* vmt);
	/*         class method */ static void __fastcall SetMaxThreads(System::TMetaClass* vmt, int Value)
		;
	void __fastcall InternalExecute(int ThreadToken, TWapSession* &Session, Appssi::THttpRequest* Request
		, Appssi::THttpResponse* Response);
	
__published:
	__property System::AnsiString AppId = {read=FAppId, write=SetAppId};
	__property bool MultiSession = {read=FMultiSession, write=FMultiSession, nodefault};
	__property TWapAppNotifyEvent OnStart = {read=FOnStart, write=FOnStart};
	__property TWapAppExecuteEvent OnExecute = {read=FOnExecute, write=FOnExecute};
	__property TWapAppNotifyEvent OnEnd = {read=FOnEnd, write=FOnEnd};
	__property TCreateSessionEvent OnCreateSession = {read=FOnCreateSession, write=FOnCreateSession};
	__property TWapAppExceptionEvent OnException = {read=FOnException, write=FOnException};
	__property TWapAppNotificationEvent OnNotify = {read=FOnNotify, write=FOnNotify};
};

enum HWebApp__4 { wsExecuting, wsAbandoned };

typedef Set<HWebApp__4, wsExecuting, wsAbandoned>  TWapSessionStatus;

enum TWapSessionEvent { wseRequestStart, wseRequestEnd };

typedef void __fastcall (__closure *TWapSessionNotificationEvent)(TWapSession* Session, TWapSessionEvent 
	Event);

class PASCALIMPLEMENTATION TWapSession : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	System::AnsiString FSessionId;
	Appssi::THttpRequest* FRequest;
	Appssi::THttpResponse* FResponse;
	TWapApp* FApplication;
	TWapSessionStatus FStatus;
	int FWaitingRequests;
	int FThreadToken;
	int FTimeout;
	Wapactns::TWapActionItems* FActions;
	System::TDateTime FLastAccess;
	TWapSessionNotifyEvent FOnStart;
	TWapSessionNotifyEvent FOnEnd;
	TWapSessionNotifyEvent FOnExecute;
	bool FFirstTime;
	Ipc::TWin32CriticalSection* FExecuteLock;
	bool FActionsDispatched;
	System::TMetaClass*FFormClassToCreate;
	Controls::TWinControl* FFormToDestroy;
	Controls::TWinControl* FCreatedForm;
	Forms::TCustomForm* FFormToGetImage;
	Graphics::TBitmap* FFormImage;
	Mthdslst::TNotificationList* FNotificationList;
	Wvardict::TVariantList* FValues;
	bool SessionEndCalled;
	Classes::TComponent* VisualComponentsOwner;
	System::Variant __fastcall GetValue(System::AnsiString Index);
	void __fastcall SetValue(System::AnsiString Index, const System::Variant &Value);
	void __fastcall SetActions(Wapactns::TWapActionItems* Value);
	Appssi::THttpRequest* __fastcall GetRequest(void);
	Appssi::THttpResponse* __fastcall GetResponse(void);
	TWapSessionStatus __fastcall GetStatus(void);
	void __fastcall SynchCreateForm(void);
	void __fastcall SynchFreeForm(void);
	void __fastcall SynchGetFormImage(void);
	Classes::TComponent* __fastcall UnsafeCreateModule(Classes::TComponent* Owner, System::TMetaClass* 
		ModuleClass);
	void __fastcall SynchDestroyVisualComponents(void);
	void __fastcall InternalExecute(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation
		);
	virtual void __fastcall SessionStart(void);
	virtual void __fastcall Execute(void);
	virtual void __fastcall SessionEnd(void);
	void __fastcall LockSession(void);
	void __fastcall UnLockSession(void);
	
public:
	__fastcall virtual TWapSession(Classes::TComponent* AOwner);
	__fastcall virtual ~TWapSession(void);
	void __fastcall AddNotificationHandler(TWapSessionNotificationEvent Handler);
	void __fastcall RemoveNotificationHandler(TWapSessionNotificationEvent Handler);
	bool __fastcall DispatchActions(void);
	void __fastcall Abandon(void);
	void __fastcall Clear(void);
	Classes::TComponent* __fastcall CreateModule(System::TMetaClass* ModuleClass);
	void __fastcall FreeModule(Classes::TComponent* Module);
	Controls::TWinControl* __fastcall CreateForm(System::TMetaClass* FormClass);
	void __fastcall FreeForm(Controls::TWinControl* Form);
	Graphics::TBitmap* __fastcall GetFormImage(Forms::TCustomForm* Form);
	__property TWapApp* Application = {read=FApplication};
	__property Appssi::THttpRequest* Request = {read=GetRequest};
	__property Appssi::THttpResponse* Response = {read=GetResponse};
	__property System::AnsiString SessionId = {read=FSessionId};
	__property System::TDateTime LastAccess = {read=FLastAccess};
	__property int WaitingRequests = {read=FWaitingRequests, nodefault};
	__property TWapSessionStatus Status = {read=GetStatus, nodefault};
	__property System::Variant Values[System::AnsiString Index] = {read=GetValue, write=SetValue/*, default
		*/};
	__property int ThreadToken = {read=FThreadToken, nodefault};
	
__published:
	__property int Timeout = {read=FTimeout, write=FTimeout, nodefault};
	__property Wapactns::TWapActionItems* Actions = {read=FActions, write=SetActions, stored=true};
	__property TWapSessionNotifyEvent OnStart = {read=FOnStart, write=FOnStart};
	__property TWapSessionNotifyEvent OnExecute = {read=FOnExecute, write=FOnExecute};
	__property TWapSessionNotifyEvent OnEnd = {read=FOnEnd, write=FOnEnd};
};

class DELPHICLASS TWapModule;
class PASCALIMPLEMENTATION TWapModule : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	TWapSession* FSession;
	Appssi::THttpRequest* __fastcall GetRequest(void);
	Appssi::THttpResponse* __fastcall GetResponse(void);
	void __fastcall VerifySession(void);
	
public:
	__property Appssi::THttpRequest* Request = {read=GetRequest};
	__property Appssi::THttpResponse* Response = {read=GetResponse};
	
__published:
	__property TWapSession* Session = {read=FSession, write=FSession};
public:
	/* TComponent.Create */ __fastcall virtual TWapModule(Classes::TComponent* AOwner) : Classes::TComponent(
		AOwner) { }
	/* TComponent.Destroy */ __fastcall virtual ~TWapModule(void) { }
	
};

class PASCALIMPLEMENTATION TWapSessionState : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	Wvardict::TVariantList* FValues;
	Sds::TExStringList* FObjects;
	Classes::TComponent* __fastcall GetObject(const System::AnsiString Name);
	void __fastcall SetObject(const System::AnsiString Name, Classes::TComponent* Instance);
	
public:
	__fastcall TWapSessionState(void);
	__fastcall virtual ~TWapSessionState(void);
	__property Wvardict::TVariantList* Values = {read=FValues};
	__property Classes::TComponent* Objects[System::AnsiString Name] = {read=GetObject, write=SetObject
		};
};

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Hwebapp */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Hwebapp;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// HWebApp
