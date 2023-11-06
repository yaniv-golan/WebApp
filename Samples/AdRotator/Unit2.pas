unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HWebApp, AppSSI, HtmlTxt, AdRotate, WapActns;

type
  TSessionModule = class(TDataModule)
    WapSession1: TWapSession;
    AdRotator1: TAdRotator;
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
  // Set the Ads schedule filename, found in the same directory as the EXE
  AdRotator1.ScheduleFilename := ExtractFilePath(Application.ExeName) + 'ADROT.TXT';
end;

procedure TSessionModule.WapSession1Execute(Session: TWapSession);
const
  DocTitle = 'WebApp AdRotator Component Sample';
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

        // Generate the Advertisement text : 
        Writeln(TextOut, Par('<B>Shameless plugs for some great HyperAct products : </B><HR>' +
          '<CENTER>' + AdRotator1.AsHTML + '</CENTER>'));

        Writeln(TextOut,
          Heading(1, DocTitle) + NewLine +

          Par('Note : whenever you click on one of the links below, or <B>Reload</B> ' +
            'the page, the above ad will change.') +
          Par('The frequency of each ad is determined by the settings specified ' +
            'in the file ' + AdRotator1.ScheduleFilename) +
          Par('If you images above are not displayed, please configure your server ' +
            ' to map the virtual directory <TT>/WapSamples</TT> to the directory <TT>' +
            ExpandFilename(ExtractFilePath(Application.ExeName) + '../web') + '</TT>.') +

          Par(Bold('The counter value is ' + IntToStr(FCounter))) +
          Par(
            'Click on the following links to increment or decrement the counter :' + LineBreak +
            Link(Request.ScriptName + '?inc', '', Bold('Increment (+)')) + ' ' +
            Link(Request.ScriptName + '?dec', '', Bold('Decrement (-)')) + ' '
          )
        );


      Writeln(TextOut, '</BODY>');

    Writeln(TextOut, '</HTML>');
  end; // with
end;

procedure TSessionModule.WapSession1End(Session: TWapSession);
begin
  // Perform session initialization
end;

end.
