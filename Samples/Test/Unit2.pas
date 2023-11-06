unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HWebApp, AppSSI, HtmlTxt;

type
  TSessionModule = class(TDataModule)
    WapSession1: TWapSession;
    procedure WapSession1Start(Session: TWapSession);
    procedure WapSession1Execute(Session: TWapSession);
    procedure WapSession1End(Session: TWapSession);
  private
    { Private declarations }
    FCounter: integer;
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
  FCounter := 0;
end;

procedure TSessionModule.WapSession1Execute(Session: TWapSession);

  function ValueInTableRow(const Name, Value: string): string;
  begin
    result := '<TR><TD><B>' + Name + '</B></TD><TD>';
    if (Value = '') then
        result := result + '&nbsp;'
    else
        result := result + Value;
    result := result + '</TD></TR>';
  end;

const
  DocTitle = 'WebApp Test Server Application';
begin
  // Handle the request and return a response

  // Incremenet / Decrement the counter :
  if Request.QueryString.VariableExists('inc') then
    Inc(FCounter)
  else if Request.QueryString.VariableExists('dec') then
    Dec(FCounter);

  with Response do
  begin
    // The indentation refelects the output HTML logical structure
    Writeln(TextOut, '<HTML>');

      Writeln(TextOut, Head(Title(DocTitle)));

      Writeln(TextOut, TagWithAttributes('BODY', [Attribute('BGColor', ColorToHTMLColor(clWhite))]));

        Writeln(TextOut,
          Heading(1, DocTitle) + NewLine +
          Heading(2, 'Automatic Session Management Test') + NewLine +
          Par(Bold('The counter value is ' + IntToStr(FCounter))) +
          Par(
            'Click on the following links to increment or decrement the counter :' + LineBreak +
            Link(Request.ScriptName + '?inc', '', Bold('Increment (+)')) + ' ' +
            Link(Request.ScriptName + '?dec', '', Bold('Decrement (-)')) + ' '
          )
        );

        Writeln(TextOut, Par(Bold('SessionId : ') + WapSession1.SessionId));

        Writeln(TextOut, '<HR>');

        // Write some server variables

        Writeln(TextOut, Heading(2, 'Server Variables'));
        Writeln(TextOut, Par('The following are values of some of the standard server variables :'));

        Writeln(TextOut, '<TABLE BORDER=1>');
        Writeln(TextOut, ValueInTableRow('Query String', Request.QueryString.AsString));
        Writeln(TextOut, ValueInTableRow('Script Name', Request.ScriptName));
        Writeln(TextOut, ValueInTableRow('Logical Path (PATH_INFO)', Request.LogicalPath));
        Writeln(TextOut, ValueInTableRow('Physical Path (PATH_TRANSLATED)', Request.PhysicalPath));
        Writeln(TextOut, ValueInTableRow('Server Name', Request.ServerVariables['SERVER_NAME']));
        Writeln(TextOut, ValueInTableRow('Server Software', Request.ServerVariables['SERVER_SOFTWARE']));
        Writeln(TextOut, ValueInTableRow('Remote User', Request.ServerVariables['REMOTE_USER']));
        Writeln(TextOut, '</TABLE>');

        Writeln(TextOut, '<HR>');

        // Write some HTTP Headings

        Writeln(TextOut, Heading(2, 'HTTP Headers'));
        Writeln(TextOut, Par('The following are values of some common HTTP Headers :'));

        Writeln(TextOut, '<TABLE BORDER=1>');
        Writeln(TextOut, ValueInTableRow('ACCEPT', Request.HTTPHeaders['ACCEPT']));
        Writeln(TextOut, ValueInTableRow('USER-AGENT', Request.HTTPHeaders['USER-AGENT']));
        Writeln(TextOut, '</TABLE>');

        // Report the browser

        Writeln(TextOut, Par('The browser you are using is <B>' +
          Request.BrowserCaps.Browser + ' ' + Request.BrowserCaps.Version + '</B>'));  

      Writeln(TextOut, '</BODY>');

    Writeln(TextOut, '</HTML>');
  end; // with
end;

procedure TSessionModule.WapSession1End(Session: TWapSession);
begin
  // Perform session initialization
end;

end.
