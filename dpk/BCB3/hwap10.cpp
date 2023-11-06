//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("hwap10.res");
USERES("..\..\hwebapp.dcr");
USERES("..\..\waptmplt.dcr");
USERES("..\..\wscr_tlb.dcr");
USERES("..\..\htmltxt.dcr");
USERES("..\..\browscap.dcr");
USERES("..\..\adrotate.dcr");
USEPACKAGE("vcl35.bpi");
USEUNIT("..\..\hwebapp.pas");
USEUNIT("..\..\waptmplt.pas");
USEUNIT("..\..\wscrimp.pas");
USEUNIT("..\..\wapcsrv.pas");
USEUNIT("..\..\wscr_tlb.pas");
USEUNIT("..\..\htmltxt.pas");
USEUNIT("..\..\scrhtprc.pas");
USEUNIT("..\..\..\misc\axshost.pas");
USEUNIT("..\..\..\misc\activscp.pas");
USEUNIT("..\..\hawrintf.pas");
USEUNIT("..\..\appssi.pas");
USEUNIT("..\..\..\misc\wrdstrms.pas");
USEUNIT("..\..\..\misc\timeutil.pas");
USEUNIT("..\..\..\misc\base64.pas");
USEUNIT("..\..\..\misc\virttext.pas");
USEUNIT("..\..\..\misc\cookutil.pas");
USEUNIT("..\..\..\misc\inetstr.pas");
USEUNIT("..\..\browscap.pas");
USEUNIT("..\..\..\misc\sds.pas");
USEUNIT("..\..\ipcrqst.pas");
USEUNIT("..\..\..\misc\ipc.pas");
USEUNIT("..\..\httpreq.pas");
USEUNIT("..\..\..\misc\d3sysutl.pas");
USEUNIT("..\..\wvardict.pas");
USEUNIT("..\..\wipcshrd.pas");
USEUNIT("..\..\adrotate.pas");
USEUNIT("..\..\..\misc\xstrings.pas");
USEUNIT("..\..\waptxrdr.pas");
USEUNIT("..\..\wapschdl.pas");
USEUNIT("..\..\wapwthrd.pas");
USEUNIT("..\..\wapactns.pas");
USEUNIT("..\..\wapmask.pas");
USEUNIT("..\..\WapRTTI.pas");
USEUNIT("..\..\..\misc\MthdsLst.pas");
USEUNIT("..\..\wapthntf.pas");
USEUNIT("..\..\wcp.pas");
USEUNIT("..\..\..\misc\comcat.pas");
USEUNIT("..\..\IpcConv.pas");
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
