/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////

unit WapActns;

interface

{$I WapDef.INC}

{$ifdef wap_cbuilder}
    {$ObjExportAll On}
{$endif wap_cbuilder}

uses Classes, SysUtils, AppSSI, WVarDict, WapMask, MthdsLst;

type

THttpRequest = AppSSI.THttpRequest;
THttpResponse = AppSSI.THttpResponse;

TVariantList = WVarDict.TVariantList;
TWapVariantDictionary = WVarDict.TWapVariantDictionary;

EUnsupportedVerb = class(Exception);

TWapActionExecuteEvent = procedure (
    Sender: TObject;
    Request: THttpRequest; Response: THttpResponse;
    const Verb, Value: string; Params: TVariantList;
    var Handled: boolean) of object;

TWapActionBeforeExecuteEvent = procedure (
    Sender: TObject;
    Request: THttpRequest; Response: THttpResponse;
    const Verb, Value: string; Params: TVariantList) of object;

TWapActionAfterExecuteEvent = procedure (
    Sender: TObject;
    Request: THttpRequest; Response: THttpResponse;
    const Verb, Value: string; Params: TVariantList) of object;

TWapCustomAction = class(TComponent)
private
    FExposedProperties: TStringList;
    FNameChangeHandlers: TNotifyEventList;
    FOnBeforeExecute: TWapActionBeforeExecuteEvent;
    FOnExecute: TWapActionExecuteEvent;
    FOnAfterExecute: TWapActionAfterExecuteEvent;
protected
    procedure UnsupportedVerbError(const Verb: string); virtual;
    procedure UpdateProperties(Params: TVariantList); virtual;
    procedure ExposeProperty(const PropName: string); virtual;
    procedure ExposeProperties(const Properties: array of string); virtual;
    procedure HideProperty(const PropName: string); virtual;
    procedure HideProperties(const Properties: array of string); virtual;
    property NameChangeHandlers: TNotifyEventList read FNameChangeHandlers;
    procedure SetName(const NewName: TComponentName); override;
    procedure BeforeExecute(Request: THttpRequest; Response: THttpResponse;
        const Verb, Value: string; Params: TVariantList); virtual;
    procedure Execute(Request: THttpRequest; Response: THttpResponse;
        const Verb, Value: string; Params: TVariantList;
        var Handled: boolean); virtual;
    procedure AfterExecute(Request: THttpRequest; Response: THttpResponse;
        const Verb, Value: string; Params: TVariantList); virtual;
    property OnBeforeExecute: TWapActionBeforeExecuteEvent read FOnBeforeExecute write FOnBeforeExecute;
    property OnExecute: TWapActionExecuteEvent read FOnExecute write FOnExecute;
    property OnAfterExecute: TWapActionAfterExecuteEvent read FOnAfterExecute write FOnAfterExecute;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExecuteAction(
        Request: THttpRequest; Response: THttpResponse;
        const Verb, Value: string; Params: TVariantList;
        var Handled: boolean); virtual;
end;

TWapAction = class(TWapCustomAction)
published
    property OnExecute;
end;

TActionItemTrigger = (atActionName, atMethodType, atLogicalPath);
TActionItemTriggers = set of TActionItemTrigger;

TWapActionItem = class(TCollectionItem)
private
    FLogicalPath: string;
    FMethodType: THttpMethodType;
    FDefault: boolean;
    FEnabled: boolean;
    FActionObject: TWapCustomAction;
    FMask: TWapMask;
    FDummyComponent: TComponent;
    FTriggers: TActionItemTriggers;
    FActionName: string;
    function DispatchAction(Request: THttpRequest; Response: THttpResponse; DoDefault: boolean): boolean;
    procedure SetDefault(Value: boolean);
    procedure SetEnabled(Value: boolean);
    procedure SetMethodType(Value: THttpMethodType);
    procedure SetLogicalPath(const Value: string);
    procedure SetActionObject(const Value: TWapCustomAction);
    procedure SetTriggers(Value: TActionItemTriggers);
    procedure NameChangeHandler(Sender: TObject);
    function DetermineActionName: string;
    procedure ReadActionName(Reader: TReader);
    procedure WriteActionName(Writer: TWriter);
    procedure SetActionName(const Value: string);
protected
    // Called by the dummy component
    procedure Notification(AComponent: TComponent; Operation: TOperation);
    procedure DefineProperties(Filer: TFiler); override;
public
{$ifdef wap_delphi_2_or_cbuilder_1}
    function GetDisplayName: string;
{$else}
    function GetDisplayName: string; override;
{$endif wap_delphi_2_or_cbuilder_1}
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure AssignTo(Dest: TPersistent); override;
    property ActionName: string read FActionName write SetActionName;
published
    property Enabled: boolean read FEnabled write SetEnabled default True;
    property Default: boolean read FDefault write SetDefault default False;
    property Triggers: TActionItemTriggers read FTriggers write SetTriggers;
    property ActionObject: TWapCustomAction read FActionObject write SetActionObject;
    property MethodType: THttpMethodType read FMethodType write SetMethodType default mtAny;
    property LogicalPath: string read FLogicalPath write SetLogicalPath;
end;

{ TWapActionItems }

TWapActionItems = class(TCollection)
private
    FOwner: TComponent;
    function GetActionItem(Index: integer): TWapActionItem;
    procedure SetActionItem(Index: integer; Value: TWapActionItem);
protected
    procedure Update(Item: TCollectionItem); override;
{$ifdef wap_delphi_2_or_cbuilder_1}
    function GetAttrCount: integer;
    function GetAttr(Index: integer): string;
    function GetItemAttr(Index, ItemIndex: integer): string;
    function GetOwner: TPersistent; 
{$else}
public
    function GetAttrCount: integer; override;
    function GetAttr(Index: integer): string; override;
    function GetItemAttr(Index, ItemIndex: integer): string; override;
    function GetOwner: TPersistent; override;
{$endif wap_delphi_2_or_cbuilder_1}
public
    constructor Create(Owner: TComponent);
    function DispatchActions(Request: THttpRequest; Response: THttpResponse): boolean; virtual;
    function ExecuteAction(
        Request: THttpRequest; Response: THttpResponse;
        const Name, Verb, Value: string; Params: TVariantList): boolean; virtual;
    function GetActionName(Action: TWapCustomAction): string;
    function ActionByName(const AName: string): TWapActionItem;
    function Add: TWapActionItem;
    property Owner: TComponent read FOwner;
    property Items[Index: integer]: TWapActionItem read GetActionItem write SetActionItem; default;
end;

function ExtractActionParams(
    // Input
    Request: THttpRequest;
    const ActionName: string;
    // output
    var Verb, Value: string;
    Params: TVariantList): boolean;

implementation

uses WapRTTI, XStrings;

////////////////////////////////////////////////////////////////////////////
//
// TDummyComponent
//
////////////////////////////////////////////////////////////////////////////

type
TDummyComponent = class(TComponent)
private
    FActionItem: TWapActionItem;
protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
end;

procedure TDummyComponent.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited;
    FActionItem.Notification(AComponent, Operation);
end;

////////////////////////////////////////////////////////////////////////////
//
// TWapActionItem
//
////////////////////////////////////////////////////////////////////////////

constructor TWapActionItem.Create(Collection: TCollection);
begin
    inherited Create(Collection);
    FEnabled := True;
    FMask := TWapMask.Create('');
    FDummyComponent := TDummyComponent.Create(nil);
    TDummyComponent(FDummyComponent).FActionItem := Self;
end;

destructor TWapActionItem.Destroy;
begin
    SetActionObject(nil);
    FMask.Free;
    FDummyComponent.Free;
    inherited Destroy;
end;

procedure TWapActionItem.Notification(AComponent: TComponent; Operation: TOperation);
begin
    if ((Operation = opRemove) and (AComponent = ActionObject)) then
        FActionObject := nil;
end;

procedure TWapActionItem.DefineProperties(Filer: TFiler);
begin
    inherited;
    Filer.DefineProperty('ActionName', ReadActionName, WriteActionName, true);
end;

procedure TWapActionItem.ReadActionName(Reader: TReader);
begin
    FActionName := Reader.ReadString;
end;

procedure TWapActionItem.WriteActionName(Writer: TWriter);
begin
    Writer.WriteString(FActionName);
end;

procedure TWapActionItem.AssignTo(Dest: TPersistent);
begin
    if (Dest is TWapActionItem) then begin
        if Assigned(Collection) then
            Collection.BeginUpdate;
        try
            with TWapActionItem(Dest) do begin
                // tbd
                Default := Self.Default;
                LogicalPath := Self.LogicalPath;
                Enabled := Self.Enabled;
                MethodType := Self.MethodType;
                Triggers := Self.Triggers;
                ActionObject := Self.ActionObject;
            end;
        finally
            if Assigned(Collection) then
                Collection.EndUpdate;
        end;
    end else
        inherited AssignTo(Dest);
end;

// True iff found values associated with the action name
// If there are several values, Value will be CRLF-seperate
function ParseRequestVars(
    // input
    Vars: TRequestVariables;
    const ActionName: string;
    // output
    var Verb, Value: string;
    Params: TVariantList): boolean;
var
    s: string;
    i: integer;
    p: integer;
    ReqVar: TRequestVariable;
    Name: string;
    j: integer;
begin
    result := false;

    Verb := '';
    Value := '';
    Params.Clear;
    
    for i := 0 to (Vars.Count - 1) do begin
        ReqVar := Vars[i];
        s := ReqVar.Name;
        // Look for ActionName@PropertyName=Value
        p := pos('@', s);
        if (p > 0) then begin
            Name := copy(s, 1, p - 1);
            if (CompareText(Name, ActionName) = 0) then begin
                Params[copy(s, p + 1, MaxInt)] := ReqVar.Value;
                result := true;
            end;
        end else begin
            // Look for ActionName.Verb = Value or ActionName=Value
            p := GetCharPosFromEnd(S, '.');
            if (p > 0) then
                Name := copy(s, 1, p - 1)
            else
                Name := s;
            if (CompareText(Name, ActionName) = 0) then begin
                if (p = 0) then
                    Verb := ''
                else
                    Verb := copy(s, p + 1, MaxInt);
                for j := 0 to (ReqVar.Count - 1) do begin
                    if (Value <> '') then
                        Value := Value + #13#10;
                    Value := Value + ReqVar.Values[j];
                end;
                result := true;
            end;
        end;
    end;
end;

function TWapActionItem.DispatchAction(Request: THttpRequest; Response: THttpResponse;
  DoDefault: boolean): boolean;
var
    IsDefault: boolean;
    MatchesMask: boolean;
    MatchesMethod: boolean;
    MatchesName: boolean;
    Verb: string;
    Value: string;
    Params: TVariantList;
    IsNameInVars: boolean;
begin
    result := False;

    Params := TVariantList.Create;
    try
        IsDefault := (FDefault and DoDefault);
        if (not IsDefault) then begin
            if (atActionName in Triggers) then
                IsNameInVars := ExtractActionParams(Request, FActionName, Verb, Value, Params)
            else
                IsNameInVars := false;

            // LogicalPath not a trigger, or matches the one in the request
            MatchesMask := ((not (atLogicalPath in Triggers)) or FMask.Matches(Request.LogicalPath));
            // Method not a trigger or matches the request method
            MatchesMethod := ((not (atMethodType in Triggers)) or (FMethodType = Request.MethodType));
            MatchesName := ((not (atActionName in Triggers)) or (
                (atActionName in Triggers) and IsNameInVars));
        end else begin
            // Keep the compiler from complaining about uninitialized variables. The
            // value doesn't really matter, since IsDefault will short-circuit the
            // boolean expression.
            MatchesMask := false;
            MatchesMethod := false;
            MatchesName := false;
        end;

        if (
            (IsDefault)
            or
            (FEnabled and (Triggers <> []) and (MatchesMask and MatchesMethod and MatchesName))
            )
        then begin
            if (FActionObject <> nil) then begin
                result := true;
                FActionObject.ExecuteAction(Request, Response, Verb, Value, Params, result);
            end;
        end;
    finally
        Params.Free;
    end;
end;

function GetOwnerModule(Component: TComponent): TComponent;
begin
    result := Component.Owner;
end;

function TWapActionItem.DetermineActionName: string;
begin
    result := TWapActionItems(Collection).GetActionName(ActionObject);
end;

function TWapActionItem.GetDisplayName: string;
begin
    if (ActionObject = nil) then
        result := '< unassigned >'
    else
        result := FActionName;
end;

procedure TWapActionItem.SetDefault(Value: boolean);
var
    I: integer;
    Action: TWapActionItem;
begin
    if Value <> FDefault then begin
        if (Value and (Collection <> nil)) then begin
            for I := 0 to (Collection.Count - 1) do begin
                Action := TWapActionItems(Collection).Items[I];
                if ((Action <> Self) and (Action is TWapActionItem)) then
                    Action.Default := False;
            end;
        end;
        FDefault := Value;
        Changed(false);
    end;
end;

procedure TWapActionItem.SetEnabled(Value: boolean);
begin
    if (Value <> FEnabled) then begin
        FEnabled := Value;
        Changed(false);
    end;
end;

procedure TWapActionItem.SetMethodType(Value: THttpMethodType);
begin
    if Value <> FMethodType then begin
        FMethodType := Value;
        Changed(false);
    end;
end;

procedure TWapActionItem.SetTriggers(Value: TActionItemTriggers);
begin
    if (Value <> FTriggers) then begin
        FTriggers := Value;
        Changed(false);
    end;
end;

procedure TWapActionItem.NameChangeHandler(Sender: TObject);
begin
    ActionName := DetermineActionName;
end;

procedure TWapActionItem.SetActionName(const Value: string);
begin
    if (Value <> FActionName) then begin
        FActionName := Value;
        Changed(false);
    end;
end;

procedure TWapActionItem.SetActionObject(const Value: TWapCustomAction);
begin
    if (Value <> FActionObject) then begin

        if (FActionObject <> nil) then begin
            FActionObject.NameChangeHandlers.Remove(NameChangeHandler);
            FActionName := '';
        end;

        FActionObject := Value;

        if (FActionObject <> nil) then begin
            FActionObject.FreeNotification(FDummyComponent);
            FActionObject.NameChangeHandlers.Add(NameChangeHandler);
            if ((Collection <> nil) and
                (TWapActionItems(Collection).Owner <> nil) and
                (csDesigning in TWapActionItems(Collection).Owner.ComponentState)) then
                FActionName := DetermineActionName;
        end;

        Changed(false);
    end;
end;

procedure TWapActionItem.SetLogicalPath(const Value: string);
var
    Mask: TWapMask;
    NewValue: string;
begin
    if (Value <> '') then
        NewValue := ReplaceCharInString(Value, '\', '/');
    if ((NewValue <> '') and (NewValue[1] <> '/')) then
        Insert('/', NewValue, 1);
    if (AnsiCompareText(FLogicalPath, NewValue) <> 0) then begin
        Mask := TWapMask.Create(NewValue);
        try
            FLogicalPath := NewValue;
            FMask.Free;
            FMask := nil;
        except
            Mask.Free;
            raise;
        end;
        FMask := Mask;
        Changed(false);
    end;
end;

////////////////////////////////////////////////////////////////////////////
//
// TWapActionItems
//
////////////////////////////////////////////////////////////////////////////

constructor TWapActionItems.Create(Owner: TComponent);
begin
    inherited Create(TWapActionItem);
    FOwner := Owner;
end;

function TWapActionItems.Add: TWapActionItem;
begin
    result := TWapActionItem(inherited Add);
end;

function TWapActionItems.DispatchActions(Request: THttpRequest; Response: THttpResponse): boolean;
var
    i: integer;
    Action, DefaultAction: TWapActionItem;
begin
    result := false;
    I := 0;
    DefaultAction := nil;
    while ((not result) and (I < Count)) do begin
        Action := Items[I];
        result := Action.DispatchAction(Request, Response, False);
        if Action.Default then
            DefaultAction := Action;
        Inc(I);
    end;
    if ((not result) and assigned(DefaultAction)) then
        result := DefaultAction.DispatchAction(Request, Response, True);
end;

function TWapActionItems.ExecuteAction(
    Request: THttpRequest; Response: THttpResponse;
    const Name, Verb, Value: string; Params: TVariantList): boolean;
var
    i: integer;
    ActionItem: TWapActionItem;
begin
    for i := 0 to (Count - 1) do begin
        ActionItem := Items[i];
        if (assigned(ActionItem.ActionObject) and
            (CompareText(ActionItem.FActionName, Name) = 0))
        then
            ActionItem.ActionObject.Execute(Request, Response, Verb, Value, Params, result);
    end;
end;     

function TWapActionItems.GetActionItem(Index: integer): TWapActionItem;
begin
    result := TWapActionItem(inherited Items[Index]);
end;

function TWapActionItems.GetAttrCount: integer;
begin
    result := 5;
end;

function TWapActionItems.GetAttr(Index: integer): string;
begin
    case Index of
        0: result := 'Action Object';
        1: result := 'Logical Path';
        2: result := 'Method Type';
        3: result := 'Enabled';
        4: result := 'Default';
    else
        result := '';
    end;
end;

function TWapActionItems.GetItemAttr(Index, ItemIndex: integer): string;
begin
    case Index of
        0: begin
            result := Items[ItemIndex].GetDisplayName;
            if (not (atActionName in Items[ItemIndex].Triggers)) then
                result := '(' + result + ')';
        end;
        1: begin
            if (atLogicalPath in Items[ItemIndex].Triggers) then
                result := Items[ItemIndex].LogicalPath
            else
                result := 'N/A';
        end;
        2: begin
            if (atMethodType in Items[ItemIndex].Triggers) then begin
                case Items[ItemIndex].MethodType of
                    mtGet: result := 'GET';
                    mtPut: result := 'PUT';
                    mtPost: result := 'POST';
                    mtHead: result := 'HEAD';
                    mtAny: result := 'Any';
                end;
            end else
                result := 'N/A';
        end;
        3: if Items[ItemIndex].Enabled then
            result := 'True' else result := 'False'; // do not localize
        4: if Items[ItemIndex].Default then
            result := '*' else result := '';  //do not localize
    else
        result := '';
    end;
end;

function TWapActionItems.GetOwner: TPersistent;
begin
    result := FOwner;
end;

procedure TWapActionItems.SetActionItem(Index: integer; Value: TWapActionItem);
begin
    Items[Index].Assign(Value);
end;

procedure TWapActionItems.Update(Item: TCollectionItem);
begin
{!!!  if (FOwner <> nil) and
    not (csLoading in FOwner.ComponentState) then }
end;

function TWapActionItems.ActionByName(const AName: string): TWapActionItem;
var
    i: integer;
begin
    for I := 0 to (Count - 1) do begin
        Result := Items[I];
        if AnsiCompareText(AName, Result.FActionName) = 0 then
            exit;
    end;
    Result := nil;
end;

function TWapActionItems.GetActionName(Action: TWapCustomAction): string;
var
    OwnerModule: TComponent;
begin
    result := Action.Name;
    OwnerModule := GetOwnerModule(Action);
    if (OwnerModule <> GetOwnerModule(Owner)) then
        result := copy(OwnerModule.ClassName, 2, MaxInt) + '_' + result;
end;


////////////////////////////////////////////////////////////////////////////
//
// TWapCustomAction
//
////////////////////////////////////////////////////////////////////////////

constructor TWapCustomAction.Create(AOwner: TComponent);
begin
    inherited;
    FNameChangeHandlers := TNotifyEventList.Create();

    FExposedProperties := TStringList.Create;
    FExposedProperties.Sorted  := true;
    FExposedProperties.Duplicates := dupIgnore;
end;

destructor TWapCustomAction.Destroy;
begin
    FExposedProperties.Free;
    FNameChangeHandlers.Free;
    inherited;
end;

procedure TWapCustomAction.SetName(const NewName: TComponentName);
begin
    inherited;
    if (csDesigning in ComponentState) then
        FNameChangeHandlers.Notify(Self);
end;

procedure TWapCustomAction.UnsupportedVerbError(const Verb: string);
begin
    raise EUnsupportedVerb.Create(Format('The verb %s is not supported by %s: %s', [Verb, Name, ClassName]));
end;

procedure TWapCustomAction.ExposeProperty(const PropName: string);
begin
    FExposedProperties.Add(UpperCase(PropName));
end;

procedure TWapCustomAction.HideProperty(const PropName: string);
var
    i: integer;
begin
    i := FExposedProperties.IndexOf(UpperCase(PropName));
    if (i <> -1) then
        FExposedProperties.Delete(i);
end;

procedure TWapCustomAction.ExposeProperties(const Properties: array of string);
var
    i: integer;
begin
    for i := Low(Properties) to High(Properties) do
        ExposeProperty(Properties[i]);
end;

procedure TWapCustomAction.HideProperties(const Properties: array of string);
var
    i: integer;
begin
    for i := Low(Properties) to High(Properties) do
        HideProperty(Properties[i]);
end;


procedure TWapCustomAction.UpdateProperties(Params: TVariantList);
var
    i: integer;
    PropName: string;
    PropValue: string;
begin
    // tbd - this is not very efficient...
    for i := 0 to (Params.Count - 1) do begin
        PropName := Params.ItemNames[i];
        if (FExposedProperties.IndexOf(UpperCase(PropName)) = -1) then
            raise Exception.Create('Property ' + PropName + ' is not exposed');
        PropValue := string(Params[PropName]);
        SetPropertyValue(Self, PropName, PropValue);
    end;
end;

procedure TWapCustomAction.Execute(
        Request: THttpRequest;
        Response: THttpResponse;
        const Verb, Value: string; Params: TVariantList;
        var Handled: boolean);
begin
    if assigned(FOnExecute) then
        FOnExecute(Self, Request, Response, Verb, Value, Params, Handled);
end;

procedure TWapCustomAction.BeforeExecute(
    Request: THttpRequest; Response: THttpResponse;
    const Verb, Value: string; Params: TVariantList); 
begin
    if assigned(FOnBeforeExecute) then
        FOnBeforeExecute(Self, Request, Response, Verb, Value, Params);
end;

procedure TWapCustomAction.AfterExecute(
    Request: THttpRequest; Response: THttpResponse;
    const Verb, Value: string; Params: TVariantList); 
begin
    if assigned(FOnAfterExecute) then
        FOnAfterExecute(Self, Request, Response, Verb, Value, Params);
end;

procedure TWapCustomAction.ExecuteAction(
    Request: THttpRequest; Response: THttpResponse;
    const Verb, Value: string; Params: TVariantList;
    var Handled: boolean); 
begin
    BeforeExecute(Request, Response, Verb, Value, Params);
    Execute(Request, Response, Verb, Value, Params, Handled);
    AfterExecute(Request, Response, Verb, Value, Params);
end;

function ExtractActionParams(
    // Input
    Request: THttpRequest;
    const ActionName: string;
    // output
    var Verb, Value: string;
    Params: TVariantList): boolean;
var
    Vars: TRequestVariables;
begin
    result := False;

    case Request.MethodType of
        mtGet: Vars := Request.QueryString;
        mtPost: Vars := Request.Form;
        else EXIT;
    end; // case

    result := ParseRequestVars(Vars, ActionName, Verb, Value, Params)
end;        


end.
