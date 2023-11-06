// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WVarDict.pas' rev: 3.00

#ifndef WVarDictHPP
#define WVarDictHPP
#include <Windows.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Wvardict
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TVariantList;
class PASCALIMPLEMENTATION TVariantList : public Classes::TPersistent 
{
	typedef Classes::TPersistent inherited;
	
private:
	Classes::TStringList* FItems;
	_RTL_CRITICAL_SECTION FLock;
	System::Variant __fastcall GetItem(const System::AnsiString Index);
	void __fastcall SetItem(const System::AnsiString Index, const System::Variant &Value);
	void __fastcall DeleteItem(int Index);
	System::AnsiString __fastcall GetItemName(int Index);
	void __fastcall SetItemName(int Index, const System::AnsiString Value);
	int __fastcall GetCount(void);
	
public:
	__fastcall TVariantList(void);
	__fastcall virtual ~TVariantList(void);
	void __fastcall Clear(void);
	void __fastcall Lock(void);
	void __fastcall Unlock(void);
	__property int Count = {read=GetCount, nodefault};
	__property System::Variant Items[System::AnsiString Index] = {read=GetItem, write=SetItem/*, default
		*/};
	System::Variant __fastcall ItemByIndex(int Index);
	__property System::AnsiString ItemNames[int Index] = {read=GetItemName, write=SetItemName};
};

typedef TVariantList TWapVariantDictionary;
;

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Wvardict */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Wvardict;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WVarDict
