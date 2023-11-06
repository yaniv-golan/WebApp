unit ImageConversion;

interface

uses Classes, SysUtils, Windows, Graphics;

type
TImageConversionCallback = procedure(Instance: pointer; Data: pointer; Size: integer); stdcall;

function BitmapToJPEG(BitmapMemory: pointer; BitmapMemorySize: integer; Instance: pointer; Callback: TImageConversionCallback): integer; stdcall; export;
function BitmapToGIF(BitmapMemory: pointer; BitmapMemorySize: integer; Instance: pointer; Callback: TImageConversionCallback): integer; stdcall; export;

implementation

uses JPEG, Bmp2Gif;

type
TCallbackCallerStream = class(TStream)
private
    FInstance: pointer;
    FCallback: TImageConversionCallback;
    FPosition: integer;
public
    constructor Create(Instance: pointer; Callback: TImageConversionCallback);
    function Write(const Buffer; Count: Longint): Longint; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
end;

TImageMemoryStream = class(TCustomMemoryStream)
private
public
    constructor Create(Memory: pointer; Len: integer);
    function Write(const Buffer; Count: Longint): Longint; override;
end;

constructor TCallbackCallerStream.Create(Instance: pointer; Callback: TImageConversionCallback);
begin
    inherited Create;
    FCallback := Callback;
    FInstance := Instance;
end;

function TCallbackCallerStream.Write(const Buffer; Count: Longint): Longint;
begin
    FCallback(FInstance, @Buffer, Count);
    inc(FPosition, Count);
    result := Count;
end;

function TCallbackCallerStream.Read(var Buffer; Count: Longint): Longint;
begin
    assert(false, 'TCallbackCallerStream.Read');
    result := 0;
end;

function TCallbackCallerStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
    assert(((Origin = soFromCurrent) and (Offset = 0)), 'TCallbackCallerStream.Seek');
    result := FPosition;
end;

constructor TImageMemoryStream.Create(Memory: pointer; Len: integer);
begin
    inherited Create;
    SetPointer(Memory, Len);
end;

function TImageMemoryStream.Write(const Buffer; Count: Longint): Longint; 
begin
    assert(false, 'TImageMemoryStream.Write');
    result := 0;
end;

function CreateBitmapFromMemory(Memory: pointer; Len: integer): TBitmap;
var
    MemStream: TImageMemoryStream;
begin
    MemStream := TImageMemoryStream.Create(Memory, Len);
    try
        result := TBitmap.Create;
        result.LoadFromStream(MemStream);
    finally
        MemStream.Free;
    end;
end;

function BitmapToJPEG(BitmapMemory: pointer; BitmapMemorySize: integer; Instance: pointer; Callback: TImageConversionCallback): integer; stdcall; export;
    var
    JPEGImage: TJPEGImage;
    Bitmap: TBitmap;
    Stream: TCallbackCallerStream;
begin
    Bitmap := CreateBitmapFromMemory(BitmapMemory, BitmapMemorySize);
    try
        JPEGImage := TJPEGImage.Create;
        try
            JPEGImage.Assign(Bitmap);
            Stream := TCallbackCallerStream.Create(Instance, Callback);
            try
                JPEGImage.SaveToStream(Stream);
                result := Stream.Position;
            finally
                Stream.Free;
            end;
        finally
            JPEGImage.Free;
        end;
    finally
        Bitmap.Free;
    end;
end;

function BitmapToGIF(BitmapMemory: pointer; BitmapMemorySize: integer; Instance: pointer; Callback: TImageConversionCallback): integer; stdcall; export;
var
    Bitmap: TBitmap;
    Stream: TCallbackCallerStream;
begin
    Bitmap := CreateBitmapFromMemory(BitmapMemory, BitmapMemorySize);
    try
        Stream := TCallbackCallerStream.Create(Instance, Callback);
        try
            ConvertBitmapToGifStream(Bitmap, Stream);
            result := Stream.Position;
        finally
            Stream.Free;
        end;
    finally
        Bitmap.Free;
    end;
end;

end.
