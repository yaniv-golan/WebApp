/////////////////////////////////////////////////////////////////////////////
//
// TBrowserType
// Version 1.3
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
// See BROWSCAP.HTM for documentation.
//
// TBrowserType is part of HyperAct's WebApp Framework.
//
// BrowsCap.pas may be freely used and distributed, as long as it is not
// modified in any way and all comments are preserved.
//
// Release History
// 1.3 Updated to handle masks with more than one asterik
// 1.2 Delphi 3 Compatibility
//     Removed security API calls
// 1.1 Updated documentation
//     Values is now the default array property
// 1.0 Initial Release
//
/////////////////////////////////////////////////////////////////////////////
unit BrowsCap;

interface

uses Classes, SysUtils;

type

TBrowserType = class(TComponent)
private
    FValues: TStringList;
    FBrowserCap: string;
    FUserAgent: string;
    procedure   ReadUserAgentInfo;
    procedure   SetBrowserCap(const Value: string);
    procedure   SetUserAgent(const Value: string);
    function    GetCount: integer;
    function    GetKey(Index: integer): string;
    function    GetValue(const Index: variant): variant;
    function    GetBrowser: string;
    function    GetVersion: string;
    function    GetMajorVer: integer;
    function    GetMinorVer: integer;
    function    GetFrames: boolean;
    function    GetTables: boolean;
    function    GetCookies: boolean;
    function    GetBackgroundSounds: boolean;
    function    GetVBScript: boolean;
    function    GetJavaScript: boolean;
    function    GetJavaApplets: boolean;
    function    GetPlatform: string;
    function    GetActiveXControls: boolean;
    function    GetBeta: boolean;
public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    property    BrowserCap: string read FBrowserCap write SetBrowserCap;
    property    UserAgent: string read FUserAgent write SetUserAgent;

    property    Browser: string read GetBrowser;
    property    Version: string read GetVersion;
    property    MajorVer: integer read GetMajorVer;
    property    MinorVer: integer read GetMinorVer;
    property    Frames: boolean read GetFrames;
    property    Tables: boolean read GetTables;
    property    Cookies: boolean read GetCookies;
    property    BackgroundSounds: boolean read GetBackgroundSounds;
    property    VBScript: boolean read GetVBScript;
    property    JavaScript: boolean read GetJavaScript;
    property    JavaApplets: boolean read GetJavaApplets;
    property    Platform: string read GetPlatform;
    property    ActiveXControls: boolean read GetActiveXControls;
    property    Beta: boolean read GetBeta;

    property    Count: integer read GetCount;
    property    Keys[Index: integer]: string read GetKey;
    property    Values[const Index: variant]: variant read GetValue; default;
end;

procedure   Register;

implementation

uses Windows, IniFiles;

constructor TBrowserType.Create(AOwner: TComponent);
begin
    inherited create(AOwner);
    FValues := TStringList.create;
    SetBrowserCap('BROWSCAP.INI');
end;

destructor  TBrowserType.Destroy;
begin
    FValues.free;
    inherited destroy;
end;

var IniLock: TRTLCriticalSection;

// Replaces TIniFile.ReadSections, whose buffer is too small.
procedure MyReadSections(const IniFilename: string; Strings: TStrings);
const
  BufSize = 32768;
var
  Buffer, P: PChar;
begin
  GetMem(Buffer, BufSize);
  try
    Strings.BeginUpdate;
    try
      Strings.Clear;
      if GetPrivateProfileString(nil, nil, '', Buffer, BufSize,
        PChar(IniFilename)) <> 0 then
      begin
        P := Buffer;
        while P^ <> #0 do
        begin
          Strings.Add(P);
          Inc(P, StrLen(P) + 1);
        end;
      end;
    finally
      Strings.EndUpdate;
    end;
  finally
    FreeMem(Buffer, BufSize);
  end;
end;

procedure   TBrowserType.ReadUserAgentInfo;
var
    ini: TIniFile;

    procedure ParseWildcard(const Wildcard: string; Parts: TStringList);
    var
        p: integer;
        s: string;
    begin
        s := Wildcard;
        repeat
            p := pos('*', s);
            if (p = 0) then begin
                Parts.Add(Trim(s));
                s := '';
            end else begin
                Parts.Add(Trim(copy(s, 1, p - 1)));
                s := Copy(s, p + 1, maxInt);
            end;
        until (s = '');
    end;

    function    MatchWithWildcard(const Wildcard: string): boolean;
    var
        Parts: TStringList;
        s: string;
        i: integer;
        PartLen: integer;
        NextPartStart: integer;
    begin
        result := false;
        Parts := TStringList.Create;
        try
            ParseWildcard(Wildcard, Parts);
            s := FUserAgent;
            for i := 0 to (Parts.count - 1) do begin
                PartLen := Length(Parts[i]);
                if ((PartLen > 0) and (Trim(Copy(s, 1, PartLen)) <> Parts[i])) then
                    exit;
                s := Copy(s, PartLen + 1, maxInt);
                if (i < Parts.Count - 1) then begin
                    NextPartStart := Pos(Parts[i + 1], s);
                    if (NextPartStart = 0) then
                        exit;
                    s := Copy(s, NextPartStart, maxInt);
                end;
            end;
            result := true;
        finally
            Parts.Free;
        end;
    end;

    function    DetermineSection: string;
    const
        DefaultBrowserSection = 'Default Browser Capability Settings';
    var
        Sections: TStringList;
        i: integer;
    begin
        Sections := TStringList.create;
        try
            MyReadSections(FBrowserCap, Sections);
            // try for exact match
            if (Sections.IndexOf(FUserAgent) <> -1) then begin
                result := FUserAgent;
                exit;
            end;
            // search using wildcards
            for i := 0 to (Sections.count - 1) do begin
                if (pos('*', Sections[i]) > 0) then begin
                    if MatchWithWildcard(Sections[i]) then begin
                        result := Sections[i];
                        exit;
                    end;
                end;
            end;
            // no match found - look for default browser
            if (Sections.IndexOf(DefaultBrowserSection) <> -1) then begin
                result := DefaultBrowserSection;
                exit;
            end;
            // admit failure
            result := '';
        finally
            Sections.free;
        end;
    end;

    procedure   readSection(const section: string);
    var
        parentSection: string;
        sectionValues: TStringList;
        i: integer;
        key: string;
    begin
        parentSection := ini.readString(section, 'parent', '');
        if ((parentSection <> '') and (parentSection <> section)) then
            readSection(parentSection);
        sectionValues := TStringList.create;
        try
            ini.readSectionValues(section, sectionValues);
            for i := 0 to (sectionValues.count - 1) do begin
                key := sectionValues.names[i];
                FValues.values[key] := sectionValues.values[key];
            end;
        finally
            sectionValues.free;
        end;
    end;

var
    section: string;
begin
    FValues.clear;
    if (FUserAgent = '') then
        exit;

    ini := TIniFile.create(FBrowserCap);
    try
        EnterCriticalSection(IniLock);
        try
            section := DetermineSection;
            if (section <> '') then
                readSection(section);
        finally
            LeaveCriticalSection(IniLock);
        end;
    finally
        ini.free;
    end;
end;

procedure   TBrowserType.SetBrowserCap(const Value: string);
begin
    if (value <> FBrowserCap) then begin
        FBrowserCap := value;
        if (FUserAgent <> '') then
            ReadUserAgentInfo;
    end;
end;

procedure   TBrowserType.SetUserAgent(const Value: string);
begin
    if (value <> FUserAgent) then begin
        FUserAgent := value;
        ReadUserAgentInfo;
    end;
end;

function    TBrowserType.GetCount: integer;
begin
    result := FValues.count;
end;

type TVarKind = (vkStr, vkInt);

function    getVarKind(const v: variant): TVarKind;
const
    varIntKindMask = varSmallint or varInteger or varByte;
    varStrKindMask = varOleStr or varString;
begin
    if ((varType(v) and varTypeMask and varIntKindMask) <> 0) then
        result := vkInt
    else if ((varType(v) and varTypeMask and varStrKindMask) <> 0) then
        result := vkStr
    else
        raise exception.create('Expecting an integer or a string');
end;

function    browsCapStrToVar(const s: string): variant;
begin
    if (s = '') then
        result := ''
    else if (s[1] = '#') then begin
        try
            result := strToInt(copy(s, 2, maxInt));
        except
            on EConvertError do
                result := s;
        end;
    end else if (compareText(s, 'true') = 0) then
        result := true
    else  if (compareText(s, 'false') = 0) then
        result := false
    else
        result := s;
end;

function    TBrowserType.GetValue(const Index: variant): variant;
var
    key: string;
begin
    case getVarKind(index) of
        vkInt: key := getKey(index);
        vkStr: key := string(index);
    end;
    if (FValues.IndexOfName(key) = -1) then
        result := null
    else
        result := browsCapStrToVar(FValues.values[key]);
end;

function    TBrowserType.GetKey(Index: integer): string;
begin
    result := FValues.Names[index];
end;

function    TBrowserType.GetBrowser: string;
begin
    result := VarToStr(values['Browser']);
end;

function    TBrowserType.GetVersion: string;
begin
    result := VarToStr(values['Version']);
end;

function    SafeVarToInt(const v: variant): integer;
begin
    if VarIsNull(v) then
        result := 0
    else
        result := integer(v);
end;

function    SafeVarToBoolean(const v: variant): boolean;
begin
    if VarIsNull(v) then
        result := false
    else
        result := boolean(v);
end;

function    TBrowserType.GetMajorVer: integer;
begin
    result := SafeVarToInt(values['MajorVer']);
end;

function    TBrowserType.GetMinorVer: integer;
begin
    result := SafeVarToInt(values['MinorVer']);
end;

function    TBrowserType.GetFrames: boolean;
begin
    result := SafeVarToBoolean(values['Frames']);
end;

function    TBrowserType.GetTables: boolean;
begin
    result := SafeVarToBoolean(values['Tables']);
end;

function    TBrowserType.GetCookies: boolean;
begin
    result := SafeVarToBoolean(values['Cookies']);
end;

function    TBrowserType.GetBackgroundSounds: boolean;
begin
    result := SafeVarToBoolean(values['BackgroundSounds']);
end;

function    TBrowserType.GetVBScript: boolean;
begin
    result := SafeVarToBoolean(values['VBScript']);
end;

function    TBrowserType.GetJavaScript: boolean;
begin
    result := SafeVarToBoolean(values['JavaScript']);
end;

function    TBrowserType.GetJavaApplets: boolean;
begin
    result := SafeVarToBoolean(values['JavaApplets']);
end;

function    TBrowserType.GetPlatform: string;
begin
    result := VarToStr(values['Platform']);
end;

function    TBrowserType.GetActiveXControls: boolean;
begin
    result := SafeVarToBoolean(values['ActiveXControls']);
end;

function    TBrowserType.GetBeta: boolean;
begin
    result := SafeVarToBoolean(values['Beta']);
end;

procedure   Register;
begin
    RegisterComponents('WebApp', [TBrowserType]);
end;

initialization
begin
    InitializeCriticalSection(IniLock);
end;

finalization
begin
    try
        DeleteCriticalSection(IniLock);
    except
        ;
    end;
end;

end.
