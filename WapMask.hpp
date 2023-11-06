// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'WapMask.pas' rev: 3.00

#ifndef WapMaskHPP
#define WapMaskHPP
#include <HAWRIntf.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Wapmask
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TWapMask;
class PASCALIMPLEMENTATION TWapMask : public System::TObject 
{
	typedef System::TObject inherited;
	
private:
	void *FInstance;
	
public:
	__fastcall TWapMask(const System::AnsiString MaskValue);
	__fastcall virtual ~TWapMask(void);
	bool __fastcall Matches(const System::AnsiString Filename);
};

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE bool __fastcall MatchesMask(const System::AnsiString Filename, const System::AnsiString 
	Mask);

}	/* namespace Wapmask */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Wapmask;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// WapMask
