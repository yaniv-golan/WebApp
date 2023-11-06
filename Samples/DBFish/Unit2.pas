unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HWebApp, AppSSI, HtmlTxt, Db, DBTables, DBWap, DBHtml, WapTmplt, WapActns;

type
  TSessionModule = class(TDataModule)
    WapSession: TWapSession;
    BioLifeHtmlTable: TDBHtmlTable;
    BioLife: TTable;
    BioLifeSpeciesNo: TFloatField;
    BioLifeCategory: TStringField;
    BioLifeCommon_Name: TStringField;
    BioLifeSpeciesName: TStringField;
    BioLifeLengthcm: TFloatField;
    BioLifeLength_In: TFloatField;
    BioLifeNotes: TMemoField;
    BioLifeGraphic: TGraphicField;
    Template: TWapTemplate;
    DBAutoSession1: TDBAutoSession;
    PagedDataSource1: TPagedDataSource;
    BioLifeSource: TDataSource;
    DBDemosDatabase: TDatabase;
    procedure WapSessionExecute(Session: TWapSession);
    procedure TemplateGetMacroValue(Sender: TObject;
      const Name: String; var Value: Variant);
    procedure BioLifeHtmlTableCustomizeField(Sender: TObject; Field: TField;
      var Text: String);
  private
    { Private declarations }
    function GetRequest: THttpRequest;
    function GetResponse: THttpResponse;
  public
    { Public declarations }
    property Request: THttpRequest read GetRequest;
    property Response: THttpResponse read GetResponse;
  end;

var
  SessionModule: TSessionModule;

implementation

uses Unit3;

{$R *.DFM}

function TSessionModule.GetRequest: THttpRequest;
begin
  Result := WapSession.Request;
end;

function TSessionModule.GetResponse: THttpResponse;
begin
  Result := WapSession.response;
end;

procedure TSessionModule.WapSessionExecute(Session: TWapSession);
var
  Bitmap: TBitmap;
  Lines: TStringList;
  i: integer;
begin
  if Request.QueryString.VariableExists('FishPicture') then begin
    // This is a request to generate the picture of the fish. The fish key is
    // specified in the SpeciesNo parameter
    BioLife.FindKey([Request['SpeciesNo']]);
    Bitmap := TBitmap.Create;
    try
      // Extract the bitmap from the Graphic BLOB and send it in JPEG format
      Bitmap.Assign(BioLifeGraphic);
      Response.SendBitmapAsJPEG(Bitmap);
    finally
      Bitmap.Free;
    end;
  end else begin
    // Since it is not a request to generate the fish picture, we assume it's a request
    // to pre-process one of the HTML template pages. The template is indiciated
    // by the LogicalPath.
    //
    // If no logical path specified, redirect to the initial page
    if (Request.LogicalPath = '') then
    begin
      Response.Redirect(Request.ScriptName + '/WapSamples/DBFish/Index.html');
      exit;
    end;

    // Simple sanity checking
    if (not FileExists(Request.PhysicalPath)) then
    begin
      Writeln(Response.TextOut, 'Unable to find ', Request.LogicalPath, '. Please verify ',
        'that that virtual directory /WapSamples is defined with your web server.');
      exit;
    end;

    // This page needs special setup :
    if (Request.LogicalPath = '/WapSamples/DBFish/FishDetails.html') then
    begin
      // Set up the SpeciesNo and BioLifeCommon_Name variables for this page
      BioLife.FindKey([Request['SpeciesNo']]);

      Lines := TStringList.Create;
      try
        // Extract the Fish notes from the Notes BLOB and format it
        Lines.Assign(BioLifeNotes);
        for i := 0 to (Lines.Count - 1) do
          Lines[i] := Lines[i] + '<BR>';
        Template['Notes'] := Lines.Text;
      finally
        Lines.Free;
      end;

      Template['BioLifeCommon_Name'] := BioLifeCommon_Name.AsString;
    end;

    Template.Filename := Request.PhysicalPath;
    Template.WriteToStream(Response.OutputStream);
  end;
end;

procedure TSessionModule.TemplateGetMacroValue(Sender: TObject;
  const Name: String; var Value: Variant);
begin
  // Generate the Fish HTML table when requested :
  if (Name = 'FishTable') then
    Value := BioLifeHtmlTable.AsHTML;
end;

procedure TSessionModule.BioLifeHtmlTableCustomizeField(Sender: TObject;
  Field: TField; var Text: String);
begin
  //
  // Format the fish name as a link, which will cause the fish details
  // to be displayed in the bottom frame.
  //
  // The fish ID is indicated in the link URL using the SpeciesNo paramter.
  //
  if Field = BioLifeCommon_Name then
  begin
    Text :=
      '<A HREF="FishDetails.html?SpeciesNo=' + BioLifeSpeciesNo.AsString +
      '" TARGET="BottomFrame">' + Field.DisplayText + '</A>';
  end;
end;


end.
