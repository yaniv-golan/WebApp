//---------------------------------------------------------------------------
#include <vcl.h>
#pragma hdrstop
USERES("Project1.res");
USEFORM("Unit1.cpp", Form1);
USEUNIT("WScrImp.pas");
USEUNIT("AppSSI.pas");
USEUNIT("BrowsCap.pas");
USEUNIT("DBHtml.pas");
USEUNIT("DBWap.pas");
USEUNIT("HAWRIntf.pas");
USEUNIT("HtmlTxt.pas");
USEUNIT("HttpReq.pas");
USEUNIT("HWebApp.pas");
USEUNIT("IpcConv.pas");
USEUNIT("IpcRqst.pas");
USEUNIT("ScrHtLex.pas");
USEUNIT("ScrHtPrc.pas");
USEFORMNS("WapAcPEd.pas", Wapacped, WapActionsEditorForm);
USEUNIT("WapActns.pas");
USEUNIT("WapCom.pas");
USEUNIT("WapCSrv.pas");
USEUNIT("WapGIF.pas");
USEUNIT("WapMask.pas");
USEUNIT("WapRTTI.pas");
USEUNIT("WapSchdl.pas");
USEUNIT("WapThNtf.pas");
USEUNIT("WapTmplt.pas");
USEUNIT("WapTXRdr.pas");
USEUNIT("WapWThrd.pas");
USEUNIT("Wcp.pas");
USEUNIT("WIPCShrd.pas");
USEUNIT("WScr_TLB.pas");
USEUNIT("AdRotate.pas");
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
    try
    {
        Application->Initialize();
        Application->CreateForm(__classid(TForm1), &Form1);
        Application->CreateForm(__classid(TWapActionsEditorForm), &WapActionsEditorForm);
        Application->Run();
    }
    catch (Exception &exception)
    {
        Application->ShowException(&exception);
    }
    return 0;
}
//---------------------------------------------------------------------------
