unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HWebApp, AppSSI, HtmlTxt, DBWap, DBTables, WapActns, WapTmplt, Db,
  taRubicn, DBHtml, InetStr, XStrings;

type
  TSessionModule = class(TDataModule)
    WapSession1: TWapSession;
    Database1: TDatabase;
    DBAutoSession1: TDBAutoSession;
    DefaultAction: TWapAction;
    DisplaySearchFrame: TWapAction;
    DisplayMessage: TWapAction;
    SearchFor: TWapAction;
    WapTemplate1: TWapTemplate;
    TempMatchTable1: TTable;
    DataSource2: TDataSource;
    MatchHtmlTable: TDBHtmlTable;
    PagedDataSource1: TPagedDataSource;
    TempMatchTable2: TTable;
    WriteFieldValue: TWapAction;
    TempMatchTable2Forum: TStringField;
    TempMatchTable2MsgNo: TIntegerField;
    TempMatchTable2ReplyTo: TIntegerField;
    TempMatchTable2Section: TSmallintField;
    TempMatchTable2Topic: TStringField;
    TempMatchTable2From: TStringField;
    TempMatchTable2To: TStringField;
    TempMatchTable2Date: TDateTimeField;
    TempMatchTable2Message: TMemoField;
    TempMatchTable2IndexNo: TAutoIncField;
    DisplayBlankPage: TWapAction;
    procedure DefaultActionExecute(Sender: TObject; Request: THttpRequest;
      Response: THttpResponse; const Verb, Value: String;
      Params: TVariantList; var Handled: Boolean);
    procedure SessionModuleCreate(Sender: TObject);
    procedure DisplaySearchFrameExecute(Sender: TObject;
      Request: THttpRequest; Response: THttpResponse; const Verb,
      Value: String; Params: TVariantList; var Handled: Boolean);
    procedure SearchForExecute(Sender: TObject; Request: THttpRequest;
      Response: THttpResponse; const Verb, Value: String;
      Params: TVariantList; var Handled: Boolean);
    procedure MatchHtmlTableCustomizeField(Sender: TObject; Field: TField;
      var Text: String);
    procedure MatchHtmlTableCustomizeTag_TD(Sender: TObject; Field: TField;
      var Attributes: String);
    procedure DisplayMessageExecute(Sender: TObject; Request: THttpRequest;
      Response: THttpResponse; const Verb, Value: String;
      Params: TVariantList; var Handled: Boolean);
    procedure WriteFieldValueExecute(Sender: TObject;
      Request: THttpRequest; Response: THttpResponse; const Verb,
      Value: String; Params: TVariantList; var Handled: Boolean);
    procedure TempMatchTable2MessageGetText(Sender: TField;
      var Text: String; DisplayText: Boolean);
    procedure WapSession1End(Session: TWapSession);
    procedure DisplayBlankPageExecute(Sender: TObject;
      Request: THttpRequest; Response: THttpResponse; const Verb,
      Value: String; Params: TVariantList; var Handled: Boolean);
  private
    { Private declarations }
    AppPath: string;
    TempFilename: string;
    TempTableName: string;
    function GetRequest: THttpRequest;
    function GetResponse: THttpResponse;
  public
    { Public declarations }
    property Request: THttpRequest read GetRequest;
    property Response: THttpResponse read GetResponse;
  end;

var
  SessionModule: TSessionModule;

implementation

uses MRubicon;

{$R *.DFM}

function GenerateUniqueFilename: string;
var
    TempPath: string;
    Len: dword;
begin
    SetLength(TempPath, MAX_PATH);
    Len := GetTempPath(MAX_PATH, PChar(TempPath));
    if (Len = 0) then
        RaiseLastWin32Error;
    SetLength(TempPath, Len);
    SetLength(Result, MAX_PATH);
    if (GetTempFileName(PChar(TempPath), 'WAP', 0, PChar(Result)) = 0) then
        RaiseLastWin32Error;
    SetLength(Result, StrLen(PChar(Result)));
end;

procedure TSessionModule.SessionModuleCreate(Sender: TObject);
begin
    AppPath := ExtractFilePath(Application.ExeName);
    // Get a unique filename
    TempFilename := GenerateUniqueFilename;
    // Use it for the temporary table name - we can be sure to a high degree
    // that the name is not already used
    TempTableName := ChangeFileExt(TempFilename, '.DB');
    
    TempMatchTable1.DatabaseName := ExtractFilePath(TempTableName);
    TempMatchTable1.TableName := ExtractFilename(TempTableName);

    // Set TempMatchTable2 to be exactly the same as TempMatchTable2. The reason
    // we need both of them is becuase we'd like to be able control which fields
    // from the results table are displayed, and how - but Rubicon does not like
    // the Match table having any defined fields. So we will use TempMatchTable1
    // to keep Rubicon happy, and TempMatchTable2 to define the fields we're interested
    // in.     
    TempMatchTable2.DatabaseName := TempMatchTable1.DatabaseName;
    TempMatchTable2.TableName := TempMatchTable1.TableName;
end;

function TSessionModule.GetRequest: THttpRequest;
begin
  Result := WapSession1.Request;
end;

function TSessionModule.GetResponse: THttpResponse;
begin
  Result := WapSession1.response;
end;

procedure TSessionModule.DefaultActionExecute(Sender: TObject;
  Request: THttpRequest; Response: THttpResponse; const Verb,
  Value: String; Params: TVariantList; var Handled: Boolean);
begin
    WapTemplate1.Filename := AppPath + 'Default.htm';
    WapTemplate1.WriteToStream(Response.OutputStream);
end;

procedure TSessionModule.DisplaySearchFrameExecute(Sender: TObject;
  Request: THttpRequest; Response: THttpResponse; const Verb,
  Value: String; Params: TVariantList; var Handled: Boolean);
begin
    WapTemplate1.Filename := AppPath + 'SearchFrame.htm';
    WapTemplate1.WriteToStream(Response.OutputStream);
end;

procedure TSessionModule.SearchForExecute(Sender: TObject;
  Request: THttpRequest; Response: THttpResponse; const Verb,
  Value: String; Params: TVariantList; var Handled: Boolean);
begin
    // Rubicon will want exclusive access to the table
    TempMatchTable2.Close;
    with RubiconModule do
    begin
        // Lock the Rubicon components, to prevent other threads from
        // trying to use them
        Lock;
        try
            SearchDictionary.SearchFor := Value;
            SearchDictionary.Execute;
            // Retrieve the search results into our uniquq temporary table
            SearchDictionary.CreateMatchTable(TempMatchTable1);
        finally
            // Release the Rubicon components lock
            Unlock;
        end;
    end; // with

    // Now we can open the results table
    TempMatchTable2.Open;

    WapSession1['DisplayResults'] := true;
    WapSession1['SearchFor'] := Value;
    WapTemplate1.Filename := AppPath + 'SearchFrame.htm';
    WapTemplate1.WriteToStream(Response.OutputStream);
end;

procedure TSessionModule.MatchHtmlTableCustomizeField(Sender: TObject;
  Field: TField; var Text: String);
begin
    Text := Link(
        SelfURL(
            Request,
            '',
            ActionWithParams('DisplayMessage', '', '', ['MsgNo=' + TempMatchTable2MsgNo.AsString])
        ),
        'ResultsFrame',
        Text);
end;

procedure TSessionModule.MatchHtmlTableCustomizeTag_TD(Sender: TObject;
  Field: TField; var Attributes: String);
begin
    Attributes := 'NOWRAP';
end;

procedure TSessionModule.DisplayMessageExecute(Sender: TObject;
  Request: THttpRequest; Response: THttpResponse; const Verb,
  Value: String; Params: TVariantList; var Handled: Boolean);
begin
    TempMatchTable2.Open; // Just for extra robustness...
    TempMatchTable2.Locate('MsgNo', Params['MsgNo'], []);
    WapTemplate1.Filename := AppPath + 'ResultsFrame.htm';
    WapTemplate1.WriteToStream(Response.OutputStream);
end;

procedure TSessionModule.WriteFieldValueExecute(Sender: TObject;
  Request: THttpRequest; Response: THttpResponse; const Verb,
  Value: String; Params: TVariantList; var Handled: Boolean);
var
    S: string;
begin
    S := TempMatchTable2.FieldByName(Params['Field']).DisplayText;
    Write(Response.TextOut, S);
end;

procedure TSessionModule.TempMatchTable2MessageGetText(Sender: TField;
  var Text: String; DisplayText: Boolean);
var
    Lines: TStringList;
    i: integer;
begin
    Lines := TStringList.Create;
    try
        Lines.Assign(TempMatchTable2Message);
        for i := 0 to (Lines.Count - 1) do
            Lines[i] := '<P>' + EscapeHTMLString(Lines[i]) + '</P>';
        Text := Lines.Text;
    finally
        Lines.Free;
    end;
end;

procedure TSessionModule.WapSession1End(Session: TWapSession);
begin
    // Cleanup
    TempMatchTable2.Close;
    TempMatchTable1.Close;
    try
        TempMatchTable1.DeleteTable;
    except
        // The table may not have been created, but we don't care
    end;
    // Delete the unique filename created before
    DeleteFile(TempFilename);
end;

procedure TSessionModule.DisplayBlankPageExecute(Sender: TObject;
  Request: THttpRequest; Response: THttpResponse; const Verb,
  Value: String; Params: TVariantList; var Handled: Boolean);
begin
    WapTemplate1.Filename := AppPath + 'Blank.htm';
    WapTemplate1.WriteToStream(Response.OutputStream);
end;

end.
