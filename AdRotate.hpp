// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'AdRotate.pas' rev: 3.00

#ifndef AdRotateHPP
#define AdRotateHPP
#include <WapActns.hpp>
#include <SDS.hpp>
#include <HtmlTxt.hpp>
#include <Classes.hpp>
#include <SysUtils.hpp>
#include <Messages.hpp>
#include <Windows.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Adrotate
{
//-- type declarations -------------------------------------------------------
typedef void __fastcall (__closure *TAdvertisementEvent)(System::TObject* Sender, const System::AnsiString 
	AdURL, const System::AnsiString AdHomePageURL, const System::AnsiString Text, System::AnsiString &HTML
	);

class DELPHICLASS TAdRotator;
class PASCALIMPLEMENTATION TAdRotator : public Htmltxt::TWapControl 
{
	typedef Htmltxt::TWapControl inherited;
	
private:
	int FBorder;
	int FWidth;
	int FHeight;
	bool FClickable;
	System::AnsiString FTargetFrame;
	Sds::TObjectList* FAds;
	System::AnsiString FSheduleFilename;
	int FTotalImpressions;
	System::AnsiString FScheduleFilename;
	System::AnsiString FRedirect;
	TAdvertisementEvent FOnAdvertisement;
	void __fastcall SetScheduleFilename(const System::AnsiString Value);
	void __fastcall ReadScheduleFile(void);
	
protected:
	virtual void __fastcall HandleAdvertisement(const System::AnsiString AdURL, const System::AnsiString 
		AdHomePageURL, const System::AnsiString Text, System::AnsiString &HTML);
	virtual void __fastcall ProduceHTML(Classes::TStrings* Dest);
	
public:
	__fastcall virtual TAdRotator(Classes::TComponent* AOwner);
	__fastcall virtual ~TAdRotator(void);
	
__published:
	__property int Border = {read=FBorder, write=FBorder, nodefault};
	__property bool Clickable = {read=FClickable, write=FClickable, nodefault};
	__property System::AnsiString TargetFrame = {read=FTargetFrame, write=FTargetFrame};
	__property System::AnsiString ScheduleFilename = {read=FScheduleFilename, write=SetScheduleFilename
		};
	__property TAdvertisementEvent OnAdvertisement = {read=FOnAdvertisement, write=FOnAdvertisement};
};

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE void __fastcall Register(void);

}	/* namespace Adrotate */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Adrotate;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// AdRotate
