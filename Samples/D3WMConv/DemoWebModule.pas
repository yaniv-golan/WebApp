unit DemoWebModule;

interface

uses
  Windows, Messages, SysUtils, Classes, HTTPApp, Db, DBTables, DBWeb,
  Forms, WapCPAdp, DBWap;

type
  TWebModule1 = class(TWebModuleAdapter)
    DataSetTableProducer1: TDataSetTableProducer;
    Table1: TTable;
    Table1SpeciesNo: TFloatField;
    Table1Category: TStringField;
    Table1Common_Name: TStringField;
    Table1SpeciesName: TStringField;
    Table1Lengthcm: TFloatField;
    Table1Length_In: TFloatField;
    Table1Notes: TMemoField;
    PageProducer1: TPageProducer;
    DBAutoSession1: TDBAutoSession;
    procedure WebModule1WebActionItem2Action(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
    procedure PageProducer1HTMLTag(Sender: TObject; Tag: TTag;
      const TagString: String; TagParams: TStrings;
      var ReplaceText: String);
    procedure WebModule1WebActionItem1Action(Sender: TObject;
      Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  WebModule1: TWebModule1;  

implementation

uses Unit2;

{$R *.DFM}

procedure TWebModule1.WebModule1WebActionItem2Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
    Response.Content := PageProducer1.Content;
end;

procedure TWebModule1.PageProducer1HTMLTag(Sender: TObject; Tag: TTag;
  const TagString: String; TagParams: TStrings; var ReplaceText: String);
begin
    if (TagString = 'CurrentTime') then
        ReplaceText := DateTimeToStr(Now);
end;

procedure TWebModule1.WebModule1WebActionItem1Action(Sender: TObject;
  Request: TWebRequest; Response: TWebResponse; var Handled: Boolean);
begin
    Response.Content := DataSetTableProducer1.Content;
end;

end.
