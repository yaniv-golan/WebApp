// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Unit1.pas' rev: 3.00

#ifndef Unit1HPP
#define Unit1HPP
#include <IPC.hpp>
#include <HWebApp.hpp>
#include <StdCtrls.hpp>
#include <Menus.hpp>
#include <Dialogs.hpp>
#include <Forms.hpp>
#include <Controls.hpp>
#include <Graphics.hpp>
#include <Classes.hpp>
#include <SysUtils.hpp>
#include <Messages.hpp>
#include <Windows.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Unit1
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TForm1;
class PASCALIMPLEMENTATION TForm1 : public Forms::TForm 
{
	typedef Forms::TForm inherited;
	
__published:
	Menus::TMainMenu* MainMenu1;
	Stdctrls::TGroupBox* GroupBox1;
	Menus::TMenuItem* File1;
	Menus::TMenuItem* Exit1;
	Menus::TMenuItem* Help1;
	Menus::TMenuItem* About1;
	Stdctrls::TLabel* Label1;
	Stdctrls::TEdit* ActiveRequestsEdit;
	Stdctrls::TLabel* Label2;
	Stdctrls::TEdit* ActiveSessionsEdit;
	Hwebapp::TWapApp* WapApp1;
	Stdctrls::TEdit* ApplicationIdEdit;
	Stdctrls::TLabel* Label3;
	Menus::TMenuItem* AlwaysOnTop1;
	void __fastcall WapApp1CreateSession(System::TObject* Sender, Hwebapp::TWapSession* &Session);
	void __fastcall WapApp1Notify(System::TObject* Sender, Hwebapp::TWapAppNotification Notification);
	void __fastcall FormCreate(System::TObject* Sender);
	void __fastcall Exit1Click(System::TObject* Sender);
	void __fastcall AlwaysOnTop1Click(System::TObject* Sender);
	
private:
	void __fastcall UpdateStatistics(void);
public:
	/* TCustomForm.Create */ __fastcall virtual TForm1(Classes::TComponent* AOwner) : Forms::TForm(AOwner
		) { }
	/* TCustomForm.CreateNew */ __fastcall TForm1(Classes::TComponent* AOwner, int Dummy) : Forms::TForm(
		AOwner, Dummy) { }
	/* TCustomForm.Destroy */ __fastcall virtual ~TForm1(void) { }
	
public:
	/* TWinControl.CreateParented */ __fastcall TForm1(HWND ParentWindow) : Forms::TForm(ParentWindow) { }
		
	
};

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE TForm1* Form1;

}	/* namespace Unit1 */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Unit1;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// Unit1
