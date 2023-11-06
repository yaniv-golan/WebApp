unit DBFormMdl;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DBTables, DBWap, Db, DBHtml, HtmlTxt, WapActns, HWebApp, WapTmplt;

type
  TDBForm = class(TDataModule)
    DBAutoSession1: TDBAutoSession;
    DBDemosDatabase: TDatabase;
    EmployeeTable: TTable;
    EmployeeTableEmpNo: TIntegerField;
    EmployeeTableLastName: TStringField;
    EmployeeTableFirstName: TStringField;
    EmployeeTablePhoneExt: TStringField;
    EmployeeTableHireDate: TDateTimeField;
    EmployeeTableSalary: TFloatField;
    EmployeeSource: TDataSource;
    HTMLForm1: THTMLForm;
    WapModule1: TWapModule;
    EmpNoHtmlText: TDBHtmlText;
    FirstNameHtmlText: TDBHtmlText;
    HireDateHtmlText: TDBHtmlText;
    LastNameHtmlText: TDBHtmlText;
    PhoneExtHtmlText: TDBHtmlText;
    SalaryHtmlText: TDBHtmlText;
    NavImage: TWapAction;
    ImageList1: TImageList;
    RecordTemplate: TWapTemplate;
    procedure DBHtmlTable1CustomizeField(Sender: TObject; Field: TField;
      var Text: String);
    procedure NavImageExecute(Sender: TObject; Request: THttpRequest;
      Response: THttpResponse; const Verb, Value: String;
      Params: TVariantList; var Handled: Boolean);
    procedure HTMLForm1AfterSubmit(Sender: TObject; Request: THttpRequest;
      Response: THttpResponse; const Value: String;
      Params: TVariantList);
    procedure RecordTemplateGetMacroValue(Sender: TObject;
      const Name: String; var Value: Variant);
    procedure HTMLForm1BeforeSubmit(Sender: TObject; Request: THttpRequest;
      Response: THttpResponse; const Value: String;
      Params: TVariantList);
    procedure DBFormCreate(Sender: TObject);
  private
    { Private declarations }
    function GetRequest: THttpRequest;
    function GetResponse: THttpResponse;
    procedure GetButtonBitmap(const Button: string; Bitmap: TBitmap);
    procedure DoDataSetAction(const Action, Bookmark: string);
  public
    { Public declarations }
    property Request: THttpRequest read GetRequest;
    property Response: THttpResponse read GetResponse;
  end;

var
  DBForm: TDBForm;

implementation

uses Unit2, Base64;

{$R *.DFM}

function TDBForm.GetRequest: THttpRequest;
begin
    result := WapModule1.Request;
end;

function TDBForm.GetResponse: THttpResponse;
begin
    result := WapModule1.Response;
end;

procedure TDBForm.RecordTemplateGetMacroValue(Sender: TObject;
  const Name: String; var Value: Variant);
begin
  // Provide the current Employee table bookmark (position). We Base64-encode it
  // because it is binary.
  if (CompareText(Name, 'EmployeeBookmark') = 0) then
    Value := StringToBase64(EmployeeTable.Bookmark);
end;

procedure TDBForm.DBHtmlTable1CustomizeField(Sender: TObject;
  Field: TField; var Text: String);
var
  URL: string;
begin
  // Create a URL which will activate the action "RecordFrame", and pass the
  // current record bookmark in the "Bookmark" paramter.
  // The bookmark indicates which record should we display in the lower frame.
  // We need to Base64-encode it because it's binary data.
  URL := SelfURL(Request, '',
    ActionWithParams('DBForm_RecordFrame', '', '', [
     ActionParam('Bookmark', StringToBase64(EmployeeTable.Bookmark))]
  ));
  // We would like the result of this action to go to the lower frame (RecordFrame)
  Text := '<A HREF="' + URL + '" TARGET="RecordFrame">' + Text + '</A>';
end;

procedure TDBForm.GetButtonBitmap(const Button: string; Bitmap: TBitmap);
var
    Index: integer;
begin
    if (Button = 'FIRST') then
        Index := 0
    else if (Button = 'PRIOR') then
        Index := 1
    else if (Button = 'NEXT') then
        Index := 2
    else if (Button = 'LAST') then
        Index := 3
    else if (Button = 'INSERT') then
        Index := 4
    else if (Button = 'DELETE') then
        Index := 5
    else if (Button = 'EDIT') then
        Index := 6
    else if (Button = 'POST') then
        Index := 7
    else if (Button = 'CANCEL') then
        Index := 8
    else if (Button = 'REFRESH') then
        Index := 9
    else
        raise Exception.Create('Button name not recognized');
    ImageList1.GetBitmap(Index, Bitmap);
end;

procedure TDBForm.DoDataSetAction(const Action, Bookmark: string);
begin
    if (Action = 'FIRST') then begin
        EmployeeTable.First;
    end else if (Action = 'PRIOR') then begin
        EmployeeTable.Bookmark := Bookmark;
        EmployeeTable.Prior;
    end else if (Action = 'NEXT') then begin
        EmployeeTable.Bookmark := Bookmark;
        EmployeeTable.Next;
    end else if (Action = 'LAST') then begin
        EmployeeTable.Last;
    end else if (Action = 'DELETE') then begin
        EmployeeTable.Bookmark := Bookmark;
        EmployeeTable.Delete;
    end else
        raise Exception.Create('Action name not recognized');
end;

procedure TDBForm.NavImageExecute(Sender: TObject; Request: THttpRequest;
  Response: THttpResponse; const Verb, Value: String;
  Params: TVariantList; var Handled: Boolean);
var
    Bitmap: TBitmap;
    Bookmark: string;
begin
    if (CompareText(Verb, 'WriteImage') = 0) then begin
        Bitmap := TBitmap.Create;
        try
            GetButtonBitmap(UpperCase(Params['Image']), Bitmap);
            // Allow the browser to cache the images :
            Response.Expires := 60 * 24;
            Response.SendBitmapAsJPEG(Bitmap);
        finally
            Bitmap.Free;
        end;
    end else if (CompareText(Verb, 'DataSetAction') = 0) then begin
        // Though it is unlikely, it is conceivable that the table's position
        // is no longer the same as it was when we generated the HTML form. If we
        // ignore this possibility, we might delete the wrong record.
        // Therefore, for dataset operations which are relative to a certain record
        // (Prior, Next, Delete) we generate the current bookmark in the HTML, and
        // here we use it to make sure we are positioned on the correct record. 
        if (Params['Bookmark'] = null) then
            Bookmark := ''
        else
            Bookmark := Base64ToString(Params['Bookmark']);
        DoDataSetAction(UpperCase(Params['Action']), Bookmark);
        RecordTemplate.WriteToStream(Response.OutputStream);
    end;
end;


procedure TDBForm.HTMLForm1BeforeSubmit(Sender: TObject;
  Request: THttpRequest; Response: THttpResponse; const Value: String;
  Params: TVariantList);
begin
  try
    if ((Params['Bookmark'] <> null) and (Params['Bookmark'] <> '')) then
    begin
      // This will happen when the user clicks the "Post" button :
      // A bookmark was specified, we would like to update the record specified
      // the "bookmark" field.
      EmployeeTable.Bookmark := Base64ToString(string(Params['Bookmark']));
      EmployeeTable.Edit;
    end
    else
    begin
      // This will happen when the user clicks the "Insert" button :
      // No bookmark - we would like to create a new record.
      // (We use JavaScript on the client-side in the "Insert" button click
      // event handler to set the "bookmark" field to null before submitting
      // the record).
      EmployeeTable.Insert;
    end;
  except
    on E: Exception do
    begin
      Writeln(Response.TextOut, Par('Could not post updated data : '+ E.Message));
      Abort;
    end;
  end;
end;

procedure TDBForm.HTMLForm1AfterSubmit(Sender: TObject;
  Request: THttpRequest; Response: THttpResponse; const Value: String;
  Params: TVariantList);
begin
  try
    EmployeeTable.Post;
  except
    on E: Exception do
    begin
      Writeln(Response.TextOut, '<P><B>Invalid Input</B>: ', E.Message, '</p>');
      EmployeeTable.Cancel;
    end;
  end;
  RecordTemplate.WriteToStream(Response.OutputStream);
end;

procedure TDBForm.DBFormCreate(Sender: TObject);
begin
    RecordTemplate.Filename := ExtractFilePath(Application.ExeName) + 'Record.htm';
end;

end.
