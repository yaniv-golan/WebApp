unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  HWebApp, AppSSI, HtmlTxt, WapActns, WapTmplt;

type
  TSessionModule = class(TDataModule)
    WapSession1: TWapSession;
    DynamicForm: TWapAction;
    TemplateForm: TWapTemplate;
    NameText: THTMLText;
    GenderRadioGroup: THTMLRadioGroup;
    MailingListCheckbox: THTMLCheckbox;
    FavColorSelect: THTMLSelect;
    SubmitButton: THTMLButton;
    HTMLForm1: THTMLForm;
    Intro: TWapTemplate;
    procedure DynamicFormExecute(Sender: TObject;
      Request: THttpRequest; Response: THttpResponse; const Verb,
      Value: String; Params: TVariantList; var Handled: Boolean);
    procedure HTMLForm1AfterSubmit(Sender: TObject; Request: THttpRequest;
      Response: THttpResponse; const Value: String;
      Params: TVariantList);
  private
    { Private declarations }
    function GetRequest: THttpRequest;
    function GetResponse: THttpResponse;
  public
    { Public declarations }
    property Request: THttpRequest read GetRequest;
    property Response: THttpResponse read GetResponse;
  end;

var
  SessionModule: TSessionModule;

implementation

{$R *.DFM}

uses Base64;

function TSessionModule.GetRequest: THttpRequest;
begin
  Result := WapSession1.Request;
end;

function TSessionModule.GetResponse: THttpResponse;
begin
  Result := WapSession1.response;
end;

procedure TSessionModule.DynamicFormExecute(Sender: TObject;
  Request: THttpRequest; Response: THttpResponse; const Verb,
  Value: String; Params: TVariantList; var Handled: Boolean);
var
  FormHandlerName: string;
begin
  // Determine the form handler action name :
  FormHandlerName := WapSession1.Actions.GetActionName(HTMLForm1);
  
  // Generate the form dynamically :
  with Response do
  begin
    // Make sure the Form's Action points back to us :
    Writeln(TextOut, FormBegin(FormHandlerName, '', Request.ScriptName, '', ''));
    // This hidden field will cause our form handler action to be called when the
    // user submits the form
    Writeln(TextOut, '<INPUT NAME="' + FormHandlerName + '.Submit" TYPE="HIDDEN">');
    Writeln(TextOut, Par('Please fill the following form and click the Send button :'));
    Writeln(TextOut, Par('Your name : ' + NameText.AsHTML));
    Writeln(TextOut, Par('<TABLE><TR>' +
          '<TD VALIGN="TOP">Your gender :</TD>' +
          '<TD VALIGN="TOP">' + GenderRadioGroup.AsHTML + '</TD>' +
          '</TR></TABLE>'));
    Writeln(TextOut, Par('Your favorite color : ' + FavColorSelect.AsHTML));
    Writeln(TextOut, Par(MailingListCheckbox.AsHTML + 'Join our mailing list'));
    Writeln(TextOut, Par(SubmitButton.AsHTML));
    Writeln(TextOut, FormEnd);
  end;
end;


procedure TSessionModule.HTMLForm1AfterSubmit(Sender: TObject;
  Request: THttpRequest; Response: THttpResponse; const Value: String;
  Params: TVariantList);
begin
  // Report the submitted values
  with Response do
  begin
    Writeln(TextOut, '<BODY BGCOLOR="', ColorToHTMLColor(clWhite) + '">');

    Writeln(TextOut, Par('The following values were submitted :'));

    Writeln(TextOut, Par('Name : ' + NameText.Text));

    Write(TextOut, '<P>Gender : ');
    if (GenderRadioGroup.ItemIndex = -1) then
      Writeln(TextOut, 'Not specified')
    else
      Writeln(TextOut, GenderRadioGroup.Items[GenderRadioGroup.ItemIndex]);

    Write(TextOut, '<P>Favorite Color : ');
    if (FavColorSelect.ItemIndex = -1) then
      Writeln(TextOut, 'Not specified')
    else
      Writeln(TextOut, FavColorSelect.Items[FavColorSelect.ItemIndex]);

    Write(TextOut, '<P>Join mailing list : ');
    if MailingListCheckbox.Checked then
      Writeln(TextOut, 'Yes')
    else
      Writeln(TextOut, 'No');

    Write(TextOut, Par('If you visit the form''s page again, you will notice that ' +
        'the form fields contain now the values you have submitted. This is because these ' +
        'values are retained in the HTML controls.'));

    Writeln(TextOut, '</BODY>');
  end;
end;

end.
