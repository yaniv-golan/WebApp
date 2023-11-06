unit D3MasksWrapper;

interface

function Mask_Create(MaskValue: PChar): pointer; stdcall; export;
procedure Mask_Free(Instance: pointer); stdcall; export;
function Mask_Matches(Instance: pointer; Filename: pchar): boolean; stdcall; export;

function MatchesMask(Filename, Mask: pchar): boolean; stdcall; export;

implementation

uses Masks;

function Mask_Create(MaskValue: PChar): pointer;
begin
    result := TMask.Create(string(MaskValue));
end;

procedure Mask_Free(Instance: pointer);
begin
    TMask(Instance).Free;
end;

function Mask_Matches(Instance: pointer; Filename: pchar): boolean;
begin
    result := TMask(Instance).Matches(string(Filename));
end;

function MatchesMask(Filename, Mask: pchar): boolean;
begin
    result := Masks.MatchesMask(string(Filename), string(Mask));
end;



end.
