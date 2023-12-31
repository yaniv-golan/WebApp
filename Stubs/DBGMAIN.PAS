unit dbgmain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Isapi, ipc;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Edit1: TEdit;
    ListBox1: TListBox;
    Label1: TLabel;
    Memo1: TMemo;
    CheckBox1: TCheckBox;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
    counter: integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

uses IsapiSupport,
  StubUtils,
  CgiSupport,
  WinCGISupport,
  WsapiSupport,
  NsapiSupport2;

var
    Vars: TStringList = nil;

function GetServerVariable( hConn: HCONN;
    VariableName: PChar;
    Buffer: Pointer;
    var Size: DWORD ): BOOL stdcall;
var
    s: string;
begin
    s := vars.values[StrPas(VariableName)];
    if (length(s) < Size - 1) then
        Size := length(s) + 1;
    if (S = '') then
        StrCopy(PChar(Buffer), '')
    else
        StrPLCopy(PChar(BUffer), PChar(S), Size);
    result := true;
end;    

function WriteClient( ConnID: HCONN;
    Buffer: Pointer;
    var Bytes: DWORD;
    dwReserved: DWORD ): BOOL stdcall;
var
    s: string;
begin
    result := true;
    if (form1.checkbox1.checked) then begin
        setLength(s, bytes);
        Move(pchar(buffer)^, pchar(s)^, bytes);
        form1.memo1.text := form1.memo1.text + s;
    end;
end;    


function ReadClient( ConnID: HCONN;
    Buffer: Pointer;
    var Size: DWORD ): BOOL stdcall;
begin
    result := false;
end;

function ServerSupportFunction( hConn: HCONN;
    HSERRequest: DWORD;
    Buffer: Pointer;
    var Size: DWORD;
    var DataType: DWORD ): BOOL stdcall;
begin
    result := false;
end;    


procedure TForm1.Button1Click(Sender: TObject);
var
    ECB: TEXTENSION_CONTROL_BLOCK;
begin
    Vars := TStringList.Create;
    try
        Vars.Values['SCRIPT_NAME'] := 'SCRIPT_NAME';
        Ecb.cbSize := sizeof (ECB);
        Ecb.ConnID := 1;
        Ecb.lpszMethod := 'GET';
        Ecb.lpszQueryString := 'app=test';
        Ecb.lpszPathInfo := '';
        Ecb.lpszPathTranslated := '';
        Ecb.cbTotalBytes := 0;
        Ecb.cbAvailable := 0;
        Ecb.lpbData := nil;
        Ecb.lpszContentType := 'application/x-www-form-urlencoded';
        Ecb.GetServerVariable := GetServerVariable;
        Ecb.WriteClient := WriteClient;
        Ecb.ReadClient := ReadClient;
        Ecb.ServerSupportFunction := ServerSupportFunction;
        IsapiHttpExtensionProc(ECB);
    finally
        Vars.Free;
    end;
end;

type
THitThread = class(TThread)
public
    procedure update;
    procedure execute; override;
end;

procedure THitThread.update;
begin
    inc(form1.counter);
    form1.label1.caption := inttostr(form1.counter);
    Application.ProcessMessages;
end;

procedure THitThread.execute;
var
    ECB: TEXTENSION_CONTROL_BLOCK;
    i: integer;
begin
    for i := 0 to 500 do begin
        synchronize(update);
        Ecb.cbSize := sizeof (ECB);
        Ecb.ConnID := 1;
        Ecb.lpszMethod := 'GET';
        Ecb.lpszQueryString := 'app=test';
        Ecb.lpszPathInfo := '';
        Ecb.lpszPathTranslated := '';
        Ecb.cbTotalBytes := 0;
        Ecb.cbAvailable := 0;
        Ecb.lpbData := nil;
        Ecb.lpszContentType := 'application/x-www-form-urlencoded';
        Ecb.GetServerVariable := GetServerVariable;
        Ecb.WriteClient := WriteClient;
        Ecb.ReadClient := ReadClient;
        Ecb.ServerSupportFunction := ServerSupportFunction;
        IsapiHttpExtensionProc(ECB);
    end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
    ECB: TEXTENSION_CONTROL_BLOCK;
    i: integer;
begin
    for i := 0 to 100 do begin
        label1.Caption := IntToStr(i);
        Application.ProcessMessages;
        Vars := TStringList.Create;
        try
            Vars.Values['SCRIPT_NAME'] := 'SCRIPT_NAME';
            Ecb.cbSize := sizeof (ECB);
            Ecb.ConnID := 1;
            Ecb.lpszMethod := 'GET';
            Ecb.lpszQueryString := 'app=test';
            Ecb.lpszPathInfo := '';
            Ecb.lpszPathTranslated := '';
            Ecb.cbTotalBytes := 0;
            Ecb.cbAvailable := 0;
            Ecb.lpbData := nil;
            Ecb.lpszContentType := 'application/x-www-form-urlencoded';
            Ecb.GetServerVariable := GetServerVariable;
            Ecb.WriteClient := WriteClient;
            Ecb.ReadClient := ReadClient;
            Ecb.ServerSupportFunction := ServerSupportFunction;
            IsapiHttpExtensionProc(ECB);
        finally
            Vars.Free;
        end;
        application.ProcessMessages;
    end;
end;

procedure TForm1.Button3Click(Sender: TObject);
var
    i: integer;
    t: THitThread;
begin
    Vars.Values['SCRIPT_NAME'] := 'SCRIPT_NAME';
    for i := 1 to 5 do begin
        t := THitThread.Create(true);
        t.freeOnTerminate := true;
        t.resume;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    Vars := TStringList.Create;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
    ECB: TEXTENSION_CONTROL_BLOCK;
begin
        Vars := TStringList.Create;
        try
            Vars.Values['SCRIPT_NAME'] := 'SCRIPT_NAME';
            Ecb.cbSize := sizeof (ECB);
            Ecb.ConnID := 1;
            Ecb.lpszMethod := 'GET';
            Ecb.lpszQueryString := 'WapCmd=test';
            Ecb.lpszPathInfo := '';
            Ecb.lpszPathTranslated := '';
            Ecb.cbTotalBytes := 0;
            Ecb.cbAvailable := 0;
            Ecb.lpbData := nil;
            Ecb.lpszContentType := 'application/x-www-form-urlencoded';
            Ecb.GetServerVariable := GetServerVariable;
            Ecb.WriteClient := WriteClient;
            Ecb.ReadClient := ReadClient;
            Ecb.ServerSupportFunction := ServerSupportFunction;
            IsapiHttpExtensionProc(ECB);
        finally
            Vars.Free;
        end;
end;

end.

