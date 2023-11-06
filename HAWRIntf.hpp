// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'HAWRIntf.pas' rev: 3.00

#ifndef HAWRIntfHPP
#define HAWRIntfHPP
#include <Windows.hpp>
#include <SysUtils.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Hawrintf
{
//-- type declarations -------------------------------------------------------
typedef void __stdcall (*TImageConversionCallback)(void * Instance, void * Data, int Size);

typedef void __stdcall (__closure *TInlineScriptCallback)(char * Text);

typedef void __stdcall (__closure *TScriptTagCallback)(char * Text, char * Language);

typedef void __stdcall (__closure *TNonScriptTextCallback)(char * Text);

typedef void __stdcall (__closure *TMacroCallback)(char * MacroName);

typedef void __stdcall (__closure *TPreProcessorIncludeCallback)(char * Attribute, char * Filename);
	

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE int __stdcall (*BitmapToJPEG)(void * BitmapMemory, int BitmapMemorySize, void * Instance
	, TImageConversionCallback Callback);
extern PACKAGE int __stdcall (*BitmapToGIF)(void * BitmapMemory, int BitmapMemorySize, void * Instance
	, TImageConversionCallback Callback);
extern PACKAGE void * __stdcall (*ScriptedHtmlLexer_Create)(void);
extern PACKAGE void __stdcall (*ScriptedHtmlLexer_Destroy)(void * Handle);
extern PACKAGE void __stdcall (*ScriptedHtmlLexer_Execute)(void * Handle, char * Buf, int BufLen);
extern PACKAGE void __stdcall (*ScriptedHtmlLexer_SetStartDelim)(void * Handle, char * Value);
extern PACKAGE void __stdcall (*ScriptedHtmlLexer_SetEndDelim)(void * Handle, char * Value);
extern PACKAGE void __stdcall (*ScriptedHtmlLexer_SetMacroChar)(void * Handle, char Value);
extern PACKAGE void __stdcall (*ScriptedHtmlLexer_SetOnInlineScript)(void * Handle, TInlineScriptCallback 
	Callback);
extern PACKAGE void __stdcall (*ScriptedHtmlLexer_SetOnScriptTag)(void * Handle, TScriptTagCallback 
	Callback);
extern PACKAGE void __stdcall (*ScriptedHtmlLexer_SetOnNonScriptText)(void * Handle, TNonScriptTextCallback 
	Callback);
extern PACKAGE void __stdcall (*ScriptedHtmlLexer_SetOnMacro)(void * Handle, TMacroCallback Callback
	);
extern PACKAGE void __stdcall (*ScriptedHtmlLexer_SetOnPreProcessorInclude)(void * Handle, TPreProcessorIncludeCallback 
	Callback);
extern PACKAGE void * __stdcall (*Mask_Create)(char * MaskValue);
extern PACKAGE void __stdcall (*Mask_Free)(void * Instance);
extern PACKAGE bool __stdcall (*Mask_Matches)(void * Instance, char * Filename);
extern PACKAGE bool __stdcall (*MatchesMask)(char * Filename, char * Mask);
extern PACKAGE void * __stdcall (*TemplateActionLexer_Create)(char * ActionString);
extern PACKAGE void __stdcall (*TemplateActionLexer_Free)(void * Instance);
extern PACKAGE void __stdcall (*TemplateActionLexer_GetActionName)(void * Instance, char * Buf, int 
	BufLen);
extern PACKAGE void __stdcall (*TemplateActionLexer_GetVerb)(void * Instance, char * Buf, int BufLen
	);
extern PACKAGE void __stdcall (*TemplateActionLexer_GetValue)(void * Instance, char * Buf, int BufLen
	);
extern PACKAGE int __stdcall (*TemplateActionLexer_GetParamCount)(void * Instance);
extern PACKAGE void __stdcall (*TemplateActionLexer_GetParamName)(void * Instance, int Index, char * 
	Buf, int BufLen);
extern PACKAGE void __stdcall (*TemplateActionLexer_GetParamValue)(void * Instance, int Index, char * 
	Buf, int BufLen);

}	/* namespace Hawrintf */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Hawrintf;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// HAWRIntf
