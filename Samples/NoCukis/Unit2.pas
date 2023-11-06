unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HWebApp, AppSSI, HtmlTxt;

type
  TSessionModule = class(TDataModule)
    WapSession1: TWapSession;
    procedure WapSession1Start(Session: TWapSession);
    procedure WapSession1Execute(Session: TWapSession);
    procedure WapSession1End(Session: TWapSession);
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

{$R *.DFM}

function TSessionModule.GetRequest: THttpRequest;
begin
  Result := WapSession1.Request;
end;

function TSessionModule.GetResponse: THttpResponse;
begin
  Result := WapSession1.response;
end;

procedure TSessionModule.WapSession1Start(Session: TWapSession);
begin
  // Perform session initialization
end;

procedure TSessionModule.WapSession1Execute(Session: TWapSession);
begin
  // Handle the request and return a response
end;

procedure TSessionModule.WapSession1End(Session: TWapSession);
begin
  // Perform session cleanup
end;

end.
