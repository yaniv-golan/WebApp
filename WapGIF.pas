unit WapGIF;

interface

// To enable WebApp's GIF conversion support (THttpResponse.SendBitmapAsGIF),
// just add this unit to your USES clause or to the project itself.

implementation

uses Classes, SysUtils, Windows, Graphics, AppSSI, HAWRIntf;

procedure WriteToStreamCallback(Instance: pointer; Data: pointer; Size: integer); stdcall; export;
begin
    TStream(Instance).WriteBuffer(Data^, Size);
end;

function BitmapToGIFStream(Bitmap: Graphics.TBitmap; Stream: TStream): integer;
var
    MemStream: TMemoryStream;
begin
    MemStream := TMemoryStream.Create;
    try
        Bitmap.SaveToStream(MemStream);
        result := BitmapToGIF(MemStream.Memory, MemStream.Size, Stream, WriteToStreamCallback);
    finally
        MemStream.free;
    end;
end;

initialization
begin
    BitmapToGIFStreamProc := BitmapToGIFStream;
end;

end.
