program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  test in 'G:\store\t\test.pas',
  NTSecurity2 in 'NTSecurity2.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
