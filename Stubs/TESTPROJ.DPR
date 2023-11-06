program testproj;

uses
  Forms,
  testmain in 'testmain.pas' {Form1},
  DummyReq in 'DummyReq.pas',
  DummySupport in 'DummySupport.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
