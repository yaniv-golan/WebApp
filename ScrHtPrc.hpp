// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'ScrHtPrc.pas' rev: 3.00

#ifndef ScrHtPrcHPP
#define ScrHtPrcHPP
#include <HAWRIntf.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Scrhtprc
{
//-- type declarations -------------------------------------------------------
typedef void __fastcall (__closure *TGetMacroValueEvent)(System::TObject* Sender, const System::AnsiString 
	Name, System::Variant &Value);

typedef void __fastcall (__closure *TPreScriptOutputEvent)(System::TObject* Sender, const void *Buffer
	, int BufLen);

typedef void __fastcall (__closure *TExecuteActionEvent)(System::TObject* Sender, const System::AnsiString 
	Action);

typedef void __fastcall (__closure *TLoadIncludeFileEvent)(System::TObject* Sender, const System::AnsiString 
	Attribute, const System::AnsiString Filename, Classes::TStrings* IncludedFile);

enum TProcessorMode { pmCreateScript, pmFormatHTML };

class DELPHICLASS TScriptedHtmlProcessor;
class PASCALIMPLEMENTATION TScriptedHtmlProcessor : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	Classes::TStrings* FInputTemplate;
	Classes::TStrings* FOutputScript;
	Classes::TStrings* FFormattedHTML;
	Classes::TStrings* FBlocks;
	System::AnsiString FResponseWritePre;
	System::AnsiString FResponseWritePost;
	System::AnsiString FResponseWriteBlockPre;
	System::AnsiString FResponseWriteBlockPost;
	System::AnsiString FStartDelim;
	System::AnsiString FEndDelim;
	char FMacroChar;
	TProcessorMode FMode;
	TGetMacroValueEvent FOnGetMacroValue;
	TPreScriptOutputEvent FOnPreScriptOutput;
	TExecuteActionEvent FOnExecuteAction;
	TLoadIncludeFileEvent FOnLoadIncludeFile;
	bool FScriptStarted;
	void *FLexer;
	void __stdcall HandleInlineScript(char * Text);
	void __stdcall HandleScriptTag(char * Text, char * Language);
	void __stdcall HandleNonScriptText(char * Text);
	void __stdcall HandleMacro(char * MacroName);
	void __stdcall HandlePreProcessorInclude(char * Attribute, char * Filename);
	void __fastcall AddScriptLine(const System::AnsiString S);
	void __fastcall WritePlainText(const System::AnsiString S);
	void __fastcall AddToFormattedHTML(const System::AnsiString S);
	int __fastcall AddBlock(const System::AnsiString S);
	System::AnsiString __fastcall GetResponseWriteEquiv();
	void __fastcall SetResponseWriteEquiv(const System::AnsiString Value);
	System::AnsiString __fastcall GetResponseWriteBlockEquiv();
	void __fastcall SetResponseWriteBlockEquiv(const System::AnsiString Value);
	void __fastcall SetStartDelim(const System::AnsiString Value);
	void __fastcall SetEndDelim(const System::AnsiString Value);
	void __fastcall SetMacroChar(char Value);
	void __fastcall WriteAction(const System::AnsiString S);
	bool __fastcall IsAction(const System::AnsiString MacroName);
	void __fastcall InternalExecute(Classes::TStrings* InputStrings);
	
protected:
	virtual System::Variant __fastcall GetMacroValue(const System::AnsiString Name);
	virtual void __fastcall PreScriptOutput(const void *Buffer, int BufLen);
	virtual void __fastcall DoExecuteAction(const System::AnsiString Action);
	virtual void __fastcall LoadIncludeFile(const System::AnsiString Attribute, const System::AnsiString 
		Filename, Classes::TStrings* IncludedFile);
	
public:
	__fastcall virtual TScriptedHtmlProcessor(Classes::TComponent* AOwner);
	__fastcall virtual ~TScriptedHtmlProcessor(void);
	void __fastcall Execute(void);
	__property Classes::TStrings* OutputScript = {read=FOutputScript, write=FOutputScript};
	__property Classes::TStrings* Blocks = {read=FBlocks};
	__property TProcessorMode Mode = {read=FMode, write=FMode, nodefault};
	__property Classes::TStrings* FormattedHTML = {read=FFormattedHTML, write=FFormattedHTML};
	
__published:
	__property System::AnsiString StartDelim = {read=FStartDelim, write=SetStartDelim};
	__property System::AnsiString EndDelim = {read=FEndDelim, write=SetEndDelim};
	__property char MacroChar = {read=FMacroChar, write=SetMacroChar, nodefault};
	__property Classes::TStrings* InputTemplate = {read=FInputTemplate, write=FInputTemplate};
	__property System::AnsiString ResponseWriteEquiv = {read=GetResponseWriteEquiv, write=SetResponseWriteEquiv
		};
	__property System::AnsiString ResponseWriteBlockEquiv = {read=GetResponseWriteBlockEquiv, write=SetResponseWriteBlockEquiv
		};
	__property TPreScriptOutputEvent OnPreScriptOutput = {read=FOnPreScriptOutput, write=FOnPreScriptOutput
		};
	__property TGetMacroValueEvent OnGetMacroValue = {read=FOnGetMacroValue, write=FOnGetMacroValue};
	__property TExecuteActionEvent OnExecuteAction = {read=FOnExecuteAction, write=FOnExecuteAction};
	__property TLoadIncludeFileEvent OnLoadIncludeFile = {read=FOnLoadIncludeFile, write=FOnLoadIncludeFile
		};
};

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Scrhtprc */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Scrhtprc;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// ScrHtPrc
