unit AppUtil;

interface

uses classes, sysUtils, forms, controls, winTypes, graphics
    ;

function    AppPath: string;
function    GetTopMostForm(FormClass: TFormClass): TForm;
function    ValidForm(FormClass: TFormClass): TForm;
function    ClientToClient(Src, Dest: TControl; const Point: TPoint): TPoint;

procedure   SafeSetFocus(Control: TWinControl);
procedure   ShowAndBringToFront(Form: TForm);

function    CreateWinControlBitmap(Control: TWinControl): Graphics.TBitmap;


implementation

uses WinProcs, Messages, SDS
    ;

function    AppPath: string;
begin
	result := extractFilePath(application.exeName);
end;

{ returns the instance of this form class which was most recently used. This is determined }
{ by the order of screens.forms, which is ordered by z-order. }
function    GetTopMostForm(formClass: TFormClass): TForm;
var
    i: integer;
begin
    if (application.mainForm.formStyle = fsMDIForm) then begin
        for i := 0 to (application.mainForm.mdiChildCount - 1) do begin
            if (application.mainForm.mdiChildren[i] is formClass) then begin
                result := application.mainForm.mdiChildren[i];
                exit;
            end;
        end;
    end else begin
        for i := 0 to (screen.formCount - 1) do begin
            if (screen.forms[i] is formClass) then begin
                result := screen.forms[i];
                exit;
            end;
        end;
    end;
    result := nil;
end;

function    ValidForm(FormClass: TFormClass): TForm;
begin
    result := GetTopMostForm(FormClass);
    if (result = nil) then
        result := FormClass.Create(Application);
end;

function    ClientToClient(Src, Dest: TControl; const Point: TPoint): TPoint;
begin
    result := src.clientToScreen(point);
    result := dest.screenToClient(result);
end;

{ For use when the control might be another notebook page - will prevent }
{ the "unable to focus invisible or disabled control" exception }
procedure   SafeSetFocus(Control: TWinControl);
begin
    control.show;
    control.setFocus;
end;

procedure   ShowAndBringToFront(Form: TForm);
begin
    if (form.windowState = wsMinimized) then
        form.windowState := wsNormal;
    form.show;
    form.bringToFront;
end;

{$ifdef ver90}

function  CreateWinControlBitmap(Control: TWinControl): Graphics.TBitmap;
var
  ScreenDC, PrintDC: HDC;
  OldBits, PrintBits: HBITMAP;
  PaintLParam: Longint;

  procedure PrintHandle(Handle: HWND);
  var
    R: TRect;
    Child: HWND;
    SavedIndex: Integer;
  begin
    if IsWindowVisible(Handle) then
    begin
      SavedIndex := SaveDC(PrintDC);
      WinProcs.GetClientRect(Handle, R);
      MapWindowPoints(Handle, Control.Handle, R, 2);
      with R do
      begin
        SetWindowOrgEx(PrintDC, -Left, -Top, nil);
        IntersectClipRect(PrintDC, 0, 0, Right - Left, Bottom - Top);
      end;
      SendMessage(Handle, WM_ERASEBKGND, PrintDC, 0);
      SendMessage(Handle, WM_PAINT, PrintDC, PaintLParam);
      Child := GetWindow(Handle, GW_CHILD);
      if Child <> 0 then
      begin
        Child := GetWindow(Child, GW_HWNDLAST);
        while Child <> 0 do
        begin
          PrintHandle(Child);
          Child := GetWindow(Child, GW_HWNDPREV);
        end;
      end;
      RestoreDC(PrintDC, SavedIndex);
    end;
  end;

begin
  Result := nil;
  ScreenDC := GetDC(0);
  PaintLParam := 0;
  try
    PrintDC := CreateCompatibleDC(ScreenDC);
    try
      PrintBits := CreateCompatibleBitmap(ScreenDC, Control.ClientWidth, Control.ClientHeight);
      try
        OldBits := SelectObject(PrintDC, PrintBits);
        try
          { Clear the contents of the bitmap }
          FillRect(PrintDC, Control.ClientRect, Control.Brush.Handle);

          { Paint form into a bitmap }
          PrintHandle(Control.Handle);
        finally
          SelectObject(PrintDC, OldBits);
        end;
        Result := Graphics.TBitmap.Create;
        Result.Handle := PrintBits;
        PrintBits := 0;
      except
        Result.Free;
        if PrintBits <> 0 then DeleteObject(PrintBits);
        raise;
      end;
    finally
      DeleteDC(PrintDC);
    end;
  finally
    ReleaseDC(0, ScreenDC);
  end;
end;

{$else}

function  CreateWinControlBitmap(Control: TWinControl): Graphics.TBitmap;
begin
  Result := Graphics.TBitmap.Create;
  try
    Result.Width := Control.ClientWidth;
    Result.Height := Control.ClientHeight;
    Result.Canvas.Brush := Control.Brush;
    Result.Canvas.FillRect(Control.ClientRect);
    Result.Canvas.Lock;
    try
      Control.PaintTo(Result.Canvas.Handle, 0, 0);
    finally
      Result.Canvas.Unlock;
    end;
  except
    Result.Free;
    raise;
  end;
end;

{$endif ver90}

end.
