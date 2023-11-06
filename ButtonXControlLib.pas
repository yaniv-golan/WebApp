unit ButtonXControlLib;

{ ButtonXControlLib Library }
{ Version 1.0 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_ButtonXControlLib: TGUID = '{BD83F2C9-9A2B-11D0-9C94-5E309A000000}';

const

{ TxDragMode }

  dmManual = 0;
  dmAutomatic = 1;

{ TxMouseButton }

  mbLeft = 0;
  mbRight = 1;
  mbMiddle = 2;

const

{ Component class GUIDs }
  Class_ButtonX: TGUID = '{BD83F2CC-9A2B-11D0-9C94-5E309A000000}';
  Class_fsdfsd: TGUID = '{BD83F2D1-9A2B-11D0-9C94-5E309A000000}';

type

{ Forward declarations }
  IButtonX = interface;
  DButtonX = dispinterface;
  IButtonXEvents = dispinterface;
  Ifsdfsd = interface;
  Dfsdfsd = dispinterface;

  TxDragMode = TOleEnum;
  TxMouseButton = TOleEnum;

{ Dispatch interface for ButtonX Control }

  IButtonX = interface(IDispatch)
    ['{BD83F2CA-9A2B-11D0-9C94-5E309A000000}']
    procedure Click; safecall;
    function Get_Cancel: WordBool; safecall;
    procedure Set_Cancel(Value: WordBool); safecall;
    function Get_Caption: WideString; safecall;
    procedure Set_Caption(const Value: WideString); safecall;
    function Get_Default: WordBool; safecall;
    procedure Set_Default(Value: WordBool); safecall;
    function Get_DragCursor: Smallint; safecall;
    procedure Set_DragCursor(Value: Smallint); safecall;
    function Get_DragMode: TxDragMode; safecall;
    procedure Set_DragMode(Value: TxDragMode); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(Value: WordBool); safecall;
    function Get_Font: Font; safecall;
    procedure Set_Font(const Value: Font); safecall;
    function Get_ModalResult: Integer; safecall;
    procedure Set_ModalResult(Value: Integer); safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Cursor: Smallint; safecall;
    procedure Set_Cursor(Value: Smallint); safecall;
    property Cancel: WordBool read Get_Cancel write Set_Cancel;
    property Caption: WideString read Get_Caption write Set_Caption;
    property Default: WordBool read Get_Default write Set_Default;
    property DragCursor: Smallint read Get_DragCursor write Set_DragCursor;
    property DragMode: TxDragMode read Get_DragMode write Set_DragMode;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property Font: Font read Get_Font write Set_Font;
    property ModalResult: Integer read Get_ModalResult write Set_ModalResult;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Cursor: Smallint read Get_Cursor write Set_Cursor;
  end;

{ DispInterface declaration for Dual Interface IButtonX }

  DButtonX = dispinterface
    ['{BD83F2CA-9A2B-11D0-9C94-5E309A000000}']
    procedure Click; dispid 1;
    property Cancel: WordBool dispid 2;
    property Caption: WideString dispid 3;
    property Default: WordBool dispid 4;
    property DragCursor: Smallint dispid 5;
    property DragMode: TxDragMode dispid 6;
    property Enabled: WordBool dispid 7;
    property Font: Font dispid 8;
    property ModalResult: Integer dispid 9;
    property Visible: WordBool dispid 10;
    property Cursor: Smallint dispid 11;
  end;

{ Events interface for ButtonX Control }

  IButtonXEvents = dispinterface
    ['{BD83F2CB-9A2B-11D0-9C94-5E309A000000}']
    procedure OnClick; dispid 1;
    procedure OnKeyPress(var Key: Smallint); dispid 2;
  end;

{ Dispatch interface for fsdfsd Object }

  Ifsdfsd = interface(IDispatch)
    ['{BD83F2D0-9A2B-11D0-9C94-5E309A000000}']
  end;

{ DispInterface declaration for Dual Interface Ifsdfsd }

  Dfsdfsd = dispinterface
    ['{BD83F2D0-9A2B-11D0-9C94-5E309A000000}']
  end;

{ ButtonXControl }

  TButtonXOnKeyPress = procedure(Sender: TObject; var Key: Smallint) of object;

  TButtonX = class(TOleControl)
  private
    FOnClick: TNotifyEvent;
    FOnKeyPress: TButtonXOnKeyPress;
    FIntf: IButtonX;
  protected
    procedure InitControlData; override;
    procedure InitControlInterface(const Obj: IUnknown); override;
  public
    procedure Click;
    property ControlInterface: IButtonX read FIntf;
  published
    property Cancel: WordBool index 2 read GetWordBoolProp write SetWordBoolProp stored False;
    property Caption: WideString index 3 read GetWideStringProp write SetWideStringProp stored False;
    property Default: WordBool index 4 read GetWordBoolProp write SetWordBoolProp stored False;
    property DragCursor: Smallint index 5 read GetSmallintProp write SetSmallintProp stored False;
    property DragMode: TxDragMode index 6 read GetTOleEnumProp write SetTOleEnumProp stored False;
    property Enabled: WordBool index 7 read GetWordBoolProp write SetWordBoolProp stored False;
    property Font: TFont index 8 read GetTFontProp write SetTFontProp stored False;
    property ModalResult: Integer index 9 read GetIntegerProp write SetIntegerProp stored False;
    property Visible: WordBool index 10 read GetWordBoolProp write SetWordBoolProp stored False;
    property Cursor: Smallint index 11 read GetSmallintProp write SetSmallintProp stored False;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnKeyPress: TButtonXOnKeyPress read FOnKeyPress write FOnKeyPress;
  end;

procedure Register;

implementation

uses ComObj;

procedure TButtonX.InitControlData;
const
  CEventDispIDs: array[0..1] of Integer = (
    $00000001, $00000002);
  CFontIDs: array [0..0] of Integer = (
    $00000008);
  CControlData: TControlData = (
    ClassID: '{BD83F2CC-9A2B-11D0-9C94-5E309A000000}';
    EventIID: '{BD83F2CB-9A2B-11D0-9C94-5E309A000000}';
    EventCount: 2;
    EventDispIDs: @CEventDispIDs;
    LicenseKey: nil;
    Flags: $00000000;
    Version: 300;
    FontCount: 1;
    FontIDs: @CFontIDs);
begin
  ControlData := @CControlData;
end;

procedure TButtonX.InitControlInterface(const Obj: IUnknown);
begin
  FIntf := Obj as IButtonX;
end;

procedure TButtonX.Click;
begin
  ControlInterface.Click;
end;


procedure Register;
begin
  RegisterComponents('ActiveX', [TButtonX]);
  RegisterNonActiveX([TButtonX]);
end;

end.
