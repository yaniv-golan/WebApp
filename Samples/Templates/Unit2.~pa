unit unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HWebApp, AppSSI, HtmlTxt, WapTmplt, InetStr, dbwap, WapActns;

type
  TSessionModule = class(TDataModule)
    WapSession1: TWapSession;
    WapTemplate1: TWapTemplate;
    procedure WapSession1Execute(Session: TWapSession);
  private
    { Private declarations }
    function GetRequest: THttpRequest;
    function GetResponse: THttpResponse;
    procedure SendTemplateSource;
  public
    { Public declarations }
    property Request: THttpRequest read GetRequest;
    property Response: THttpResponse read GetResponse;
  end;

var
  SessionModule: TSessionModule;

implementation

uses Unit1;

{$R *.DFM}

function TSessionModule.GetRequest: THttpRequest;
begin
  Result := WapSession1.Request;
end;

function TSessionModule.GetResponse: THttpResponse;
begin
  Result := WapSession1.response;
end;

procedure TSessionModule.WapSession1Execute(Session: TWapSession);
begin
  if (Request.LogicalPath = '') then
  begin
    Response.Redirect(Request.ScriptName + '/WapSamples/Templates/Index.htm');
    exit;
  end;

  // Increment (or initialize) the application access count
  if WapSession1['AccessCount'] = null then
    WapSession1['AccessCount'] := 1
  else
    WapSession1['AccessCount'] := WapSession1['AccessCount'] + 1;

  // Increment (or initialize) the session access count
  if WapSession1.Application['AccessCount'] = null then
    WapSession1.Application['AccessCount'] := 1
  else
    WapSession1.Application['AccessCount'] := WapSession1.Application['AccessCount'] + 1;

  if Request.QueryString.VariableExists('ViewSource') then
    SendTemplateSource
  else
  begin
    // Send the file indiciated in the Logical Path through the templates engine
    WapTemplate1.Filename := Request.PhysicalPath;
    WapTemplate1.WriteToStream(Response.OutputStream);

    // If specified, send the footer as through the engine as well
    if Form1.TemplateFileEdit.Text <> '' then
    begin
      WapTemplate1.Filename := Form1.TemplateFileEdit.Text;
      WapTemplate1.WriteToStream(Response.OutputStream);
    end;
  end;
end;

// This is invoked to handle a request to send the template source, including
// the embedded script.
procedure TSessionModule.SendTemplateSource;
var
  TemplateSource: TStringList;
begin
  TemplateSource := TStringList.Create;
  try
    WapTemplate1.Filename := Request.PhysicalPath;
    WapTemplate1.FormatHTML(TemplateSource);
    Writeln(Response.TextOut,
      '<HTML><HEAD><TITLE>Source of ', Request.LogicalPath, '</TITLE></HEAD>',
      '<BODY BGCOLOR="', ColorToHTMLColor(clWhite), '"><TT>');
    TemplateSource.SaveToStream(Response.OutputStream);
    Writeln(Response.TextOut, '</TT></BODY>');
  finally
    TemplateSource.Free;
  end;
end;

end.
