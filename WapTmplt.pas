/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////
unit WapTmplt;

interface

{$I WapDef.INC}

{$ifdef wap_cbuilder}
    {$ObjExportAll On}
{$endif wap_cbuilder}

uses Classes, SysUtils, Windows, HWebApp, AppSSI, HtmlTxt, WVarDict, ScrHtPrc
{$ifdef wap_axscript}
    ,ActiveX, AXSHost, ComObj
{$endif wap_axscript}
;

type

{$ifdef wap_axscript}
TScriptErrorEvent = AXSHost.TScriptErrorEvent;
{$endif wap_axscript}
TGetMacroValueEvent = ScrHtPrc.TGetMacroValueEvent;

EWapTemplate = class(Exception);

TWapTemplate = class(TWapControl)
private
    InputTemplate: TStringList;
    // properties
    FFilename: string;
    FValues: TVariantList;
    FSession: TWapSession;

    // events
    FOnGetMacroValue: TGetMacroValueEvent;
    {$ifdef wap_axscript}
    FOnRegisterScriptObjects: TNotifyEvent;
    {$endif wap_axscript}

    {$ifdef wap_axscript}
    FOnScriptError: TScriptErrorEvent;
    FInRegisterScriptObjects: boolean;
    FHost: TActiveScriptHost;
    FErrorInScript: boolean;
    FScriptingEngine: TCLSID;
    {$endif wap_axscript}

    FParser: TScriptedHtmlProcessor;
    function DoExecuteAction(const Action: string): boolean;
    procedure SetSession(Value: TWapSession);
    function GetVariable(Index: string): variant;
    procedure SetVariable(Index: string; Value: variant);
    procedure HandleParserGetMacroValue(Sender: TObject; const Name: string; var Value: variant);
    procedure HandlePreScriptOutput(Sender: TObject; const Buffer; BufLen: integer);
    procedure HandleParserExecuteAction(Sender: TObject; const Action: string);
    function GetStartDelim: string;
    procedure SetStartDelim(const Value: string);
    function GetEndDelim: string;
    procedure SetEndDelim(const Value: string);
    function GetMacroChar: char;
    procedure SetMacroChar(Value: char);
    procedure SetFilename(const Value: string);
    {$ifdef wap_axscript}
    function GetBlock(BlockId: integer): string;
    procedure ExecuteActionBlock(BlockId: integer);
    procedure RunScript(Script: TStrings);
    procedure HandleScriptError(Sender: TObject; Info: TScriptErrorInfo; var Action: TScriptErrorAction);
    procedure RegisterStandardScriptObjects;
    procedure HandleStop;
    function GetScriptingEngine: string;
    procedure SetScriptingEngine(const Value: string);
    {$endif wap_axscript}
protected
    procedure ProduceHTML(Dest: TStrings); override;
    function GetMacroValue(const Name: string): variant; virtual;
    {$ifdef wap_axscript}
    procedure ScriptError(Info: TScriptErrorInfo; var Action: TScriptErrorAction); virtual;
    procedure RegisterScriptObjects; virtual;
    {$endif wap_axscript}
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // Input
    procedure LoadFromFile(const Filename: string);
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromStrings(Strings: TStrings);

    // output
    procedure WriteToStream(Stream: TStream); override;
    procedure FormatHTML(HTML: TStrings);

    procedure Clear;
    property Values[Index: string]: variant read GetVariable write SetVariable; default;
    {$ifdef wap_axscript}
    procedure RegisterObject(const Name: string; Instance: IUnknown);
    property ErrorInScript: boolean read FErrorInScript;
    {$endif wap_axscript}
published
    {$ifdef wap_axscript}
    property ScriptingEngine: string read GetScriptingEngine write SetScriptingEngine;
    {$endif wap_axscript}
    property StartDelim: string read GetStartDelim write SetStartDelim;
    property EndDelim: string read GetEndDelim write SetEndDelim;
    property MacroChar: char read GetMacroChar write SetMacroChar;

    property Filename: string read FFilename write SetFilename;
    property Session: TWapSession read FSession write SetSession;

    property OnGetMacroValue: TGetMacroValueEvent read FOnGetMacroValue write FOnGetMacroValue;
    {$ifdef wap_axscript}
    property OnRegisterScriptObjects: TNotifyEvent read FOnRegisterScriptObjects write FOnRegisterScriptObjects;
    property OnScriptError: TScriptErrorEvent read FOnScriptError write FOnScriptError;
    {$endif wap_axscript}
end;

// Translates a "Action.Verb value=... param1=... param2=...." string into
// a URL-compatible encoding - "Action.Verb=value&Action@param1=...&Action@param2=..."
function EncodeAction(const ActionMacro: string): string;    

implementation

uses HAWRIntf, Forms
{$ifdef wap_axscript}
    ,WScrImp, ActivScp
{$endif wap_axscript}
    ;

{$ifdef wap_axscript}
{$R WSCR.TLB}
{$endif wap_axscript}

constructor TWapTemplate.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FValues := TVariantList.Create;
    FParser := TScriptedHtmlProcessor.Create(nil);
    InputTemplate := TStringList.Create;
{$ifdef wap_axscript}
    FScriptingEngine := CLSID_VBScript;
{$endif wap_axscript}
end;

destructor TWapTemplate.Destroy;
begin
    InputTemplate.Free;
    FParser.Free;
    FValues.Free;
    inherited;
end;

procedure TWapTemplate.ProduceHTML(Dest: TStrings);
var
    TempStream: TMemoryStream;
begin
    TempStream := TMemoryStream.Create;
    try
        WriteToStream(TempStream);
        Dest.LoadFromStream(TempStream);
    finally
        TempStream.Free;
    end;
end;

procedure TWapTemplate.WriteToStream(Stream: TStream);
var
    OutputScript: TStringList;
begin
    if (FSession = nil) then
        raise Exception.Create('Session must be assigned');
    OutputScript := TStringList.Create;
    try
        FParser.Mode := pmCreateScript;
        FParser.InputTemplate := InputTemplate;
        FParser.OutputScript := OutputScript;
        FParser.OnPreScriptOutput := HandlePreScriptOutput;
        FParser.OnGetMacroValue := HandleParserGetMacroValue;
        FParser.OnExecuteAction := HandleParserExecuteAction;
        FParser.Execute;
        if (OutputScript.Count > 0) then begin
            {$IFDEF wap_axscript}
                RunScript(OutputScript);
            {$ELSE}
                raise Exception.Create('Scripting not supported');
            {$ENDIF wap_axscript}
        end;
    finally
        OutputScript.Free;
    end;
end;

procedure TWapTemplate.FormatHTML(HTML: TStrings);
var
    i: integer;
begin
    FParser.Mode := pmFormatHTML;
    FParser.InputTemplate := InputTemplate;
    FParser.FormattedHTML := HTML;
    FParser.Execute;

    HTML.BeginUpdate;
    try
        for i := 0 to (HTML.Count - 1) do
            HTML[i] := HTML[i] + '<BR>';
    finally
        HTML.EndUpdate;
    end;
end;

function TWapTemplate.GetVariable(Index: string): variant;
begin
    result := FValues[Index];
end;

procedure TWapTemplate.SetVariable(Index: string; Value: variant);
begin
    FValues[Index] := Value;
end;

procedure TWapTemplate.Clear;
begin
    FValues.Clear;
end;

procedure TWapTemplate.HandleParserGetMacroValue(Sender: TObject; const Name: string; var Value: variant);
begin
    Value := GetMacroValue(Name);
    if (Value = null) then
        Value := Values[Name];
    if (Value = null) and (FSession <> nil) then
        Value := FSession[Name];
    if (Value = null) and (FSession <> nil) then
        Value := FSession.Application[Name];
end;

function TWapTemplate.GetMacroValue(const Name: string): variant;
begin
    result := null;
    if assigned(FOnGetMacroValue) then
        FOnGetMacroValue(Self, Name, Result);
end;

procedure ParseAction(
    // input
    const Action: string;
    // output
    var Name, Verb, Value: string; Params: TVariantList);
var
    Instance: pointer;
    i: integer;
    count: integer;
    paramName: string;
    paramValue: string;
    Buf: array[0..1024] of char;
begin
    Instance := TemplateActionLexer_Create(PChar(Action));
    try
        TemplateActionLexer_GetActionName(Instance, Buf, SizeOf(Buf));
        Name := Buf;
        TemplateActionLexer_GetVerb(Instance, Buf, SizeOf(Buf));
        Verb := Buf;
        TemplateActionLexer_GetValue(Instance, Buf, SizeOf(Buf));
        Value := Buf;
        count := TemplateActionLexer_GetParamCount(Instance);
        for i := 0 to (count - 1) do begin
            TemplateActionLexer_GetParamName(Instance, i, Buf, SizeOf(Buf));
            ParamName := Buf;
            if (CompareText(ParamName, 'Value') <> 0) then begin
                TemplateActionLexer_GetParamValue(Instance, i, Buf, SizeOf(Buf));
                ParamValue := Buf;
                Params[ParamName] := ParamValue;
            end;
        end;
    finally
        TemplateActionLexer_Free(Instance);
    end;
end;

function TWapTemplate.DoExecuteAction(const Action: string): boolean;
var
    Name, Verb, Value: string;
    Params: TVariantList;
begin
    Params := TVariantList.Create;
    try
        ParseAction(Action, Name, Verb, Value, Params);
        result := FSession.Actions.ExecuteAction(
            FSession.Request, FSession.Response, Name, Verb, Value, Params);
    finally
        Params.Free;
    end;
end;

procedure TWapTemplate.HandleParserExecuteAction(Sender: TObject; const Action: string);
begin
    DoExecuteAction(Action);
end;


procedure TWapTemplate.SetSession(Value: TWapSession);
begin
    if (Value <> FSession) then begin
        FSession := Value;
    end;
end;

procedure TWapTemplate.HandlePreScriptOutput(Sender: TObject; const Buffer; BufLen: integer);
begin
    Session.Response.OutputStream.WriteBuffer(Buffer, BufLen);
end;


function TWapTemplate.GetStartDelim: string;
begin
    result := FParser.StartDelim;
end;

procedure TWapTemplate.SetStartDelim(const Value: string);
begin
    FParser.StartDelim := Value;
end;

function TWapTemplate.GetEndDelim: string;
begin
    result := FParser.EndDelim;
end;

procedure TWapTemplate.SetEndDelim(const Value: string);
begin
    FParser.EndDelim := Value;
end;

function TWapTemplate.GetMacroChar: char;
begin
    result := FParser.MacroChar;
end;

procedure TWapTemplate.SetMacroChar(Value: char);
begin
    FParser.MacroChar := Value;
end;

function EncodeAction(const ActionMacro: string): string;
var
    Name, Verb, Value: string;
    Params: TVariantList;
    i: integer;
begin
    Params := TVariantList.Create;
    try
        ParseAction(ActionMacro, Name, Verb, Value, Params);
        result := Name;
        if (Verb <> '') then
            result := result + '.' + Verb;
        if (Value <> '') then
            result := result + '=' + Value;
        for i := 0 to (Params.Count - 1) do begin
            result := result + '&' + Name + '@' + Params.ItemNames[i] + '=' + Params[Params.ItemNames[i]];
        end;
    finally
        Params.Free;
    end;
end;

procedure TWapTemplate.SetFilename(const Value: string);
begin   
    try
        if (Value <> FFilename) then begin
            LoadFromFile(Value);
        end;
    except
        if (csDesigning in ComponentState) then
            Application.HandleException(Self)
        else
            raise;
    end;
end;


procedure TWapTemplate.LoadFromFile(const Filename: string);
begin
    FFilename := Filename;
    try
        InputTemplate.LoadFromFile(Filename);
    except
        on E: Exception do
            raise EWapTemplate.Create('Unable to load ' + ExpandFilename(Filename) + ' : ' + E.Message);
    end;
end;

procedure TWapTemplate.LoadFromStream(Stream: TStream);
begin
    FFilename := '';
    InputTemplate.LoadFromStream(Stream);
end;

procedure TWapTemplate.LoadFromStrings(Strings: TStrings);
begin
    FFilename := '';
    InputTemplate.Assign(Strings);
end;

{$ifdef wap_axscript}
procedure TWapTemplate.HandleScriptError(Sender: TObject; Info: TScriptErrorInfo; var Action: TScriptErrorAction);
begin
    ScriptError(Info, Action);
end;

procedure TWapTemplate.ScriptError(Info: TScriptErrorInfo; var Action: TScriptErrorAction);
begin
    FErrorInScript := true;
    if assigned(FOnScriptError) then
        FOnScriptError(Self, Info, Action)
    else begin
    // tbd
        with Session.Response do begin
            Writeln(TextOut, '<H2>Script Error</H2>');
            Writeln(TextOut, '<P>"' + string(Info.Description) + '" in line ', Info.LineNumber, ' of <TT>' + FFilename, '</TT>: ');
            Writeln(TextOut, '<PRE>' + string(Info.SourceLineText));
            Writeln(TextOut, StringOfChar(' ', Info.CharacterPosition - 1) + '^' + '</PRE>');
        end;
    end;
end;

procedure TWapTemplate.RunScript(Script: TStrings);
begin
    FErrorInScript := false;
    CoInitialize(nil);
    try
        FHost := TActiveScriptHost.Create(nil);
        try
            FHost.ScriptingEngine := FScriptingEngine;
            FHost.OnScriptError := HandleScriptError;
            FHost.Connect;

            RegisterScriptObjects;

            FHost.ParseScriptText(
                Script.Text,
                '',
                nil,
                '',
                0,
                0,
                [stfIsVisible]
                );
            FHost.Start;
        finally
            FHost.Free;
            FHost := nil;
        end;
    finally
        CoUninitialize;
    end;
end;

procedure TWapTemplate.RegisterScriptObjects;
begin
    FInRegisterScriptObjects := true;
    try
        RegisterStandardScriptObjects;
        if assigned(FOnRegisterScriptObjects) then
            FOnRegisterScriptObjects(Self);
    finally
        FInRegisterScriptObjects := false;
    end;
end;

procedure TWapTemplate.RegisterStandardScriptObjects;
var
    HttpResponseAdapter: THttpResponseAdapter;
    HttpRequestAdapter: THttpRequestAdapter;
    WapAppAdapter: TWapAppAdapter;
    WapSessionAdapter: TWapSessionAdapter;
begin
    HttpResponseAdapter := THttpResponseAdapter.Create;
    HttpResponseAdapter.Response := Session.Response;
    HttpResponseAdapter.GetBlockFunction := GetBlock;
    HttpResponseAdapter.ExecuteActionBlockFunction := ExecuteActionBlock;
    HttpResponseAdapter.StopProc := HandleStop;
    RegisterObject('Response', HttpResponseAdapter);

    HttpRequestAdapter := THttpRequestAdapter.Create;
    HttpRequestAdapter.RealRequest := Session.Request;
    RegisterObject('Request', HttpRequestAdapter);

    WapAppAdapter := TWapAppAdapter.Create;
    WapAppAdapter.RealWapApp := Session.Application;
    RegisterObject('Application', WapAppAdapter);

    WapSessionAdapter := TWapSessionAdapter.Create;
    WapSessionAdapter.RealWapSession := Session;
    WapSessionAdapter.OnExecuteAction := HandleParserExecuteAction;
    RegisterObject('Session', WapSessionAdapter);
end;

procedure TWapTemplate.RegisterObject(const Name: string; Instance: IUnknown);
begin
    if (not FInRegisterScriptObjects) then
        raise Exception.Create('RegisterObject should be called only in response to RegisterScriptObjects');
    FHost.AddNamedObject(Name, [sifIsVisible, sifGlobalMembers], Instance);
end;

function TWapTemplate.GetBlock(BlockId: integer): string;
begin
    result := FParser.Blocks[BlockId];
end;

procedure TWapTemplate.ExecuteActionBlock(BlockId: integer);
var
    Action: string;
begin
    Action := FParser.Blocks[- BlockId];
    DoExecuteAction(Action);
end;


procedure TWapTemplate.HandleStop;
begin
    if (FHost <> nil) then
        FHost.InterruptScriptThread(-1, PExcepInfo(nil)^, []);
end;

function TWapTemplate.GetScriptingEngine: string;
begin
    Result := GUIDToString(FScriptingEngine);
end;

procedure TWapTemplate.SetScriptingEngine(const Value: string);
begin
    if (Value = '') then
        raise EWapTemplate.Create('Invalid value for ScriptingEngine');
    if (Value[1] = '{') then
        FScriptingEngine := StringToGUID(Value)
    else
        FScriptingEngine := ProgIDToClassID(Value);
end;

{$endif wap_axscript}

end.
