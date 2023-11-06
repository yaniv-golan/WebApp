unit tempInetReg;

interface

procedure Register;

implementation

uses Classes, HTTPApp, DBWeb;

procedure Register;
begin
    RegisterComponents('WebApp', [TPageProducer, TWebDispatcher, TDSTableProducer, TQueryTableProducer, TDataSetTableProducer]);
end;

end.
