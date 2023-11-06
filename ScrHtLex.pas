unit ScrHtLex;

interface

uses Classes, SysUtils, LexTool, HTMLLex
    ;

type

TInlineScriptCallback = procedure(Text: pchar) of object; stdcall;
TScriptTagCallback = procedure(Text: pchar; Language: pchar) of object; stdcall;
TNonScriptTextCallback = procedure(Text: pchar) of object; stdcall;
TMacroCallback = procedure(MacroName: pchar) of object; stdcall;
TPreProcessorIncludeCallback = procedure(Attribute, Filename: PChar) of object; stdcall;

TScriptedHtmlLexer = class(TComponent)
private
    FStartDelim: string;
    FEndDelim: string;
    FMacroChar: char;
    FOnInlineScript: TInlineScriptCallback;
    FOnNonScriptText: TNonScriptTextCallback;
    FOnScriptTag: TScriptTagCallback;
    FOnMacro: TMacroCallback;
    FOnPreprocessorInclude: TPreProcessorIncludeCallback;
protected
    procedure InlineScript(const Text: string); virtual;
    procedure NonScriptText(const Text: string); virtual;
    procedure ScriptTag(const Text: string; const Language: string); virtual;
    procedure Macro(const Name: string); virtual;
    procedure PreProcessorInclude(const Attribute, Filename: string); virtual;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Execute(Template: TStrings); virtual;
published
    property StartDelim: string read FStartDelim write FStartDelim;
    property EndDelim: string read FEndDelim write FEndDelim;
    property MacroChar: char read FMacroChar write FMacroChar;
    
    property OnInlineScript: TInlineScriptCallback read FOnInlineScript write FOnInlineScript;
    property OnScriptTag: TScriptTagCallback read FOnScriptTag write FOnScriptTag;
    property OnNonScriptText: TNonScriptTextCallback read FOnNonScriptText write FOnNonScriptText;
    property OnMacro: TMacroCallback read FOnMacro write FOnMacro;
    property OnPreprocessorInclude: TPreProcessorIncludeCallback read FOnPreprocessorInclude write FOnPreprocessorInclude;
end;

implementation

uses XStrings;

function RemoveTrailingCRLF(const s: string): string;
begin
    result := s;
    if ((length(result) > 2) and (result[length(result) - 1] = #13) and (result[length(result)] = #10)) then
        setLength(result, length(result) - 2);
end;

constructor TScriptedHtmlLexer.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FStartDelim := '<%';
    FEndDelim := '%>';
    FMacroChar := '~';
end;

destructor TScriptedHtmlLexer.Destroy;
begin
    inherited destroy;
end;

procedure TScriptedHtmlLexer.Execute(Template: TStrings);
var
    Lexer: TLexTool;

    function getInlineScriptToken: boolean;
    var
        Contents: TStringList;
        Temp: TStringList;
        S: string;
        c: char;
    begin
        result := false;
        // We got here because PeekChar saw the first char of FStartDelim. We will
        // read it using ReadChar, which (like PeekChar) skips EOLs etc.
        if (not Lexer.ReadChar(c)) then
            exit;
        // Now read the rest of the start delim
        if (not Lexer.PeekString(length(FStartDelim) - 1, S)) then
            exit;
        if (S <> Copy(FStartDelim, 2, MaxInt)) then
            exit;
        Lexer.ReadString(length(FStartDelim) - 1, S);

        result := true;

        if (Lexer.PeekChar(c) and (c = FMacroChar)) then begin
            // Handle <%~VarName%>
            Lexer.ReadChar(c);
            // We will get false here if the end-delim was not found on this line
            if (not Lexer.ReadWordLongDelim(S, [FEndDelim], false)) then
                raise exception.create('Macro statement spans more than a single line or not terminated correctly');
            Macro(Trim(S));
            Lexer.ReadString(length(FEndDelim), S);
        end else begin
            // Handle real inlined scripts
            Contents := TStringList.Create;
            Temp := TStringList.Create;
            try
                while (not Lexer.EOF) do begin
                    Temp.Clear;
                    Lexer.ReadStrings(Temp, [FEndDelim[1]]);
                    AppendStringsToStrings(Temp, Contents);
                    if (Lexer.EOF) then
                        break;
                    if (Lexer.PeekString(length(FStartDelim), S)) then begin
                        if (s = FEndDelim) then begin
                            Lexer.ReadString(length(FEndDelim), S);
                            break;
                        end;
                    end;
                end; // while
                InlineScript(RemoveTrailingCRLF(Contents.Text));
            finally
                Contents.Free;
                Temp.Free;
            end;
        end;
    end;

    function getScriptTagToken: boolean;
    var
        Language: string;

        // true only if tag is 'script', and RunAt matches
        function    readIfCorrectScriptTag: boolean;
        var
            HTMLTagToken: THtmlTagToken;
        begin
            result := false;
            HTMLTagToken := THTMLTagToken.Create;
            try
                HTMLTagToken.Contents.BeginUpdate;
                try
                    Lexer.ReadStrings(HTMLTagToken.Contents, ['>']);
                    if (Lexer.SkipChar('>')) then
                        AppendCharToStrings('>', HTMLTagToken.Contents);
                finally
                    HTMLTagToken.Contents.EndUpdate;
                end;
                if (not HtmlTagToken.IsTag('SCRIPT')) then
                    exit;
                if (UpperCase(HtmlTagToken.Attributes['RUNAT']) <> 'SERVER') then
                    exit;
                Language := HtmlTagToken.Attributes['LANGUAGE'];
            finally
                HTMLTagToken.Free;
            end;
            result := true;
        end;

        // true only if tag is </script>
        function skipIfScriptEndTag: boolean;
        var
            HTMLTagToken: THtmlTagToken;
        begin
            result := false;
            HTMLTagToken := THTMLTagToken.Create;
            try
                Lexer.ReadStrings(HTMLTagToken.Contents, ['>']);
                Lexer.SkipChar('>');
                if (not HtmlTagToken.IsTag('/SCRIPT')) then
                    exit;
            finally
                HTMLTagToken.Free;
            end;
            result := true;
        end;

    var
        Contents: TStringList;
        Temp: TStringList;
        PrevPos: TLexToolPos;
    begin
        result := false;
        if (Lexer.EOF) then
            exit;

        PrevPos := Lexer.Position;

        if (not readIfCorrectScriptTag) then begin
            Lexer.Position := PrevPos;
            exit;
        end;

        result := true;
        Contents := TStringList.Create;
        Temp := TStringList.Create;
        try
            while (not Lexer.EOF) do begin
                Temp.Clear;
                Lexer.ReadStrings(Temp, ['<']);
                AppendStringsToStrings(Temp, Contents);
                if (Lexer.EOF) then
                    break;


                PrevPos := Lexer.Position;
                if (skipIfScriptEndTag) then
                    break
                else begin
                    Lexer.Position := PrevPos;
                    Lexer.SkipChar('<');
                    AppendCharToStrings('<', Contents);
                end;
            end; // while
            ScriptTag(RemoveTrailingCRLF(Contents.Text), Language);
        finally
            Contents.Free;
            Temp.Free;
        end;
    end;

    procedure getNonScriptTextToken;
    var
        Contents: TStringList;
        c: char;
    begin
        Contents := TStringList.Create;
        try
            // the first char might be "<", but we still want it - we already
            // checked that it isn't part of the delimiter or the <script> tag
            Lexer.ReadChar(c);
            Lexer.ReadStrings(Contents, ['<', FStartDelim[1]]);
            // Add the character we read before as the first char of contents
            if (Contents.Count = 0) then
                Contents.Add(c)
            else
                Contents[0] := c + Contents[0];
            NonScriptText(RemoveTrailingCRLF(Contents.Text));
        finally
            Contents.Free;
        end;
    end;

const
    EndOfComment = '-->';

    function getPreProcessorInclude: boolean;
    var
        s: string;
        c: char;
        CommandStrings: TStringList;
        Filename: string;
        Attribute: string;

        procedure NoAttributeError;
        begin
            raise Exception.Create('The Include file name must be specified using either the File or Virtual attribute.');
        end;

        procedure AttributeValueNoClosingDelimiterError;
        begin
            raise Exception.Create('The value of the ''' + Attribute + ''' attribute has no closing delimiter.');
        end;

        procedure NoClosingTagError;
        begin
            raise Exception.Create('The HTML comment or server-side include lacks the close tag (-->).');
        end;

        function readIfIncludeCommand: boolean;
        var
            S: string;
        begin
            result := false;
            if (not Lexer.ReadString(4, S)) then
                exit;
            if (S <> '<!--') then
                exit;
            Lexer.SkipWhileChars(WhiteSpaceChars, false);
            if (not Lexer.ReadWord(S, AsciiChars - (AlphaChars + ['#']), true)) then
                exit;
            if (CompareText(S, '#INCLUDE') <> 0) then
                exit;
            result := true;
        end;


    var
        PrevPos: TLexToolPos;
    begin
        result := false;
        if (Lexer.EOF) then
            exit;

        PrevPos := Lexer.Position;

        if (not readIfIncludeCommand) then begin
            Lexer.Position := PrevPos;
            exit;
        end;

        result := true;

        CommandStrings := TStringList.Create;
        try
            Lexer.SkipWhileChars(WhiteSpaceChars, false);
            if (not Lexer.ReadWord(Attribute, AsciiChars - AlphaChars, true)) then
                NoAttributeError;
            Lexer.SkipWhileChars(WhiteSpaceChars, false);
            if (not Lexer.SkipChar('=')) then
                NoAttributeError;
            Lexer.SkipWhileChars(WhiteSpaceChars, false);
            if (not Lexer.PeekChar(c)) then
                NoAttributeError;
            if (c = '"') then begin
                Lexer.SkipChar(c);
                Lexer.ReadWord(Filename, ['"'], false);
                if (not Lexer.SkipChar('"')) then
                    AttributeValueNoClosingDelimiterError;
                Lexer.SkipWhileChars(WhiteSpaceChars, false);
                Lexer.ReadString(Length(EndOfComment), S);
                if (S <> EndOfComment) then
                    NoClosingTagError;
            end else begin
                Filename := '';
                while (true) do begin
                    if (not Lexer.ReadWord(S, WhiteSpaceChars + ['-', '>'], false)) then
                        if (Filename = '') then
                            NoAttributeError
                        else
                            NoClosingTagError;
                    Filename := Filename + S;
                    Lexer.SkipWhileChars(WhiteSpaceChars, false);
                    if (not Lexer.PeekString(Length(EndOfComment), S)) then
                        NoClosingTagError;
                    if (S = EndOfComment) then
                        break;
                end;
                Lexer.ReadString(Length(EndOfComment), S);
            end;
            PreProcessorInclude(Attribute, Filename);
        finally
            CommandStrings.Free;
        end;
    end;

var
    c: char;
begin
    Lexer := TLexTool.Create(nil);
    try
        Lexer.Strings := Template;
        while (not Lexer.EOF) do begin
            if (not Lexer.PeekChar(c)) then
                exit;
            if (c = FStartDelim[1]) then begin
                Lexer.PushState;
                if (getInlineScriptToken) then begin
                    Lexer.DiscardPushedState;
                    continue;
                end else
                    Lexer.PopState;
            end;
            if (c = '<') then begin
                if (getScriptTagToken) then
                    continue;
                if (getPreProcessorInclude) then
                    continue;
            end;
            getNonScriptTextToken;
        end; // while not lexer.eof
    finally
        Lexer.Free;
    end;
end;

procedure TScriptedHtmlLexer.InlineScript(const Text: string);
begin
    if assigned(FOnInlineScript) then
        FOnInlineScript(pchar(Text));
end;

procedure TScriptedHtmlLexer.NonScriptText(const Text: string);
begin
    if assigned(FOnNonScriptText) then
        FOnNonScriptText(pchar(Text));
end;

procedure TScriptedHtmlLexer.ScriptTag(const Text: string; const Language: string);
begin
    if assigned(FOnScriptTag) then
        FOnScriptTag(pchar(Text), pchar(Language));
end;

procedure TScriptedHtmlLexer.Macro(const Name: string);
begin
    if assigned(FOnMacro) then
        FOnMacro(pchar(Name));
end;

procedure TScriptedHtmlLexer.PreProcessorInclude(const Attribute, Filename: string);
begin
    if assigned(FOnPreprocessorInclude) then
        FOnPreprocessorInclude(PChar(Attribute), PChar(Filename));
end;



end.
