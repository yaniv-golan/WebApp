unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses HAWRIntf;

procedure WriteToStreamCallback(Instance: pointer; Data: pointer; Size: integer); stdcall; export;
begin
    TStream(Instance).WriteBuffer(Data^, Size);
end;

procedure BitmapToJPEGStream(Bitmap: TBitmap; Stream: TStream);
begin
    BitmapToJPEG(Bitmap.Handle, Stream, WriteToStreamCallback);
end;

procedure BitmapToJPEGFile(Bitmap: TBitmap; const Filename: string);
var
    F: TFileStream;
begin
    F := TFileStream.Create(Filename, fmCreate or fmOpenWrite);
    try
        BitmapToJPEGStream(Bitmap, F);
    finally
        F.Free;
    end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
    BitmapToJPEGFile(Image1.Picture.Bitmap, 'c:\test2.jpg');
end;

end.
