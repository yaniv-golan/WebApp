unit WAReg;

interface

procedure   Register;

implementation

uses Classes, SysUtils, HWebApp, BrowsCap, AdRotate, HtmlTxt, DBHtml, WapTmplt
    ;

{$R BROWSCAP.DCR}
{$R ADROTATE.DCR}
{$R HTMLTXT.DCR}
{$R DBHTML.DCR}
{$R HWEBAPP.DCR}
{$R WAPTMPLT.DCR}

procedure   Register;
begin
    RegisterComponents('WebApp', [
        TWapApp,
        TWapSession,
        TBrowserType,
        TAdRotator,
        TWapTemplate,
        THTMLSelect,
        THTMLHidden,
        THTMLText,
        THTMLTextArea,
        THTMLRadio,
        THTMLCheckbox,
        THTMLButton,
        THTMLRadioGroup,
        THTMLCheckboxGroup,
        TDataSetPage,
        TDBHtmlTable]
        );
end;

end.
 