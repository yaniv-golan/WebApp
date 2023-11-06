unit testmain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ISAPI;

type
  TForm1 = class(TForm)
    OutputMemo: TMemo;
    QueryStringEdit: TEdit;
    InputMemo: TMemo;
    HeadersMemo: TMemo;
    Button1: TButton;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses DummySupport;

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
    ECB : TEXTENSION_CONTROL_BLOCK;
    i: integer;
begin
    for i := 0 to 50000 do begin
        if (checkbox1.Checked) then
            abort;
        OutputMemo.Lines.Clear;
        FillChar(ECB, SizeOf(TEXTENSION_CONTROL_BLOCK), 0);
        IsapiHttpExtensionProc(ECB);
        label1.Caption := IntToStr(i);
        Application.ProcessMessages;
    end;
end;

end.
