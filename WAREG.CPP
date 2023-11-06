//---------------------------------------------------------------------------
#include <vcl\vcl.h>
#pragma hdrstop

#include "wareg.h"

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

namespace Wareg
{
	void __fastcall Register()
	{
        TComponentClass classes[15] = {
        	__classid(TWapApp),
        	__classid(TWapSession),
        	__classid(TBrowserType),
        	__classid(TAdRotator),
        	__classid(THTMLSelect),
        	__classid(THTMLHidden),
        	__classid(THTMLText),
        	__classid(THTMLTextArea),
        	__classid(THTMLRadio),
        	__classid(THTMLCheckbox),
        	__classid(THTMLButton),
	        __classid(THTMLRadioGroup),
        	__classid(THTMLCheckboxGroup),
        	__classid(TDBPaginator),
        	__classid(TDBHtmlTable)
            };

		RegisterComponents("WebApp", classes, 14);
	}
}
//---------------------------------------------------------------------------
