unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, HWebApp, IPC, AppSSI, HtmlTxt;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    GroupBox1: TGroupBox;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    Label1: TLabel;
    ActiveRequestsEdit: TEdit;
    Label2: TLabel;
    ActiveSessionsEdit: TEdit;
    WapApp1: TWapApp;
    ApplicationIdEdit: TEdit;
    Label3: TLabel;
    AlwaysOnTop1: TMenuItem;
    procedure WapApp1Notify(Sender: TObject;
      Notification: TWapAppNotification);
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure AlwaysOnTop1Click(Sender: TObject);
    procedure WapApp1Execute(Sender: TObject; Request: THttpRequest;
      Response: THttpResponse);
  private
    { Private declarations }
    procedure UpdateStatistics;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  Caption := 'WebApp ' + WapApp1.AppId + ' Sample';
  UpdateStatistics;
end;

procedure TForm1.WapApp1Notify(Sender: TObject;
  Notification: TWapAppNotification);
begin
  if not (csDestroying in ComponentState) then
    CallInMainThread(UpdateStatistics);
end;

procedure TForm1.UpdateStatistics;
begin
  ApplicationIdEdit.Text := WapApp1.AppId;
  ActiveSessionsEdit.Text := IntToStr(WapApp1.Sessions.Count);
  ActiveRequestsEdit.Text := IntToStr(WapApp1.ActiveRequests);
end;


procedure TForm1.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.AlwaysOnTop1Click(Sender: TObject);
begin
    // Setting the form style to "Always On Top" is sometimes
    // useful for debugging
    AlwaysOnTop1.Checked := not AlwaysOnTop1.Checked;
    if (AlwaysOnTop1.Checked) then
        FormStyle := fsStayOnTop
    else
        FormStyle := fsNormal;
end;

// Utility function to convert boolean value to a string
function BooleanToYesNo(Value: boolean): string;
begin
  if (Value) then
    Result := 'Yes'
  else
    Result := 'No';
end;

procedure TForm1.WapApp1Execute(Sender: TObject; Request: THttpRequest;
  Response: THttpResponse);

  function ValueInTableRow(const Name, Value: string): string;
  begin
    result := '<TR><TH>' + Name + '</TH><TD>';
    if (Value = '') then
        result := result + '&nbsp;'
    else
        result := result + Value;
    result := result + '</TD></TR>';
  end;

begin
  with Response do
  begin
    Writeln(TextOut, '<HTML>');

    Writeln(TextOut, Head(Title('WebApp Browser Capabilities Report')));

    Writeln(TextOut, TagWithAttributes('BODY', [Attribute('BGColor', ColorToHTMLColor(clWhite))]));

    Writeln(TextOut, Heading(1, 'WebApp Browser Capabilities Report'));

    Writeln(TextOut, Par('The browser you are using is <B>' +
      Request.BrowserCaps.Browser + ' ' + Request.BrowserCaps.Version + '</B>, ' +
      'running on ' + Request.BrowserCaps.Platform + '.'));

    Writeln(TextOut, Par('Following is a list of your browser''s capabilties :'));

    Writeln(TextOut, '<TABLE BORDER=1>');
    Writeln(TextOut, ValueInTableRow('Tables', BooleanToYesNo(Request.BrowserCaps.Tables)));
    Writeln(TextOut, ValueInTableRow('Frames', BooleanToYesNo(Request.BrowserCaps.Frames)));
    Writeln(TextOut, ValueInTableRow('Cookies', BooleanToYesNo(Request.BrowserCaps.Cookies)));
    Writeln(TextOut, ValueInTableRow('JavaScript', BooleanToYesNo(Request.BrowserCaps.JavaScript)));
    Writeln(TextOut, ValueInTableRow('VBScript', BooleanToYesNo(Request.BrowserCaps.VBScript)));
    Writeln(TextOut, ValueInTableRow('Java Applets', BooleanToYesNo(Request.BrowserCaps.JavaApplets)));
    Writeln(TextOut, ValueInTableRow('ActiveX Controls', BooleanToYesNo(Request.BrowserCaps.ActiveXControls)));
    Writeln(TextOut, '</TABLE>');

    Writeln(TextOut, '</BODY>');

    Writeln(TextOut, '<HTML>');
    Writeln(TextOut, '</HTML>');
  end;
end;

end.
