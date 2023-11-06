unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HWebApp, AppSSI, HtmlTxt, TCForm;

type
  TSessionModule = class(TDataModule)
    WapSession1: TWapSession;
    procedure WapSession1Execute(Session: TWapSession);
    procedure SessionModuleCreate(Sender: TObject);
    procedure SessionModuleDestroy(Sender: TObject);
  private
    { Private declarations }
    function GetRequest: THttpRequest;
    function GetResponse: THttpResponse;
  public
    { Public declarations }
    FTeeChartForm: TTeeChartForm;
    property Request: THttpRequest read GetRequest;
    property Response: THttpResponse read GetResponse;
  end;

var
  SessionModule: TSessionModule;

implementation

{$R *.DFM}

function TSessionModule.GetRequest: THttpRequest;
begin
  Result := WapSession1.Request;
end;

function TSessionModule.GetResponse: THttpResponse;
begin
  Result := WapSession1.response;
end;

procedure TSessionModule.SessionModuleCreate(Sender: TObject);
begin
  // Use TWapSession.CreateForm to create a form which will be associated
  // with this session. The form will be destroyed automatically when
  // the session terminates.
  FTeeChartForm := WapSession1.CreateForm(TTeeChartForm) as TTeeChartForm;
end;

procedure TSessionModule.WapSession1Execute(Session: TWapSession);
var
  Bitmap: TBitmap;
begin
  // Get a bitmap of the form image
  Bitmap := WapSession1.GetFormImage(FTeeChartForm);
  try
    // And send it as the response
    Response.SendBitmapAsJPEG(Bitmap);
  finally
//    Bitmap.Free;
  end;
end;

procedure TSessionModule.SessionModuleDestroy(Sender: TObject);
begin
    WapSession1.FreeForm(FTeeChartForm);
end;

end.
