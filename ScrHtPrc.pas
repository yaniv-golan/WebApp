unit ScrHtPrc;

interface

uses Classes, SysUtils, HAWRIntf;

type

TGetMacroValueEvent = procedure(Sender: TObject; const Name: string; var Value: variant) of object;
TPreScriptOutputEvent = procedure(Sender: TObject; const Buffer; BufLen: integer) of object;
TExecuteActionEvent = procedure(Sender: TObject; const Action: string) of object;
TLoadIncludeFileEvent = procedure(Sender: TObject; const Attribute, Filename: string; IncludedFile: TStrings) of object;


TProcessorMode = (pmCreateScript, pmFormatHTML);

TScriptedHtmlProcessor = class(TComponent)
private
    // properties
    FInputTemplate: TStrings;
    FOutputScript: TStrings;
    FFormattedHTML: TStrings;
    FBlocks: TStrings;
    FResponseWritePre: string;
    FResponseWritePost: string;
    FResponseWriteBlockPre: string;
    FResponseWriteBlockPost: string;
    FStartDelim: string;
    FEndDelim: string;
    FMacroChar: char;
    FMode: TProcessorMode;
    // events
    FOnGetMacroValue: TGetMacroValueEvent;
    FOnPreScriptOutput: TPreScriptOutputEvent;
    FOnExecuteAction: TExecuteActionEvent;
    FOnLoadIncludeFile: TLoadIncludeFileEvent;

    FScriptStarted: boolean;
    FLexer: pointer;
    // TScriptedHtmlTemplateParser event handlers :
    procedure HandleInlineScript(Text: pchar); stdcall;
    procedure HandleScriptTag(Text: pchar; Language: pchar); stdcall;
    procedure HandleNonScriptText(Text: pchar); stdcall;
    procedure HandleMacro(MacroName: pchar); stdcall;
    procedure HandlePreProcessorInclude(Attribute, Filename: PChar); stdcall;

    procedure AddScriptLine(const S: string);
    procedure WritePlainText(const S: string);
    procedure AddToFormattedHTML(const S: string);
    function AddBlock(const S: string): integer;
    function GetResponseWriteEquiv: string;
    procedure SetResponseWriteEquiv(const Value: string);
    function GetResponseWriteBlockEquiv: string;
    procedure SetResponseWriteBlockEquiv(const Value: string);

    procedure SetStartDelim(const Value: string);
    procedure SetEndDelim(const Value: string);
    procedure SetMacroChar(Value: char);
    procedure WriteAction(const S: string);
    function IsAction(const MacroName: string): boolean;
    procedure InternalExecute(InputStrings: TStrings);
protected
    function GetMacroValue(const Name: string): variant; virtual;
    procedure PreScriptOutput(const Buffer; BufLen: integer); virtual;
    procedure DoExecuteAction(const Action: string); virtual;
    procedure LoadIncludeFile(const Attribute, Filename: string; IncludedFile: TStrings); virtual; 
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // On input :
    //   InputTemplate = the scripted HTML chunk
    //   OnPreScriptOutput = method to handle output before any script
    // On output :
    //   The text up to the first script line send to the OnPreScriptOutput event
    //   (including <%~macros%>
    //   OutputScript = The generated script
    //   Blocks = the blocks referenced by Response.WriteBlock
    procedure Execute;

    property OutputScript: TStrings read FOutputScript write FOutputScript;
    property Blocks: TStrings read FBlocks;
    property Mode: TProcessorMode read FMode write FMode;
    property FormattedHTML: TStrings read FFormattedHTML write FFormattedHTML; 
published
    property StartDelim: string read FStartDelim write SetStartDelim;
    property EndDelim: string read FEndDelim write SetEndDelim;
    property MacroChar: char read FMacroChar write SetMacroChar;

    property InputTemplate: TStrings read FInputTemplate write FInputTemplate;
    property ResponseWriteEquiv: string read GetResponseWriteEquiv write SetResponseWriteEquiv;
    property ResponseWriteBlockEquiv: string read GetResponseWriteBlockEquiv write SetResponseWriteBlockEquiv;

    property OnPreScriptOutput: TPreScriptOutputEvent read FOnPreScriptOutput write FOnPreScriptOutput; 
    property OnGetMacroValue: TGetMacroValueEvent read FOnGetMacroValue write FOnGetMacroValue;
    property OnExecuteAction: TExecuteActionEvent read FOnExecuteAction write FOnExecuteAction;
    property OnLoadIncludeFile: TLoadIncludeFileEvent read FOnLoadIncludeFile write FOnLoadIncludeFile;  
end;

implementation

uses XStrings, InetStr;

{$BOOLEVAL OFF}

constructor TScriptedHtmlProcessor.Create(AOwner: TComponent);
begin
    inherited;
    FBlocks := TStringList.Create;
    ResponseWriteEquiv := 'Response.Write(|)';
    ResponseWriteBlockEquiv := 'Response.WriteBlock(|)';

    FLexer := ScriptedHtmlLexer_Create;
    ScriptedHtmlLexer_SetOnInlineScript(FLexer, HandleInlineScript);
    ScriptedHtmlLexer_SetOnScriptTag(FLexer, HandleScriptTag);
    ScriptedHtmlLexer_SetOnNonScriptText(FLexer, HandleNonScriptText);
    ScriptedHtmlLexer_SetOnMacro(FLexer, HandleMacro);
    ScriptedHtmlLexer_SetOnPreProcessorInclude(FLexer, HandlePreProcessorInclude);

    StartDelim := '<%';
    EndDelim := '%>';
    MacroChar := '~';
end;

destructor TScriptedHtmlProcessor.Destroy;
begin
    ScriptedHtmlLexer_Destroy(FLexer);
    FBlocks.Free;
    inherited;
end;

procedure TScriptedHtmlProcessor.AddScriptLine(const S: string);
begin
    FOutputScript.Add(S);
end;

procedure TScriptedHtmlProcessor.HandleInlineScript(Text: pchar);
var
    s: string;
    i: integer;
    Handled: boolean;
begin
    case Mode of
        pmCreateScript: begin
            FScriptStarted := true;
            s := string(text);
            if (Length(s) > 0) then begin
                Handled := false;
                for i := 1 to length(s) do begin
                    // break on the first non-space char
                    if (s[i] > #32) then begin
                        // special handling for "=" as the first non-space char :
                        if (s[i] = '=') then begin
                            // Translate <%=expression%> into Response.Write(expression)
                            AddScriptLine(FResponseWritePre + Trim(copy(s, i + 1, maxInt)) + FResponseWritePost);
                            Handled := true;
                        end;
                        break;
                    end;
                end;
                if (not Handled) then
                    FOutputScript.Add(s);
            end;
        end;
        pmFormatHTML: begin
            AddToFormattedHTML('<FONT COLOR="RED"><B>' + FStartDelim + SpacesToNBSP(TabsToSpaces(string(Text), 4)) + FEndDelim + '</B></FONT>');
        end;
    end;
end;

procedure TScriptedHtmlProcessor.HandleScriptTag(Text: pchar; Language: pchar);
begin
    case Mode of
        pmCreateScript: begin
            FScriptStarted := true;
            FOutputScript.Add(string(Text));
        end;
        pmFormatHTML: begin
            AddToFormattedHTML('<FONT COLOR="RED"><B>' + FStartDelim + SpacesToNBSP(TabsToSpaces(string(Text), 4)) + FEndDelim + '</B></FONT>');
        end;
    end;
end;

function TScriptedHtmlProcessor.AddBlock(const S: string): integer;
begin
    result := FBlocks.Add(S);
end;

procedure TScriptedHtmlProcessor.WritePlainText(const S: string);
var
    BlockId: integer;
begin
    if (FScriptStarted) then begin
        BlockId := AddBlock(S);
        AddScriptLine(FResponseWriteBlockPre + IntToStr(BlockId) + FResponseWriteBlockPost);
    end else begin
        PreScriptOutput(PChar(s)^, length(s));
    end;
end;

procedure TScriptedHtmlProcessor.WriteAction(const S: string);
var
    BlockId: integer;
begin
    if (FScriptStarted) then begin
        BlockId := AddBlock(S);
        AddScriptLine(FResponseWriteBlockPre + IntToStr(- BlockId) + FResponseWriteBlockPost);
    end else begin
        DoExecuteAction(S);
    end;
end;

procedure TScriptedHtmlProcessor.DoExecuteAction(const Action: string);
begin
    if assigned(FOnExecuteAction) then
        FOnExecuteAction(Self, Action);
end;


procedure TScriptedHtmlProcessor.AddToFormattedHTML(const S: string);
var
    Temp: TStringList;
begin
    Temp := TStringList.Create;
    try
        Temp.Text := S;
        AppendStringsToStrings(Temp, FFormattedHTML);
    finally
        Temp.Free;
    end;
end;

procedure TScriptedHtmlProcessor.HandleNonScriptText(Text: pchar);
begin
    case Mode of
        pmCreateScript: begin
            if (Text <> '') then
                WritePlainText(string(Text));
        end;
        pmFormatHTML: begin
            AddToFormattedHTML(SpacesToNBSP(EscapeHTMLString(TabsToSpaces(string(Text), 4))));
        end;
    end;
end;

function TScriptedHtmlProcessor.IsAction(const MacroName: string): boolean;
begin
    result := (Pos('.', MacroName) > 0);
end;

procedure TScriptedHtmlProcessor.HandleMacro(MacroName: pchar);
var
    Value: variant;
    s: string;
begin
    case Mode of
        pmCreateScript: begin
            if IsAction(MacroName) then begin
                WriteAction(MacroName)
            end else begin
                Value := GetMacroValue(MacroName);
                if (Value <> null) then begin
                    s := string(Value);
                    if (s <> '') then
                        WritePlainText(s);
                end;
            end;
        end;
        pmFormatHTML: begin
            AddToFormattedHTML('<FONT COLOR="GREEN"><B>' + FStartDelim + FMacroChar + SpacesToNBSP(string(MacroName)) + FEndDelim + '</B></FONT>');
        end;
    end;
end;

procedure TScriptedHtmlProcessor.HandlePreProcessorInclude(Attribute, Filename: PChar);
var
    IncludedFile: TStringList;
begin
    IncludedFile := TStringList.Create;
    try
        LoadIncludeFile(StrPas(Attribute), StrPas(Filename), IncludedFile);
        InternalExecute(IncludedFile);
    finally
        IncludedFile.Free;
    end;
end;

procedure TScriptedHtmlProcessor.Execute;
begin
    if (FInputTemplate = nil) then
        raise Exception.Create('InputTemplate not assigned');
    if (Mode = pmCreateScript) then begin
        FBlocks.Clear;
        FBlocks.Add(''); // Make sure we never have to deal with block id 0
    end;
    InternalExecute(FInputTemplate);
end;

procedure TScriptedHtmlProcessor.InternalExecute(InputStrings: TStrings);
var
    s: string;
begin
    if (InputStrings = nil) then
        raise Exception.Create('InputStrings not assigned');
    case Mode of
        pmCreateScript: begin
            if (FOutputScript = nil) then
                raise Exception.Create('OutputScript not assigned');
            FBlocks.BeginUpdate;
            OutputScript.BeginUpdate;
            try
                s := InputStrings.Text;
                ScriptedHtmlLexer_Execute(FLexer, pchar(s), length(s));
            finally
                OutputScript.EndUpdate;
                FBlocks.EndUpdate;
            end;
        end;
        pmFormatHTML: begin
            if (FFormattedHTML = nil) then
                raise Exception.Create('FormattedHTML not assigned');
            FormattedHTML.BeginUpdate;
            try
                s := InputTemplate.Text;
                ScriptedHtmlLexer_Execute(FLexer, pchar(s), length(s));
            finally
                FormattedHTML.EndUpdate;
            end;
        end;
    end;

end;

procedure TScriptedHtmlProcessor.LoadIncludeFile(const Attribute, Filename: string; IncludedFile: TStrings);
begin
    if assigned(FOnLoadIncludeFile) then
        FOnLoadIncludeFile(Self, Attribute, Filename, IncludedFile);
end;


function TScriptedHtmlProcessor.GetMacroValue(const Name: string): variant;
begin
    result := null;
    if assigned(FOnGetMacroValue) then
        FOnGetMacroValue(Self, Name, Result);
end;

function TScriptedHtmlProcessor.GetResponseWriteEquiv: string;
begin
    result := FResponseWritePre + '|' + FResponseWritePost;
end;

procedure TScriptedHtmlProcessor.SetResponseWriteEquiv(const Value: string);
var
    p: integer;
begin
    p := pos('|', Value);
    if (p = 0) then begin
        FResponseWritePre := Value;
        FResponseWritePost := '';
    end else begin
        FResponseWritePre := copy(Value, 1, p - 1);
        FResponseWritePost := copy(Value, p + 1, maxInt);
    end;
end;

function TScriptedHtmlProcessor.GetResponseWriteBlockEquiv: string;
begin
    result := FResponseWriteBlockPre + '|' + FResponseWriteBlockPost;
end;

procedure TScriptedHtmlProcessor.SetResponseWriteBlockEquiv(const Value: string);
var
    p: integer;
begin
    p := pos('|', Value);
    if (p = 0) then begin
        FResponseWriteBlockPre := Value;
        FResponseWriteBlockPost := '';
    end else begin
        FResponseWriteBlockPre := copy(Value, 1, p - 1);
        FResponseWriteBlockPost := copy(Value, p + 1, maxInt);
    end;
end;

procedure TScriptedHtmlProcessor.PreScriptOutput(const Buffer; BufLen: integer);
begin
    if assigned(FOnPreScriptOutput) then
        FOnPreScriptOutput(Self, Buffer, BufLen);
end;

procedure TScriptedHtmlProcessor.SetStartDelim(const Value: string);
begin
    FStartDelim := Value;
    ScriptedHtmlLexer_SetStartDelim(FLexer, pchar(Value));
end;

procedure TScriptedHtmlProcessor.SetEndDelim(const Value: string);
begin
    FEndDelim := Value;
    ScriptedHtmlLexer_SetEndDelim(FLexer, pchar(Value));
end;

procedure TScriptedHtmlProcessor.SetMacroChar(Value: char);
begin
    FMacroChar := Value;
    ScriptedHtmlLexer_SetMacroChar(FLexer, Value);
end;

end.
