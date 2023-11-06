unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, AaWizStd, AaWiz, XFiles, IISCfg, WebSCfg;

type
  TForm1 = class(TForm)
    AAWizard1: TAAWizard;
    SelectServerQuestion: TAAOptionQuestion;
    PWSOptions: TAAOptionQuestion;
    WelcomePrompt: TAAPromptQuestion;
    InstructionsPrompt: TAAPromptQuestion;
    WebSiteOptions: TAAOptionQuestion;
    WebSiteProOptions: TAAOptionQuestion;
    NetscapeOptions: TAAOptionQuestion;
    OtherServerOptions: TAAOptionQuestion;
    TestPrompt: TAAPromptQuestion;
    procedure WebSiteOptionsNext(Sender: TObject);
    procedure SelectServerQuestionNext(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure WebSiteProOptionsNext(Sender: TObject);
    procedure PWSOptionsNext(Sender: TObject);
    procedure NetscapeOptionsNext(Sender: TObject);
    procedure OtherServerOptionsNext(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure WelcomePromptDataLoading(Sender: TObject);
    procedure SelectServerQuestionValidate(Sender: TObject;
      var Continue: Boolean);
  private
    { Private declarations }
    IISConfig: TIISConfig;
    WebSiteConfig: TWebSiteConfig;
    function GetIISScriptsDir: string;
    procedure SetupInstructions(const Stub, Server, Detail: string);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

const CRLF = #13#10;

const
    isapiStub = 'WAPIS.ISA';
    wsapiStub = 'WAPWS.WSA';
    nsapiStub = 'WAPNS.DLL';
    plainCgiStub = 'WAPCGI.EXE';
    netscapeCgiStub = 'NPH-WAP.EXE';
    websiteCgiStub = '$WAPCGI.EXE';
    winCgiStub = 'WAPWCGI.EXE';

    selfTestCommand = '?WapCmd=test';
    verifyInstallTextPrefix =
        'To verify that the WebApp Server Interface ' +
        'is installed and functioning, use your browser to open the following URL :' + CRLF + CRLF;
    verifyInstallURLPrefix = 'http://127.0.0.1/';

function    GetDistribDir: string;
begin
    result := SlashPath(ExtractFilePath(Application.ExeName)) + 'Server';
end;

procedure TForm1.WebSiteOptionsNext(Sender: TObject);
begin
    if (WebSiteOptions.OptionIndex = 1) then begin
        // CGI
        SetupInstructions(
            'Standard CGI',
            'O''reilly WebSite',
            'Copy the WebApp CGI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + websiteCgiStub + CRLF + CRLF +
            'to the WebSite /cgi-bin/ directory, at :' + CRLF + CRLF +
            WebSiteConfig.GetURLMapping('/cgi-bin/', mtStdCGI));
        TestPrompt.PromptDetail := verifyInstallTextPrefix +
            verifyInstallURLPrefix + 'cgi-bin/' + websiteCgiStub + selfTestCommand;
    end else begin
        // WinCGI
        SetupInstructions(
            'Windows CGI',
            'O''reilly WebSite',
            'Copy the WebApp WinCGI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + winCgiStub + CRLF + CRLF +
            'to the WebSite /cgi-win/ directory, at :' + CRLF + CRLF +
            WebSiteConfig.GetURLMapping('/cgi-win/', mtWinCGI));
        TestPrompt.PromptDetail := verifyInstallTextPrefix +
            verifyInstallURLPrefix + 'cgi-win/' + winCgiStub + selfTestCommand;
    end;
end;

procedure  TForm1.SetupInstructions(const Stub, Server, Detail: string);
begin
    InstructionsPrompt.Prompt := 'Installing the WebApp ' + Stub + ' interface on ' + Server;
    InstructionsPrompt.PromptDetail := Detail + '.' + CRLF + CRLF +
        'Click the Next button to test the installation';
end;

function    TForm1.GetIISScriptsDir: string;
var
    Root: TIISVirtualRoot;
begin
    Root := IISConfig.GetVirtualRoot('/SCRIPTS', '');
    Result := Root.PhysicalPath;
end;

procedure TForm1.SelectServerQuestionNext(Sender: TObject);
begin
    if (SelectServerQuestion.OptionIndex = 1) then begin
        // IIS
        SetupInstructions(
            'ISAPI',
            'Microsoft Internet Information Server',
            'Copy the WebApp ISAPI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + isapiStub + CRLF + CRLF +
            'to the IIS /scripts directory, at :' + CRLF + CRLF +
            GetIISScriptsDir);
        TestPrompt.PromptDetail := verifyInstallTextPrefix +
            verifyInstallURLPrefix + 'scripts/' + isapiStub + selfTestCommand;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    IISConfig := TIISConfig.Create(nil);
    WebSiteConfig := TWebSiteConfig.Create(nil);
    Release;    // We don't want to see the form...
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
    aawizard1.run; // our chance to run the wizard
    WebSiteConfig.Free;
    IISConfig.Free;
    Close;
end;

procedure TForm1.WebSiteProOptionsNext(Sender: TObject);
begin
    if (WebSiteProOptions.OptionIndex = 1) then begin
        // WSAPI
        SetupInstructions(
            'WSAPI',
            'O''reilly WebSite Pro',
            'Copy the WebApp WSAPI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + wsapiStub + CRLF + CRLF +
            'to the WebSite / (root) directory, at :' + CRLF + CRLF +
            WebSiteConfig.GetURLMapping('/', mtDocuments));
        TestPrompt.PromptDetail := verifyInstallTextPrefix +
            verifyInstallURLPrefix + '' + wsapiStub + selfTestCommand;
    end else if (WebSiteProOptions.OptionIndex = 2) then begin
        // ISAPI
        SetupInstructions(
            'Standard CGI',
            'O''reilly WebSite Pro',
            'Copy the WebApp ISAPI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + isapiStub + CRLF + CRLF +
            'to the WebSite /cgi-bin/ directory, at :' + CRLF + CRLF +
            WebSiteConfig.GetURLMapping('/cgi-bin/', mtStdCGI));
        TestPrompt.PromptDetail := verifyInstallTextPrefix +
            verifyInstallURLPrefix + 'cgi-bin/' + isapiStub + selfTestCommand;
    end else if (WebSiteProOptions.OptionIndex = 3) then begin
        // CGI
        SetupInstructions(
            'Standard CGI',
            'O''reilly WebSite Pro',
            'Copy the WebApp CGI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + websiteCgiStub + CRLF + CRLF +
            'to the WebSite /cgi-bin/ directory, at :' + CRLF + CRLF +
            WebSiteConfig.GetURLMapping('/cgi-bin/', mtStdCGI));
        TestPrompt.PromptDetail := verifyInstallTextPrefix +
            verifyInstallURLPrefix + 'cgi-bin/' + websiteCgiStub + selfTestCommand;
    end else begin
        // WinCGI
        SetupInstructions(
            'Windows CGI',
            'O''reilly WebSite Pro',
            'Copy the WebApp WinCGI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + wincgiStub + CRLF + CRLF +
            'to the WebSite /cgi-win/ directory, at :' + CRLF + CRLF +
            WebSiteConfig.GetURLMapping('/cgi-win/', mtWinCGI));
        TestPrompt.PromptDetail := verifyInstallTextPrefix +
            verifyInstallURLPrefix + 'cgi-win/' + wincgiStub + selfTestCommand;
    end;
end;

procedure TForm1.PWSOptionsNext(Sender: TObject);
begin
    if (PWSOptions.OptionIndex = 1) then begin
        // ISAPI
        SetupInstructions(
            'ISAPI',
            'Microsoft Personal Web Server',
            'Copy the WebApp ISAPI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + isapiStub + CRLF + CRLF +
            'to the PWS /scripts directory, at :' + CRLF + CRLF +
            GetIISScriptsDir);
        TestPrompt.PromptDetail := verifyInstallTextPrefix +
            verifyInstallURLPrefix + 'scripts/' + isapiStub + selfTestCommand;
    end else begin
        // CGI
        SetupInstructions(
            'Standard CGI',
            'Microsoft Personal Web Server',
            'Copy the WebApp CGI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + plainCgiStub + CRLF + CRLF +
            'to the PWS /scripts directory, at :' + CRLF + CRLF +
            GetIISScriptsDir);
        TestPrompt.PromptDetail := verifyInstallTextPrefix +
            verifyInstallURLPrefix + 'scripts/' + plainCgiStub + selfTestCommand;
    end;
end;

procedure TForm1.NetscapeOptionsNext(Sender: TObject);
begin
    if (NetscapeOptions.OptionIndex = 1) then begin
        // NSAPI
        SetupInstructions(
            'NSAPI',
            'Netscape Server',
            'The NSAPI interface is not distributed with the beta version. ' +
            'please contact Yaniv Golan, ygolan@hyperact.com, to receive the file.');
    end else if (NetscapeOptions.OptionIndex = 2) then begin
        // CGI
        SetupInstructions(
            'Standard CGI',
            'Netscape Server',
            'Copy the WebApp CGI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + plainCgiStub + CRLF + CRLF +
            'to one of the Netscape CGI directories.');
        TestPrompt.PromptDetail := verifyInstallTextPrefix +
            verifyInstallURLPrefix + 'cgi-directory/' + plainCgiStub + selfTestCommand +
            ', where cgi-directory is the directory you copied ' + plainCgiStub + ' to.';
    end else begin
        // Win-CGI
        SetupInstructions(
            'Windows CGI',
            'Netscape Server',
            'Copy the WebApp WinCGI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + winCgiStub + CRLF + CRLF +
            'to one of the Netscape WinCGI directories');
        TestPrompt.PromptDetail := verifyInstallTextPrefix +
            verifyInstallURLPrefix + 'wincgi-directory/' + plainCgiStub + selfTestCommand +
            ', where wincgi-directory is the directory you copied ' + winCgiStub + ' to.';
    end;
end;

procedure TForm1.OtherServerOptionsNext(Sender: TObject);
begin
    if (OtherServerOptions.OptionIndex = 1) then begin
        // CGI
        SetupInstructions(
            'Standard CGI',
            'Unlisted Server',
            'If your server supports Standard CGI programs, copy the WebApp CGI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + plainCgiStub + CRLF + CRLF +
            'to the proper directory for Standard CGI programs. ' + CRLF +
            'If you are not sure which directory is that, consult your server documentation.');
    end else if (OtherServerOptions.OptionIndex = 2) then begin
        // WINCGI
        SetupInstructions(
            'Windows CGI',
            'Unlisted Server',
            'If your server supports Windows CGI (WinCGI) programs, copy the WebApp WinCGI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + winCgiStub + CRLF + CRLF +
            'to the proper directory for Windows CGI programs. ' + CRLF +
            'If you are not sure which directory is that, consult your server documentation.');
    end else if (OtherServerOptions.OptionIndex = 3) then begin
        // ISAPI
        SetupInstructions(
            'ISAPI',
            'Unlisted Server',
            'If your server supports ISAPI Extension DLLs, copy the WebApp ISAPI Stub, ' + CRLF + CRLF +
            GetDistribDir + '\' + isapiStub + CRLF + CRLF +
            'to the proper directory for ISAPI DLLs. ' + CRLF +
            'If you are not sure which directory is that, consult your server documentation.');
    end else if (OtherServerOptions.OptionIndex = 4) then begin
        // NSAPI
        SetupInstructions(
            'NSAPI',
            'Unlisted Server',
            'The NSAPI interface is not distributed with the beta version. ' +
            'please contact Yaniv Golan, ygolan@hyperact.com, to receive the file.');
    end else begin
        // WSAPI
        SetupInstructions(
            'WSAPI',
            'Unlisted Server',
            'The WSAPI interface is not distributed with the beta version. ' +
            'please contact Yaniv Golan, ygolan@hyperact.com, to receive the file.');
    end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
    PostMessage(Handle, wm_showWindow, 0, 0);
end;

procedure TForm1.WelcomePromptDataLoading(Sender: TObject);
begin
    WelcomePrompt.PromptDetail :=
        'The WebApp Server Interface Installation Assistant will help you ' +
        'figure out which files you need to install on your Web server, ' +
        'and what are the configuration changes you need to make.' + CRLF + CRLF +
        'Before using the Assistant, make sure you review the "Installing the WebApp Server Runtime files" ' +
        'section in the WebApp documentation!';
end;

procedure TForm1.SelectServerQuestionValidate(Sender: TObject;
  var Continue: Boolean);
begin
    Continue := true;
    if (SelectServerQuestion.OptionIndex = 1) then begin
        // IIS
        if (not IISConfig.Installed) then begin
            Continue := (MessageDlg('Microsoft Internet Information Server is not installed. Continue ?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes);
        end;
    end else if (SelectServerQuestion.OptionIndex = 2) then begin
        // PWS
        if (not IISConfig.Installed) then begin
            Continue := (MessageDlg('Microsoft Personal Web Server is not installed. Continue ?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes);
        end;
    end else if (SelectServerQuestion.OptionIndex = 3) then begin
        // WebSite
        if (not WebSiteConfig.Installed) then begin
            Continue := (MessageDlg('O''reilly WebSite is not installed. Continue ?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes);
        end;
    end else if (SelectServerQuestion.OptionIndex = 4) then begin
        // WebSite Pro
        if (not WebSiteConfig.Installed) then begin
            Continue := (MessageDlg('O''reilly WebSite is not installed. Continue ?',
                mtConfirmation, [mbYes, mbNo], 0) = mrYes);
        end;
    end else if (SelectServerQuestion.OptionIndex = 5) then begin
        // Netscape Server
    end;
end;

end.
