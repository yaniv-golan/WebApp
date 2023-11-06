/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////

unit WapASmtp;

interface

{$I WapDef.INC}

{$ifdef wap_cbuilder}
    {$ObjExportAll On}
{$endif wap_cbuilder}

uses Classes, SysUtils, WapActns, ArgoSMTP;

type

TArgoSMTPData = record
    Server : string;
    TimeOut : Integer;
    Attachments : string;
    From : string;
    Recipient : string;
    CC : string;
    BCC : string;
    Subject : string;
    Body : string;
    Encoding : TEncoding;
    CharSet : TCharSet;
    ReturnReceipt : boolean;
    Priority : TPriority;
    UseDomainAddress : boolean;
    DefaultPort: word;

    Asynch: boolean;
end;


TSendMessageEvent = procedure (
    Sender: TObject;
    Request: THttpRequest; Response: THttpResponse;
    const Value: string; Params: TVariantList;
    var Handled: boolean) of object;

TMessageSentEvent = procedure(Sender: TObject; Asynch: boolean) of object;

TExceptionEvent = procedure(Sender: TObject; E: Exception; Asynch: boolean) of object;

TWapSMTP = class(TWapCustomAction)
private
    FOnSendMessage: TSendMessageEvent;
    FOnException: TExceptionEvent;
    FOnMessageSent: TMessageSentEvent;

    // TMSTP-reflected properties
    FSmtpData: TArgoSMTPData;
    procedure DoSendMessage(const SmtpData: TArgoSMTPData);
protected
    procedure Execute(
        Request: THttpRequest;
        Response: THttpResponse;
        const Verb, Value: string; Params: TVariantList;
        var Handled: Boolean); override;
    procedure ExecuteSendMessage(
        Request: THttpRequest;
        Response: THttpResponse;
        const Value: string; Params: TVariantList;
        var Handled: Boolean); virtual;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure SendMessage;
published
    // The following properties reflect properties of the TArgoSMTP component,
    // exposing some of them in a easier-to-use format for use in templates etc.
    property Server : string read FSmtpData.Server write FSmtpData.Server;
    property TimeOut : Integer read FSmtpData.TimeOut write FSmtpData.TimeOut;
    property Attachments : string read FSmtpData.Attachments write FSmtpData.Attachments;
    property From : string read FSmtpData.From write FSmtpData.From;
    property Recipient : string read FSmtpData.Recipient write FSmtpData.Recipient;
    property CC : string read FSmtpData.CC write FSmtpData.CC;
    property BCC : string read FSmtpData.BCC write FSmtpData.BCC;
    property Subject : string read FSmtpData.Subject write FSmtpData.Subject;
    property Body : string read FSmtpData.Body write FSmtpData.Body;
    property Encoding : TEncoding read FSmtpData.Encoding write FSmtpData.Encoding;
    property CharSet : TCharSet read FSmtpData.CharSet write FSmtpData.CharSet;
    property ReturnReceipt : boolean read FSmtpData.ReturnReceipt write FSmtpData.ReturnReceipt;
    property Priority : TPriority read FSmtpData.Priority write FSmtpData.Priority;
    property UseDomainAddress : boolean read FSmtpData.UseDomainAddress write FSmtpData.UseDomainAddress;
    property DefaultPort: word read FSmtpData.DefaultPort write FSmtpData.DefaultPort;

    // New properties
    property Asynch: boolean read FSmtpData.Asynch write FSmtpData.Asynch;

    property OnSendMessage: TSendMessageEvent read FOnSendMessage write FOnSendMessage;
    property OnException: TExceptionEvent read FOnException write FOnException;
    property OnMessageSent: TMessageSentEvent read FOnMessageSent write FOnMessageSent;
end;

implementation

///////////////////////////////////////////////////////////////////////////
//
// TWapSMTPSenderThread
//
///////////////////////////////////////////////////////////////////////////

type
TWapSMTPSenderThread = class(TThread)
private
    FController: TWapSMTP;
    FSmtpData: TArgoSMTPData;
public
    constructor Create(Controller: TWapSMTP);
    procedure Execute; override;
end;

constructor TWapSMTPSenderThread.Create(Controller: TWapSMTP);
begin
    inherited Create(true);
    FController := Controller;
    FSmtpData := Controller.FSmtpData;
    FreeOnTerminate := true;
    Resume;
end;

procedure TWapSMTPSenderThread.Execute;
begin
    FController.DoSendMessage(FSmtpData);
end;

///////////////////////////////////////////////////////////////////////////
//
// TWapSMTP
//
///////////////////////////////////////////////////////////////////////////

constructor TWapSMTP.Create(AOwner: TComponent);
begin
    inherited;
    ExposeProperties([
        'Server', 'TimeOut', 'Attachments', 'From', 'Recipient',
        'CC', 'BCC', 'Subject', 'Body', 'Encoding ', 'CharSet', 'ReturnReceipt',
        'Priority', 'UseDomainAddress', 'DefaultPort', 'Asynch']);
    Asynch := true;

    Encoding := etMIME;
    Priority := ptNormal;
    ReturnReceipt := false;
    DefaultPort := 25;
    UseDomainAddress := true;
    TimeOut := 60;
end;

destructor TWapSMTP.Destroy;
begin
    inherited;
end;

procedure TWapSMTP.Execute(
    Request: THttpRequest;
    Response: THttpResponse;
    const Verb, Value: string; Params: TVariantList;
    var Handled: Boolean);
begin
    if (CompareText(Verb, 'SendMessage') = 0) then
        ExecuteSendMessage(Request, Response, Value, Params, Handled)
    else
        UnsupportedVerbError(Verb);
end;

procedure TWapSMTP.ExecuteSendMessage(
    Request: THttpRequest;
    Response: THttpResponse;
    const Value: string; Params: TVariantList;
    var Handled: Boolean);
begin
    UpdateProperties(Params);
    if assigned(FOnSendMessage) then
        FOnSendMessage(Self, Request, Response, Value, Params, Handled);
    SendMessage;
end;

procedure TWapSMTP.SendMessage;
begin
    if (Asynch) then begin
        TWapSMTPSenderThread.Create(Self);
    end else begin
        DoSendMessage(FSmtpData);
    end;
end;

procedure TWapSMTP.DoSendMessage(const SmtpData: TArgoSMTPData);
var
    Mailer: TArgoSMTP;
begin
    try
        Mailer := TArgoSMTP.Create(nil);
        try
            with Mailer do begin
                Server := SmtpData.Server;
                TimeOut := SmtpData.TimeOut;
                Attachments.CommaText := SmtpData.Attachments;
                From := SmtpData.From;
                Recipient := SmtpData.Recipient;
                CC.CommaText := SmtpData.CC;
                BCC.CommaText := SmtpData.BCC;
                Subject := SmtpData.Subject;
                Body.Text := SmtpData.Body;
                Encoding := SmtpData.Encoding;
                CharSet := SmtpData.CharSet;
                ReturnReceipt := SmtpData.ReturnReceipt;
                Priority := SmtpData.Priority;
                UseDomainAddress := SmtpData.UseDomainAddress;
                DefaultPort := SmtpData.DefaultPort;
            end;

            Mailer.SendSingleMessage;

            if Assigned(FOnMessageSent) then
                FOnMessageSent(Self, SmtpData.Asynch);
        finally
            Mailer.Free;
        end;
    except
        on E: Exception do
            if Assigned(FOnException) then
                FOnException(Self, E, SmtpData.Asynch)
            else
                // we can raise the exception only if not in the secondary thread.
                // Otherwise, we have to hide it.
                if (not SmtpData.Asynch) then
                    raise;
    end;
end;

end.
