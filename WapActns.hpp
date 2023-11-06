// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WapActns.pas' rev: 3.00

#ifndef WapActnsHPP
#define WapActnsHPP
#include <MthdsLst.hpp>
#include <WapMask.hpp>
#include <WVarDict.hpp>
#include <AppSSI.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Wapactns
{
//-- type declarations -------------------------------------------------------
typedef THttpRequest THttpRequest;
;

typedef THttpResponse THttpResponse;
;

typedef TVariantList TVariantList;
;

typedef TVariantList TWapVariantDictionary;
;

class DELPHICLASS EUnsupportedVerb;
class PASCALIMPLEMENTATION EUnsupportedVerb : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ __fastcall EUnsupportedVerb(const System::AnsiString Msg) : Sysutils::Exception(
		Msg) { }
	/* Exception.CreateFmt */ __fastcall EUnsupportedVerb(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ __fastcall EUnsupportedVerb(int Ident, Extended Dummy) : Sysutils::Exception(
		Ident, Dummy) { }
	/* Exception.CreateResFmt */ __fastcall EUnsupportedVerb(int Ident, const System::TVarRec * Args, const 
		int Args_Size) : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ __fastcall EUnsupportedVerb(const System::AnsiString Msg, int AHelpContext
		) : Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ __fastcall EUnsupportedVerb(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext
		) { }
	/* Exception.CreateResHelp */ __fastcall EUnsupportedVerb(int Ident, int AHelpContext) : Sysutils::
		Exception(Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ __fastcall EUnsupportedVerb(int Ident, const System::TVarRec * Args
		, const int Args_Size, int AHelpContext) : Sysutils::Exception(Ident, Args, Args_Size, AHelpContext
		) { }
	
public:
	/* TObject.Destroy */ __fastcall virtual ~EUnsupportedVerb(void) { }
	
};

typedef void __fastcall (__closure *TWapActionExecuteEvent)(System::TObject* Sender, Appssi::THttpRequest* 
	Request, Appssi::THttpResponse* Response, const System::AnsiString Verb, const System::AnsiString Value
	, Wvardict::TVariantList* Params, bool &Handled);

typedef void __fastcall (__closure *TWapActionBeforeExecuteEvent)(System::TObject* Sender, Appssi::THttpRequest* 
	Request, Appssi::THttpResponse* Response, const System::AnsiString Verb, const System::AnsiString Value
	, Wvardict::TVariantList* Params);

typedef void __fastcall (__closure *TWapActionAfterExecuteEvent)(System::TObject* Sender, Appssi::THttpRequest* 
	Request, Appssi::THttpResponse* Response, const System::AnsiString Verb, const System::AnsiString Value
	, Wvardict::TVariantList* Params);

class DELPHICLASS TWapCustomAction;
class PASCALIMPLEMENTATION TWapCustomAction : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	Classes::TStringList* FExposedProperties;
	Mthdslst::TNotifyEventList* FNameChangeHandlers;
	TWapActionBeforeExecuteEvent FOnBeforeExecute;
	TWapActionExecuteEvent FOnExecute;
	TWapActionAfterExecuteEvent FOnAfterExecute;
	
protected:
	virtual void __fastcall UnsupportedVerbError(const System::AnsiString Verb);
	virtual void __fastcall UpdateProperties(Wvardict::TVariantList* Params);
	virtual void __fastcall ExposeProperty(const System::AnsiString PropName);
	virtual void __fastcall ExposeProperties(const System::AnsiString * Properties, const int Properties_Size
		);
	virtual void __fastcall HideProperty(const System::AnsiString PropName);
	virtual void __fastcall HideProperties(const System::AnsiString * Properties, const int Properties_Size
		);
	__property Mthdslst::TNotifyEventList* NameChangeHandlers = {read=FNameChangeHandlers};
	virtual void __fastcall SetName(const System::AnsiString NewName);
	virtual void __fastcall BeforeExecute(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response
		, const System::AnsiString Verb, const System::AnsiString Value, Wvardict::TVariantList* Params);
	virtual void __fastcall Execute(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response, const 
		System::AnsiString Verb, const System::AnsiString Value, Wvardict::TVariantList* Params, bool &Handled
		);
	virtual void __fastcall AfterExecute(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response
		, const System::AnsiString Verb, const System::AnsiString Value, Wvardict::TVariantList* Params);
	__property TWapActionBeforeExecuteEvent OnBeforeExecute = {read=FOnBeforeExecute, write=FOnBeforeExecute
		};
	__property TWapActionExecuteEvent OnExecute = {read=FOnExecute, write=FOnExecute};
	__property TWapActionAfterExecuteEvent OnAfterExecute = {read=FOnAfterExecute, write=FOnAfterExecute
		};
	
public:
	__fastcall virtual TWapCustomAction(Classes::TComponent* AOwner);
	__fastcall virtual ~TWapCustomAction(void);
	virtual void __fastcall ExecuteAction(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response
		, const System::AnsiString Verb, const System::AnsiString Value, Wvardict::TVariantList* Params, bool 
		&Handled);
};

class DELPHICLASS TWapAction;
class PASCALIMPLEMENTATION TWapAction : public Wapactns::TWapCustomAction 
{
	typedef Wapactns::TWapCustomAction inherited;
	
__published:
	__property OnExecute ;
public:
	/* TWapCustomAction.Create */ __fastcall virtual TWapAction(Classes::TComponent* AOwner) : Wapactns::
		TWapCustomAction(AOwner) { }
	/* TWapCustomAction.Destroy */ __fastcall virtual ~TWapAction(void) { }
	
};

enum TActionItemTrigger { atActionName, atMethodType, atLogicalPath };

typedef Set<TActionItemTrigger, atActionName, atLogicalPath>  TActionItemTriggers;

class DELPHICLASS TWapActionItem;
class PASCALIMPLEMENTATION TWapActionItem : public Classes::TCollectionItem 
{
	typedef Classes::TCollectionItem inherited;
	
private:
	System::AnsiString FLogicalPath;
	THttpMethodType FMethodType;
	bool FDefault;
	bool FEnabled;
	TWapCustomAction* FActionObject;
	Wapmask::TWapMask* FMask;
	Classes::TComponent* FDummyComponent;
	TActionItemTriggers FTriggers;
	System::AnsiString FActionName;
	bool __fastcall DispatchAction(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response, bool 
		DoDefault);
	void __fastcall SetDefault(bool Value);
	void __fastcall SetEnabled(bool Value);
	void __fastcall SetMethodType(Appssi::THttpMethodType Value);
	void __fastcall SetLogicalPath(const System::AnsiString Value);
	void __fastcall SetActionObject(const TWapCustomAction* Value);
	void __fastcall SetTriggers(TActionItemTriggers Value);
	void __fastcall NameChangeHandler(System::TObject* Sender);
	System::AnsiString __fastcall DetermineActionName();
	void __fastcall ReadActionName(Classes::TReader* Reader);
	void __fastcall WriteActionName(Classes::TWriter* Writer);
	void __fastcall SetActionName(const System::AnsiString Value);
	
protected:
	void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation);
	virtual void __fastcall DefineProperties(Classes::TFiler* Filer);
	
public:
	virtual System::AnsiString __fastcall GetDisplayName();
	__fastcall virtual TWapActionItem(Classes::TCollection* Collection);
	__fastcall virtual ~TWapActionItem(void);
	virtual void __fastcall AssignTo(Classes::TPersistent* Dest);
	__property System::AnsiString ActionName = {read=FActionName, write=SetActionName};
	
__published:
	__property bool Enabled = {read=FEnabled, write=SetEnabled, default=1};
	__property bool Default = {read=FDefault, write=SetDefault, default=0};
	__property TActionItemTriggers Triggers = {read=FTriggers, write=SetTriggers, nodefault};
	__property TWapCustomAction* ActionObject = {read=FActionObject, write=SetActionObject};
	__property Appssi::THttpMethodType MethodType = {read=FMethodType, write=SetMethodType, default=4};
		
	__property System::AnsiString LogicalPath = {read=FLogicalPath, write=SetLogicalPath};
};

class DELPHICLASS TWapActionItems;
class PASCALIMPLEMENTATION TWapActionItems : public Classes::TCollection 
{
	typedef Classes::TCollection inherited;
	
private:
	Classes::TComponent* FOwner;
	TWapActionItem* __fastcall GetActionItem(int Index);
	void __fastcall SetActionItem(int Index, TWapActionItem* Value);
	
protected:
	virtual void __fastcall Update(Classes::TCollectionItem* Item);
	
public:
	DYNAMIC int __fastcall GetAttrCount(void);
	DYNAMIC System::AnsiString __fastcall GetAttr(int Index);
	DYNAMIC System::AnsiString __fastcall GetItemAttr(int Index, int ItemIndex);
	DYNAMIC Classes::TPersistent* __fastcall GetOwner(void);
	__fastcall TWapActionItems(Classes::TComponent* Owner);
	virtual bool __fastcall DispatchActions(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response
		);
	virtual bool __fastcall ExecuteAction(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response
		, const System::AnsiString Name, const System::AnsiString Verb, const System::AnsiString Value, Wvardict::TVariantList* 
		Params);
	System::AnsiString __fastcall GetActionName(TWapCustomAction* Action);
	TWapActionItem* __fastcall ActionByName(const System::AnsiString AName);
	HIDESBASE TWapActionItem* __fastcall Add(void);
	__property Classes::TComponent* Owner = {read=FOwner};
	__property TWapActionItem* Items[int Index] = {read=GetActionItem, write=SetActionItem/*, default*/
		};
public:
	/* TCollection.Destroy */ __fastcall virtual ~TWapActionItems(void) { }
	
};

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE bool __fastcall ExtractActionParams(Appssi::THttpRequest* Request, const System::AnsiString 
	ActionName, System::AnsiString &Verb, System::AnsiString &Value, Wvardict::TVariantList* Params);

}	/* namespace Wapactns */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Wapactns;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WapActns
