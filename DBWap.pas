/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////
unit DBWap;

{$I WapDef.INC}

interface

uses
  SysUtils, Classes, DB, DBTables, WapThNtf, WapWThrd;

type

EDBAutoSession = class(Exception);

TDBAutoSession = class(TComponent)
private
    FSession: TSession;
    procedure SetSessionNames;
    class procedure HandleSessionOnPassword(Sender: TObject; var Continue: Boolean);
    class procedure ThreadNotification(Thread: TWapWorkerThread; Notification: TThreadNotification);
protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Loaded; override;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Session: TSession read FSession;
end;

function GetSessionForCurrentThread: TSession;
function GetSessionForThreadId(ThreadId: integer): TSession;

procedure Register;

implementation

uses BDE, Windows, Forms, IPC, ShellAPI;

{$ifndef wap_delphi_2_or_cbuilder_1}
    {$ifndef wap_delphi_3_or_delphi_4_or_cbuilder_3}
        Error : Unsupported Delphi version.
    {$endif wap_delphi_3_or_delphi_4_or_cbuilder_3}
{$endif wap_delphi_2_or_cbuilder_1}

var SessionsLock: TWin32CriticalSection = nil;

var
    PrivateDirsRoot: string = '';

function    CreateTempFileName(const PathName: string; const PrefixString: string): string;
begin
    SetLength(Result, MAX_PATH + 1);
    GetTempFileName(PChar(PathName), PChar(PrefixString), 0, PChar(Result));
    SetLength(Result, StrLen(PChar(Result)));
end;

function    GetTempPath: string;
begin
    SetLength(Result, MAX_PATH + 1);
    SetLength(Result, Windows.GetTempPath(MAX_PATH, PChar(Result)));
end;

function CreateTempDirectory: string;
var
    TempFilename: string;
begin
    TempFilename := CreateTempFileName(GetTempPath, 'DIR');
    try
        Result := ChangeFileExt(TempFilename, '.DIR');
        MkDir(Result);
    finally
        SysUtils.DeleteFile(TempFilename);
    end;
end;

function GetValidPrivateDirsRoot: string;
begin
    if (PrivateDirsRoot = '') then begin
        PrivateDirsRoot := CreateTempDirectory;
    end;
    result := PrivateDirsRoot;
end;

function GetSessionPrivateDirName(Session: TSession): string;
begin
    result := GetValidPrivateDirsRoot + '\' + Session.SessionName;
end;

procedure CreateSessionPrivateDir(Session: TSession);
var
    Dir: string;
begin
    Dir := GetSessionPrivateDirName(Session);
    MkDir(Dir);
    Session.PrivateDir := Dir;
end;

procedure RemovePrivateDirsRoot;
var
    FileOp: TSHFileOpStruct;
    RetCode: integer;
begin
    if (PrivateDirsRoot <> '') then begin
        FillChar(FileOp, SizeOf(FileOp), 0);
        FileOp.Wnd := 0;
        FileOp.wFunc := FO_DELETE;
        FileOp.pFrom := PChar(PrivateDirsRoot);
        FileOp.fFlags := FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOERRORUI;
        RetCode := SHFileOperation(FileOp);
        if (RetCode <> 0) then
            ;
    end;
end;

function GetSessionForThreadId(ThreadId: integer): TSession;
var
    SessionName: string;
begin
    SessionName := 'WapSession_' + IntToHex(ThreadId, 8);
    // The DBTables.Sessions object is not threadsafe, we need to protect
    // access to it.
    SessionsLock.Enter;
    try
        result := Sessions.FindSession(SessionName);
        if (result = nil) then begin
            result := TSession.Create(Application);
            result.SessionName := SessionName;
            result.OnPassword := TDBAutoSession.HandleSessionOnPassword;
            CreateSessionPrivateDir(result);
        end;
    finally
        SessionsLock.Leave;
    end;
end;

function GetSessionForCurrentThread: TSession;
begin
    result := GetSessionForThreadId(GetCurrentThreadId);
end;


constructor TDBAutoSession.Create(AOwner: TComponent);
begin
    inherited;
    FSession := GetSessionForCurrentThread;
    SetSessionNames;
end;

destructor TDBAutoSession.Destroy;
begin
    inherited Destroy;
end;

procedure TDBAutoSession.Loaded;
begin
    inherited Loaded;
    try
        SetSessionNames;
    except
        if csDesigning in ComponentState then
          Application.HandleException(Self)
        else
          raise;
    end;
end;

class procedure TDBAutoSession.HandleSessionOnPassword(Sender: TObject; var Continue: Boolean);
begin
    raise EDBAutoSession.Create('Invalid attempt to access a password protected table without supplying a password first');
end;

procedure TDBAutoSession.SetSessionNames;
var
  I: Integer;
  Component: TComponent;
begin
  if Owner <> nil then
    for I := 0 to Owner.ComponentCount - 1 do
    begin
      Component := Owner.Components[I];
      if (Component is TDBDataSet) and
        (AnsiCompareText(TDBDataSet(Component).SessionName, FSession.SessionName) <> 0) then
        TDBDataSet(Component).SessionName := FSession.SessionName
      else if (Component is TDataBase) and
        (AnsiCompareText(TDatabase(Component).SessionName, FSession.SessionName) <> 0) then
        TDataBase(Component).SessionName := FSession.SessionName
    end;
end;


type
    // Some things are better left unsaid. Do not try this at home...

{$HINTS OFF}

{$ifdef wap_delphi_2_or_cbuilder_1}
  TDBDataSetHack = class(TDataSet)
  private
    FDBFlags: TDBFlags;
    FUpdateMode: TUpdateMode;
    FReserved: Byte;
    FDatabase: TDatabase;
    FDatabaseName: string;
    FSessionName: string;
  end;

  TDatabaseHack = class(TComponent)
  private
    FDataSets: TList;
    FTransIsolation: TTransIsolation;
    FLoginPrompt: Boolean;
    FKeepConnection: Boolean;
    FTemporary: Boolean;
    FSessionAlias: Boolean;
    FStreamedConnected: Boolean;
    FLocaleLoaded: Boolean;
    FAliased: Boolean;
    FReserved: Byte;
    FRefCount: Integer;
    FHandle: HDBIDB;
    FSQLBased: Boolean;
    FTransHandle: HDBIXAct;
    FLocale: TLocale;
    FSession: TSession;
  end;
{$endif wap_delphi_2_or_cbuilder_1}

{$ifdef wap_delphi_3_or_delphi_4_or_cbuilder_3}
  TDBDataSetHack = class(TBDEDataSet)
  private
    FDBFlags: TDBFlags;
    FUpdateMode: TUpdateMode;
    FDatabase: TDatabase;
    FDatabaseName: string;
    FSessionName: string;
  end;

  TDatabaseHack = class(TComponent)
  private
    FDataSets: TList;
    FTransIsolation: TTransIsolation;
    FLoginPrompt: Boolean;
    FKeepConnection: Boolean;
    FTemporary: Boolean;
    FSessionAlias: Boolean;
    FStreamedConnected: Boolean;
    FLocaleLoaded: Boolean;
    FAliased: Boolean;
    FSQLBased: Boolean;
    FAcquiredHandle: Boolean;
    FPseudoIndexes: Boolean;
    FHandleShared: Boolean;
    FRefCount: Integer;
    FHandle: HDBIDB;
    FLocale: TLocale;
    FSession: TSession;
  end;
{$endif wap_delphi_3_or_delphi_4_or_cbuilder_3}

{$HINTS ON}

procedure TDBAutoSession.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opInsert) then
    if AComponent is TDBDataSet then
      TDBDataSetHack(AComponent).FSessionName := FSession.SessionName
    else if AComponent is TDatabase then
      TDatabaseHack(AComponent).FSession := FSession;
end;

class procedure TDBAutoSession.ThreadNotification(Thread: TWapWorkerThread; Notification: TThreadNotification);
var
    Session: TSession;
begin
    Session := GetSessionForCurrentThread;
    case Notification of
        tnThreadInitialization: begin
            Session.Active := true;
        end;
        tnThreadFinalization: begin
            Session.Active := false;
        end;
    end;
end;


procedure Register;
begin
    RegisterComponents('WebApp', [TDBAutoSession]);
end;

initialization
begin
    try
        SessionsLock := TWin32CriticalSection.Create;
        AddOnThreadNotification(TDBAutoSession.ThreadNotification);
    except
        // todo : add initialization exception handling code
    end;
end;

finalization
begin
    try
        RemoveOnThreadNotification(TDBAutoSession.ThreadNotification);
        SessionsLock.Free;
        SessionsLock := nil;
        RemovePrivateDirsRoot;
    except
        // todo : add finalization exception handling code
    end;
end;

end.
