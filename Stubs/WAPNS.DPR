library WAPNS;

uses
    WapDIntf, DynNSAPI;


function init_webapp(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
begin
    result := NsapiInit(pb, sn, rq);
end;

function service_webapp(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
begin
    result := NsapiService(pb, sn, rq);
end;

function pathcheck_webapp(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
begin
    result := NsapiPathCheck(pb, sn, rq);
end;

function log_webapp(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
begin
    result := NsapiLog(pb, sn, rq);
end;

function nametrans_webapp(pb: PPblock; sn: PSession; rq: Prequest): Integer; cdecl; export;
begin
    result := NsapiNameTrans(pb, sn, rq);
end;

exports
    init_webapp,
    service_webapp,
    pathcheck_webapp,
    log_webapp,
    nametrans_webapp
    ;


begin
end.
