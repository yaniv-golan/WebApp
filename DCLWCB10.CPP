//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("DCLWCB10.res");
USEPACKAGE("vcl35.bpi");
USEPACKAGE("vcldb35.bpi");
USEPACKAGE("dcldb35.bpi");
USEPACKAGE("HWCB10.bpi");
USEUNIT("wapreg.pas");
USEUNIT("..\misc\ComCat.pas");
USEUNIT("..\misc\ActivScp.pas");
//---------------------------------------------------------------------------
#pragma package(smart_init)
//---------------------------------------------------------------------------
//   Package source.
//---------------------------------------------------------------------------
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
    return 1;
}
//---------------------------------------------------------------------------
