program HTDbCtr;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  DBFormMdl in 'DBFormMdl.pas' {DBForm: TDataModule},
  Unit2 in 'Unit2.pas' {SessionModule: TDataModule};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
