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
end;

procedure TSessionModule.WapSession1Execute(Session: TWapSession);
begin
  // Handle the request and return a response

  // Request['RedirectField'] could also be written as
  // Request.QueryString['RedirectField'].Value, or
  // Request.Literals['RedirectField']
  if (Request['RedirectField'] = '') then
  begin
    // No value for RedirectField, generate the HTML form to let
    // the user select destination
    with Response do
    begin
      Writeln(TextOut, '<FORM METHOD="GET" ACTION="' + Request.ScriptName + '">');
      Writeln(TextOut, 'Select your destination :');
      Writeln(TextOut, '<SELECT NAME="RedirectField" SIZE="1">');
      Writeln(TextOut, '<OPTION SELECTED VALUE="http://www.hyperact.com">www.hyperact.com</OPTION>');
      Writeln(TextOut, '<OPTION VALUE="http://www.microsoft.com">www.microsoft.com</OPTION>');
      Writeln(TextOut, '<OPTION VALUE="http://www.netscape.com">www.netscape.com</OPTION>');
      Writeln(TextOut, '<OPTION VALUE="http://www.borland.com">www.borland.com</OPTION>');
      Writeln(TextOut, '</SELECT>');
      Writeln(TextOut, '<INPUT TYPE="SUBMIT" VALUE="Go There!">');
      Writeln(TextOut, '</FORM>');
    end;
  end else
  begin
    // The user selected a destination, redirect the browser to the new URL
    Response.Redirect(Request['RedirectField']);
  end;
end;

procedure TSessionModule.WapSession1End(Session: TWapSession);
begin
  // Perform session cleanup
end;

end.
