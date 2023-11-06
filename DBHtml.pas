/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////
unit DBHtml;

{$I WapDef.INC}

interface

uses Classes, SysUtils, DB, DBTables, Controls, Graphics, DBCtrls, Messages,
    HtmlTxt, AppSSI, WVarDict;

type

TPagedDataSource = class(TComponent)
private
    FDataLink: TDataLink;
    FPageSize: integer;
    FCurrentPageStartBookmark: TBookmarkStr;
    function GetDataSet: TDataSet;
    procedure SetDataSource(Value: TDataSource);
    function  GetDataSource: TDataSource;
    procedure UpdatePageStartBookmark;
    procedure HandleDataSetChanged(Sender: TObject);
    procedure HandleActiveChanged(Sender: TObject);
    function GetAtFirstPage: boolean;
    function GetAtLastPage: boolean;
protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function MoveBy(PagesDistance: integer): integer;
    procedure FirstPage;
    procedure LastPage;
    procedure NextPage;
    procedure PriorPage;

    procedure SetPageStart;
    procedure GotoFirstInPage;

    property DataSet: TDataSet read GetDataSet;
    property AtFirstPage: boolean read GetAtFirstPage;
    property AtLastPage: boolean read GetAtLastPage;
published
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property PageSize: integer read FPageSize write FPageSize;
end;

type
EDBHtmlTable = class(Exception);

TPixelOrPercent = (ppPixel, ppPercent);
TDBHtmlTableOption = (htoBorderEmptyCells, htoTitles);
TDBHtmlTableOptions = set of TDBHtmlTableOption;

TCustomizeTag_TABLE_Event = procedure(Sender: TObject; var Attributes: string) of object;
TCustomizeTag_TH_Event = procedure(Sender: TObject; Field: TField; var Attributes: string) of object;
TCustomizeTag_TD_Event = procedure(Sender: TObject; Field: TField; var Attributes: string) of object;
TCustomizeTag_TR_Event = procedure(Sender: TObject; var Attributes: string) of object;
TCustomizeFieldEvent = procedure(Sender: TObject; Field: TField; var Text: string) of object;
TCustomizeFieldTitleEvent = procedure(Sender: TObject; Field: TField; var TitleText: string) of object;

TDBHtmlTable = class(TWapControl)
private
    FPagedDataSource: TPagedDataSource;
    FCaption: TCaption;
    FBorder: integer;
    FCellSpacing: integer;
    FCellPadding: integer;
    FWidth: integer;
    FWidthUnits: TPixelOrPercent;
    FBgColor: TColor;
    FBorderColor: TColor;
    FBorderColorLight: TColor;
    FBorderColorDark: TColor;
    FOptions: TDBHtmlTableOptions;
    FTitleBGColor: TColor;
    FTitleColor: TColor;

    FOnCustomizeTag_TABLE: TCustomizeTag_TABLE_Event;
    FOnCustomizeFieldTitleTag_TH: TCustomizeTag_TH_Event;
    FOnCustomizeTitleTag_TR: TCustomizeTag_TR_Event;
    FOnCustomizeTag_TD: TCustomizeTag_TD_Event;
    FOnCustomizeField: TCustomizeFieldEvent;
    FOnCustomizeFieldTitle: TCustomizeFieldTitleEvent;
    FOnCustomizeTag_TR: TCustomizeTag_TR_Event;

    function FixCellString(const S: string): string;
    function GetDataSet: TDataSet;
protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure CustomizeField(Field: TField; var Text: string); virtual;
    procedure CustomizeFieldTitle(Field: TField; var TitleText: string); virtual;
    function CustomizeTag_TABLE: string; virtual;
    function CustomizeFieldTitleTag_TH(Field: TField): string; virtual;
    function CustomizeTitleTag_TR: string; virtual;
    function CustomizeTag_TR: string; virtual;
    function CustomizeTag_TD(Field: TField): string; virtual;
    procedure ProduceHTML(Dest: TStrings); override;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property DataSet: TDataSet read GetDataSet;
published
    property PagedDataSource: TPagedDataSource read FPagedDataSource write FPagedDataSource;

    property Caption: TCaption read FCaption write FCaption;
    property Border: integer read FBorder write FBorder;
    property CellPadding: integer read FCellPadding write FCellPadding;
    property CellSpacing: integer read FCellSpacing write FCellSpacing;
    property Width: integer read FWidth write FWidth;
    property WidthUnits: TPixelOrPercent read FWidthUnits write FWidthUnits;
    property BgColor: TColor read FBgColor write FBgColor;
    property BorderColor: TColor read FBorderColor write FBorderColor;
    property BorderColorLight: TColor read FBorderColorLight write FBorderColorLight;
    property BorderColorDark: TColor read FBorderColorDark write FBorderColorDark;
    property TitleColor: TColor read FTitleColor write FTitleColor;
    property TitleBgColor: TColor read FTitleBGColor write FTitleBGColor;
    property Options: TDBHtmlTableOptions read FOptions write FOptions;

    property OnCustomizeTag_TABLE: TCustomizeTag_TABLE_Event read FOnCustomizeTag_TABLE write FOnCustomizeTag_TABLE;

    property OnCustomizeTitleTag_TR: TCustomizeTag_TR_Event read FOnCustomizeTitleTag_TR write FOnCustomizeTitleTag_TR;
    property OnCustomizeFieldTitleTag_TH: TCustomizeTag_TH_Event read FOnCustomizeFieldTitleTag_TH write FOnCustomizeFieldTitleTag_TH;
    property OnCustomizeFieldTitle: TCustomizeFieldTitleEvent read FOnCustomizeFieldTitle write FOnCustomizeFieldTitle;

    property OnCustomizeTag_TR: TCustomizeTag_TR_Event read FOnCustomizeTag_TR write FOnCustomizeTag_TR;
    property OnCustomizeTag_TD: TCustomizeTag_TD_Event read FOnCustomizeTag_TD write FOnCustomizeTag_TD;
    property OnCustomizeField: TCustomizeFieldEvent read FOnCustomizeField write FOnCustomizeField;
end;


(*

UNDER CONSTRUCTION!

TNavButtonsFormat = (bfImage, bfText, bfCustom);
TNavButton = (nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel, nbRefresh);

TNavRenderButtonEvent = procedure(Sender: TObject; Button: TNavButton; var ButtonHTML: string) of object;

TNavigationMethod = (nmRecord, nmPage);

TDBHtmlNavigatorImages = class;

TDBHtmlNavigator = class(TWapControl)
private
    FImages: TDBHtmlNavigatorImages;
    FPagedDataSource: TPagedDataSource;
    FButtonsFormat: TNavButtonsFormat;
    FNavigation: TNavigationMethod;
    FOnRenderButton: TNavRenderButtonEvent;
protected
    procedure Submit(
        Request: THttpRequest; Response: THttpResponse;
        const Value: string; Params: TVariantList;
        var Handled: Boolean); override;
    procedure WriteHTML(
        Request: THttpRequest; Response: THttpResponse;
        const Value: string; Params: TVariantList;
        var Handled: Boolean); override;
    procedure ProduceHTML(Dest: TStrings); override;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
published
    // Properties
    property PagedDataSource: TPagedDataSource read FPagedDataSource write FPagedDataSource;
    property Images: TDBHtmlNavigatorImages read FImages;
    property ButtonsFormat: TNavButtonsFormat read FButtonsFormat write FButtonsFormat;
    property Navigation: TNavigationMethod read FNavigation write FNavigation;
    // Events
    property OnRenderButton: TNavRenderButtonEvent read FOnRenderButton write FOnRenderButton;
end;

TDBHtmlNavigatorImage = class(TPersistent)
private
    FURL: string;
    FAltText: string;
published
    property URL: string read FURL write FURL;
    property AltText: string read FAltText write FAltText;
end;

TDBHtmlNavigatorImages = class(TPersistent)
private
    FFirst: TDBHtmlNavigatorImage;
    FPrior: TDBHtmlNavigatorImage;
    FNext: TDBHtmlNavigatorImage;
    FLast: TDBHtmlNavigatorImage;
    FInsert: TDBHtmlNavigatorImage;
    FDelete: TDBHtmlNavigatorImage;
    FEdit: TDBHtmlNavigatorImage;
    FPost: TDBHtmlNavigatorImage;
    FCancel: TDBHtmlNavigatorImage;
    FRefresh: TDBHtmlNavigatorImage;
public
    constructor Create; 
    destructor Destroy; override;
published
    property First: TDBHtmlNavigatorImage read FFirst write FFirst;
    property Prior: TDBHtmlNavigatorImage read FPrior write FPrior;
    property Next: TDBHtmlNavigatorImage read FNext write FNext;
    property Last: TDBHtmlNavigatorImage read FLast write FLast;
    property Insert: TDBHtmlNavigatorImage read FInsert write FInsert;
    property Delete: TDBHtmlNavigatorImage read FDelete write FDelete;
    property Edit: TDBHtmlNavigatorImage read FEdit write FEdit;
    property Post: TDBHtmlNavigatorImage read FPost write FPost;
    property Cancel: TDBHtmlNavigatorImage read FCancel write FCancel;
    property Refresh: TDBHtmlNavigatorImage read FRefresh write FRefresh;
end;
*)

TDBHtmlText = class(TCustomHtmlText)
private
    FDataLink: TFieldDataLink;
    procedure UpdateData(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    function GetField: TField;
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Change; override;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;
published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property MaxLength;
    property Size;
    property Password;
end;

TDBHtmlTextArea = class(TCustomHTMLTextArea)
private
    FDataLink: TFieldDataLink;
    procedure UpdateData(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    function GetField: TField;
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Change; override;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;
published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property MaxLength;
    property Rows;
    property Cols;
end;

TDBHtmlHidden = class(TCustomHTMLHidden)
private
    FDataLink: TFieldDataLink;
    procedure UpdateData(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    function GetField: TField;
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Change; override;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;
published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
end;

TDBHtmlCheckbox = class(TCustomHTMLCheckbox)
private
    FDataLink: TFieldDataLink;
    FValueCheck: string;
    FValueUncheck: string;
    procedure UpdateData(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    function GetField: TField;
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
    procedure SetValueCheck(const Value: string);
    procedure SetValueUncheck(const Value: string);
    function ValueMatch(const ValueList, Value: string): Boolean;
    function GetFieldState: boolean;
protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Change; override;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;
    property Checked;
published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ValueChecked: string read FValueCheck write SetValueCheck;
    property ValueUnchecked: string read FValueUncheck write SetValueUncheck;
end;

TDBHtmlChunk = class(TCustomHtmlChunk)
private
    FDataLink: TFieldDataLink;
    procedure UpdateData(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    function GetField: TField;
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Change; override;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;
published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property Escape;
end;

TDBHtmlSelect = class(TCustomHtmlSelect)
private
    FDataLink: TFieldDataLink;
    procedure UpdateData(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    function GetField: TField;
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
    procedure ItemsChanged(Sender: TObject);
protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Change; override;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Field: TField read GetField;
published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property Size;
    property Items;
end;


implementation

uses DBConsts;

////////////////////////////////////////////////////////////////////
//
// TInternalDataLink
//
////////////////////////////////////////////////////////////////////

type

TDataSetScrolledEvent = procedure(Sender: TObject; Distance: integer) of object;
TFocusControlEvent = procedure(Sender: TObject; Field: TFieldRef) of object;
TRecordChangedEvent = procedure(Sender: TObject; Field: TField) of object;

TInternalDataLink = class(TDataLink)
private
    FOnActiveChanged: TNotifyEvent;
    FOnCheckBrowseMode: TNotifyEvent;
    FOnDataSetChanged: TNotifyEvent;
    FOnDataSetScrolled: TDataSetScrolledEvent;
    FOnFocusControl: TFocusControlEvent;
    FOnEditingChanged: TNotifyEvent;
    FOnLayoutChanged: TNotifyEvent;
    FOnRecordChanged: TRecordChangedEvent;
    FOnUpdateData: TNotifyEvent;
protected
    procedure ActiveChanged; override;
    procedure CheckBrowseMode; override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure FocusControl(Field: TFieldRef); override;
    procedure EditingChanged; override;
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;
    procedure UpdateData; override;
public
    property OnActiveChanged: TNotifyEvent read FOnActiveChanged write FOnActiveChanged;
    property OnCheckBrowseMode: TNotifyEvent read FOnCheckBrowseMode write FOnCheckBrowseMode;
    property OnDataSetChanged: TNotifyEvent read FOnDataSetChanged write FOnDataSetChanged;
    property OnDataSetScrolled: TDataSetScrolledEvent read FOnDataSetScrolled write FOnDataSetScrolled;
    property OnFocusControl: TFocusControlEvent read FOnFocusControl write FOnFocusControl;
    property OnEditingChanged: TNotifyEvent read FOnEditingChanged write FOnEditingChanged;
    property OnLayoutChanged: TNotifyEvent read FOnLayoutChanged write FOnLayoutChanged;
    property OnRecordChanged: TRecordChangedEvent read FOnRecordChanged write FOnRecordChanged;
    property OnUpdateData: TNotifyEvent read FOnUpdateData write FOnUpdateData;
end;

procedure TInternalDataLink.ActiveChanged;
begin
    inherited;
    if assigned(FOnActiveChanged) then
        FOnActiveChanged(Self);
end;

procedure TInternalDataLink.CheckBrowseMode;
begin
    inherited;
    if assigned(FOnCheckBrowseMode) then
        FOnCheckBrowseMode(Self);
end;

procedure TInternalDataLink.DataSetChanged;
begin
    inherited;
    if assigned(FOnDataSetChanged) then
        FOnDataSetChanged(Self);
end;

procedure TInternalDataLink.DataSetScrolled(Distance: Integer);
begin
    inherited;
    if assigned(FOnDataSetScrolled) then
        FOnDataSetScrolled(Self, Distance);
end;

procedure TInternalDataLink.FocusControl(Field: TFieldRef);
begin
    inherited;
    if assigned(FOnFocusControl) then
        FOnFocusControl(Self, Field);
end;

procedure TInternalDataLink.EditingChanged;
begin
    inherited;
    if assigned(FOnEditingChanged) then
        FOnEditingChanged(Self);
end;

procedure TInternalDataLink.LayoutChanged;
begin
    inherited;
    if assigned(FOnLayoutChanged) then
        FOnLayoutChanged(Self);
end;

procedure TInternalDataLink.RecordChanged(Field: TField);
begin
    inherited;
    if assigned(FOnRecordChanged) then
        FOnRecordChanged(Self, Field);
end;

procedure TInternalDataLink.UpdateData;
begin
    inherited;
    if assigned(FOnUpdateData) then
        FOnUpdateData(Self);
end;

////////////////////////////////////////////////////////////////////
//
// TPagedDataSource
//
////////////////////////////////////////////////////////////////////

constructor TPagedDataSource.Create(AOwner: TComponent);
begin
    inherited;
    FPageSize := 10;
    FDataLink := TInternalDataLink.Create;
    TInternalDataLink(FDataLink).OnDataSetChanged := HandleDataSetChanged;
    TInternalDataLink(FDataLink).OnActiveChanged := HandleActiveChanged;
end;

destructor TPagedDataSource.Destroy;
begin
    FDataLink.Free;
    FDataLink := nil;
    inherited;
end;

procedure TPagedDataSource.HandleDataSetChanged(Sender: TObject);
begin
    FCurrentPageStartBookmark := '';
    if (FDataLink.Active) then
        HandleActiveChanged(Self);
end;

procedure TPagedDataSource.HandleActiveChanged(Sender: TObject);
begin
    UpdatePageStartBookmark;
end;

procedure TPagedDataSource.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if ((Operation = opRemove) and (FDataLink <> nil) and (AComponent = DataSource)) then
    DataSource := nil;
end;

function TPagedDataSource.GetDataSet: TDataSet;
begin
    if (DataSource = nil) then
        result := nil
    else
        result := DataSource.DataSet;
end;

procedure TPagedDataSource.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if not (csLoading in ComponentState) then
    HandleActiveChanged(Self);
  if Value <> nil then Value.FreeNotification(Self);
end;

function TPagedDataSource.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TPagedDataSource.Loaded;
begin
  inherited Loaded;
  HandleActiveChanged(Self);
end;

procedure   TPagedDataSource.UpdatePageStartBookmark;
begin
    if (DataSet <> nil) then
        FCurrentPageStartBookmark := DataSet.Bookmark
    else
        FCurrentPageStartBookmark := '';
end;

procedure TPagedDataSource.SetPageStart;
begin
    UpdatePageStartBookmark;
end;

procedure   TPagedDataSource.GotoFirstInPage;
begin
    if (DataSet <> nil) then
        DataSet.Bookmark := FCurrentPageStartBookmark;
end;

function TPagedDataSource.GetAtFirstPage: boolean;
var
    DistMoved: integer;
begin
    if (DataSet = nil) then begin
        result := false;
        exit;
    end;
    
    DistMoved := MoveBy(-1);
    try
        result := DataSet.BOF;
    finally
        DataSet.MoveBy(-DistMoved);
    end;
end;

function TPagedDataSource.GetAtLastPage: boolean;
var
    DistMoved: integer;
begin
    if (DataSet = nil) then begin
        result := false;
        exit;
    end;
    
    DistMoved := MoveBy(1);
    try
        result := DataSet.EOF;
    finally
        DataSet.MoveBy(-DistMoved);
    end;
end;

function TPagedDataSource.MoveBy(PagesDistance: integer): integer;
begin
    if (DataSet = nil) then begin
        result := 0;
        exit;
    end;

    GotoFirstInPage;
    result := DataSet.MoveBy(FPageSize * PagesDistance);
    UpdatePageStartBookmark;
end;

procedure   TPagedDataSource.FirstPage;
begin
    if (DataSet <> nil) then begin
        DataSet.First;
        UpdatePageStartBookmark;
    end;
end;

procedure   TPagedDataSource.LastPage;
begin
    if (DataSet <> nil) then begin
        DataSet.Last;
        DataSet.Prior; // Turns off the EOF flag
        DataSet.MoveBy(-FPageSize + 1);
        DataSet.Next; // Compensate for the Prior
        UpdatePageStartBookmark;
    end;
end;

procedure   TPagedDataSource.NextPage;
begin
    MoveBy(1);
end;

procedure   TPagedDataSource.PriorPage;
begin
    MoveBy(-1);
end;


////////////////////////////////////////////////////////////////////
//
// TDBHtmlTable
//
////////////////////////////////////////////////////////////////////


constructor TDBHtmlTable.Create(AOwner: TComponent);
begin
    inherited;
    FBorder := -1;
    FCellSpacing := -1;
    FCellPadding := -1;
    FWidth := -1;
    FWidthUnits := ppPixel;
    FOptions := [htoTitles];
    FBgColor := clNone;
    FBorderColor := clNone;
    FBorderColorLight := clNone;
    FBorderColorDark := clNone;
    FTitleBGColor := clNone;
    FTitleColor := clNone;
end;

destructor  TDBHtmlTable.Destroy;
begin
    inherited;
end;

procedure   TDBHtmlTable.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if ((AComponent = FPagedDataSource) and (Operation = opRemove)) then begin
        FPagedDataSource := nil;
    end;
end;

function TDBHtmlTable.FixCellString(const S: string): string;
begin
    if ((S = '') and ((htoBorderEmptyCells in Options))) then
        result := '&nbsp;'
    else
        result := S;
end;

function IsEmptyDataSet(DataSet: TDataSet): boolean;
begin
    result := (DataSet.EOF and DataSet.BOF);
end;

procedure TDBHtmlTable.ProduceHTML(Dest: TStrings); 
var
    RecCount: integer;
    I: integer;
    S: string;
    Temp: string;
    Bookmark: string;
begin
    with Dest do begin
        // <TABLE> tag
        S := '<TABLE';
        if (FCellPadding <> -1) then
            S := S + ' CELLPADDING=' + IntToStr(FCellPadding);
        if (FCellSpacing <> -1) then
            S := S + ' CELLSPACING=' + IntToStr(FCellSpacing);
        if (FBorder <> -1) then
            S := S + ' BORDER=' + IntToStr(FBorder);
        if (FWidth <> -1) then begin
            S := S + ' WIDTH=' + IntToStr(FWidth);
            if (FWidthUnits = ppPercent) then
                S := S + '%';
        end;
        if ((FBgColor <> clDefault) and (FBgColor <> clNone)) then
            S := S + ' BGCOLOR="' + ColorToHtmlColor(FBgColor) + '"';
        if ((FBorderColor <> clDefault) and (FBorderColor <> clNone)) then
            S := S + ' BORDERCOLOR="' + ColorToHtmlColor(FBorderColor) + '"';
        if ((FBorderColorLight <> clDefault) and (FBorderColorLight <> clNone)) then
            S := S + ' BORDERCOLORLIGHT="' + ColorToHtmlColor(FBorderColorLight) + '"';
        if ((FBorderColorDark <> clDefault) and (FBorderColorDark <> clNone)) then
            S := S + ' BORDERCOLORDARK="' + ColorToHtmlColor(FBorderColorDark) + '"';
        Add(S + ' ' + CustomizeTag_TABLE + '>');

        // <CAPTION>..</CAPTION>
        if (FCaption <> '') then
            Add('<CAPTION>' + FCaption + '</CAPTION>');

        if ((FPagedDataSource <> nil) and (DataSet <> nil)) then begin
            // <TR> <TH>..</TH> <TH>..</TH> </TR>
            if (htoTitles in Options) then begin
                S := '<TR ';
                if ((FTitleBGColor <> clNone) and (FTitleBGColor <> clDefault)) then
                    S := S + ' BGCOLOR="' + ColorToHtmlColor(FTitleBGColor) + '" ';
                Add(S + CustomizeTitleTag_TR + '>');
                S := '  ';
                for I := 0 to (DataSet.FieldCount - 1) do begin
                    if (DataSet.Fields[I].Visible) then begin
                        Temp := DataSet.Fields[I].DisplayName;
                        CustomizeFieldTitle(DataSet.Fields[I], Temp);
                        S := S + '<TH ' + CustomizeFieldTitleTag_TH(DataSet.Fields[I]) + '>';
                        if ((FTitleColor <> clNone) and (FTitleColor <> clDefault)) then
                            S := S + '<FONT COLOR="' + ColorToHtmlColor(FTitleColor) + '">';
                        S := S + FixCellString(Temp);
                        if ((FTitleColor <> clNone) and (FTitleColor <> clDefault)) then
                            S := S + '</FONT>';
                        S := S + '</TH>';
                    end;
                end; // for
                S := S + '</TR>';
                Add(S);
            end;

            if ((DataSet.Active) and (not IsEmptyDataSet(DataSet))) then begin
                // <TR> <TD>..</TD> <TD>..</TD> </TR>
                RecCount := 0;
                DataSet.DisableControls;
                Bookmark := DataSet.Bookmark;
                try
                    while (
                        (
                            (FPagedDataSource.PageSize <= 0) or
                            ((FPagedDataSource.PageSize > 0) and (RecCount < FPagedDataSource.PageSize))
                        ))
                    do begin
                        Add('<TR' + CustomizeTag_TR + '>');
                        S := '  ';
                        for I := 0 to (DataSet.FieldCount - 1) do begin
                            if (DataSet.Fields[I].Visible) then begin
                                Temp := DataSet.Fields[I].DisplayText;
                                CustomizeField(DataSet.Fields[I], Temp);
                                S := S + '<TD ' + CustomizeTag_TD(DataSet.Fields[I]) + '>' +
                                    FixCellString(Temp) + '</TD>';
                            end;
                        end; // for
                        Add(S);
                        Add('</TR>');
                        DataSet.Next;
                        if (DataSet.EOF) then
                            BREAK;
                        inc(RecCount);
                    end; // while
                finally
                    DataSet.Bookmark := Bookmark;
                    DataSet.EnableControls;
                end;
            end; // if
        end; // if has dataset
        Add('</TABLE>');
    end; // with Strings
end;

function    TDBHtmlTable.CustomizeTag_TABLE: string;
begin
    result := '';
    if assigned(FOnCustomizeTag_TABLE) then
        FOnCustomizeTag_TABLE(self, result);
end;

function    TDBHtmlTable.CustomizeFieldTitleTag_TH(Field: TField): string;
begin
    result := '';
    if assigned(FOnCustomizeFieldTitleTag_TH) then
        FOnCustomizeFieldTitleTag_TH(self, field, result);
end;

function    TDBHtmlTable.CustomizeTag_TD(Field: TField): string;
begin
    result := '';
    if assigned(FOnCustomizeTag_TD) then
        FOnCustomizeTag_TD(self, field, result);
end;

function TDBHtmlTable.GetDataSet: TDataSet;
begin
    if (FPagedDataSource = nil) then
        result := nil
    else
        result := FPagedDataSource.DataSet;
end;

procedure TDBHtmlTable.CustomizeField(Field: TField; var Text: string);
begin
    if assigned(FOnCustomizeField) then
        FOnCustomizeField(Self, Field, Text);
end;

procedure TDBHtmlTable.CustomizeFieldTitle(Field: TField; var TitleText: string);
begin
    if assigned(FOnCustomizeFieldTitle) then
        FOnCustomizeFieldTitle(Self, Field, TitleTExt);
end;

function TDBHtmlTable.CustomizeTitleTag_TR: string;
begin
    result := '';
    if assigned(FOnCustomizeTitleTag_TR) then
        FOnCustomizeTitleTag_TR(Self, Result);
end;

function TDBHtmlTable.CustomizeTag_TR: string;
begin
    result := '';
    if assigned(FOnCustomizeTag_TR) then
        FOnCustomizeTag_TR(Self, Result);
end;


(*

////////////////////////////////////////////////////////////////////
//
// TDBHtmlNavigator
//
////////////////////////////////////////////////////////////////////

constructor TDBHtmlNavigator.Create(AOwner: TComponent);
begin
    inherited;
    FImages := TDBHtmlNavigatorImages.Create;
end;

destructor TDBHtmlNavigator.Destroy;
begin
    FImages.Free;
    inherited;
end;


////////////////////////////////////////////////////////////////////
//
// TDBHtmlNavigatorImages
//
////////////////////////////////////////////////////////////////////

function CreateImage(const URL, AltText: string): TDBHtmlNavigatorImage;
begin
    result := TDBHtmlNavigatorImage.Create;
    result.URL := URL;
    result.AltText := AltText;
end;

constructor TDBHtmlNavigatorImages.Create;
begin
    inherited;
    FFirst := CreateImage('', 'First');
    FPrior := CreateImage('', 'Prior');
    FNext := CreateImage('', 'Next');
    FLast := CreateImage('', 'Last');
    FInsert := CreateImage('', 'Insert');
    FDelete := CreateImage('', 'Delete');
    FEdit := CreateImage('', 'Edit');
    FPost := CreateImage('', 'Post');
    FCancel := CreateImage('', 'Cancel');
    FRefresh := CreateImage('', 'Refresh');
end;

destructor TDBHtmlNavigatorImages.Destroy;
begin
    FFirst.Free;
    FPrior.Free;
    FNext.Free;
    FLast.Free;
    FInsert.Free;
    FDelete.Free;
    FEdit.Free;
    FPost.Free;
    FCancel.Free;
    FRefresh.Free;
    inherited;
end;

*)

////////////////////////////////////////////////////////////////////
//
// TDBHtmlText
//
////////////////////////////////////////////////////////////////////

constructor TDBHtmlText.Create(AOwner: TComponent);
begin
    inherited;
    FDataLink := TFieldDataLink.Create;
    FDataLink.Control := TWinControl(Self);
    FDataLink.OnDataChange := DataChange;
    FDataLink.OnEditingChange := EditingChange;
    FDataLink.OnUpdateData := UpdateData;
end;

destructor TDBHtmlText.Destroy;
begin
    FDataLink.Free;
    FDataLink := nil;
    inherited Destroy;
end;

procedure TDBHtmlText.Loaded;
begin
    inherited Loaded;
    if (csDesigning in ComponentState) then DataChange(Self);
end;

procedure TDBHtmlText.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if ((Operation = opRemove) and (FDataLink <> nil) and (AComponent = DataSource)) then
        DataSource := nil;
end;

function TDBHtmlText.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBHtmlText.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

function TDBHtmlText.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDBHtmlText.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TDBHtmlText.GetField: TField;
begin
  Result := FDataLink.Field;
end;


procedure TDBHtmlText.DataChange(Sender: TObject);
begin
    if FDataLink.Field <> nil then begin
(*        if FAlignment <> FDataLink.Field.Alignment then begin
            EditText := '';  {forces update}
            FAlignment := FDataLink.Field.Alignment;
        end;*)
        Text := FDataLink.Field.DisplayText;
    end else begin
        if csDesigning in ComponentState then
            Text := Name
        else
            Text := '';
    end;
end;

procedure TDBHtmlText.EditingChange(Sender: TObject);
begin
end;

procedure TDBHtmlText.CMGetDataLink(var Message: TMessage);
begin
    Message.Result := Integer(FDataLink);
end;

procedure TDBHtmlText.UpdateData(Sender: TObject);
begin
    FDataLink.Field.Text := Text;
end;

procedure TDBHtmlText.Change;
begin
  FDataLink.Modified;
  inherited Change;
end;

////////////////////////////////////////////////////////////////////
//
// TDBHtmlTextArea
//
////////////////////////////////////////////////////////////////////

constructor TDBHtmlTextArea.Create(AOwner: TComponent);
begin
    inherited;
    FDataLink := TFieldDataLink.Create;
    FDataLink.Control := TWinControl(Self);
    FDataLink.OnDataChange := DataChange;
    FDataLink.OnEditingChange := EditingChange;
    FDataLink.OnUpdateData := UpdateData;
end;

destructor TDBHtmlTextArea.Destroy;
begin
    FDataLink.Free;
    FDataLink := nil;
    inherited Destroy;
end;

procedure TDBHtmlTextArea.Loaded;
begin
    inherited Loaded;
    if (csDesigning in ComponentState) then DataChange(Self);
end;

procedure TDBHtmlTextArea.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if ((Operation = opRemove) and (FDataLink <> nil) and (AComponent = DataSource)) then
        DataSource := nil;
end;

function TDBHtmlTextArea.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBHtmlTextArea.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

function TDBHtmlTextArea.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDBHtmlTextArea.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TDBHtmlTextArea.GetField: TField;
begin
  Result := FDataLink.Field;
end;

function IsBlobField(Field: TField): boolean;
begin
{$ifdef wap_delphi_2_or_cbuilder_1}
        result := Field is TBlobField;
{$endif wap_delphi_2_or_cbuilder_1}
{$ifdef wap_delphi_3_or_delphi_4_or_cbuilder_3}
        result := Field.IsBlob;
{$endif wap_delphi_3_or_delphi_4_or_cbuilder_3}
end;


procedure TDBHtmlTextArea.DataChange(Sender: TObject);
begin
    if FDataLink.Field <> nil then begin
(*        if FAlignment <> FDataLink.Field.Alignment then begin
            EditText := '';  {forces update}
            FAlignment := FDataLink.Field.Alignment;
        end;*)
        if IsBlobField(FDataLink.Field) then begin
            Lines.Text := FDataLink.Field.AsString;
        end else begin
            Lines.Text := FDataLink.Field.DisplayText;
        end;
    end else begin
        if csDesigning in ComponentState then
            Lines.Text := Name
        else
            Lines.Text := '';
    end;
end;

procedure TDBHtmlTextArea.EditingChange(Sender: TObject);
begin
end;

procedure TDBHtmlTextArea.CMGetDataLink(var Message: TMessage);
begin
    Message.Result := Integer(FDataLink);
end;

procedure TDBHtmlTextArea.UpdateData(Sender: TObject);
begin
    if IsBlobField(FDataLink.Field) then
        FDataLink.Field.Assign(Lines)
    else
        FDataLink.Field.AsString := Lines.Text;
end;

procedure TDBHtmlTextArea.Change;
begin
  FDataLink.Modified;
  inherited Change;
end;

////////////////////////////////////////////////////////////////////
//
// TDBHtmlHidden
//
////////////////////////////////////////////////////////////////////

constructor TDBHtmlHidden.Create(AOwner: TComponent);
begin
    inherited;
    FDataLink := TFieldDataLink.Create;
    FDataLink.Control := TWinControl(Self);
    FDataLink.OnDataChange := DataChange;
    FDataLink.OnEditingChange := EditingChange;
    FDataLink.OnUpdateData := UpdateData;
end;

destructor TDBHtmlHidden.Destroy;
begin
    FDataLink.Free;
    FDataLink := nil;
    inherited Destroy;
end;

procedure TDBHtmlHidden.Loaded;
begin
    inherited Loaded;
    if (csDesigning in ComponentState) then DataChange(Self);
end;

procedure TDBHtmlHidden.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if ((Operation = opRemove) and (FDataLink <> nil) and (AComponent = DataSource)) then
        DataSource := nil;
end;

function TDBHtmlHidden.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBHtmlHidden.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

function TDBHtmlHidden.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDBHtmlHidden.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TDBHtmlHidden.GetField: TField;
begin
  Result := FDataLink.Field;
end;


procedure TDBHtmlHidden.DataChange(Sender: TObject);
begin
    if FDataLink.Field <> nil then begin
(*        if FAlignment <> FDataLink.Field.Alignment then begin
            EditText := '';  {forces update}
            FAlignment := FDataLink.Field.Alignment;
        end;*)
        Value := FDataLink.Field.AsString;
    end else begin
        if csDesigning in ComponentState then
            Value := Name
        else
            Value := '';
    end;
end;

procedure TDBHtmlHidden.EditingChange(Sender: TObject);
begin
end;

procedure TDBHtmlHidden.CMGetDataLink(var Message: TMessage);
begin
    Message.Result := Integer(FDataLink);
end;

procedure TDBHtmlHidden.UpdateData(Sender: TObject);
begin
    FDataLink.Field.Text := Value;
end;

procedure TDBHtmlHidden.Change;
begin
  FDataLink.Modified;
  inherited Change;
end;


////////////////////////////////////////////////////////////////////
//
// TDBHtmlCheckbox
//
////////////////////////////////////////////////////////////////////

constructor TDBHtmlCheckbox.Create(AOwner: TComponent);
begin
    inherited;
    Checked := false;
{$ifdef wap_delphi_2_or_cbuilder_1}
    FValueCheck := LoadStr(STextTrue);
    FValueUncheck := LoadStr(STextFalse);
{$endif wap_delphi_2_or_cbuilder_1}
{$ifdef wap_delphi_3_or_delphi_4_or_cbuilder_3}
    FValueCheck := STextTrue;
    FValueUncheck := STextFalse;
{$endif wap_delphi_3_or_delphi_4_or_cbuilder_3}
    FDataLink := TFieldDataLink.Create;
    FDataLink.Control := TWinControl(Self);
    FDataLink.OnDataChange := DataChange;
    FDataLink.OnEditingChange := EditingChange;
    FDataLink.OnUpdateData := UpdateData;
end;

destructor TDBHtmlCheckbox.Destroy;
begin
    FDataLink.Free;
    FDataLink := nil;
    inherited Destroy;
end;

procedure TDBHtmlCheckbox.Loaded;
begin
    inherited Loaded;
    if (csDesigning in ComponentState) then DataChange(Self);
end;

procedure TDBHtmlCheckbox.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if ((Operation = opRemove) and (FDataLink <> nil) and (AComponent = DataSource)) then
        DataSource := nil;
end;

function TDBHtmlCheckbox.GetFieldState: boolean;
var
  Text: string;
begin
  if FDatalink.Field <> nil then
    if FDataLink.Field.IsNull then
      Result := false
    else if FDataLink.Field.DataType = ftBoolean then
      if FDataLink.Field.AsBoolean then
        Result := true
      else
        Result := false
    else
    begin
      Result := false;
      Text := FDataLink.Field.Text;
      if ValueMatch(FValueCheck, Text) then Result := true else
        if ValueMatch(FValueUncheck, Text) then Result := false;
    end
  else
    Result := false;
end;

function TDBHtmlCheckbox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBHtmlCheckbox.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

function TDBHtmlCheckbox.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDBHtmlCheckbox.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TDBHtmlCheckbox.GetField: TField;
begin
  Result := FDataLink.Field;
end;


procedure TDBHtmlCheckbox.DataChange(Sender: TObject);
begin
    Checked := GetFieldState;
end;

procedure TDBHtmlCheckbox.EditingChange(Sender: TObject);
begin
end;

procedure TDBHtmlCheckbox.CMGetDataLink(var Message: TMessage);
begin
    Message.Result := Integer(FDataLink);
end;

procedure TDBHtmlCheckbox.UpdateData(Sender: TObject);
var
  Pos: Integer;
  S: string;
begin
    if FDataLink.Field.DataType = ftBoolean then
      FDataLink.Field.AsBoolean := Checked
    else
    begin
      if Checked then S := FValueCheck else S := FValueUncheck;
      Pos := 1;
      FDataLink.Field.Text := ExtractFieldName(S, Pos);
    end;
end;

procedure TDBHtmlCheckbox.Change;
begin
  FDataLink.Modified;
  inherited Change;
end;

procedure TDBHtmlCheckbox.SetValueCheck(const Value: string);
begin
    FValueCheck := Value;
    DataChange(Self);
end;

procedure TDBHtmlCheckbox.SetValueUncheck(const Value: string);
begin
    FValueUncheck := Value;
    DataChange(Self);
end;

function TDBHtmlCheckbox.ValueMatch(const ValueList, Value: string): Boolean;
var
    p: integer;
begin
    result := false;
    p := 1;
    while (p <= Length(ValueList)) do begin
        if (AnsiCompareText(ExtractFieldName(ValueList, p), Value) = 0) then begin
            result := true;
            break;
        end;
    end;
end;

////////////////////////////////////////////////////////////////////
//
// TDBHtmlChunk
//
////////////////////////////////////////////////////////////////////

constructor TDBHtmlChunk.Create(AOwner: TComponent);
begin
    inherited;
    FDataLink := TFieldDataLink.Create;
    FDataLink.Control := TWinControl(Self);
    FDataLink.OnDataChange := DataChange;
    FDataLink.OnEditingChange := EditingChange;
    FDataLink.OnUpdateData := UpdateData;
end;

destructor TDBHtmlChunk.Destroy;
begin
    FDataLink.Free;
    FDataLink := nil;
    inherited Destroy;
end;

procedure TDBHtmlChunk.Loaded;
begin
    inherited Loaded;
    if (csDesigning in ComponentState) then DataChange(Self);
end;

procedure TDBHtmlChunk.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if ((Operation = opRemove) and (FDataLink <> nil) and (AComponent = DataSource)) then
        DataSource := nil;
end;

function TDBHtmlChunk.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBHtmlChunk.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

function TDBHtmlChunk.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDBHtmlChunk.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TDBHtmlChunk.GetField: TField;
begin
  Result := FDataLink.Field;
end;


procedure TDBHtmlChunk.DataChange(Sender: TObject);
begin
    if FDataLink.Field <> nil then begin
(*        if FAlignment <> FDataLink.Field.Alignment then begin
            EditText := '';  {forces update}
            FAlignment := FDataLink.Field.Alignment;
        end;*)
        if IsBlobField(FDataLink.Field) then begin
            Lines.Text := FDataLink.Field.AsString;
        end else begin
            Lines.Text := FDataLink.Field.DisplayText;
        end;
    end else begin
        if csDesigning in ComponentState then
            Lines.Text := Name
        else
            Lines.Clear;
    end;
end;

procedure TDBHtmlChunk.EditingChange(Sender: TObject);
begin
end;

procedure TDBHtmlChunk.CMGetDataLink(var Message: TMessage);
begin
    Message.Result := Integer(FDataLink);
end;

procedure TDBHtmlChunk.UpdateData(Sender: TObject);
begin
    if IsBlobField(FDataLink.Field) then
        FDataLink.Field.Assign(Lines)
    else
        FDataLink.Field.AsString := Lines.Text;
end;

procedure TDBHtmlChunk.Change;
begin
  FDataLink.Modified;
  inherited Change;
end;

////////////////////////////////////////////////////////////////////
//
// TDBHtmlSelect
//
////////////////////////////////////////////////////////////////////

constructor TDBHtmlSelect.Create(AOwner: TComponent);
begin
    inherited;
    FDataLink := TFieldDataLink.Create;
    FDataLink.Control := TWinControl(Self);
    FDataLink.OnDataChange := DataChange;
    FDataLink.OnEditingChange := EditingChange;
    FDataLink.OnUpdateData := UpdateData;
    (Items as TStringList).OnChange := ItemsChanged;
end;

destructor TDBHtmlSelect.Destroy;
begin
    FDataLink.Free;
    FDataLink := nil;
    inherited Destroy;
end;

procedure TDBHtmlSelect.Loaded;
begin
    inherited Loaded;
    if (csDesigning in ComponentState) then DataChange(Self);
end;

procedure TDBHtmlSelect.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited Notification(AComponent, Operation);
    if ((Operation = opRemove) and (FDataLink <> nil) and (AComponent = DataSource)) then
        DataSource := nil;
end;

function TDBHtmlSelect.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBHtmlSelect.SetDataSource(Value: TDataSource);
begin
  FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

function TDBHtmlSelect.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDBHtmlSelect.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TDBHtmlSelect.GetField: TField;
begin
  Result := FDataLink.Field;
end;


procedure TDBHtmlSelect.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    ItemIndex := Items.IndexOf(FDataLink.Field.Text) else
    ItemIndex := -1;
end;

procedure TDBHtmlSelect.EditingChange(Sender: TObject);
begin
end;

procedure TDBHtmlSelect.CMGetDataLink(var Message: TMessage);
begin
    Message.Result := Integer(FDataLink);
end;

procedure TDBHtmlSelect.UpdateData(Sender: TObject);
begin
  if ItemIndex >= 0 then
    FDataLink.Field.Text := Items[ItemIndex] else
    FDataLink.Field.Text := '';
end;

procedure TDBHtmlSelect.Change;
begin
    if (FDataLink.Edit) then begin
        inherited Change;
        FDataLink.Modified;
    end;
end;

procedure TDBHtmlSelect.ItemsChanged(Sender: TObject);
begin
    DataChange(Self);
end;

end.
