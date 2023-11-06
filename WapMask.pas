unit WapMask;

interface

{$I WapDef.INC}

{$ifdef wap_cbuilder}
    {$ObjExportAll On}
{$endif wap_cbuilder}

uses HAWRIntf;

type

TWapMask = class
private
    FInstance: pointer;
public
    constructor Create(const MaskValue: string);
    destructor Destroy; override;
    function Matches(const Filename: string): Boolean;
end;

function MatchesMask(const Filename, Mask: string): Boolean;

implementation

constructor TWapMask.Create(const MaskValue: string);
begin
    inherited Create;
    FInstance := Mask_Create(PChar(MaskValue));
end;

destructor TWapMask.Destroy;
begin
    Mask_Free(FInstance);
    inherited;
end;

function TWapMask.Matches(const Filename: string): Boolean;
begin
    result := Mask_Matches(FInstance, PChar(Filename));
end;

function MatchesMask(const Filename, Mask: string): Boolean;
begin
    result := HAWRIntf.MatchesMask(PChar(Filename), PChar(Mask));
end;

end.
