unit MPartDcd;

interface

uses Classes, SysUtils, SDS;

type

TFormDataPart = class
private
    FName: string;
    FContentType: string;
    FContentTransferEncoding: string;
    FFilename: string; 
public
    property Name: string read FName;
    property ContentType: string read FContentType;
    property ContentTransferEncoding: string read FContentTransferEncoding;
    property Filename: string read FFilename;
end;

TMultiPartDecoder = class
private
    FStream: TStream;
    FBoundary: string;
    FFilesDirectory: string;
    FItems: TObjectList;
    function GetItem(Index: integer): TFormDataPart;
    function GetCount: integer;
public
    constructor Create;
    destructor Destroy; override;

    procedure Execute;

    // Input
    property InputStream: TStream read FStream write FStream;
    property Boundary: string read FBoundary write FBoundary;
    property FilesDirectory: string read FFilesDirectory write FFilesDirectory;

    // Output
    property Count: integer read GetCount;
    property Items[Index: integer]: TFormDataPart read GetItem;
end;

implementation

constructor TMultiPartDecoder.Create;
begin
    inherited Create;
    FItems := TObjectList.Create(nil);
end;

destructor TMultiPartDecoder.Destroy;
begin
    FItems.Free;
    inherited Destroy;
end;

function TMultiPartDecoder.GetItem(Index: integer): TFormDataPart;
begin
    result := FItems[Index] as TFormDataPart;
end;

function TMultiPartDecoder.GetCount: integer;
begin
    result := FItems.Count;
end;

procedure TMultiPartDecoder.Execute;
begin
    SkipBoundary;
    MarkPart;
end;

end.
