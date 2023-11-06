unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, HWebApp, IPC, AppSSI, ExtCtrls, Buttons;

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
    GroupBox3: TGroupBox;
    Label5: TLabel;
    TemplateFileEdit: TEdit;
    BrowseButton: TSpeedButton;
    OpenDialog1: TOpenDialog;
    procedure WapApp1CreateSession(Sender: TObject;
      var Session: TWapSession);
    procedure WapApp1Notify(Sender: TObject;
      Notification: TWapAppNotification);
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure AlwaysOnTop1Click(Sender: TObject);
    procedure BrowseButtonClick(Sender: TObject);
  private
    { Private declarations }
    procedure UpdateStatistics;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Unit2;

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
begin
  UpdateStatistics;

  // Initialize the footer to the pre-installed FOOTER.HTM
  TemplateFileEdit.Text := ExtractFilePath(Application.ExeName) + 'FOOTER.HTM';
end;

procedure TForm1.WapApp1CreateSession(Sender: TObject;
  var Session: TWapSession);
var
  SessionModule: TSessionModule;
begin
  // Create an instance of the TSessionModule Data Module
  SessionModule := TSessionModule.Create(nil);
  // Return the TWapSession instance from the new Data Module
  Session := SessionModule.WapSession1;
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

procedure TForm1.BrowseButtonClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    TemplateFileEdit.Text := OpenDialog1.FileName;
end;

end.
 