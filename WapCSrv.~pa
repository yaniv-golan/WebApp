//////////////////////////////////////////////////////////////////////////
//
// This is a modified version of Delphi's ComServ.pas, for use by WebApp's
// TWebTemplate implementation.
//
// The original ComServ.pas could not be installed into a Delphi package.
//
// Modified by Yaniv Golan, ygolan@hyperact.com
//
//////////////////////////////////////////////////////////////////////////


unit WapCSrv;

{$INCLUDE WAPDEF.INC}

{$IFDEF wap_delphi_3_or_cbuilder_3}

    interface

    uses Windows, ActiveX, SysUtils, ComObj;

    type

    { TWapComServer }

      TWapComServer = class(TComServerObject)
      private
        FObjectCount: Integer;
        FFactoryCount: Integer;
        FTypeLib: ITypeLib;
        FServerName: string;
        FHelpFileName: string;
        FIsInprocServer: Boolean;
        procedure FactoryFree(Factory: TComObjectFactory);
        procedure FactoryRegisterClassObject(Factory: TComObjectFactory);
      protected
        function CountObject(Created: Boolean): Integer; override;
        function CountFactory(Created: Boolean): Integer; override;
        function GetHelpFileName: string; override;
        function GetServerFileName: string; override;
        function GetServerKey: string; override;
        function GetServerName: string; override;
        function GetTypeLib: ITypeLib; override;
      public
        constructor Create;
        destructor Destroy; override;
        procedure Initialize;
        procedure LoadTypeLib;
        procedure SetServerName(const Name: string);
        property IsInprocServer: Boolean read FIsInprocServer write FIsInprocServer;
        property ObjectCount: Integer read FObjectCount;
      end;

    var
      WapComServer: TWapComServer;

    implementation

    function GetModuleFileName: string;
    var
      Buffer: array[0..261] of Char;
    begin
      SetString(Result, Buffer, Windows.GetModuleFileName(HInstance,
        Buffer, SizeOf(Buffer)));
    end;

    function GetModuleName: string;
    begin
      Result := ChangeFileExt(ExtractFileName(GetModuleFileName), '');
    end;

    function LoadTypeLibrary(const ModuleName: string): ITypeLib;
    begin
      OleCheck(LoadTypeLib(PWideChar(WideString(ModuleName)), Result));
    end;

    function GetTypeLibName(TypeLib: ITypeLib): string;
    var
      Name: WideString;
    begin
      OleCheck(TypeLib.GetDocumentation(-1, @Name, nil, nil, nil));
      Result := Name;
    end;

    { Automation TerminateProc }

    function AutomationTerminateProc: Boolean;
    begin
      Result := True;
    end;

    { TWapComServer }

    constructor TWapComServer.Create;
    begin
      FTypeLib := nil;
      FIsInprocServer := ModuleIsLib;
    end;

    destructor TWapComServer.Destroy;
    begin
      ComClassManager.ForEachFactory(Self, FactoryFree);
    end;

    function TWapComServer.CountObject(Created: Boolean): Integer;
    begin
      if Created then Inc(FObjectCount) else
      begin
        Dec(FObjectCount);
      end;
      Result := FObjectCount;
    end;

    function TWapComServer.CountFactory(Created: Boolean): Integer;
    begin
      if Created then Inc(FFactoryCount) else Dec(FFactoryCount);
      Result := FFactoryCount;
    end;

    procedure TWapComServer.FactoryFree(Factory: TComObjectFactory);
    begin
      Factory.Free;
    end;

    procedure TWapComServer.FactoryRegisterClassObject(Factory: TComObjectFactory);
    begin
      Factory.RegisterClassObject;
    end;

    function TWapComServer.GetHelpFileName: string;
    begin
      Result := FHelpFileName;
    end;

    function TWapComServer.GetServerFileName: string;
    begin
      Result := GetModuleFileName;
    end;

    function TWapComServer.GetServerKey: string;
    begin
      if FIsInprocServer then
        Result := 'InprocServer32' else
        Result := 'LocalServer32';
    end;

    function TWapComServer.GetServerName: string;
    begin
      if FServerName <> '' then
        Result := FServerName
      else
        if FTypeLib <> nil then
          Result := GetTypeLibName(FTypeLib)
        else
          Result := GetModuleName;
    end;

    procedure TWapComServer.SetServerName(const Name: string);
    begin
      if FTypeLib = nil then
        FServerName := Name;
    end;

    function TWapComServer.GetTypeLib: ITypeLib;
    begin
      LoadTypeLib;
      Result := FTypeLib;
    end;

    procedure TWapComServer.Initialize;
    begin
      ComClassManager.ForEachFactory(Self, FactoryRegisterClassObject);
    end;

    procedure TWapComServer.LoadTypeLib;
    begin
      if FTypeLib = nil then FTypeLib := LoadTypeLibrary(GetModuleFileName);
    end;

    var
      SaveInitProc: Pointer = nil;
      OleAutHandle: Integer;

    procedure InitWapComServer;
    begin
      if SaveInitProc <> nil then TProcedure(SaveInitProc);
      WapComServer.Initialize;
    end;

    initialization
    begin
      OleAutHandle := LoadLibrary('OLEAUT32.DLL');
      WapComServer := TWapComServer.Create;
      if not ModuleIsLib then
      begin
        SaveInitProc := InitProc;
        InitProc := @InitWapComServer;
        AddTerminateProc(@AutomationTerminateProc);
      end;
    end;

    finalization
    begin
        try
          WapComServer.Free;
          WapComServer := nil;
          FreeLibrary(OleAutHandle);
        except
            // nothing to do
        end;
    end;

{$ENDIF wap_delphi_3_or_cbuilder_3}

{$IFDEF wap_delphi_4}

    interface

    uses Windows, Messages, ActiveX, SysUtils, ComObj;

    type

    { Application start mode }

      TStartMode = (smStandalone, smAutomation, smRegServer, smUnregServer);

    { Class manager event types }

      TLastReleaseEvent = procedure(var Shutdown: Boolean) of object;

    { TWapComServer }

      TWapComServer = class(TComServerObject)
      private
        FObjectCount: Integer;
        FFactoryCount: Integer;
        FTypeLib: ITypeLib;
        FServerName: string;
        FHelpFileName: string;
        FIsInprocServer: Boolean;
        FStartMode: TStartMode;
        FStartSuspended: Boolean;
        FRegister: Boolean;
        FOnLastRelease: TLastReleaseEvent;
        procedure FactoryFree(Factory: TComObjectFactory);
        procedure FactoryRegisterClassObject(Factory: TComObjectFactory);
        procedure FactoryUpdateRegistry(Factory: TComObjectFactory);
        procedure LastReleased;
      protected
        function CountObject(Created: Boolean): Integer; override;
        function CountFactory(Created: Boolean): Integer; override;
        function GetHelpFileName: string; override;
        function GetServerFileName: string; override;
        function GetServerKey: string; override;
        function GetServerName: string; override;
        function GetStartSuspended: Boolean; override;
        function GetTypeLib: ITypeLib; override;
        procedure SetHelpFileName(const Value: string); override;
      public
        constructor Create;
        destructor Destroy; override;
        procedure Initialize;
        procedure LoadTypeLib;
        procedure SetServerName(const Name: string);
        procedure UpdateRegistry(Register: Boolean);
        property IsInprocServer: Boolean read FIsInprocServer write FIsInprocServer;
        property ObjectCount: Integer read FObjectCount;
        property StartMode: TStartMode read FStartMode;
        property OnLastRelease: TLastReleaseEvent read FOnLastRelease write FOnLastRelease;
      end;

    var
      WapComServer: TWapComServer;

    function DllGetClassObject(const CLSID, IID: TGUID; var Obj): HResult; stdcall;
    function DllCanUnloadNow: HResult; stdcall;
    function DllRegisterServer: HResult; stdcall;
    function DllUnregisterServer: HResult; stdcall;

    implementation

    uses ComConst;

    function GetModuleFileName: string;
    var
      Buffer: array[0..261] of Char;
    begin
      SetString(Result, Buffer, Windows.GetModuleFileName(HInstance,
        Buffer, SizeOf(Buffer)));
    end;

    function GetModuleName: string;
    begin
      Result := ChangeFileExt(ExtractFileName(GetModuleFileName), '');
    end;

    function LoadTypeLibrary(const ModuleName: string): ITypeLib;
    begin
      OleCheck(LoadTypeLib(PWideChar(WideString(ModuleName)), Result));
    end;

    procedure RegisterTypeLibrary(TypeLib: ITypeLib; const ModuleName: string);
    var
      Name: WideString;
      HelpPath: WideString;
    begin
      Name := ModuleName;
      HelpPath := ExtractFilePath(ModuleName);
      OleCheck(RegisterTypeLib(TypeLib, PWideChar(Name), PWideChar(HelpPath)));
    end;

    procedure UnregisterTypeLibrary(TypeLib: ITypeLib);
    type
      TUnregisterProc = function(const GUID: TGUID; VerMajor, VerMinor: Word;
        LCID: TLCID; SysKind: TSysKind): HResult stdcall;
    var
      Handle: THandle;
      UnregisterProc: TUnregisterProc;
      LibAttr: PTLibAttr;
    begin
      Handle := GetModuleHandle('OLEAUT32.DLL');
      if Handle <> 0 then
      begin
        @UnregisterProc := GetProcAddress(Handle, 'UnRegisterTypeLib');
        if @UnregisterProc <> nil then
        begin
          OleCheck(WapComServer.TypeLib.GetLibAttr(LibAttr));
          with LibAttr^ do
            UnregisterProc(guid, wMajorVerNum, wMinorVerNum, lcid, syskind);
          WapComServer.TypeLib.ReleaseTLibAttr(LibAttr);
        end;
      end;
    end;

    function GetTypeLibName(TypeLib: ITypeLib): string;
    var
      Name: WideString;
    begin
      OleCheck(TypeLib.GetDocumentation(-1, @Name, nil, nil, nil));
      Result := Name;
    end;

    function DllGetClassObject(const CLSID, IID: TGUID; var Obj): HResult;
    var
      Factory: TComObjectFactory;
    begin
      Factory := ComClassManager.GetFactoryFromClassID(CLSID);
      if Factory <> nil then
        if Factory.GetInterface(IID, Obj) then
          Result := S_OK
        else
          Result := E_NOINTERFACE
      else
      begin
        Pointer(Obj) := nil;
        Result := CLASS_E_CLASSNOTAVAILABLE;
      end;
    end;

    function DllCanUnloadNow: HResult;
    begin
      if (WapComServer = nil) or
        ((WapComServer.FObjectCount = 0) and (WapComServer.FFactoryCount = 0)) then
        Result := S_OK
      else
        Result := S_FALSE;
    end;

    function DllRegisterServer: HResult;
    begin
      Result := S_OK;
      try
        WapComServer.UpdateRegistry(True);
      except
        Result := E_FAIL;
      end;
    end;

    function DllUnregisterServer: HResult;
    begin
      Result := S_OK;
      try
        WapComServer.UpdateRegistry(False);
      except
        Result := E_FAIL;
      end;
    end;

    { Automation TerminateProc }

    function AutomationTerminateProc: Boolean;
    begin
      Result := True;
      if (WapComServer <> nil) and (WapComServer.ObjectCount > 0) then
      begin
        Result := MessageBox(0, PChar(SNoCloseActiveServer1 + SNoCloseActiveServer2),
          PChar(SAutomationWarning), MB_YESNO or MB_TASKMODAL or
          MB_ICONWARNING or MB_DEFBUTTON2) = IDYES;
      end;
    end;

    { TWapComServer }

    constructor TWapComServer.Create;

      function FindSwitch(const Switch: string): Boolean;
      begin
        Result := FindCmdLineSwitch(Switch, ['-', '/'], True);
      end;

    begin
      FTypeLib := nil;
      FIsInprocServer := ModuleIsLib;
      if FindSwitch('AUTOMATION') or FindSwitch('EMBEDDING') then
        FStartMode := smAutomation
      else if FindSwitch('REGSERVER') then
        FStartMode := smRegServer
      else if FindSwitch('UNREGSERVER') then
        FStartMode := smUnregServer;
    end;

    destructor TWapComServer.Destroy;
    begin
      ComClassManager.ForEachFactory(Self, FactoryFree);
    end;

    function TWapComServer.CountObject(Created: Boolean): Integer;
    begin
      if Created then
      begin
        Result := InterlockedIncrement(FObjectCount);
        if (not IsInProcServer) and (StartMode = smAutomation)
          and Assigned(ComObj.CoAddRefServerProcess) then
          ComObj.CoAddRefServerProcess;
      end
      else
      begin
        Result := InterlockedDecrement(FObjectCount);
        if (not IsInProcServer) and (StartMode = smAutomation)
          and Assigned(ComObj.CoReleaseServerProcess) then
        begin
          if ComObj.CoReleaseServerProcess = 0 then
            LastReleased;
        end
        else if Result = 0 then
          LastReleased;
      end;
    end;

    function TWapComServer.CountFactory(Created: Boolean): Integer;
    begin
      if Created then
        Result := InterlockedIncrement(FFactoryCount)
      else
        Result := InterlockedDecrement(FFactoryCount);
    end;

    procedure TWapComServer.FactoryFree(Factory: TComObjectFactory);
    begin
      Factory.Free;
    end;

    procedure TWapComServer.FactoryRegisterClassObject(Factory: TComObjectFactory);
    begin
      Factory.RegisterClassObject;
    end;

    procedure TWapComServer.FactoryUpdateRegistry(Factory: TComObjectFactory);
    begin
      if Factory.Instancing <> ciInternal then
        Factory.UpdateRegistry(FRegister);
    end;

    function TWapComServer.GetHelpFileName: string;
    begin
      Result := FHelpFileName;
    end;

    function TWapComServer.GetServerFileName: string;
    begin
      Result := GetModuleFileName;
    end;

    function TWapComServer.GetServerKey: string;
    begin
      if FIsInprocServer then
        Result := 'InprocServer32' else
        Result := 'LocalServer32';
    end;

    function TWapComServer.GetServerName: string;
    begin
      if FServerName <> '' then
        Result := FServerName
      else
        if FTypeLib <> nil then
          Result := GetTypeLibName(FTypeLib)
        else
          Result := GetModuleName;
    end;

    procedure TWapComServer.SetServerName(const Name: string);
    begin
      if FTypeLib = nil then
        FServerName := Name;
    end;

    function TWapComServer.GetTypeLib: ITypeLib;
    begin
      LoadTypeLib;
      Result := FTypeLib;
    end;

    procedure TWapComServer.Initialize;
    begin
      UpdateRegistry(FStartMode <> smUnregServer);
      if FStartMode in [smRegServer, smUnregServer] then Halt;
      ComClassManager.ForEachFactory(Self, FactoryRegisterClassObject);
    end;

    procedure TWapComServer.LastReleased;
    var
      Shutdown: Boolean;
    begin
      if not FIsInprocServer then
      begin
        Shutdown := FStartMode = smAutomation;
        try
          if Assigned(FOnLastRelease) then FOnLastRelease(Shutdown);
        finally
          if Shutdown then PostThreadMessage(MainThreadID, WM_QUIT, 0, 0);
        end;
      end;
    end;

    procedure TWapComServer.LoadTypeLib;
    var
      Temp: ITypeLib;
    begin
      if FTypeLib = nil then
      begin
      // this may load typelib more than once, but avoids need for critical section
      // and releases the interface correctly
        Temp := LoadTypeLibrary(GetModuleFileName);
        Integer(Temp) := InterlockedExchange(Integer(FTypeLib), Integer(Temp));
      end;
    end;

    procedure TWapComServer.UpdateRegistry(Register: Boolean);
    begin
      if FTypeLib <> nil then
        if Register then
          RegisterTypeLibrary(FTypeLib, GetModuleFileName) else
          UnregisterTypeLibrary(FTypeLib);
      FRegister := Register;
      ComClassManager.ForEachFactory(Self, FactoryUpdateRegistry);
    end;

    var
      SaveInitProc: Pointer = nil;
      OleAutHandle: Integer;

    procedure InitWapComServer;
    begin
      if SaveInitProc <> nil then TProcedure(SaveInitProc);
      WapComServer.FStartSuspended := (CoInitFlags <> -1) and
        Assigned(ComObj.CoInitializeEx) and Assigned(ComObj.CoResumeClassObjects);
      WapComServer.Initialize;
      if WapComServer.FStartSuspended then
        ComObj.CoResumeClassObjects;
    end;

    function TWapComServer.GetStartSuspended: Boolean;
    begin
      Result := FStartSuspended;
    end;

    procedure TWapComServer.SetHelpFileName(const Value: string);
    begin
      FHelpFileName := Value;
    end;

    initialization
    begin
      OleAutHandle := LoadLibrary('OLEAUT32.DLL');
      WapComServer := TWapComServer.Create;
      if not ModuleIsLib then
      begin
        SaveInitProc := InitProc;
        InitProc := @InitWapComServer;
        AddTerminateProc(@AutomationTerminateProc);
      end;
    end;

    finalization
    begin
      WapComServer.Free;
      WapComServer := nil;
      FreeLibrary(OleAutHandle);
    end;

    {$ENDIF wap_delphi_4}

end.

