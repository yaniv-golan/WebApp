unit WapReg;

interface

procedure Register;

implementation

{$I WapDef.INC}

uses Classes, SysUtils, HWebApp, BrowsCap, HtmlTxt, WapTmplt, AdRotate, Controls,
    DBHtml, DBWap, WapActns, DsgnIntf, TypInfo
{$ifdef wap_need_TCollection_editor}
    ,WapAcPEd
{$endif wap_need_TCollection_editor}
{$ifdef wap_axscript}
    ,ActiveX, ComCat, ComObj, ActivScp, Windows
{$endif wap_axscript}
    ;

{$R HWebApp.DCR}
{$R BrowsCap.DCR}
{$R HtmlTxt.DCR}
{$R WapTmplt.DCR}
{$R AdRotate.DCR}
{$R DBHtml.DCR}
{$R DBWap.DCR}
{$R WapActns.DCR}


{$ifdef wap_need_TCollection_editor}

type

///////////////////////////////////////////////////////////////////////////
//
// TWapActionItemsProperty
//
///////////////////////////////////////////////////////////////////////////

TWapActionItemsProperty = class(TPropertyEditor)
public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure Edit; override;
end;

function TWapActionItemsProperty.GetAttributes: TPropertyAttributes;
begin
    result := [paDialog, paRevertable];
end;

function TWapActionItemsProperty.GetValue: string;
begin
    FmtStr(Result, '(%s)', [GetPropType^.Name]);
end;

procedure TWapActionItemsProperty.Edit;
var
    F: TWapActionsEditorForm;
    ActionItems: TWapActionItems;
begin
    F := TWapActionsEditorForm.Create(nil);
    try
        // It is important to for the new collection to have the same owner!
        ActionItems := TWapActionItems.Create(TWapActionItems(GetOrdValue).Owner);
        try
            ActionItems.Assign(TWapActionItems(GetOrdValue));
            F.Actions := ActionItems;
            F.Designer := Designer;
            if (F.ShowModal = mrOk) then
                TWapActionItems(GetOrdValue).Assign(ActionItems);
        finally
            ActionItems.Free;
        end;
    finally
        F.Free;
    end;
end;

///////////////////////////////////////////////////////////////////////////
//
// TWapActionItemsProperty
//
///////////////////////////////////////////////////////////////////////////

type

TWapActionItemsEditor = class(TComponentEditor)
private
    procedure EditWapActionItemsProperty(PropertyEditor: TPropertyEditor);
public
    procedure Edit; override;
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
end;

procedure TWapActionItemsEditor.EditWapActionItemsProperty(PropertyEditor: TPropertyEditor);
begin
    if (PropertyEditor is TWapActionItemsProperty) then begin
        TWapActionItemsProperty(PropertyEditor).Edit;
    end;
end;

procedure TWapActionItemsEditor.Edit;
var
    Components: TComponentList;
begin
    Components := TComponentList.Create;
    try
        Components.Add(Component);
        GetComponentProperties(Components, [tkClass], Designer, EditWapActionItemsProperty);
    finally
        Components.Free;
    end;
end;

procedure TWapActionItemsEditor.ExecuteVerb(Index: Integer);
begin
    if (Index = 0) then
        Edit;
end;

function TWapActionItemsEditor.GetVerb(Index: Integer): string;
begin
    if (Index = 0) Then
        result := '&Edit Actions';
end;

function TWapActionItemsEditor.GetVerbCount: Integer;
begin
    result := 1;
end;

{$endif wap_need_TCollection_editor}

{$ifdef wap_axscript}

type

TScriptingEngineProperty = class(TStringProperty)
public
    function GetAttributes: TPropertyAttributes; override;
    procedure SetValue(const sVal: string); override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
end;

function TScriptingEngineProperty.GetAttributes: TPropertyAttributes;
begin
    Result := inherited GetAttributes;
    Result := Result + [paValueList, paSortList];
end;

procedure TScriptingEngineProperty.SetValue(const sVal: string);
begin
    SetStrValue(sVal);
end;

procedure TScriptingEngineProperty.GetValues(Proc: TGetStrProc);
var
    CatMgr: ICatInformation;
    enum: IEnumGUID;
    clsid: TGUID;
    nFetched: Integer;
    s: string;
begin
    CatMgr := CreateCategoryMgrInfo;
    OleCheck(CatMgr.EnumClassesOfCategories(
        1, CATID_ActiveScriptParse, 0, TGUID(nil^), enum));
    while enum.Next(1, clsid, nFetched) = S_OK do begin
        s := ClassIdToProgID(clsid);
        Proc(s);
    end;
end;

function TScriptingEngineProperty.GetValue: string;
begin
    result := ClassIdToProgId(StringToGUID(GetStrValue));
end;

{$endif wap_axscript}


procedure Register;
begin
    RegisterComponents(
        'WebApp',
        [
        TWapApp,
        TWapSession,
        TWapModule,
        TDBAutoSession,
        TWapAction,
        TWapTemplate,
        TAdRotator,
        TBrowserType,
        TPagedDataSource
        ]);

    RegisterComponents(
        'WebApp Controls',
        [
        THTMLForm,
        THTMLText,
        THTMLTextArea,
        THTMLButton,
        THTMLSelect,
        THTMLRadio,
        THTMLCheckbox,
        THTMLRadioGroup,
        THTMLCheckboxGroup,
        THTMLChunk,
        THTMLHidden
        ]);

    RegisterComponents(
        'WebApp Data Controls',
        [
        TDBHtmlTable,
        TDBHtmlText,
        TDBHtmlTextArea,
        TDBHtmlCheckbox,
        TDBHtmlSelect,
        TDBHtmlChunk,
        TDBHtmlHidden
        ]);

{$ifdef wap_need_TCollection_editor}
    RegisterPropertyEditor(TypeInfo(TWapActionItems), nil, '', TWapActionItemsProperty);
    RegisterComponentEditor(TWapSession, TWapActionItemsEditor);
{$endif wap_need_TCollection_editor}
{$ifdef wap_axscript}
    RegisterPropertyEditor(TypeInfo(string), TWapTemplate, 'ScriptingEngine', TScriptingEngineProperty);
{$endif wap_axscript}
end;

end.
