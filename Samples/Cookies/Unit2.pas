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

  // Setting Response.Buffer to true allows us to add Cookies even after the response
  // body is written
  Response.Buffer := true;

  Writeln(Response.TextOut, Title('WebApp Cookies Demo'));
  Writeln(Response.TextOut, '<BODY BGCOLOR=' + ColorToHtmlColor(clWhite) + '>');
  Writeln(Response.TextOut, Heading(1, 'WebApp Cookies Demo'));

  if Request.QueryString['Command'].Value = 'UpdatePersonalInfo' then
  begin
    //
    // Handle the submitted form with the new values :
    //

    with Response.Cookies['FirstName'] do
    begin
      Value := Request.QueryString['FirstNameField'].Value;
      Path := '/'; // Accessible to the entire web site
      ExpiresOnLocalTime := Now + 7; // Expires a week from now
    end;

    with Response.Cookies['FavColor'] do
    begin
      Value := Request.QueryString['FavColorField'].Value;
      Path := '/'; // Accessible to the entire web site
      ExpiresOnLocalTime := Now + 7; // Expires a week from now
    end;

    with Response.Cookies['LastVisit'] do
    begin
      Value := Now;
      Path := '/'; // Accessible to the entire web site
      ExpiresOnLocalTime := Now + 7; // Expires a week from now
    end;

    Writeln(Response.TextOut, '<p>Thank you for updating our database! We will ',
      'use it on your next visit...');
    Writeln(Response.TextOut, '<p>(Actually the information was stored in the FavColor ',
      'and LastVisit cookies).');
  end else
  begin
    // If found cookies stored in the previous visit, write the information
    // stored in them
    if Request.Cookies.CookieExists('FirstName') then
    begin
      with Response do
      begin
        Writeln(TextOut, Par('Hello ' + Request.Cookies['FirstName'].Value));
        Writeln(TextOut, Par('Your last visit was on ' + Request.Cookies['LastVisit'].Value + '.'));
        Writeln(TextOut, Par('Your favorite color back than was  ' + Request.Cookies['FavColor'].Value + '.'));
      end;
    end;
    // Generate the form which will allow the user to update the information
    With Response do
    begin
      Writeln(TextOut, '<FORM METHOD="GET" ACTION="' + Request.ScriptName + '">');
      Writeln(TextOut, '<INPUT TYPE="HIDDEN" NAME="Command" VALUE="UpdatePersonalInfo">');
      Writeln(TextOut, '<P>Enter your first name : ');
      // We will use the information stored in the cookie to initialize the field value
      Writeln(TextOut, '<INPUT TYPE="TEXT" NAME="FirstNameField" VALUE="' + Request.Cookies['FirstName'].Value + '">');
      Writeln(TextOut, '<P>Enter your favorite color : ');
      Writeln(TextOut, '<INPUT TYPE="TEXT" NAME="FavColorField" VALUE="' + Request.Cookies['FavColor'].Value + '">');
      Writeln(TextOut, '<P><INPUT TYPE="SUBMIT" VALUE="Update Information">');
    end;
  end;
end;

procedure TSessionModule.WapSession1End(Session: TWapSession);
begin
  // Perform session cleanup
end;

end.
