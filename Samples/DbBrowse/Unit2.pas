unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HWebApp, AppSSI, HtmlTxt, DbHtml, Db, DBTables, DBWap, WapActns;

type
  TSessionModule = class(TDataModule)
    WapSession1: TWapSession;
    CustomersTable: TTable;
    CustomersTableCustNo: TFloatField;
    CustomersTableCompany: TStringField;
    CustomersTableCity: TStringField;
    CustomersTableState: TStringField;
    CustomersTableZip: TStringField;
    CustomersTableCountry: TStringField;
    CustomersTablePhone: TStringField;
    CustomersTableContact: TStringField;
    DBHtmlTable1: TDBHtmlTable;
    PageSizeText: THTMLText;
    RedrawButton: THTMLButton;
    RedrawCommand: THTMLHidden;
    DBAutoSession1: TDBAutoSession;
    PagedDataSource1: TPagedDataSource;
    DataSource1: TDataSource;
    procedure WapSession1Start(Session: TWapSession);
    procedure WapSession1Execute(Session: TWapSession);
    procedure WapSession1End(Session: TWapSession);
    procedure SessionModuleCreate(Sender: TObject);
  private
    { Private declarations }
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

{$R *.DFM}

procedure TSessionModule.SessionModuleCreate(Sender: TObject);
begin
  DBHtmlTable1.Caption := 'Table : ' + CustomersTable.TableName;
end;

function TSessionModule.GetRequest: THttpRequest;
begin
  Result := WapSession1.Request;
end;

function TSessionModule.GetResponse: THttpResponse;
begin
  Result := WapSession1.response;
end;

procedure TSessionModule.WapSession1Start(Session: TWapSession);
begin
  // Perform session initialization
end;

procedure TSessionModule.WapSession1Execute(Session: TWapSession);

  procedure WriteCommand(const Text, Command: string; Enabled: boolean);
  begin
    if Enabled then
      Writeln(Response.TextOut,
        ' [', Link(Request.ScriptName + '?' + Command, '', Text), '] ')
    else
      Writeln(Response.TextOut,' [', Text, '] ');
  end;

begin
  // Execute the commands passed in the Query String
  if Request.QueryString.VariableExists('FirstPage') then
    PagedDataSource1.FirstPage
  else if Request.QueryString.VariableExists('PriorPage') then
    PagedDataSource1.PriorPage
  else if Request.QueryString.VariableExists('NextPage') then
    PagedDataSource1.NextPage
  else if Request.QueryString.VariableExists('LastPage') then
    PagedDataSource1.LastPage
  else if Request.QueryString.VariableExists(RedrawCommand.Name) then
    PagedDataSource1.PageSize := Request.QueryString[PageSizeText.Name].Value;

  // Generate the response
  with Response do
  begin
    Writeln(TextOut, TagWithAttributes('BODY', [Attribute('BGCOLOR', ColorToHTMLColor(clYellow))]));
    // Generate the table. Note : this could also be written as : Write(TextOut, DBHtmlTable1.AsHTML)
    DBHtmlTable1.WriteToStream(Response.OutputStream);
    // The following adds links to navigate the table
    WriteCommand('First Page', 'FirstPage', true);
    WriteCommand('Prior Page', 'PriorPage', not PagedDataSource1.AtFirstPage);
    WriteCommand('Next Page', 'NextPage', not PagedDataSource1.AtLastPage);
    WriteCommand('Last Page', 'LastPage', true);
    // The following form allows the user to change the number of lines per page
    Write(TextOut, '<FORM METHOD="GET" ACTION="' + Request.ScriptName + '">');
    Write(TextOut, ' Lines per page : ');
    PageSizeText.Text := IntToStr(PagedDataSource1.PageSize);
    // Note: the following could also be written as PageSizeText.WriteToStream(Response.OutputStream)
    Write(TextOut, PageSizeText.AsHTML);
    Write(TextOut, RedrawButton.AsHTML);
    Write(TextOut, RedrawCommand.AsHTML);
    Write(TextOut, '</FORM>');
    Writeln(TextOut, '</BODY>');
  end;
end;

procedure TSessionModule.WapSession1End(Session: TWapSession);
begin
  // Perform session cleanup
end;

end.
