//---------------------------------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop

#include "HWebApp.hpp"
#pragma link "HWebApp"

#include "BrowsCap.hpp"
#pragma link "BrowsCap"

#include "AdRotate.hpp"
#pragma link "AdRotate"

#include "HtmlTxt.hpp"
#pragma link "HtmlTxt"

#include "DBHtml.hpp"
#pragma link "DBHtml"

#include "WapTmplt.hpp"
#pragma link "WapTmplt"

#include "DBWap.hpp"
#pragma link "DBWap"

#pragma resource "HWebApp.DCR"
#pragma resource "BrowsCap.DCR"
#pragma resource "HtmlTxt.DCR"
#pragma resource "WapTmplt.DCR"
#pragma resource "AdRotate.DCR"
#pragma resource "DBHtml.DCR"
#pragma resource "DBWap.DCR"


namespace Wapreg
{
	void __fastcall Register()
	{
	TComponentClass classes[17] = {
		__classid(TWapApp),
		__classid(TWapSession),
	    __classid(TWapTemplate),
	    __classid(TDBWapSession),
		__classid(TAdRotator),
		__classid(TBrowserType),
		__classid(TDataSetPage),
		__classid(TDBHtmlTable),
		__classid(THTMLSelect),
		__classid(THTMLText),
		__classid(THTMLHidden),
		__classid(THTMLTextArea),
		__classid(THTMLRadio),
		__classid(THTMLCheckbox),
		__classid(THTMLButton),
		__classid(THTMLRadioGroup),
		__classid(THTMLCheckboxGroup)
	    };

		RegisterComponents("WebApp", classes, 16);
	}
}
//---------------------------------------------------------------------------
