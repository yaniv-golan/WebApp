unit NTSrvCmp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TNTServiceCompatibility = class(TComponent)
  private
    { Private declarations }
  protected
    { Protected declarations }
    procedure 
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('WebApp', [TNTServiceCompatibility]);
end;

end.
