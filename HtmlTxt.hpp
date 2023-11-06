// Borland C++ Builder
// Copyright (c) 1995, 1998 by Borland International
// All rights reserved

// (DO NOT EDIT: machine generated header) 'HtmlTxt.pas' rev: 3.00

#ifndef HtmlTxtHPP
#define HtmlTxtHPP
#include <WVarDict.hpp>
#include <WapActns.hpp>
#include <AppSSI.hpp>
#include <Graphics.hpp>
#include <SysUtils.hpp>
#include <Classes.hpp>
#include <SysInit.hpp>
#include <System.hpp>

//-- user supplied -----------------------------------------------------------

namespace Htmltxt
{
//-- type declarations -------------------------------------------------------
typedef Graphics::TColor THtmlColor;

class DELPHICLASS TWapControl;
class PASCALIMPLEMENTATION TWapControl : public Wapactns::TWapCustomAction 
{
	typedef Wapactns::TWapCustomAction inherited;
	
private:
	System::AnsiString __fastcall GetAsHtml();
	
protected:
	virtual void __fastcall SubmitValue(const System::AnsiString Value);
	virtual void __fastcall Execute(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response, const 
		System::AnsiString Verb, const System::AnsiString Value, Wvardict::TVariantList* Params, bool &Handled
		);
	virtual void __fastcall DoDefault(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response, const 
		System::AnsiString Value, Wvardict::TVariantList* Params, bool &Handled);
	virtual void __fastcall ExecuteSubmit(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response
		, const System::AnsiString Value, Wvardict::TVariantList* Params, bool &Handled);
	virtual void __fastcall ExecuteWriteHtml(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response
		, const System::AnsiString Value, Wvardict::TVariantList* Params, bool &Handled);
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest) = 0;
	
public:
	__fastcall virtual TWapControl(Classes::TComponent* AOwner);
	__fastcall virtual ~TWapControl(void);
	virtual void __fastcall WriteToStrings(Classes::TStrings* Strings);
	virtual void __fastcall WriteToStream(Classes::TStream* Stream);
	virtual void __fastcall WriteToFile(const System::AnsiString Filename);
	__property System::AnsiString AsHTML = {read=GetAsHtml};
	
__published:
	__property OnBeforeExecute ;
	__property OnAfterExecute ;
};

class DELPHICLASS TCustomHtmlChunk;
class PASCALIMPLEMENTATION TCustomHtmlChunk : public Htmltxt::TWapControl 
{
	typedef Htmltxt::TWapControl inherited;
	
private:
	Classes::TNotifyEvent FOnChange;
	Classes::TStrings* FLines;
	bool FEscape;
	void __fastcall SetLines(Classes::TStrings* Value);
	
protected:
	virtual void __fastcall Change(void);
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest);
	__property Classes::TStrings* Lines = {read=FLines, write=SetLines};
	__property bool Escape = {read=FEscape, write=FEscape, nodefault};
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	
public:
	__fastcall virtual TCustomHtmlChunk(Classes::TComponent* AOwner);
	__fastcall virtual ~TCustomHtmlChunk(void);
};

class DELPHICLASS THtmlChunk;
class PASCALIMPLEMENTATION THtmlChunk : public Htmltxt::TCustomHtmlChunk 
{
	typedef Htmltxt::TCustomHtmlChunk inherited;
	
__published:
	__property Lines ;
	__property Escape ;
public:
	/* TCustomHtmlChunk.Create */ __fastcall virtual THtmlChunk(Classes::TComponent* AOwner) : Htmltxt::
		TCustomHtmlChunk(AOwner) { }
	/* TCustomHtmlChunk.Destroy */ __fastcall virtual ~THtmlChunk(void) { }
	
};

class DELPHICLASS THtmlFormControl;
class DELPHICLASS TCustomHtmlForm;
typedef void __fastcall (__closure *THtmlFormBeforeSubmitEvent)(System::TObject* Sender, Appssi::THttpRequest* 
	Request, Appssi::THttpResponse* Response, const System::AnsiString Value, Wvardict::TVariantList* Params
	);

typedef void __fastcall (__closure *THtmlFormAfterSubmitEvent)(System::TObject* Sender, Appssi::THttpRequest* 
	Request, Appssi::THttpResponse* Response, const System::AnsiString Value, Wvardict::TVariantList* Params
	);

class PASCALIMPLEMENTATION TCustomHtmlForm : public Wapactns::TWapCustomAction 
{
	typedef Wapactns::TWapCustomAction inherited;
	
private:
	Classes::TList* FControls;
	THtmlFormBeforeSubmitEvent FOnBeforeSubmit;
	THtmlFormAfterSubmitEvent FOnAfterSubmit;
	void __fastcall AddControl(THtmlFormControl* Control);
	void __fastcall RemoveControl(THtmlFormControl* Control);
	int __fastcall GetControlCount(void);
	THtmlFormControl* __fastcall GetControl(int Index);
	
protected:
	virtual void __fastcall Execute(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response, const 
		System::AnsiString Verb, const System::AnsiString Value, Wvardict::TVariantList* Params, bool &Handled
		);
	void __fastcall BeforeSubmit(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response, const 
		System::AnsiString Value, Wvardict::TVariantList* Params);
	void __fastcall AfterSubmit(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response, const System::AnsiString 
		Value, Wvardict::TVariantList* Params);
	virtual void __fastcall ExecuteWriteFormBegin(Appssi::THttpRequest* Request, Appssi::THttpResponse* 
		Response, const System::AnsiString Value, Wvardict::TVariantList* Params, bool &Handled);
	virtual void __fastcall ExecuteWriteControlHtml(Appssi::THttpRequest* Request, Appssi::THttpResponse* 
		Response, const System::AnsiString Value, Wvardict::TVariantList* Params, bool &Handled);
	virtual void __fastcall ExecuteWriteFormEnd(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response
		, const System::AnsiString Value, Wvardict::TVariantList* Params, bool &Handled);
	virtual void __fastcall ExecuteSubmit(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response
		, const System::AnsiString Value, Wvardict::TVariantList* Params, bool &Handled);
	__property THtmlFormBeforeSubmitEvent OnBeforeSubmit = {read=FOnBeforeSubmit, write=FOnBeforeSubmit
		};
	__property THtmlFormAfterSubmitEvent OnAfterSubmit = {read=FOnAfterSubmit, write=FOnAfterSubmit};
	
public:
	__fastcall virtual TCustomHtmlForm(Classes::TComponent* AOwner);
	__fastcall virtual ~TCustomHtmlForm(void);
	__property int ControlCount = {read=GetControlCount, nodefault};
	__property THtmlFormControl* Controls[int Index] = {read=GetControl};
	THtmlFormControl* __fastcall ControlByName(const System::AnsiString Name);
};

class PASCALIMPLEMENTATION THtmlFormControl : public Htmltxt::TWapControl 
{
	typedef Htmltxt::TWapControl inherited;
	
private:
	Classes::TNotifyEvent FOnChange;
	TCustomHtmlForm* FHtmlForm;
	void __fastcall SetHtmlForm(TCustomHtmlForm* Value);
	
protected:
	virtual void __fastcall DoDefault(Appssi::THttpRequest* Request, Appssi::THttpResponse* Response, const 
		System::AnsiString Value, Wvardict::TVariantList* Params, bool &Handled);
	virtual void __fastcall Change(void);
	__property Classes::TNotifyEvent OnChange = {read=FOnChange, write=FOnChange};
	
__published:
	__property TCustomHtmlForm* HtmlForm = {read=FHtmlForm, write=SetHtmlForm};
public:
	/* TWapControl.Create */ __fastcall virtual THtmlFormControl(Classes::TComponent* AOwner) : Htmltxt::
		TWapControl(AOwner) { }
	/* TWapControl.Destroy */ __fastcall virtual ~THtmlFormControl(void) { }
	
};

class DELPHICLASS TCustomHtmlSelect;
class PASCALIMPLEMENTATION TCustomHtmlSelect : public Htmltxt::THtmlFormControl 
{
	typedef Htmltxt::THtmlFormControl inherited;
	
private:
	int FSize;
	Classes::TStrings* FItems;
	int FItemIndex;
	bool FMultiSelect;
	void __fastcall SetItems(Classes::TStrings* Strings);
	int __fastcall FindValueIndex(const System::AnsiString Value);
	System::AnsiString __fastcall GetValueAt(int Index);
	void __fastcall OnItemsChange(System::TObject* Sender);
	void __fastcall SetItemIndex(int Value);
	
protected:
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest);
	virtual void __fastcall SubmitValue(const System::AnsiString Value);
	
public:
	__fastcall virtual TCustomHtmlSelect(Classes::TComponent* AOwner);
	__fastcall virtual ~TCustomHtmlSelect(void);
	__property int Size = {read=FSize, write=FSize, nodefault};
	__property Classes::TStrings* Items = {read=FItems, write=SetItems};
	__property int ItemIndex = {read=FItemIndex, write=SetItemIndex, nodefault};
	__property bool MultiSelect = {read=FMultiSelect, write=FMultiSelect, nodefault};
};

class DELPHICLASS THtmlSelect;
class PASCALIMPLEMENTATION THtmlSelect : public Htmltxt::TCustomHtmlSelect 
{
	typedef Htmltxt::TCustomHtmlSelect inherited;
	
public:
	__fastcall virtual THtmlSelect(Classes::TComponent* AOwner);
	
__published:
	__property Size ;
	__property Items ;
	__property ItemIndex ;
	__property MultiSelect ;
	__property OnChange ;
public:
	/* TCustomHtmlSelect.Destroy */ __fastcall virtual ~THtmlSelect(void) { }
	
};

class DELPHICLASS TCustomHtmlText;
class PASCALIMPLEMENTATION TCustomHtmlText : public Htmltxt::THtmlFormControl 
{
	typedef Htmltxt::THtmlFormControl inherited;
	
private:
	int FSize;
	bool FPassword;
	System::AnsiString FText;
	int FMaxLength;
	void __fastcall SetText(const System::AnsiString Value);
	
protected:
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest);
	virtual void __fastcall SubmitValue(const System::AnsiString Value);
	__property int MaxLength = {read=FMaxLength, write=FMaxLength, nodefault};
	__property int Size = {read=FSize, write=FSize, nodefault};
	__property bool Password = {read=FPassword, write=FPassword, nodefault};
	
public:
	__property System::AnsiString Text = {read=FText, write=SetText};
public:
	/* TWapControl.Create */ __fastcall virtual TCustomHtmlText(Classes::TComponent* AOwner) : Htmltxt::
		THtmlFormControl(AOwner) { }
	/* TWapControl.Destroy */ __fastcall virtual ~TCustomHtmlText(void) { }
	
};

class DELPHICLASS THtmlText;
class PASCALIMPLEMENTATION THtmlText : public Htmltxt::TCustomHtmlText 
{
	typedef Htmltxt::TCustomHtmlText inherited;
	
public:
	__fastcall virtual THtmlText(Classes::TComponent* AOwner);
	
__published:
	__property Text ;
	__property MaxLength ;
	__property Size ;
	__property Password ;
	__property OnChange ;
public:
	/* TWapControl.Destroy */ __fastcall virtual ~THtmlText(void) { }
	
};

class DELPHICLASS TCustomHtmlTextArea;
class PASCALIMPLEMENTATION TCustomHtmlTextArea : public Htmltxt::THtmlFormControl 
{
	typedef Htmltxt::THtmlFormControl inherited;
	
private:
	int FRows;
	int FCols;
	Classes::TStrings* FLines;
	int FMaxLength;
	void __fastcall SetLines(Classes::TStrings* Value);
	void __fastcall HandleLinesChange(System::TObject* Sender);
	
protected:
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest);
	virtual void __fastcall SubmitValue(const System::AnsiString Value);
	
public:
	__fastcall virtual TCustomHtmlTextArea(Classes::TComponent* AOwner);
	__fastcall virtual ~TCustomHtmlTextArea(void);
	__property int MaxLength = {read=FMaxLength, write=FMaxLength, nodefault};
	__property int Rows = {read=FRows, write=FRows, nodefault};
	__property int Cols = {read=FCols, write=FCols, nodefault};
	__property Classes::TStrings* Lines = {read=FLines, write=SetLines};
};

class DELPHICLASS THtmlTextArea;
class PASCALIMPLEMENTATION THtmlTextArea : public Htmltxt::TCustomHtmlTextArea 
{
	typedef Htmltxt::TCustomHtmlTextArea inherited;
	
public:
	__fastcall virtual THtmlTextArea(Classes::TComponent* AOwner);
	
__published:
	__property MaxLength ;
	__property Rows ;
	__property Cols ;
	__property Lines ;
	__property OnChange ;
public:
	/* TCustomHtmlTextArea.Destroy */ __fastcall virtual ~THtmlTextArea(void) { }
	
};

class DELPHICLASS TCustomHtmlHidden;
class PASCALIMPLEMENTATION TCustomHtmlHidden : public Htmltxt::THtmlFormControl 
{
	typedef Htmltxt::THtmlFormControl inherited;
	
private:
	System::AnsiString FValue;
	
protected:
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest);
	void __fastcall SetValue(const System::AnsiString Value);
	virtual void __fastcall SubmitValue(const System::AnsiString Value);
	
public:
	__property System::AnsiString Value = {read=FValue, write=SetValue};
public:
	/* TWapControl.Create */ __fastcall virtual TCustomHtmlHidden(Classes::TComponent* AOwner) : Htmltxt::
		THtmlFormControl(AOwner) { }
	/* TWapControl.Destroy */ __fastcall virtual ~TCustomHtmlHidden(void) { }
	
};

class DELPHICLASS THtmlHidden;
class PASCALIMPLEMENTATION THtmlHidden : public Htmltxt::TCustomHtmlHidden 
{
	typedef Htmltxt::TCustomHtmlHidden inherited;
	
public:
	__fastcall virtual THtmlHidden(Classes::TComponent* AOwner);
	
__published:
	__property Value ;
	__property OnChange ;
public:
	/* TWapControl.Destroy */ __fastcall virtual ~THtmlHidden(void) { }
	
};

class DELPHICLASS TCustomHtmlRadio;
class PASCALIMPLEMENTATION TCustomHtmlRadio : public Htmltxt::THtmlFormControl 
{
	typedef Htmltxt::THtmlFormControl inherited;
	
private:
	bool FChecked;
	System::AnsiString FValue;
	System::AnsiString FCaption;
	void __fastcall SetChecked(bool Value);
	
protected:
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest);
	virtual void __fastcall SubmitValue(const System::AnsiString Value);
	__property bool Checked = {read=FChecked, write=SetChecked, nodefault};
	__property System::AnsiString Value = {read=FValue, write=FValue};
	__property System::AnsiString Caption = {read=FCaption, write=FCaption};
	
public:
	__fastcall virtual TCustomHtmlRadio(Classes::TComponent* AOwner);
public:
	/* TWapControl.Destroy */ __fastcall virtual ~TCustomHtmlRadio(void) { }
	
};

class DELPHICLASS THtmlRadio;
class PASCALIMPLEMENTATION THtmlRadio : public Htmltxt::TCustomHtmlRadio 
{
	typedef Htmltxt::TCustomHtmlRadio inherited;
	
public:
	__fastcall virtual THtmlRadio(Classes::TComponent* AOwner);
	
__published:
	__property Checked ;
	__property Value ;
	__property OnChange ;
	__property Caption ;
public:
	/* TWapControl.Destroy */ __fastcall virtual ~THtmlRadio(void) { }
	
};

class DELPHICLASS TCustomHtmlCheckbox;
class PASCALIMPLEMENTATION TCustomHtmlCheckbox : public Htmltxt::THtmlFormControl 
{
	typedef Htmltxt::THtmlFormControl inherited;
	
private:
	bool FChecked;
	System::AnsiString FValue;
	System::AnsiString FCaption;
	void __fastcall SetChecked(bool Value);
	
protected:
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest);
	virtual void __fastcall SubmitValue(const System::AnsiString Value);
	__property bool Checked = {read=FChecked, write=SetChecked, nodefault};
	__property System::AnsiString Value = {read=FValue, write=FValue};
	__property System::AnsiString Caption = {read=FCaption, write=FCaption};
	
public:
	__fastcall virtual TCustomHtmlCheckbox(Classes::TComponent* AOwner);
public:
	/* TWapControl.Destroy */ __fastcall virtual ~TCustomHtmlCheckbox(void) { }
	
};

class DELPHICLASS THtmlCheckbox;
class PASCALIMPLEMENTATION THtmlCheckbox : public Htmltxt::TCustomHtmlCheckbox 
{
	typedef Htmltxt::TCustomHtmlCheckbox inherited;
	
public:
	__fastcall virtual THtmlCheckbox(Classes::TComponent* AOwner);
	
__published:
	__property Checked ;
	__property Value ;
	__property OnChange ;
	__property Caption ;
public:
	/* TWapControl.Destroy */ __fastcall virtual ~THtmlCheckbox(void) { }
	
};

enum THtmlButtonType { btNormal, btSubmit, btReset };

class DELPHICLASS TCustomHtmlButton;
class PASCALIMPLEMENTATION TCustomHtmlButton : public Htmltxt::THtmlFormControl 
{
	typedef Htmltxt::THtmlFormControl inherited;
	
private:
	THtmlButtonType FButtonType;
	System::AnsiString FValue;
	void __fastcall SetValue(const System::AnsiString Value);
	
protected:
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest);
	virtual void __fastcall SubmitValue(const System::AnsiString Value);
	__property System::AnsiString Value = {read=FValue, write=SetValue};
	__property THtmlButtonType ButtonType = {read=FButtonType, write=FButtonType, nodefault};
	__property System::AnsiString Caption = {read=FValue, write=SetValue};
	
public:
	__fastcall virtual TCustomHtmlButton(Classes::TComponent* AOwner);
public:
	/* TWapControl.Destroy */ __fastcall virtual ~TCustomHtmlButton(void) { }
	
};

class DELPHICLASS THtmlButton;
class PASCALIMPLEMENTATION THtmlButton : public Htmltxt::TCustomHtmlButton 
{
	typedef Htmltxt::TCustomHtmlButton inherited;
	
public:
	__fastcall virtual THtmlButton(Classes::TComponent* AOwner);
	
__published:
	__property Value ;
	__property ButtonType ;
	__property Caption ;
	__property OnChange ;
public:
	/* TWapControl.Destroy */ __fastcall virtual ~THtmlButton(void) { }
	
};

class DELPHICLASS TCustomHtmlRadioGroup;
class PASCALIMPLEMENTATION TCustomHtmlRadioGroup : public Htmltxt::THtmlFormControl 
{
	typedef Htmltxt::THtmlFormControl inherited;
	
private:
	Classes::TStrings* FItems;
	int FItemIndex;
	System::AnsiString FBetweenItems;
	void __fastcall SetItems(Classes::TStrings* Value);
	int __fastcall FindValueIndex(const System::AnsiString Value);
	System::AnsiString __fastcall GetValueAt(int Index);
	void __fastcall SetItemIndex(int Value);
	void __fastcall OnItemsChange(System::TObject* Sender);
	
protected:
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest);
	virtual void __fastcall SubmitValue(const System::AnsiString Value);
	__property System::AnsiString BetweenItems = {read=FBetweenItems, write=FBetweenItems};
	__property Classes::TStrings* Items = {read=FItems, write=SetItems};
	__property int ItemIndex = {read=FItemIndex, write=SetItemIndex, nodefault};
	
public:
	__fastcall virtual TCustomHtmlRadioGroup(Classes::TComponent* AOwner);
	__fastcall virtual ~TCustomHtmlRadioGroup(void);
};

class DELPHICLASS THtmlRadioGroup;
class PASCALIMPLEMENTATION THtmlRadioGroup : public Htmltxt::TCustomHtmlRadioGroup 
{
	typedef Htmltxt::TCustomHtmlRadioGroup inherited;
	
public:
	__fastcall virtual THtmlRadioGroup(Classes::TComponent* AOwner);
	
__published:
	__property BetweenItems ;
	__property ItemIndex ;
	__property Items ;
	__property OnChange ;
public:
	/* TCustomHtmlRadioGroup.Destroy */ __fastcall virtual ~THtmlRadioGroup(void) { }
	
};

class DELPHICLASS TCustomHtmlCheckboxGroup;
class PASCALIMPLEMENTATION TCustomHtmlCheckboxGroup : public Htmltxt::THtmlFormControl 
{
	typedef Htmltxt::THtmlFormControl inherited;
	
private:
	Classes::TStrings* FItems;
	System::AnsiString FBetweenItems;
	bool __fastcall GetSelected(int Index);
	void __fastcall SetSelected(int Index, bool Value);
	void __fastcall SetItems(Classes::TStrings* Value);
	System::AnsiString __fastcall GetValueAt(int Index);
	
protected:
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest);
	virtual void __fastcall SubmitValue(const System::AnsiString Value);
	
public:
	__fastcall virtual TCustomHtmlCheckboxGroup(Classes::TComponent* AOwner);
	__fastcall virtual ~TCustomHtmlCheckboxGroup(void);
	__property bool Selected[int Index] = {read=GetSelected, write=SetSelected};
	__property System::AnsiString BetweenItems = {read=FBetweenItems, write=FBetweenItems};
	__property Classes::TStrings* Items = {read=FItems, write=SetItems};
};

class DELPHICLASS THtmlCheckboxGroup;
class PASCALIMPLEMENTATION THtmlCheckboxGroup : public Htmltxt::TCustomHtmlCheckboxGroup 
{
	typedef Htmltxt::TCustomHtmlCheckboxGroup inherited;
	
public:
	__fastcall virtual THtmlCheckboxGroup(Classes::TComponent* AOwner);
	
__published:
	__property BetweenItems ;
	__property Items ;
	__property OnChange ;
public:
	/* TCustomHtmlCheckboxGroup.Destroy */ __fastcall virtual ~THtmlCheckboxGroup(void) { }
	
};

class DELPHICLASS THtmlForm;
class PASCALIMPLEMENTATION THtmlForm : public Htmltxt::TCustomHtmlForm 
{
	typedef Htmltxt::TCustomHtmlForm inherited;
	
__published:
	__property OnBeforeSubmit ;
	__property OnAfterSubmit ;
public:
	/* TCustomHtmlForm.Create */ __fastcall virtual THtmlForm(Classes::TComponent* AOwner) : Htmltxt::TCustomHtmlForm(
		AOwner) { }
	/* TCustomHtmlForm.Destroy */ __fastcall virtual ~THtmlForm(void) { }
	
};

class DELPHICLASS TCustomHtmlJavaApplet;
class PASCALIMPLEMENTATION TCustomHtmlJavaApplet : public Htmltxt::TWapControl 
{
	typedef Htmltxt::TWapControl inherited;
	
private:
	System::AnsiString FArchive;
	System::AnsiString FCodeBase;
	System::AnsiString FCode;
	int FWidth;
	int FHeight;
	int FHSpace;
	int FVSpace;
	System::AnsiString FAlign;
	Classes::TStrings* FParams;
	void __fastcall SetParams(Classes::TStrings* Value);
	
protected:
	virtual void __fastcall ProduceHtml(Classes::TStrings* Dest);
	__property System::AnsiString Archive = {read=FArchive, write=FArchive};
	__property System::AnsiString CodeBase = {read=FCodeBase, write=FCodeBase};
	__property System::AnsiString Code = {read=FCode, write=FCode};
	__property int Width = {read=FWidth, write=FWidth, nodefault};
	__property int Height = {read=FHeight, write=FHeight, nodefault};
	__property int HSpace = {read=FHSpace, write=FHSpace, nodefault};
	__property int VSpace = {read=FVSpace, write=FVSpace, nodefault};
	__property System::AnsiString Align = {read=FAlign, write=FAlign};
	__property Classes::TStrings* Params = {read=FParams, write=SetParams};
	
public:
	__fastcall virtual TCustomHtmlJavaApplet(Classes::TComponent* AOwner);
	__fastcall virtual ~TCustomHtmlJavaApplet(void);
};

class DELPHICLASS THtmlJavaApplet;
class PASCALIMPLEMENTATION THtmlJavaApplet : public Htmltxt::TCustomHtmlJavaApplet 
{
	typedef Htmltxt::TCustomHtmlJavaApplet inherited;
	
__published:
	__property Archive ;
	__property CodeBase ;
	__property Code ;
	__property Width ;
	__property Height ;
	__property HSpace ;
	__property VSpace ;
	__property Align ;
	__property Params ;
public:
	/* TCustomHtmlJavaApplet.Create */ __fastcall virtual THtmlJavaApplet(Classes::TComponent* AOwner) : 
		Htmltxt::TCustomHtmlJavaApplet(AOwner) { }
	/* TCustomHtmlJavaApplet.Destroy */ __fastcall virtual ~THtmlJavaApplet(void) { }
	
};

//-- var, const, procedure ---------------------------------------------------
#define NewLine "\r\n"
extern PACKAGE System::AnsiString __fastcall Tag(const System::AnsiString Tag);
extern PACKAGE System::AnsiString __fastcall TagWithAttributes(const System::AnsiString Tag, const System::AnsiString 
	* Attributes, const int Attributes_Size);
extern PACKAGE System::AnsiString __fastcall EndTag(const System::AnsiString Tag);
extern PACKAGE System::AnsiString __fastcall EnclosingTag(const System::AnsiString Tag, const System::AnsiString 
	Text);
extern PACKAGE System::AnsiString __fastcall EnclosingTagWithAttributes(const System::AnsiString Tag
	, const System::AnsiString * Attributes, const int Attributes_Size, System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall Attribute(const System::AnsiString Name, const System::AnsiString 
	Value);
extern PACKAGE System::AnsiString __fastcall Html(const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall Head(const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall Body(const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall BodyWithAttributes(const System::AnsiString * Attributes
	, const int Attributes_Size, const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall FormBegin(const System::AnsiString Name, const System::AnsiString 
	Method, const System::AnsiString Action, const System::AnsiString EncType, const System::AnsiString 
	Target);
extern PACKAGE System::AnsiString __fastcall FormEnd();
extern PACKAGE System::AnsiString __fastcall Form(const System::AnsiString Name, const System::AnsiString 
	Method, const System::AnsiString Action, const System::AnsiString EncType, const System::AnsiString 
	Target, const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall Italic(const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall Bold(const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall Underline(const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall Script(const System::AnsiString ScriptLanguage, const System::AnsiString 
	Text);
extern PACKAGE System::AnsiString __fastcall NoScript(const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall Par(const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall ParWithAttributes(const System::AnsiString * Attributes
	, const int Attributes_Size, const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall Link(const System::AnsiString HRef, const System::AnsiString 
	Target, const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall LineBreak();
extern PACKAGE System::AnsiString __fastcall Title(const System::AnsiString Title);
extern PACKAGE System::AnsiString __fastcall Heading(int Level, const System::AnsiString Text);
extern PACKAGE System::AnsiString __fastcall ColorToHtmlColor(Graphics::TColor Color);
extern PACKAGE System::AnsiString __fastcall SelfURL(Appssi::THttpRequest* Request, const System::AnsiString 
	LogicalPath, const System::AnsiString QueryString);
extern PACKAGE System::AnsiString __fastcall URLFields(const System::AnsiString * Fields, const int 
	Fields_Size);
extern PACKAGE System::AnsiString __fastcall URLField(const System::AnsiString Field, const System::AnsiString 
	Value);
extern PACKAGE System::AnsiString __fastcall Action(const System::AnsiString ActionName, const System::AnsiString 
	Verb, const System::AnsiString Value);
extern PACKAGE System::AnsiString __fastcall ActionWithParams(const System::AnsiString ActionName, const 
	System::AnsiString Verb, const System::AnsiString Value, const System::AnsiString * Params, const int 
	Params_Size);
extern PACKAGE System::AnsiString __fastcall ActionParam(const System::AnsiString Param, const System::AnsiString 
	Value);
extern PACKAGE System::AnsiString __fastcall ColorToJSColor(Graphics::TColor Color);
extern PACKAGE void __fastcall FormatStringsAsParams(Classes::TStrings* SourceStrings, Classes::TStrings* 
	DestParams);

}	/* namespace Htmltxt */
#if !defined(NO_IMPLICIT_NAMESPACE_USE)
using namespace Htmltxt;
#endif
//-- end unit ----------------------------------------------------------------
#endif	// HtmlTxt
