//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USEPACKAGE("vcl35.bpi");
USERES("HWCB10.res");
USERES("hwebapp.dcr");
USERES("waptmplt.dcr");
USERES("wscr_tlb.dcr");
USERES("htmltxt.dcr");
USERES("browscap.dcr");
USERES("adrotate.dcr");
USEUNIT("hwebapp");
USEUNIT("waptmplt");
USEUNIT("wscrimp");
USEUNIT("wapcsrv");
USEUNIT("wscr_tlb");
USEUNIT("htmltxt");
USEUNIT("scrhtprc");
USEUNIT("..\misc\axshost");
USEUNIT("..\misc\activscp");
USEUNIT("hawrintf");
USEUNIT("appssi");
USEUNIT("..\misc\wrdstrms");
USEUNIT("..\misc\timeutil");
USEUNIT("..\misc\base64");
USEUNIT("..\misc\virttext");
USEUNIT("..\misc\cookutil");
USEUNIT("..\misc\inetstr");
USEUNIT("browscap");
USEUNIT("..\misc\sds");
USEUNIT("ipcrqst");
USEUNIT("..\misc\ipc");
USEUNIT("httpreq");
USEUNIT("..\misc\d3sysutl");
USEUNIT("wvardict");
USEUNIT("wipcshrd");
USEUNIT("adrotate");
USEUNIT("..\misc\xstrings");
USEUNIT("waptxrdr");
USEUNIT("wapschdl");
USEUNIT("wapwthrd");
USEUNIT("wapactns");
USEUNIT("wapmask");
USEUNIT("WapRTTI");
USEUNIT("..\misc\MthdsLst");
USEUNIT("wapthntf");
USEUNIT("wcp");
USEUNIT("IpcConv");

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
