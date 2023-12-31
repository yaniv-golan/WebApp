////////////////////////////////////////////////////////////////////////////
//
// WebApp checkpoint debugging utility
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////
unit wcp;

interface

{$include WCP.INC}

procedure cp(IndentDelta: integer; const S: string);

implementation

{$ifdef CP_ON}
uses Classes, SysUtils, Windows, IPC;

var
    Initialized: boolean = false;
    Lock: TWin32CriticalSection = nil;
    OutFile: textFile;
    Filename: string = '';

threadvar
    Indent: integer;

function GetTimeStamp: string;

    function Pad(const S: string; Len: integer): string;
    begin
        result := s;
        while (Length(result) < Len) do
            result := '0' + result;
    end;

var
    Hour, Min, Sec, MSec: word;
begin
    DecodeTime(Now, Hour, Min, Sec, MSec);
    result := Pad(IntToStr(Min), 2) + ':' + Pad(IntToStr(Sec), 2) + '.' + Pad(IntToStr(MSec), 3);
end;

procedure cp(IndentDelta: integer; const S: string);
begin
    Lock.Enter;
    try
        try
            if (not Initialized) then begin
                try
                    // Create the file
                    Filename := ExtractFilePath(ParamStr(0)) + ChangeFileExt(ExtractFilename(ParamStr(0)), '.DBG');
                    AssignFile(OutFile, Filename);
                    Rewrite(OutFile);
                    CloseFile(OutFile);
                    Initialized:= true;
                except
                    Initialized := false;
                    raise;
                end;
            end;

            Append(OutFile);
            try
                if (IndentDelta < 0) then
                    Inc(indent, indentDelta);
                writeln(OutFile,
                    IntToHex(GetCurrentThreadId, 8) + ' ' + GetTimeStamp + ' : ' + StringOfChar(' ', 2 * Indent) + s);
                if (IndentDelta > 0) then
                    inc(Indent, IndentDelta);
                flush(OutFile);
            finally
                CloseFile(OutFile);
            end;
        except
            // do nothing, the log attempt is lost
        end;
    finally
        Lock.leave;
    end;
end;

initialization
begin
    Lock := TWin32CriticalSection.Create;
end;

finalization
begin
    try
        Lock.Free;
    except
        // do nothing, ignore exception on termination
    end;
end;

{$else}

procedure cp(IndentDelta: integer; const S: string);
asm;
end;

{$endif CP_ON}


end.
