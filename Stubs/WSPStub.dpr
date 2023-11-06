library WSPStub;

uses DynWSAPI, WapDIntf;

function Process(tp : PTCTX) : Boolean; export; cdecl;
begin
    result := WsapiProcess(tp);
end;

exports
    Process;

{$E wsa}

begin
    if (not WsapiInit) then
        ExitCode := 1;
end.
