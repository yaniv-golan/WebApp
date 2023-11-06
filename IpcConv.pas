/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////
unit IpcConv;

interface

uses Classes, SysUtils, Windows, IPC, WIPCShrd;

type

TIpcConversation = class
private
    FConversationSlot: PConversationSlot;
    FStubGone: boolean;
    procedure   TerminateConversation;
public
    constructor Create(ConversationSlot: PConversationSlot);
    destructor  Destroy; override;
    // this will release the lock on the handshake area
    procedure   InitiateConversation;
    procedure   SendRequest(RequestId: TRequestId);
    property    Slot: PConversationSlot read FConversationSlot;
    property    StubGone: boolean read FStubGone;
end;

implementation

uses D3SysUtl;

constructor TIpcConversation.Create(ConversationSlot: PConversationSlot);
begin
    inherited Create;
    FConversationSlot := ConversationSlot;
end;

destructor  TIpcConversation.Destroy;
begin
    if (not FStubGone) then begin
        try
            TerminateConversation;
        except
            // do nothing, ignore the exception
        end;
    end;
    inherited Destroy;
end;

procedure   TIpcConversation.SendRequest(RequestId: TRequestId);
const
    Timeout = 30 * 1000; // 30 secs
begin
    if (FStubGone) then
        exit;
    try
        FConversationSlot.RequestId := RequestId;
        StrCopy(FConversationSlot.ErrorMessage, '');
        Win32Check(
            SetEvent(FConversationSlot.Wap_hServerRequestReadyEvent)
        );
        // All requests, except for riTerminateConversation, will be acknowledged
        if (RequestId <> riTerminateConversation) then begin
            try
                case WaitForSingleObject(FConversationSlot.Wap_hStubResponseReadyEvent, Timeout) of
                    WAIT_FAILED: RaiseLastWin32Error;
                    WAIT_TIMEOUT: raise exception.create('Timed-out while waiting for stub to response');
                    WAIT_ABANDONED: raise exception.create('Stub abandonded');
                end;
            except
                FStubGone := true;
                raise;
            end;
            if (StrComp(FConversationSlot.ErrorMessage, '') <> 0) then
                raise exception.create('Exception in stub : ' + FConversationSlot.ErrorMessage);
        end;
    except
        on E: Exception do
            raise EAbort.Create('TIpcConversation.SendRequest: ' + E.Message);
    end;
end;

procedure   TIpcConversation.TerminateConversation;
begin
    SendRequest(riTerminateConversation);
end;

procedure   TIpcConversation.InitiateConversation;
begin
    // This tells the stub that we've picked up the conversation, and will
    // not need the handshake me\m anymore.
    SendRequest(riInitiateConversion);
end;

end.
