program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {DataModule2: TDataModule},
  MRubicon in 'MRubicon.pas' {RubiconModule: TDataModule},
  Db in 'G:\Delphi3\Source\VCL\db.pas',
  DBTables in 'G:\Delphi3\Source\VCL\dbtables.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TRubiconModule, RubiconModule);
  Application.Run;
end.
