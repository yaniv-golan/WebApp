unit WapAcPEd;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, WapActns, DsgnIntf, Menus;

type
  TWapActionsEditorForm = class(TForm)
    ActionsListbox: TListBox;
    Label11: TLabel;
    Label1: TLabel;
    ActionObjectCombo: TComboBox;
    Label3: TLabel;
    DefaultCombo: TComboBox;
    Label4: TLabel;
    EnabledCombo: TComboBox;
    Label5: TLabel;
    Label6: TLabel;
    MethodTypeCombo: TComboBox;
    LogicalPathEdit: TEdit;
    Panel1: TPanel;
    CancelButton: TButton;
    OkButton: TButton;
    Bevel1: TBevel;
    AddButton: TButton;
    DeleteButton: TButton;
    GroupBox1: TGroupBox;
    ActionNameCbox: TCheckBox;
    LogicalPathCbox: TCheckBox;
    MethodTypeCbox: TCheckBox;
    procedure AddButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ActionsListboxClick(Sender: TObject);
    procedure ActionObjectComboChange(Sender: TObject);
    procedure DefaultComboChange(Sender: TObject);
    procedure EnabledComboChange(Sender: TObject);
    procedure LogicalPathEditChange(Sender: TObject);
    procedure MethodTypeComboChange(Sender: TObject);
    procedure DeleteButtonClick(Sender: TObject);
    procedure ActionNameCboxClick(Sender: TObject);
    procedure LogicalPathCboxClick(Sender: TObject);
    procedure MethodTypeCboxClick(Sender: TObject);
  private
    { Private declarations }
    FActions: TWapActionItems;
    FDesigner: TFormDesigner;
    procedure RefreshList;
    procedure SelectionChanged;
    procedure AddActionObjectName(const S: string);
    function GetSelectedAction: TWapActionItem;
    procedure AddSelectedActionsToList(List: TComponentList);
  public
    { Public declarations }
    property Actions: TWapActionItems read FActions write FActions;
    property Designer: TFormDesigner read FDesigner write FDesigner;
  end;

var
  WapActionsEditorForm: TWapActionsEditorForm;

implementation

{$R *.DFM}

uses TypInfo, AppSSI;

procedure TWapActionsEditorForm.AddButtonClick(Sender: TObject);
var
    ActionItem: TWapActionItem;
    i: integer;
begin
    ActionItem := Actions.Add as TWapActionItem;
    RefreshList;
    i := ActionsListbox.Items.IndexOfObject(ActionItem);
    ActionsListbox.ItemIndex := i;
end;

procedure TWapActionsEditorForm.RefreshList;
var
    i: integer;
    ActionItem: TWapActionItem;
begin
    with ActionsListbox do begin
        Items.BeginUpdate;
        try
            Items.Clear;
            for i := 0 to (Actions.Count - 1) do begin
                ActionItem := Actions[i] as TWapActionItem;
                Items.AddObject(ActionItem.GetDisplayName, ActionItem);
            end;
        finally
            Items.EndUpdate;
        end;
    end;
end;

procedure EnumToStrings(EnumType: PTypeInfo; Strings: TStrings);
var
  I: Integer;
begin
  with GetTypeData(EnumType)^ do
    for I := MinValue to MaxValue do
        Strings.AddObject(GetEnumName(EnumType, I), TObject(I));
end;

procedure TWapActionsEditorForm.FormShow(Sender: TObject);
begin
    EnumToStrings(TypeInfo(THttpMethodType), MethodTypeCombo.Items);
    EnumToStrings(TypeInfo(Boolean), EnabledCombo.Items);
    EnumToStrings(TypeInfo(Boolean), DefaultCombo.Items);
    Designer.GetComponentNames(GetTypeData(TypeInfo(TWapCustomAction)), AddActionObjectName);

    RefreshList;
    SelectionChanged;

    Caption := 'Editing ' + Actions.Owner.Name + ' Actions';
end;

procedure TWapActionsEditorForm.ActionsListboxClick(Sender: TObject);
begin
    SelectionChanged;
end;

function TWapActionsEditorForm.GetSelectedAction: TWapActionItem;
begin
    if ((ActionsListbox.ItemIndex = -1) or (ActionsListbox.SelCount > 1)) then
        result := nil
    else
        result := ActionsListbox.Items.Objects[ActionsListbox.ItemIndex] as TWapActionItem;
end;

procedure TWapActionsEditorForm.SelectionChanged;
var
    ActionItem: TWapActionItem;
begin
    ActionItem := GetSelectedAction;

    if (ActionItem = nil) then begin
        ActionObjectCombo.ItemIndex := -1;
        ActionObjectCombo.Enabled := false;

        ActionNameCbox.Checked := false;
        ActionNameCbox.Enabled := false;

        LogicalPathCbox.Checked := false;
        LogicalPathCbox.Enabled := false;

        MethodTypeCbox.Checked := false;
        MethodTypeCbox.Enabled := false;

        DefaultCombo.ItemIndex := -1;
        DefaultCombo.Enabled := false;

        EnabledCombo.ItemIndex := -1;
        EnabledCombo.Enabled := false;

        LogicalPathEdit.Text := '';
        LogicalPathEdit.Enabled := false;

        MethodTypeCombo.ItemIndex := -1;
        MethodTypeCombo.Enabled := false;
    end else begin
        if (ActionItem.ActionObject = nil) then
            ActionObjectCombo.ItemIndex := -1
        else
            ActionObjectCombo.ItemIndex := ActionObjectCombo.Items.IndexOf(Designer.GetComponentName(ActionItem.ActionObject));
        ActionObjectCombo.Enabled := true;

        ActionNameCbox.Checked := atActionName in ActionItem.Triggers;
        ActionNameCbox.Enabled := true;

        LogicalPathCbox.Checked := atLogicalPath in ActionItem.Triggers;
        LogicalPathCbox.Enabled := true;

        MethodTypeCbox.Checked := atMethodType in ActionItem.Triggers;
        MethodTypeCbox.Enabled := true;

        DefaultCombo.ItemIndex := DefaultCombo.Items.IndexOfObject(TObject(Ord(ActionItem.Default)));
        DefaultCombo.Enabled := true;

        EnabledCombo.ItemIndex := EnabledCombo.Items.IndexOfObject(TObject(Ord(ActionItem.Enabled)));
        EnabledCombo.Enabled := true;

        LogicalPathEdit.Text := ActionItem.LogicalPath;
        LogicalPathEdit.Enabled := true;

        MethodTypeCombo.ItemIndex := MethodTypeCombo.Items.IndexOfObject(TObject(Ord(ActionItem.MethodType)));
        MethodTypeCombo.Enabled := true;
    end;
end;

procedure TWapActionsEditorForm.AddActionObjectName(const S: string);
begin
    ActionObjectCombo.Items.Add(S);
end;

procedure TWapActionsEditorForm.ActionObjectComboChange(Sender: TObject);
var
    Action: TWapActionItem;
    S: string;
    ActionObject: TObject;
begin
    Action := GetSelectedAction;
    S := ActionObjectCombo.Items[ActionObjectCombo.ItemIndex];
    if (S = '') then
        Action.ActionObject := nil
    else begin
        ActionObject := Designer.GetComponent(S);
        if not (ActionObject is TWapCustomAction) then
            raise Exception.Create('Invalid property value');
        Action.ActionObject := TWapCustomAction(ActionObject);
    end;
    ActionsListbox.Items[ActionsListbox.ItemIndex] := Action.GetDisplayName;
end;

procedure TWapActionsEditorForm.DefaultComboChange(Sender: TObject);
var
    Action: TWapActionItem;
begin
    Action := GetSelectedAction;
    Action.Default := Boolean(DefaultCombo.Items.Objects[DefaultCombo.ItemIndex]);
end;

procedure TWapActionsEditorForm.EnabledComboChange(Sender: TObject);
var
    Action: TWapActionItem;
begin
    Action := GetSelectedAction;
    Action.Enabled := Boolean(EnabledCombo.Items.Objects[EnabledCombo.ItemIndex]);
end;

procedure TWapActionsEditorForm.LogicalPathEditChange(Sender: TObject);
var
    Action: TWapActionItem;
begin
    Action := GetSelectedAction;
    Action.LogicalPath := LogicalPathEdit.Text;
end;


procedure TWapActionsEditorForm.MethodTypeComboChange(Sender: TObject);
var
    Action: TWapActionItem;
begin
    Action := GetSelectedAction;
    Action.MethodType := THttpMethodType(MethodTypeCombo.Items.Objects[MethodTypeCombo.ItemIndex]);
end;

procedure TWapActionsEditorForm.DeleteButtonClick(Sender: TObject);
var
    Action: TWapActionItem;
    ItemIndex: integer;
    Selected: TList;
    i: integer;
begin
    ItemIndex := ActionsListbox.ItemIndex;
    Selected := TList.Create;
    try
        for i := 0 to (ActionsListbox.Items.Count - 1) do
            if ActionsListbox.Selected[i] then
                Selected.Add(ActionsListbox.Items.Objects[i]);
        for i := 0 to (Selected.Count - 1) do begin
            Action := ActionsListbox.Items.Objects[i] as TWapActionItem;
            if (Action <> nil) then begin
                Action.Collection := nil;
                Action.Free;
            end;
        end;
    finally
        Selected.Free;
    end;
    RefreshList;
    if (ItemIndex > ActionsListbox.Items.Count - 1) then
        ItemIndex := ActionsListbox.Items.Count - 1;
    ActionsListbox.ItemIndex := ItemIndex;
end;

procedure TWapActionsEditorForm.AddSelectedActionsToList(List: TComponentList);
var
    I: Integer;
begin
    with ActionsListbox do
        for I := 0 to (Items.Count - 1) do
            if Selected[I] then
                List.Add(Items.Objects[I] as TComponent);
end;

procedure TWapActionsEditorForm.ActionNameCboxClick(Sender: TObject);
var
    Action: TWapActionItem;
begin
    Action := GetSelectedAction;
    if (ActionNameCbox.Checked) then
        Action.Triggers := Action.Triggers + [atActionName]
    else
        Action.Triggers := Action.Triggers - [atActionName];
end;

procedure TWapActionsEditorForm.LogicalPathCboxClick(Sender: TObject);
var
    Action: TWapActionItem;
begin
    Action := GetSelectedAction;
    if (LogicalPathCbox.Checked) then
        Action.Triggers := Action.Triggers + [atLogicalPath]
    else
        Action.Triggers := Action.Triggers - [atLogicalPath];
end;

procedure TWapActionsEditorForm.MethodTypeCboxClick(Sender: TObject);
var
    Action: TWapActionItem;
begin
    Action := GetSelectedAction;
    if (MethodTypeCbox.Checked) then
        Action.Triggers := Action.Triggers + [atMethodType]
    else
        Action.Triggers := Action.Triggers - [atMethodType];
end;

end.
