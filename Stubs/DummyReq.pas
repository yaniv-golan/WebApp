unit DummyReq;

interface

uses Classes, SysUtils, Windows, ISAPI, HttpReq, IPC
    ;

type

EIsapiHttpRequestImp = class(EAbstractHttpRequestInterface);

TIsapiHttpRequestImp = class(TAbstractHttpRequestInterface)
private
    FEcb: PEXTENSION_CONTROL_BLOCK;
    FHttpHeaders: TStringList;
public
    constructor Create(Ecb: PEXTENSION_CONTROL_BLOCK);
    destructor  Destroy; override;
    function    GetQueryString: string; override;
    function    GetMethod: string; override;
    function    GetLogicalPath: string; override;
    function    GetPhysicalPath: string; override;
    function    WriteToClient(const Buffer; Count: integer): integer; override;
    function    ReadFromClient(var Buffer; Count: integer): integer; override;
    function    GetInputSize: integer; override;
    function    GetInputContentType: string; override;
    function    GetServerVariable(const VarName: string): string; override;
    function    GetHttpHeader(const HeaderName: string): string; override;
    function    MapURLToPath(const LogicalURL: string): string; override;

    property    Ecb: PEXTENSION_CONTROL_BLOCK read FEcb;
end;

implementation

uses D3SysUtl, TestMain
;

constructor TIsapiHttpRequestImp.Create(Ecb: PEXTENSION_CONTROL_BLOCK);
begin
    inherited Create;
    FEcb := Ecb;
end;

destructor  TIsapiHttpRequestImp.Destroy;
begin
    FHttpHeaders.Free;
    inherited Destroy;
end;

function TIsapiHttpRequestImp.WriteToClient(const Buffer; Count: integer): integer;
var
    s: string;
begin
    s := strPas(pchar(@buffer));
    form1.OutputMemo.text := form1.OutputMemo.text + s; 
    result := count;
end;

function    TIsapiHttpRequestImp.ReadFromClient(var Buffer; Count: integer): integer; 
begin
    result := 0;
end;

function    TIsapiHttpRequestImp.GetInputSize: integer;
begin
    result := 0;
end;

function    TIsapiHttpRequestImp.GetInputContentType: string;
begin
    result := '';
end;

function    TIsapiHttpRequestImp.GetServerVariable(const VarName: string): string;
begin
    result := '';
end;

function    TIsapiHttpRequestImp.GetHttpHeader(const HeaderName: string): string;
begin
    result := '';
end;

function    TIsapiHttpRequestImp.MapURLToPath(const LogicalURL: string): string; 
begin
    result := '';
end;

function    TIsapiHttpRequestImp.GetQueryString: string;
begin
    result := form1.QueryStringEdit.text;
end;

function    TIsapiHttpRequestImp.GetMethod: string;
begin
    result:= 'GET';
end;

function    TIsapiHttpRequestImp.GetLogicalPath: string;
begin
    result := '';
end;

function    TIsapiHttpRequestImp.GetPhysicalPath: string;
begin
    result := '';
end;

end.

