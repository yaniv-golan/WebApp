// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'BrowsCap.pas' rev: 3.00

#ifndef BrowsCapHPP
#define BrowsCapHPP
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Browscap
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TBrowserType;
class PASCALIMPLEMENTATION TBrowserType : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	Classes::TStringList* FValues;
	System::AnsiString FBrowserCap;
	System::AnsiString FUserAgent;
	void __fastcall ReadUserAgentInfo(void);
	void __fastcall SetBrowserCap(const System::AnsiString Value);
	void __fastcall SetUserAgent(const System::AnsiString Value);
	int __fastcall GetCount(void);
	System::AnsiString __fastcall GetKey(int Index);
	System::Variant __fastcall GetValue(const System::Variant &Index);
	System::AnsiString __fastcall GetBrowser();
	System::AnsiString __fastcall GetVersion();
	int __fastcall GetMajorVer(void);
	int __fastcall GetMinorVer(void);
	bool __fastcall GetFrames(void);
	bool __fastcall GetTables(void);
	bool __fastcall GetCookies(void);
	bool __fastcall GetBackgroundSounds(void);
	bool __fastcall GetVBScript(void);
	bool __fastcall GetJavaScript(void);
	bool __fastcall GetJavaApplets(void);
	System::AnsiString __fastcall GetPlatform();
	bool __fastcall GetActiveXControls(void);
	bool __fastcall GetBeta(void);
	
public:
	__fastcall virtual TBrowserType(Classes::TComponent* AOwner);
	__fastcall virtual ~TBrowserType(void);
	__property System::AnsiString BrowserCap = {read=FBrowserCap, write=SetBrowserCap};
	__property System::AnsiString UserAgent = {read=FUserAgent, write=SetUserAgent};
	__property System::AnsiString Browser = {read=GetBrowser};
	__property System::AnsiString Version = {read=GetVersion};
	__property int MajorVer = {read=GetMajorVer, nodefault};
	__property int MinorVer = {read=GetMinorVer, nodefault};
	__property bool Frames = {read=GetFrames, nodefault};
	__property bool Tables = {read=GetTables, nodefault};
	__property bool Cookies = {read=GetCookies, nodefault};
	__property bool BackgroundSounds = {read=GetBackgroundSounds, nodefault};
	__property bool VBScript = {read=GetVBScript, nodefault};
	__property bool JavaScript = {read=GetJavaScript, nodefault};
	__property bool JavaApplets = {read=GetJavaApplets, nodefault};
	__property System::AnsiString Platform = {read=GetPlatform};
	__property bool ActiveXControls = {read=GetActiveXControls, nodefault};
	__property bool Beta = {read=GetBeta, nodefault};
	__property int Count = {read=GetCount, nodefault};
	__property System::AnsiString Keys[int Index] = {read=GetKey};
	__property System::Variant Values[System::Variant Index] = {read=GetValue/*, default*/};
};

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall Register(void);

}	/* namespace Browscap */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Browscap;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// BrowsCap
