/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////
unit OHtmlTxt;

interface

uses Classes, SysUtils, HWebApp
    ;

type

THtmlOutput = class(TComponent)
private
    FSession: TWapSession;
    function GetValidSession: TWapSession;
public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Write(const S: string);
    procedure WriteLn(const S: string);

    procedure BeginTag(const Tag: string);
    procedure EndTag(const Tag: string);

    procedure BeginHtml;  // <html>
    procedure EndHtml;    // </html>

    procedure BeginHead;  // <head>
    procedure EndHead;    //  </head>

    procedure BeginBody;  // <body>
    procedure EndBody;    //  </body>

    procedure BeginItalic; // <i>
    procedure EndItalic; // </i>

    procedure BeginBold;  // <b>
    procedure EndBold;  // <b>

    procedure BeginScript(const ScriptLanguage: string); // <script language="<ScriptLanguage>"><crlf> <!--
    procedure EndScript; // // --><crlf></script>

    procedure BeginNoScript; // <noscript>
    procedure EndNoScript;    // </noscript>

    procedure BeginPar;   // <p>
    procedure EndPar; // </p>

    procedure BeginLink(const HRef: string; const Target: string);    // <A HREF=".." [TARGET=".."]>
    procedure EndLink;    // </A>

    procedure LineBreak;  // <BR>
    procedure Title(const Title: string); // <TITLE>...</TITLE>

    procedure BeginHeader(HeaderLevel: integer);  // <Hn>
    procedure EndHeader(HeaderLevel: integer);    // </Hn>
published
    property Session: TWapSession read FSession write FSession;
end;

procedure Register;

implementation

constructor THtmlOutput.Create(AOwner: TComponent);
begin
    inherited;
end;

destructor THtmlOutput.Destroy;
begin
    inherited Destroy;
end;

function THtmlOutput.GetValidSession: TWapSession;
begin
    if (FSession = nil) then
        raise exception.create('Not attached to session');
    result := FSession;
end;

procedure   THtmlOutput.write(const s: string);
begin
    system.write(GetValidSession.Response.TextOut, s);
end;

procedure   THtmlOutput.writeln(const s: string);
begin
    system.writeln(GetValidSession.Response.TextOut, s);
end;

procedure   THtmlOutput.BeginTag(const Tag: string);
begin
    write('<' + tag + '>');
end;

procedure   THtmlOutput.EndTag(const Tag: string);
begin
    write('</' + tag + '>');
end;

procedure   THtmlOutput.BeginHtml;  // <html>
begin
    writeln('<HTML>');
end;

procedure   THtmlOutput.EndHtml;    // </html>
begin
    writeln('</HTML>');
end;

procedure   THtmlOutput.BeginHead;  // <head>
begin
    writeln('<HEAD>');
end;

procedure   THtmlOutput.EndHead;    //  </head>
begin
    writeln('</HEAD>');
end;

procedure   THtmlOutput.BeginBody;  // <body>
begin
    writeln('<BODY>');
end;

procedure   THtmlOutput.EndBody;    //  </body>
begin
    writeln('</BODY>');
end;

procedure   THtmlOutput.BeginItalic; // <i>
begin
    write('<I>');
end;

procedure   THtmlOutput.EndItalic; // </i>
begin
    write('</I>');
end;

procedure   THtmlOutput.BeginBold;  // <b>
begin
    write('<B>');
end;

procedure   THtmlOutput.EndBold;  // <b>
begin
    write('</B>');
end;

procedure   THtmlOutput.BeginScript(const ScriptLanguage: string); // <script language="<ScriptLanguage>"> <-- Hide from old browsers
begin
    writeln('<SCRIPT LANGUAGE="' + ScriptLanguage + '">');
    writeln('<!--');
end;

procedure   THtmlOutput.EndScript; // --> </script>
begin
    writeln('// -->');
    writeln('</SCRIPT>');
end;

procedure   THtmlOutput.BeginNoScript; // <noscript>
begin
    writeln('<NOSCRIPT>');
end;

procedure   THtmlOutput.EndNoScript;    // </noscript>
begin
    writeln('</NOSCRIPT>');
end;

procedure   THtmlOutput.BeginPar;   // <p>
begin
    writeln('<P>');
end;

procedure   THtmlOutput.EndPar; // </p>
begin
    writeln('</P>');
end;

procedure   THtmlOutput.BeginLink(const HRef: string; const Target: string);
begin
    write('<A HREF="' + href + '"');
    if (target <> '') then
        write(' TARGET = "' + target + '"');
    write('>');
end;

procedure   THtmlOutput.EndLink;
begin
    write('</A>');
end;

procedure   THtmlOutput.LineBreak;
begin
    writeln('<BR>');
end;

procedure   THtmlOutput.BeginHeader(HeaderLevel: integer);
begin
    write('<H' + intToStr(headerLevel) + '>');
end;

procedure   THtmlOutput.EndHeader(HeaderLevel: integer);
begin
    write('</H' + intToStr(headerLevel) + '>');
end;

procedure THtmlOutput.Title(const Title: string);
begin
    writeln('<TITLE>' + Title + '</TITLE>');
end;

procedure Register;
begin
    RegisterComponents('WebApp', [THtmlOutput]);
end;

end.
