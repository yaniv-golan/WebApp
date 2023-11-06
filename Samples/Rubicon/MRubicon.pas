unit MRubicon;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Db, taRubicn, DBTables, IPC;

type
  TRubiconModule = class(TDataModule)
    WordsTable: TTable;
    SearchDictionary: TSearchDictionary;
    MessagesDataSource: TDataSource;
    MessagesTable: TTable;
    procedure RubiconModuleCreate(Sender: TObject);
    procedure RubiconModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    FLock: TWin32CriticalSection;
  public
    { Public declarations }
    procedure Lock;
    procedure Unlock;
  end;

var
  RubiconModule: TRubiconModule;

implementation

{$R *.DFM}


procedure TRubiconModule.RubiconModuleCreate(Sender: TObject);
begin
    FLock := TWin32CriticalSection.Create;
end;

procedure TRubiconModule.RubiconModuleDestroy(Sender: TObject);
begin
    FLock.Free;
end;

procedure TRubiconModule.Lock;
begin
    FLock.Enter;
end;

procedure TRubiconModule.Unlock;
begin
    FLock.Leave;
end;

end.
