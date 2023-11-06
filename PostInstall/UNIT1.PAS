unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Registry, IniFiles,
  StdCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses XFiles;

function GetRootDir(const DelphiVer: string): string;
var
    Reg: TRegistry;
begin
    result := '';
    Reg := TRegistry.Create;
    try
        Reg.RootKey := HKEY_LOCAL_MACHINE;
        if (not Reg.OpenKey('SOFTWARE\Borland\Delphi\' + DelphiVer, false)) then
            exit;
        result := Reg.ReadString('RootDir');
    finally
        Reg.Free;
    end;
end;

procedure DeletePageTemplates(
    Ini: TIniFile;
    const Page: string);
var
    Sections: TStringList;
    i: integer;
    SectionPage: string;
begin
    Sections := TStringList.Create;
    try
        Ini.ReadSections(Sections);
        for i := 0 to (Sections.Count - 1) do begin
            SectionPage := Ini.ReadString(Sections[i], 'Page', '');
            if (SectionPage = Page) then
                Ini.EraseSection(Sections[i]);
        end;
    finally
        Sections.Free;
    end;
end;

procedure InstallDataModule(
    Ini: TIniFile;
    const UnitName: string;
    const Name: string;
    const Page: string;
    const Icon: string;
    const Description: string;
    const Author: string;
    DefaultMainForm: boolean;
    DefaultNewForm: boolean;
    const Ancestor: string
    );
begin
    Ini.WriteString('Repository Pages', Page, '');

    Ini.WriteString(UnitName, 'Type', 'FormTemplate');
    Ini.WriteString(UnitName, 'Name', Name);
    Ini.WriteString(UnitName, 'Page', Page);
    Ini.WriteString(UnitName, 'Icon', Icon);
    Ini.WriteString(UnitName, 'Description', Description);
    Ini.WriteString(UnitName, 'Author', Author);
    if (DefaultMainForm) then
        Ini.WriteInteger(UnitName, 'DefaultMainForm', 1)
    else
        Ini.WriteInteger(UnitName, 'DefaultMainForm', 0);
    if (DefaultNewForm) then
        Ini.WriteInteger(UnitName, 'DefaultNewForm', 1)
    else
        Ini.WriteInteger(UnitName, 'DefaultNewForm', 0);
    Ini.WriteString(UnitName, 'Ancestor', Ancestor);
end;

procedure InstallProject(
    Ini: TIniFile;
    const ProjFilename: string;
    const Name: string;
    const Page: string;
    const Icon: string;
    const Description: string;
    const Author: string;
    DefaultProject: boolean
    );
begin
    Ini.WriteString('Repository Pages', Page, '');

    Ini.WriteString(ProjFilename, 'Type', 'ProjectTemplate');
    Ini.WriteString(ProjFilename, 'Name', Name);
    Ini.WriteString(ProjFilename, 'Page', Page);
    Ini.WriteString(ProjFilename, 'Icon', Icon);
    Ini.WriteString(ProjFilename, 'Description', Description);
    Ini.WriteString(ProjFilename, 'Author', Author);
    if (DefaultProject) then
        Ini.WriteInteger(ProjFilename, 'DefaultProject', 1)
    else
        Ini.WriteInteger(ProjFilename, 'DefaultProject', 0);
end;

procedure InstallTemplates(const RootDir: string; TemplatesDir: string);
var
    DroFn: string;
    Ini: TIniFile;
    Attr: integer;
begin
    DroFn := SlashPath(RootDir) + 'Bin\Delphi32.DRO';
    if (not FileExists(DroFn)) then
        exit;
    Attr := FileGetAttr(DroFn);
    if ((Attr and faReadOnly) <> 0) then
        exit;
    Ini := TIniFile.Create(DroFn);
    try
        DeletePageTemplates(Ini, 'WebApp');
        
        InstallProject(
            Ini,
            SlashPath(TemplatesDir) + 'App\Project1',
            'WebApp Non-BDE Application',
            'WebApp',
            '',
            'WebApp Application which does not use the BDE',
            'HyperAct',
            false
            );

        InstallDataModule(
            Ini,
            SlashPath(TemplatesDir) + 'SecMdl',
            'Secondary Data Module',
            'WebApp',
            '',
            'Secondary Data Module which does not use the BDE',
            'HyperAct',
            false,
            false,
            ''
            );

        InstallProject(
            Ini,
            SlashPath(TemplatesDir) + 'BDEApp\Project1',
            'WebApp BDE Application',
            'WebApp',
            '',
            'WebApp Application with BDE Support',
            'HyperAct',
            false
            );

        InstallDataModule(
            Ini,
            SlashPath(TemplatesDir) + 'BDEMdl',
            'Secondary BDE Data Module',
            'WebApp',
            '',
            'Secondary Data Module with BDE support',
            'HyperAct',
            false,
            false,
            ''
            );

    finally
        Ini.Free;
    end;
end;

procedure TForm1.FormShow(Sender: TObject);
var
    RootDir: string;
begin
    try
        RootDir := GetRootDir('2.0');
        if (RootDir <> '') then
            InstallTemplates(RootDir, SlashPath(ParamStr(1)) + 'templates\d2');
    except
        ;
    end;
    try
        RootDir := GetRootDir('3.0');
        if (RootDir <> '') then
            InstallTemplates(RootDir, SlashPath(ParamStr(1)) + 'templates\d3');
    except
        ;
    end;
    Release;
    Close;
end;

end.
