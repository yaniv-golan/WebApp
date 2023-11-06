program instwiz;

uses
  Forms,
  main in 'main.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'WebApp Server Interface Installation Wizard';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
