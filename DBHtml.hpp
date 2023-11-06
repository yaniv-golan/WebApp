// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'DBHtml.pas' rev: 3.00

#ifndef DBHtmlHPP
#define DBHtmlHPP
#include <WapActns.hpp>
#include <WVarDict.hpp>
#include <AppSSI.hpp>
#include <HtmlTxt.hpp>
#include <Messages.hpp>
#include <DBCtrls.hpp>
#include <Graphics.hpp>
#include <Controls.hpp>
#include <DBTables.hpp>
#include <Db.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Dbhtml
{
//-- type declarations -------------------------------------------------------
class DELPHICLASS TPagedDataSource;
class PASCALIMPLEMENTATION TPagedDataSource : public Classes::TComponent 
{
	typedef Classes::TComponent inherited;
	
private:
	Db::TDataLink* FDataLink;
	int FPageSize;
	System::AnsiString FCurrentPageStartBookmark;
	Db::TDataSet* __fastcall GetDataSet(void);
	void __fastcall SetDataSource(Db::TDataSource* Value);
	Db::TDataSource* __fastcall GetDataSource(void);
	void __fastcall UpdatePageStartBookmark(void);
	void __fastcall HandleDataSetChanged(System::TObject* Sender);
	void __fastcall HandleActiveChanged(System::TObject* Sender);
	bool __fastcall GetAtFirstPage(void);
	bool __fastcall GetAtLastPage(void);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation
		);
	virtual void __fastcall Loaded(void);
	
public:
	__fastcall virtual TPagedDataSource(Classes::TComponent* AOwner);
	__fastcall virtual ~TPagedDataSource(void);
	int __fastcall MoveBy(int PagesDistance);
	void __fastcall FirstPage(void);
	void __fastcall LastPage(void);
	void __fastcall NextPage(void);
	void __fastcall PriorPage(void);
	void __fastcall SetPageStart(void);
	void __fastcall GotoFirstInPage(void);
	__property Db::TDataSet* DataSet = {read=GetDataSet};
	__property bool AtFirstPage = {read=GetAtFirstPage, nodefault};
	__property bool AtLastPage = {read=GetAtLastPage, nodefault};
	
__published:
	__property Db::TDataSource* DataSource = {read=GetDataSource, write=SetDataSource};
	__property int PageSize = {read=FPageSize, write=FPageSize, nodefault};
};

class DELPHICLASS EDBHtmlTable;
class PASCALIMPLEMENTATION EDBHtmlTable : public Sysutils::Exception 
{
	typedef Sysutils::Exception inherited;
	
public:
	/* Exception.Create */ __fastcall EDBHtmlTable(const System::AnsiString Msg) : Sysutils::Exception(
		Msg) { }
	/* Exception.CreateFmt */ __fastcall EDBHtmlTable(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size) : Sysutils::Exception(Msg, Args, Args_Size) { }
	/* Exception.CreateRes */ __fastcall EDBHtmlTable(int Ident, Extended Dummy) : Sysutils::Exception(
		Ident, Dummy) { }
	/* Exception.CreateResFmt */ __fastcall EDBHtmlTable(int Ident, const System::TVarRec * Args, const 
		int Args_Size) : Sysutils::Exception(Ident, Args, Args_Size) { }
	/* Exception.CreateHelp */ __fastcall EDBHtmlTable(const System::AnsiString Msg, int AHelpContext) : 
		Sysutils::Exception(Msg, AHelpContext) { }
	/* Exception.CreateFmtHelp */ __fastcall EDBHtmlTable(const System::AnsiString Msg, const System::TVarRec 
		* Args, const int Args_Size, int AHelpContext) : Sysutils::Exception(Msg, Args, Args_Size, AHelpContext
		) { }
	/* Exception.CreateResHelp */ __fastcall EDBHtmlTable(int Ident, int AHelpContext) : Sysutils::Exception(
		Ident, AHelpContext) { }
	/* Exception.CreateResFmtHelp */ __fastcall EDBHtmlTable(int Ident, const System::TVarRec * Args, const 
		int Args_Size, int AHelpContext) : Sysutils::Exception(Ident, Args, Args_Size, AHelpContext) { }
	
public:
	/* TObject.Destroy */ __fastcall virtual ~EDBHtmlTable(void) { }
	
};

enum TPixelOrPercent { ppPixel, ppPercent };

enum TDBHtmlTableOption { htoBorderEmptyCells, htoTitles };

typedef Set<TDBHtmlTableOption, htoBorderEmptyCells, htoTitles>  TDBHtmlTableOptions;

typedef void __fastcall (__closure *TCustomizeTag_TABLE_Event)(System::TObject* Sender, System::AnsiString 
	&Attributes);

typedef void __fastcall (__closure *TCustomizeTag_TH_Event)(System::TObject* Sender, Db::TField* Field
	, System::AnsiString &Attributes);

typedef void __fastcall (__closure *TCustomizeTag_TD_Event)(System::TObject* Sender, Db::TField* Field
	, System::AnsiString &Attributes);

typedef void __fastcall (__closure *TCustomizeTag_TR_Event)(System::TObject* Sender, System::AnsiString 
	&Attributes);

typedef void __fastcall (__closure *TCustomizeFieldEvent)(System::TObject* Sender, Db::TField* Field
	, System::AnsiString &Text);

typedef void __fastcall (__closure *TCustomizeFieldTitleEvent)(System::TObject* Sender, Db::TField* 
	Field, System::AnsiString &TitleText);

class DELPHICLASS TDBHtmlTable;
class PASCALIMPLEMENTATION TDBHtmlTable : public Htmltxt::TWapControl 
{
	typedef Htmltxt::TWapControl inherited;
	
private:
	TPagedDataSource* FPagedDataSource;
	System::AnsiString FCaption;
	int FBorder;
	int FCellSpacing;
	int FCellPadding;
	int FWidth;
	TPixelOrPercent FWidthUnits;
	Graphics::TColor FBgColor;
	Graphics::TColor FBorderColor;
	Graphics::TColor FBorderColorLight;
	Graphics::TColor FBorderColorDark;
	TDBHtmlTableOptions FOptions;
	Graphics::TColor FTitleBGColor;
	Graphics::TColor FTitleColor;
	TCustomizeTag_TABLE_Event FOnCustomizeTag_TABLE;
	TCustomizeTag_TH_Event FOnCustomizeFieldTitleTag_TH;
	TCustomizeTag_TR_Event FOnCustomizeTitleTag_TR;
	TCustomizeTag_TD_Event FOnCustomizeTag_TD;
	TCustomizeFieldEvent FOnCustomizeField;
	TCustomizeFieldTitleEvent FOnCustomizeFieldTitle;
	TCustomizeTag_TR_Event FOnCustomizeTag_TR;
	System::AnsiString __fastcall FixCellString(const System::AnsiString S);
	Db::TDataSet* __fastcall GetDataSet(void);
	
protected:
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation
		);
	virtual void __fastcall CustomizeField(Db::TField* Field, System::AnsiString &Text);
	virtual void __fastcall CustomizeFieldTitle(Db::TField* Field, System::AnsiString &TitleText);
	virtual System::AnsiString __fastcall CustomizeTag_TABLE();
	virtual System::AnsiString __fastcall CustomizeFieldTitleTag_TH(Db::TField* Field);
	virtual System::AnsiString __fastcall CustomizeTitleTag_TR();
	virtual System::AnsiString __fastcall CustomizeTag_TR();
	virtual System::AnsiString __fastcall CustomizeTag_TD(Db::TField* Field);
	virtual void __fastcall ProduceHTML(Classes::TStrings* Dest);
	
public:
	__fastcall virtual TDBHtmlTable(Classes::TComponent* AOwner);
	__fastcall virtual ~TDBHtmlTable(void);
	__property Db::TDataSet* DataSet = {read=GetDataSet};
	
__published:
	__property TPagedDataSource* PagedDataSource = {read=FPagedDataSource, write=FPagedDataSource};
	__property System::AnsiString Caption = {read=FCaption, write=FCaption};
	__property int Border = {read=FBorder, write=FBorder, nodefault};
	__property int CellPadding = {read=FCellPadding, write=FCellPadding, nodefault};
	__property int CellSpacing = {read=FCellSpacing, write=FCellSpacing, nodefault};
	__property int Width = {read=FWidth, write=FWidth, nodefault};
	__property TPixelOrPercent WidthUnits = {read=FWidthUnits, write=FWidthUnits, nodefault};
	__property Graphics::TColor BgColor = {read=FBgColor, write=FBgColor, nodefault};
	__property Graphics::TColor BorderColor = {read=FBorderColor, write=FBorderColor, nodefault};
	__property Graphics::TColor BorderColorLight = {read=FBorderColorLight, write=FBorderColorLight, nodefault
		};
	__property Graphics::TColor BorderColorDark = {read=FBorderColorDark, write=FBorderColorDark, nodefault
		};
	__property Graphics::TColor TitleColor = {read=FTitleColor, write=FTitleColor, nodefault};
	__property Graphics::TColor TitleBgColor = {read=FTitleBGColor, write=FTitleBGColor, nodefault};
	__property TDBHtmlTableOptions Options = {read=FOptions, write=FOptions, nodefault};
	__property TCustomizeTag_TABLE_Event OnCustomizeTag_TABLE = {read=FOnCustomizeTag_TABLE, write=FOnCustomizeTag_TABLE
		};
	__property TCustomizeTag_TR_Event OnCustomizeTitleTag_TR = {read=FOnCustomizeTitleTag_TR, write=FOnCustomizeTitleTag_TR
		};
	__property TCustomizeTag_TH_Event OnCustomizeFieldTitleTag_TH = {read=FOnCustomizeFieldTitleTag_TH, 
		write=FOnCustomizeFieldTitleTag_TH};
	__property TCustomizeFieldTitleEvent OnCustomizeFieldTitle = {read=FOnCustomizeFieldTitle, write=FOnCustomizeFieldTitle
		};
	__property TCustomizeTag_TR_Event OnCustomizeTag_TR = {read=FOnCustomizeTag_TR, write=FOnCustomizeTag_TR
		};
	__property TCustomizeTag_TD_Event OnCustomizeTag_TD = {read=FOnCustomizeTag_TD, write=FOnCustomizeTag_TD
		};
	__property TCustomizeFieldEvent OnCustomizeField = {read=FOnCustomizeField, write=FOnCustomizeField
		};
};

class DELPHICLASS TDBHtmlText;
class PASCALIMPLEMENTATION TDBHtmlText : public Htmltxt::TCustomHtmlText 
{
	typedef Htmltxt::TCustomHtmlText inherited;
	
private:
	Dbctrls::TFieldDataLink* FDataLink;
	void __fastcall UpdateData(System::TObject* Sender);
	void __fastcall DataChange(System::TObject* Sender);
	void __fastcall EditingChange(System::TObject* Sender);
	System::AnsiString __fastcall GetDataField();
	Db::TDataSource* __fastcall GetDataSource(void);
	void __fastcall SetDataField(const System::AnsiString Value);
	void __fastcall SetDataSource(Db::TDataSource* Value);
	Db::TField* __fastcall GetField(void);
	MESSAGE void __fastcall CMGetDataLink(Messages::TMessage &Message);
	
protected:
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation
		);
	virtual void __fastcall Change(void);
	
public:
	__fastcall virtual TDBHtmlText(Classes::TComponent* AOwner);
	__fastcall virtual ~TDBHtmlText(void);
	__property Db::TField* Field = {read=GetField};
	
__published:
	__property System::AnsiString DataField = {read=GetDataField, write=SetDataField};
	__property Db::TDataSource* DataSource = {read=GetDataSource, write=SetDataSource};
	__property MaxLength ;
	__property Size ;
	__property Password ;
};

class DELPHICLASS TDBHtmlTextArea;
class PASCALIMPLEMENTATION TDBHtmlTextArea : public Htmltxt::TCustomHtmlTextArea 
{
	typedef Htmltxt::TCustomHtmlTextArea inherited;
	
private:
	Dbctrls::TFieldDataLink* FDataLink;
	void __fastcall UpdateData(System::TObject* Sender);
	void __fastcall DataChange(System::TObject* Sender);
	void __fastcall EditingChange(System::TObject* Sender);
	System::AnsiString __fastcall GetDataField();
	Db::TDataSource* __fastcall GetDataSource(void);
	void __fastcall SetDataField(const System::AnsiString Value);
	void __fastcall SetDataSource(Db::TDataSource* Value);
	Db::TField* __fastcall GetField(void);
	MESSAGE void __fastcall CMGetDataLink(Messages::TMessage &Message);
	
protected:
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation
		);
	virtual void __fastcall Change(void);
	
public:
	__fastcall virtual TDBHtmlTextArea(Classes::TComponent* AOwner);
	__fastcall virtual ~TDBHtmlTextArea(void);
	__property Db::TField* Field = {read=GetField};
	
__published:
	__property System::AnsiString DataField = {read=GetDataField, write=SetDataField};
	__property Db::TDataSource* DataSource = {read=GetDataSource, write=SetDataSource};
	__property MaxLength ;
	__property Rows ;
	__property Cols ;
};

class DELPHICLASS TDBHtmlHidden;
class PASCALIMPLEMENTATION TDBHtmlHidden : public Htmltxt::TCustomHtmlHidden 
{
	typedef Htmltxt::TCustomHtmlHidden inherited;
	
private:
	Dbctrls::TFieldDataLink* FDataLink;
	void __fastcall UpdateData(System::TObject* Sender);
	void __fastcall DataChange(System::TObject* Sender);
	void __fastcall EditingChange(System::TObject* Sender);
	System::AnsiString __fastcall GetDataField();
	Db::TDataSource* __fastcall GetDataSource(void);
	void __fastcall SetDataField(const System::AnsiString Value);
	void __fastcall SetDataSource(Db::TDataSource* Value);
	Db::TField* __fastcall GetField(void);
	MESSAGE void __fastcall CMGetDataLink(Messages::TMessage &Message);
	
protected:
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation
		);
	virtual void __fastcall Change(void);
	
public:
	__fastcall virtual TDBHtmlHidden(Classes::TComponent* AOwner);
	__fastcall virtual ~TDBHtmlHidden(void);
	__property Db::TField* Field = {read=GetField};
	
__published:
	__property System::AnsiString DataField = {read=GetDataField, write=SetDataField};
	__property Db::TDataSource* DataSource = {read=GetDataSource, write=SetDataSource};
};

class DELPHICLASS TDBHtmlCheckbox;
class PASCALIMPLEMENTATION TDBHtmlCheckbox : public Htmltxt::TCustomHtmlCheckbox 
{
	typedef Htmltxt::TCustomHtmlCheckbox inherited;
	
private:
	Dbctrls::TFieldDataLink* FDataLink;
	System::AnsiString FValueCheck;
	System::AnsiString FValueUncheck;
	void __fastcall UpdateData(System::TObject* Sender);
	void __fastcall DataChange(System::TObject* Sender);
	void __fastcall EditingChange(System::TObject* Sender);
	System::AnsiString __fastcall GetDataField();
	Db::TDataSource* __fastcall GetDataSource(void);
	void __fastcall SetDataField(const System::AnsiString Value);
	void __fastcall SetDataSource(Db::TDataSource* Value);
	Db::TField* __fastcall GetField(void);
	MESSAGE void __fastcall CMGetDataLink(Messages::TMessage &Message);
	void __fastcall SetValueCheck(const System::AnsiString Value);
	void __fastcall SetValueUncheck(const System::AnsiString Value);
	bool __fastcall ValueMatch(const System::AnsiString ValueList, const System::AnsiString Value);
	bool __fastcall GetFieldState(void);
	
protected:
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation
		);
	virtual void __fastcall Change(void);
	
public:
	__fastcall virtual TDBHtmlCheckbox(Classes::TComponent* AOwner);
	__fastcall virtual ~TDBHtmlCheckbox(void);
	__property Db::TField* Field = {read=GetField};
	__property Checked ;
	
__published:
	__property System::AnsiString DataField = {read=GetDataField, write=SetDataField};
	__property Db::TDataSource* DataSource = {read=GetDataSource, write=SetDataSource};
	__property System::AnsiString ValueChecked = {read=FValueCheck, write=SetValueCheck};
	__property System::AnsiString ValueUnchecked = {read=FValueUncheck, write=SetValueUncheck};
};

class DELPHICLASS TDBHtmlChunk;
class PASCALIMPLEMENTATION TDBHtmlChunk : public Htmltxt::TCustomHtmlChunk 
{
	typedef Htmltxt::TCustomHtmlChunk inherited;
	
private:
	Dbctrls::TFieldDataLink* FDataLink;
	void __fastcall UpdateData(System::TObject* Sender);
	void __fastcall DataChange(System::TObject* Sender);
	void __fastcall EditingChange(System::TObject* Sender);
	System::AnsiString __fastcall GetDataField();
	Db::TDataSource* __fastcall GetDataSource(void);
	void __fastcall SetDataField(const System::AnsiString Value);
	void __fastcall SetDataSource(Db::TDataSource* Value);
	Db::TField* __fastcall GetField(void);
	MESSAGE void __fastcall CMGetDataLink(Messages::TMessage &Message);
	
protected:
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation
		);
	virtual void __fastcall Change(void);
	
public:
	__fastcall virtual TDBHtmlChunk(Classes::TComponent* AOwner);
	__fastcall virtual ~TDBHtmlChunk(void);
	__property Db::TField* Field = {read=GetField};
	
__published:
	__property System::AnsiString DataField = {read=GetDataField, write=SetDataField};
	__property Db::TDataSource* DataSource = {read=GetDataSource, write=SetDataSource};
	__property Escape ;
};

class DELPHICLASS TDBHtmlSelect;
class PASCALIMPLEMENTATION TDBHtmlSelect : public Htmltxt::TCustomHtmlSelect 
{
	typedef Htmltxt::TCustomHtmlSelect inherited;
	
private:
	Dbctrls::TFieldDataLink* FDataLink;
	void __fastcall UpdateData(System::TObject* Sender);
	void __fastcall DataChange(System::TObject* Sender);
	void __fastcall EditingChange(System::TObject* Sender);
	System::AnsiString __fastcall GetDataField();
	Db::TDataSource* __fastcall GetDataSource(void);
	void __fastcall SetDataField(const System::AnsiString Value);
	void __fastcall SetDataSource(Db::TDataSource* Value);
	Db::TField* __fastcall GetField(void);
	MESSAGE void __fastcall CMGetDataLink(Messages::TMessage &Message);
	void __fastcall ItemsChanged(System::TObject* Sender);
	
protected:
	virtual void __fastcall Loaded(void);
	virtual void __fastcall Notification(Classes::TComponent* AComponent, Classes::TOperation Operation
		);
	virtual void __fastcall Change(void);
	
public:
	__fastcall virtual TDBHtmlSelect(Classes::TComponent* AOwner);
	__fastcall virtual ~TDBHtmlSelect(void);
	__property Db::TField* Field = {read=GetField};
	
__published:
	__property System::AnsiString DataField = {read=GetDataField, write=SetDataField};
	__property Db::TDataSource* DataSource = {read=GetDataSource, write=SetDataSource};
	__property Size ;
	__property Items ;
};

//-- var, const, procedure ---------------------------------------------------

}	/* namespace Dbhtml */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Dbhtml;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// DBHtml
