// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WapTmplt.pas' rev: 3.00

#ifndef WapTmpltHPP
#define WapTmpltHPP
#include <WapActns.hpp>
#include <ComObj.hpp>
#include <AXSHost.hpp>
#include <ActiveX.hpp>
#include <ScrHtPrc.hpp>
#include <WVarDict.hpp>
#include <HtmlTxt.hpp>
#include <AppSSI.hpp>
#include <HWebApp.hpp>
#include <Windows.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Waptmplt
{
//-- type declarations -------------------------------------------------------
typedef void __fastcall (__closure *TScriptErrorEvent)(System::TObject* Sender, Axshost::TScriptErrorInfo* 
	ScriptError, Axshost::TScriptErrorAction &Action);

typedef void __fastcall (__closure *TGetMacroValueEvent)(System::TObject* Sender, const System::AnsiString 
	Name, System::Variant &Value);

class DELPHICLASS EWapTemplate;
class PASCALIMPLEMENTATION EWapTemplate : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ __fastcall EWapTemplate(const System::AnsiString Msg) : Sysutils::Exception(
		Msg) { }
	/* Exception.CreateFmt */ __fastcall EWapTemplate(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ __fastcall EWapTemplate(int Ident, Extended Dummy) : Sysutils::Exception(
		Ident, Dummy) { }
	/* Exception.CreateResFmt */ __fastcall EWapTemplate(int Ident, const System::TVarRec * Args, const 
		int Args_Size) : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ __fastcall EWapTemplate(const System::AnsiString Msg, int AHelpContext) : 
		Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ __fastcall EWapTemplate(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext
		) { }
	/* Exception.CreateResHelp */ __fastcall EWapTemplate(int Ident, int AHelpContext) : Sysutils::Exception(
		Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ __fastcall EWapTemplate(int Ident, const System::TVarRec * Args, const 
		int Args_Size, int AHelpContext) : Sysutils::Exception(Ident, Args, Args_Size, AHelpContext) { }
	
public:
	/* TObject.Destroy */ __fastcall virtual ~EWapTemplate(void) { }
	
};

class DELPHICLASS TWapTemplate;
class PASCALIMPLEMENTATION TWapTemplate : public Htmltxt::TWapControl 
{
	typedef Htmltxt::TWapControl inherited;
	
private:
	Classes::TStringList* InputTemplate;
	System::AnsiString FFilename;
	Wvardict::TVariantList* FValues;
	Hwebapp::TWapSession* FSession;
	Scrhtprc::TGetMacroValueEvent FOnGetMacroValue;
	Classes::TNotifyEvent FOnRegisterScriptObjects;
	Axshost::TScriptErrorEvent FOnScriptError;
	bool FInRegisterScriptObjects;
	Axshost::TActiveScriptHost* FHost;
	bool FErrorInScript;
	GUID FScriptingEngine;
	Scrhtprc::TScriptedHtmlProcessor* FParser;
	bool __fastcall DoExecuteAction(const System::AnsiString Action);
	void __fastcall SetSession(Hwebapp::TWapSession* Value);
	System::Variant __fastcall GetVariable(System::AnsiString Index);
	void __fastcall SetVariable(System::AnsiString Index, const System::Variant &Value);
	void __fastcall HandleParserGetMacroValue(System::TObject* Sender, const System::AnsiString Name, System::Variant 
		&Value);
	void __fastcall HandlePreScriptOutput(System::TObject* Sender, const void *Buffer, int BufLen);
	void __fastcall HandleParserExecuteAction(System::TObject* Sender, const System::AnsiString Action)
		;
	System::AnsiString __fastcall GetStartDelim();
	void __fastcall SetStartDelim(const System::AnsiString Value);
	System::AnsiString __fastcall GetEndDelim();
	void __fastcall SetEndDelim(const System::AnsiString Value);
	char __fastcall GetMacroChar(void);
	void __fastcall SetMacroChar(char Value);
	void __fastcall SetFilename(const System::AnsiString Value);
	System::AnsiString __fastcall GetBlock(int BlockId);
	void __fastcall ExecuteActionBlock(int BlockId);
	void __fastcall RunScript(Classes::TStrings* Script);
	void __fastcall HandleScriptError(System::TObject* Sender, Axshost::TScriptErrorInfo* Info, Axshost::TScriptErrorAction 
		&Action);
	void __fastcall RegisterStandardScriptObjects(void);
	void __fastcall HandleStop(void);
	System::AnsiString __fastcall GetScriptingEngine();
	void __fastcall SetScriptingEngine(const System::AnsiString Value);
	
protected:
	virtual void __fastcall ProduceHTML(Classes::TStrings* Dest);
	virtual System::Variant __fastcall GetMacroValue(const System::AnsiString Name);
	virtual void __fastcall ScriptError(Axshost::TScriptErrorInfo* Info, Axshost::TScriptErrorAction &Action
		);
	virtual void __fastcall RegisterScriptObjects(void);
	
public:
	__fastcall virtual TWapTemplate(Classes::TComponent* AOwner);
	__fastcall virtual ~TWapTemplate(void);
	void __fastcall LoadFromFile(const System::AnsiString Filename);
	void __fastcall LoadFromStream(Classes::TStream* Stream);
	void __fastcall LoadFromStrings(Classes::TStrings* Strings);
	virtual void __fastcall WriteToStream(Classes::TStream* Stream);
	void __fastcall FormatHTML(Classes::TStrings* HTML);
	void __fastcall Clear(void);
	__property System::Variant Values[System::AnsiString Index] = {read=GetVariable, write=SetVariable/*
		, default*/};
	void __fastcall RegisterObject(const System::AnsiString Name, _di_IUnknown Instance);
	__property bool ErrorInScript = {read=FErrorInScript, nodefault};
	
__published:
	__property System::AnsiString ScriptingEngine = {read=GetScriptingEngine, write=SetScriptingEngine}
		;
	__property System::AnsiString StartDelim = {read=GetStartDelim, write=SetStartDelim};
	__property System::AnsiString EndDelim = {read=GetEndDelim, write=SetEndDelim};
	__property char MacroChar = {read=GetMacroChar, write=SetMacroChar, nodefault};
	__property System::AnsiString Filename = {read=FFilename, write=SetFilename};
	__property Hwebapp::TWapSession* Session = {read=FSession, write=SetSession};
	__property Scrhtprc::TGetMacroValueEvent OnGetMacroValue = {read=FOnGetMacroValue, write=FOnGetMacroValue
		};
	__property Classes::TNotifyEvent OnRegisterScriptObjects = {read=FOnRegisterScriptObjects, write=FOnRegisterScriptObjects
		};
	__property Axshost::TScriptErrorEvent OnScriptError = {read=FOnScriptError, write=FOnScriptError};
};

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE System::AnsiString __fastcall EncodeAction(const System::AnsiString ActionMacro);

}	/* namespace Waptmplt */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Waptmplt;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WapTmplt
