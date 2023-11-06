unit dclwap;

interface

procedure Register;

implementation

uses Classes, HWebApp, BrowsCap, HtmlTxt, WapTmplt, AdRotate, DBHtml, DBWap;

procedure Register;
begin
    RegisterComponents(
        'WebApp',
        [
        TWapApp,
        TWapSession,
        TDBWapSession,
        TWapTemplate,
        TAdRotator,
        TBrowserType,
        TDataSetPage,
        TDBHtmlTable,
        THTMLSelect,
        THTMLText,
        THTMLHidden,
        THTMLTextArea,
        THTMLRadio,
        THTMLCheckbox,
        THTMLButton,
        THTMLRadioGroup,
        THTMLCheckboxGroup
        ]);
end;

end.
