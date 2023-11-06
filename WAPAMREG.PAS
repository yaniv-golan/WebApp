unit WAPAMREG;

interface

uses Classes, WapASmtp;

procedure Register;

implementation

procedure Register;
begin
    RegisterComponents('WebApp', [TWapSMTP]);
end;


end.
 