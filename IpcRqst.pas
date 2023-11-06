/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////
unit IpcRqst;

interface

uses Classes, SysUtils, Windows
    ,HttpReq, IPC, WIPCShrd, IpcConv
    ;

type
TIpcRequest = class(TAbstractHttpRequestInterface)
private
    FConversation: TIpcConversation;
    FWriteToClientFailed: boolean;
    FPhysicalPath: string;
    FLogicalPath: string;
    FMethod: string;
    FQueryString: string;
    procedure   InitiateConversation;
public
    constructor Create(Conversation: TIpcConversation);
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
end;

implementation

uses D3SysUtl;

constructor TIpcRequest.Create(Conversation: TIpcConversation);
begin
    inherited Create;
    FConversation := Conversation;
    InitiateConversation;
end;

destructor  TIpcRequest.Destroy;
begin
    FConversation.Free;
    inherited Destroy;
end;

procedure   TIpcRequest.InitiateConversation;
begin
    // Should be copied away before the riInitiateConversation is sent
    FPhysicalPath := StrPas(FConversation.Slot.PhysicalPath);
    FLogicalPath := StrPas(FConversation.Slot.LogicalPath);
    FMethod := StrPas(FConversation.Slot.Method);
    FQueryString := StrPas(FConversation.Slot.QueryString);

    // This tells the stub that we've picked up the conversation, and will
    // not need the handshake me\m anymore.
    FConversation.InitiateConversation;
end;

function    TIpcRequest.GetInputSize: integer;
begin
    FConversation.SendRequest(riGetInputSize);
    result := FConversation.Slot.InputSize;
end;

function    TIpcRequest.ReadFromClient(var Buffer; Count: integer): integer;
var
    BufferPtr: PChar;
    BytesToRead: integer;
begin
    if (Count = 0) then begin
        result := 0;
        exit;
    end;

    BufferPtr := @Buffer;
    result := 0;
    repeat
        if (Count > Sizeof(FConversation.Slot.ReadBuffer)) then
            BytesToRead := Sizeof(FConversation.Slot.ReadBuffer)
        else
            BytesToRead := Count;

        FConversation.Slot.ReadCount := BytesToRead;

        FConversation.SendRequest(riReadFromClient);

        Move(FConversation.Slot.ReadBuffer, BufferPtr^, FConversation.Slot.ReadCount);
        inc(result, FConversation.Slot.ReadCount);
        inc(BufferPtr, FConversation.Slot.ReadCount);
        dec(Count, FConversation.Slot.ReadCount);
    until ((Count <= 0) or (FConversation.Slot.ReadCount < BytesToRead));
end;

function    TIpcRequest.WriteToClient(const Buffer; Count: integer): integer;
var
    BufferPtr: PChar;
    BytesToWrite: integer;
begin
    if (FConversation.StubGone or FWriteToClientFailed) then begin
        result := Count;
        exit;
    end;

    BufferPtr := @Buffer;
    result := 0;
    repeat
        if (Count > Sizeof(FConversation.Slot.WriteBuffer)) then
            BytesToWrite := Sizeof(FConversation.Slot.WriteBuffer)
        else
            BytesToWrite := Count;

        FConversation.Slot.WriteCount := BytesToWrite;

        Move(BufferPtr^, FConversation.Slot.WriteBuffer, FConversation.Slot.WriteCount);
        try
            FConversation.SendRequest(riWriteToClient);
        except
            FWriteToClientFailed := true;
            raise;
        end;

        inc(result, FConversation.Slot.WriteCount);
        inc(BufferPtr, FConversation.Slot.WriteCount);
        dec(Count, FConversation.Slot.WriteCount);
    until ((Count <= 0) or (FConversation.Slot.WriteCount < BytesToWrite));
    FWriteToClientFailed := (FConversation.Slot.WriteCount < BytesToWrite);
end;

function    TIpcRequest.GetPhysicalPath: string;
begin
    result := FPhysicalPath;
end;

function    TIpcRequest.GetLogicalPath: string;
begin
    result := FLogicalPath;
end;

function    TIpcRequest.GetMethod: string;
begin
    result := FMethod;
end;

function    TIpcRequest.GetQueryString: string;
begin
    result := FQueryString;
end;

function    TIpcRequest.GetHttpHeader(const HeaderName: string): string;
begin
    StrCopy(FConversation.Slot.HeaderName, pchar(HeaderName));
    FConversation.SendRequest(riGetHttpHeader);
    result := StrPas(FConversation.Slot.HeaderValue);
end;

function    TIpcRequest.MapURLToPath(const LogicalURL: string): string; 
begin
    StrCopy(FConversation.Slot.MapURLToPath_Path, PChar(LogicalURL));
    FConversation.SendRequest(riMapURLToPath);
    result := FConversation.Slot.MapURLToPath_Path;
end;

function    TIpcRequest.GetServerVariable(const VarName: string): string;
begin
    StrCopy(FConversation.Slot.VarName, pchar(VarName));
    FConversation.SendRequest(riGetServerVariable);
    result := StrPas(FConversation.Slot.VarValue);
end;

function    TIpcRequest.GetInputContentType: string;
begin
    FConversation.SendRequest(riGetInputContentType);
    result := StrPas(FConversation.Slot.InputContentType);
end;

end.
