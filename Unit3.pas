unit Unit3;

interface

uses Classes, SysUtils, DB, DBCtrls, Messages, Controls, HTMLTxt;

type

TDBHtmlText = class(THtmlText)
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

procedure Register;

implementation

constructor TDBHtmlText.Create(AOwner: TComponent);
begin
    inherited;
    FDataLink := TFieldDataLink.Create;
    FDataLink.Control := Self;
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

procedure Register;
begin
    RegisterComponents('Test', [TDBHTMLText]);
end;

end.
