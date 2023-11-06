/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////
unit AppSSI;

interface

uses
  Classes, SysUtils, VirtText, CookUtil, BrowsCap, SDS, HttpReq,
  Windows, Graphics;

type

THttpRequest = class;
THttpResponse = class;
THttpTransaction = class;
TRequestVariable = class;
TRequestVariables = class;
TRequestCookie = class;
TRequestCookies = class;

{:  Known HTTP request methods.
  Used in <see property=THttpRequest.MethodType> }
THttpMethodType = (
  mtGet,
  mtPut,
  mtPost,
  mtHead,
  mtAny
);

{: The THttpTransaction is used internally to bind the Request and Response objects
which are associated with a single HTTP transaction.}
THttpTransaction = class
private
    FRequestInterface: TAbstractHttpRequestInterface;
    FOwnRequestInterface: boolean;
    FRequest: THttpRequest;
    FResponse: THttpResponse;
public
    {: The constructor takes a reference to the internal RequestInterface object, and a flag
    which indicates if the RequestInterface object should be freed when the object is destroyed.}
    constructor Create(RequestInterface: TAbstractHttpRequestInterface; OwnRequestInterface: boolean);
    {: A standard desteructor }
    destructor Destroy; override;
    {: RawHttpRequest is the internal low level interface to the Web server. }
    property RawHttpRequest: TAbstractHttpRequestInterface read FRequestInterface;
    {: Request is the HTTP request object associated with this transaction }
    property Request: THttpRequest read FRequest;
    {: Response is the HTTP request object associated with this transaction }
    property Response: THttpResponse read FResponse;
end;

{: The THttpRequest object represents a request from the client
  to the browser. }
THttpRequest = class
private
    FHttpInterface: TAbstractHttpRequestInterface;

    FInputStream: TStream;

    // cached values
    FLogicalPath: string;
    FPhysicalPath: string;
    FMethod: string;
    FMethodType: THttpMethodType;
    FContentType: string;

    FCachedLiteralName: string;
    FCachedLiteralValue: string;

    FQueryString: TRequestVariables;
    FForm: TRequestVariables;
    FCookies: TRequestCookies;
    FBrowserCaps: TBrowserType;

    function    GetServerVariable(const varName: string): string;
    function    GetHttpHeader(const headerName: string): string;
    function    GetCookies: TRequestCookies;
    procedure   RetrieveCookies;
    function    GetScriptName: string;
    function    GetRemoteUser: string;
    function    GetBrowserCaps: TBrowserType;
    function    GetForm: TRequestVariables;
    function    GetLiteral(const name: string): string;
public
    {: A constructor, for internal use ony.
      You never need to create new <see class=THttpRequest> instances.
      When your code gets called to process client's HTTP request, both
      Request and Response objects are already created and available
      via <see property=TWapSession.Request> and <see property=TWapSession.Response>
      properties.}
    constructor Create(HttpInterface: TAbstractHttpRequestInterface);
    {: A standard destructor, for internal use only }
    destructor  Destroy; override;

    {: Provides access to the request body
      using a generic TStream interface. <p>
      Do not call the stream's Seek method - doing so
      will raise an exception.  }
    property    InputStream: TStream read FInputStream;

    {: Describes the MIME type of the request body.
     In the case of HTML forms being submitted using the <i>POST</i>
     method, this will usually be <i>application/x-www-form-urlencoded</i>
    @seeAlso
      <see property=THttpRequest.Literals> <br>
      <see property=THttpRequest.Form> <br>
      <see property=THttpRequest.InputStream> <br>
    }
    property    ContentType: string read FContentType;

    {: Given <em>name</em> as an index, the <strong>Literals</strong>
       property will retrieve a corresponding value by searching all
       relevant collections in <see class=THttpRequest>.
       The following collections are searched, in the specified order :<ol>
          <li><see property=THttpRequest.QueryString></li>
          <li><see property=THttpRequest.Form></li>
          <li><see property=THttpRequest.Cookies></li>
          <li><see property=THttpRequest.ServerVariables></li>
          <li><see property=THttpRequest.HTTPHeaders></li>
        </ol>

     Note:  Since <strong>Literals</strong> is the
     default property of <see class=THttpRequest>, we can
     omit the property name and use the following syntax :<p>
     <DelphiCode>
     Writeln(Response.TextOut, Request['SCRIPT_NAME'])
     </DelphiCode>
    }
    property    Literals[const Name: string]: string read getLiteral; default;

    {: This property retrieves the values of the variables encoded in the HTTP
      request URL (for GET requests).<p>

      The query string variable values are encoded after the
      question mark ('?') in a HTTP request. Such query string is
      created, for example, when a form sends it data using the
      GET method.<p>
      The <b>QueryString</b> property is actually a parsed
      version of the QUERY_STRING variable which is available through
      the <see property=THttpRequest.ServerVariables> property.
      If your application requires unparsed QueryString data,
      you can retrieve it using the <see property=TRequestVariables.AsString
      text = QueryString.AsString>  property.
      Or, you can retrieve the QUERY_STRING variables by name or by index. <p>

      To retrieve a QueryString variable by name, use
      <b>Request.QueryString[</b><i>variable-name</i><b>]</b>.
      To retrieve a variable using its index, use <b>Request.QueryString[</b><i>index</i><b>]</b>.
      The <i>index</i> parameter is zero based, and may have
      any value between 0 and <b>Request.QueryString.Count</b> - 1.<p>

      The value of <b>Request.QueryString[</b><i>variable-name</i><b>]</b>
      (or <i>index</i>) is an array of all the values of <i>variable-name</i>
      that occur in QUERY_STRING. Likewise, value of <b>Request.QueryString[</b><i>integer-index</i><b>]</b>
      is an array of all of the values of the <i>integer-index</i>' variable
      in QUERY_STRING. <p>
      You can determine the number of values of a variable
      using the <b>Request.QueryString[</b><i>parameter</i><b>].Count</b>
      property. If a variable does not have multiple values
      associated with it, the count is 1. If the variable is
      not found, the count is 0. To retrieve a specific value
      of a variable, use <b>Request.QueryString[</b><i>parameter</i><b>][</b><i>index</i><b>]</b>,
      where index is any value between 0 and <b>Request.QueryString[</b><i>parameter</i><b>].Count</b>
      - 1.<p>
      You can reference one of multiple QueryString
      variables without specifying a value for index using the
      Value property, in which case the data is returned as a
      comma-delimited string.

    @example
      The following client request :<p>
      <Code>
         'http://myhost/shop.dll?Item=GreatBook&Card=MasterCard'<p>
      </code>
      Results in a HTTP request that contains a QUERY_STRING
      header with this value :<p>
      <Code>
         Item=GreatBook&Card=MasterCard<p>
      </code>
      The QueryString array would then contain two entries,
      one for "Item" and one for "Card". To
      write the values of these variables as the response, you
      can use :<p>
      <code>
          Writeln(Response.TextOut, 'Item = ',
             Request.QueryString['Item'].Value,
             ' Card = ',
             Request.QueryString['Card'].Value);
      </code><p>
      To loop through all the values of the variable <Code>Selection</code>
      of the following request :<p>
      <code>
          http://myhost/myapp.dll?Selection=1&Selection=2
      </code><p>
      Use the following syntax :<p>
      <DelphiCode>
        for i := 0 to
          Request.QueryString['Selection'].Count - 1 do
          begin
            Writeln(Response.TextOut,
              Request.QueryString['Selection'][i]);
          end;
      </DelphiCode>

    #seeAlso <see property=THttpRequest.Literals>,
             <see property=THttpRequest.Form>,
    }
    property    QueryString: TRequestVariables read FQueryString;

    {: This property retrieves the values of the variables in the HTTP query
      string, taking them from the request body (for POST requests).

      This property is similar to the <see property THttpRequest.QueryString>
     property. The only difference is that the <b>QueryString</b>
     property is parsed from the value of the QUERY_STRING
     server variable, while the <b>Form</b> property
     is parsed from the contents of the request body (for
     example, when a forms sends its data using the POST
     method).<p>
     @seeAlso
        <see property=THttpRequest.QueryString><br>
        <see property=THttpRequest.Literals><br>
        <see property=THttpRequest.InputStream><br>
        <see property=THttpRequest.Method><br>
        <see property=THttpRequest.ContentType>
    }
    property    Form: TRequestVariables read getForm;

    {: This is an array of the cookies sent in the HTTP request.<p>
      Each cookie is represented by a <see class=TRequestCookies>
      object, which provide access to the value or values
      encoded in the cookie. <p>
      Example:<p>

      The following code will write the user's favorite color,
      stored in a cookie during his last visit to our site:<p>
      <DelphiCode>
      Writeln(Response.TextOut, 'Your favorite color is ',
        Request.Cookies['FavoriteColor'].Value);
      </DelphiCode> <p>
      For an example of writing a cookie, see
      the <see property=THttpResponse.Cookies> property.

    @seeAlso  <see property=THttpResponse.Cookies><p>

      Cookies were originally defined by Netscape in a document titled
      <a href="http://home.netscape.com/newsref/std/cookie_spec.html">
      "Persistent Client State - HTTP Cookies"</a>.<p>

      They are supported by most browsers including Netscape
      Navigator version 1.1 and later, and Microsoft Internet
      Explorer version 1.5 and later. The cookies specification
      was rewritten in RFC 2109,
      <a href="http://www.w3.org/pub/WWW/Protocols/rfc2109/rfc2109">
      "HTTP State Management Mechanism"</a>.</p>
    }
    property    Cookies: TRequestCookies read getCookies;

    {: The <b>ServerVariables</b> property
        retrieves the values of the server variables which were
        passed by the server to the application.<p>
        To retrieve a specific variable, use <b>Request.ServerVariables[</b><i>variable-name</i><b>]</b>.
        For example, to retrieve the value of the SERVER_NAME
        variable, use :<p>
        <DelphiCode>
          Request.ServerVariables['SERVER_NAME']<p>
        </DelphiCode>
          The possible variable names are server dependent, but
        will usually contain at least the following standard CGI
        variables:<p>
        <Code>
            AUTH_TYPE
            CONTENT_LENGTH
            CONTENT_TYPE
            GATEWAY_INTERFACE
            HTTP_*
            PATH_INFO
            PATH_TRANSLATED
            QUERY_STRING
            REMOTE_ADDR
            REMOTE_HOST
            REMOTE_IDENT
            REMOTE_USER
            REQUEST_METHOD
            SCRIPT_NAME
            SERVER_NAME
            SERVER_PORT
            SERVER_PROTOCOL
            SERVER_SOFTWARE
        </Code> <p>
        If the client sends a HTTP header other than those
        specified in the preceding table, you can retrieve the
        value of that header by prefixing the header name with "HTTP_"
        in the parameter to <b>ServerVariables</b>.
        All HTTP headers are also accessible using the
        <see property=THTTPRequest.HTTPHeaders> property.
     }
    property    ServerVariables[const VarName: string]: string read getServerVariable;

    {: Retrieves the values of the the headers sent by the client in the
       HTTP request.

       To retrieve a specific header, use <b>Request.HTTPHeaders[</b><i>header-name</i><b>]</b>.
        <p>For a description of the various HTTP headers, consult the
        <a href="http://www.w3.org/pub/WWW/Protocols/rfc1945/rfc1945">
        HTTP protocol specifications</a>.

    @seeAlso <see property=THttpRequest.ServerVariables>
    }
    property    HTTPHeaders[const HeaderName: string]: string read getHttpHeader;

    {: Retrieves the extra path info as given by the client. This value is
      parsed by the server into the PATH_INFO server variable,
      which is also accessible through the <see property=THttpRequest.ServerVariables>
      property. <p>
      The server maps the logical path to a physical path.
      The value of the mapped logical path can be retrieved
      using the <see property=THttpRequest.PhysicalPath> property.
    @example
      Given the following client request :<p>
        <Code>
       'http://myhost/scripts/myapp.dll/VirtualShop/Items/CoolSoftware.htm?Action=info'
        </Code> <p>
        The output of the following code fragment:<p>
        <DelphiCode>
            Writeln(Response.TextOut, Request.LogicalPath);
        </DelphiCode> <p>
        Will be :<p>
        <Code>
            VirualShop/Items/CoolSoftware.htm
        </Code>
    @seeAlso
        <see property=THttpRequest.PhysicalPath><br>
        <see property=THttpRequest.ServerVariables><br>
    }
    property    LogicalPath: string read FLogicalPath;

    {: Retrieves the value of the document path after the server performs
     any necessary virtual-to-physical mapping. <p>
     This value is parsed by the server into the PATH_TRANSLATED server variable,
     which is also accessible through the <see property=THttpRequest.ServerVariables>.

     You can access the path before the mapping through the
     <see property=THttpRequest.LogicalPath> property.
    @seeAlso
        <see property=THttpRequest.LogicalPath><br>
        <see property=THttpRequest.ServerVariables><br>
    }
    property    PhysicalPath: string read FPhysicalPath;

    {: Retrieves the name of the method used to make the request
      ('GET', 'HEAD', 'POST', etc.)<p>
      For HTTP, the most commonly used methods are listed above.
      Consult the HTTP specifications for the list of all possible values. }
    property    Method: string read FMethod;

    {: Retrieves the request method, similar to
       <see property=THttpRequest.Method text="Method">, but returns it as an
      enumerated value, rather than a method name string.<p>
      See <see type=THttpMethodType> enumeration for the list of known methods.
      The <b>MethodType</b> property returns <b>mtAny</b> if the method
      is not one of the methods recognized by WebApp {GET, PUT, POST, HEAD),
      in which case you can analyze the <see property=THttpRequest.Method text="Method">
      property directly. }
    property    MethodType: THttpMethodType read FMethodType;

    {: Retrieves the virtual path of the script being executed.
      This is useful when creating HTML code that references the
      executing application.

     Example:

      The following code will create an HTML form which will be processed
       by the generating application :

     <DelphiCode>
       with Response do
       begin
         Writeln(TextOut, '<FORM METHOD=GET ACTION=', ScriptName, '>');
         Writeln(TextOut, '<INPUT TYPE=SUBMIT>');
         Writeln(TextOut, '</FORM>');
       end;
     </DelphiCode>
    }
    property    ScriptName: string read GetScriptName;

    {: This is the short way to retrieve the REMOTE_USER server variable.
      Accessing this read-only property is exactly equivant to: <p>
      <b>Request.ServerVariables[</b><i>variable-name</i><b>]</b>. }
    property    RemoteUser: string read GetRemoteUser;

    {: Converts a specified logical path to the corresponding physical path. This method is available
    only when using the ISAPI interface.
    }
    function    MapPath(const LogicalPath: string): string;

    {: Use this property to customize the output based on the capabilities
       of the browser (User Agent) that made the request.<p>

       The browser capabilities are determined based on the USER-AGENT HTTP
       header and the information in BROWSCAP.INI
       (see <see class=TBrowserType> for more information).<p>
       If you use this property, you will need to deploy
       the BROWSCAP.INI file (see <jump id=deploy
       text="Deploying a WebApp Application">).
    @example
      The following code will adjust the output HTML page depending on
        the client browser support for ActiveX controls or Java Applets: <p>
        <DelphiCode>
         if Request.BrowserCaps.ActiveXControls then
           // Use an ActiveX Control
           Writeln(Response.TextOut,
            '&lt;OBJECT ID="MyObject" NAME="MyObject" CLASSID="clsid:12345678-1234....')
         else if Request.BrowserCaps.JavaApplets then
           // Use a Java Applet
           Writeln(Response.TextOut, '&lt;APPLET CODE="..." CODEBASE="...." WIDTH=200 HEIGHT=...');
        </DelphiCode>
    @seeAlso
      <jump id=deploy text="Deploying a WebApp Application"><br>
      <jump id=samples text="Sample programs"><br>    }
    property    BrowserCaps: TBrowserType read getBrowserCaps;
end;

{:
  The THttpResponse object is used to send output to the client browser.
}
THttpResponse = class
private
    FHttpInterface: TAbstractHttpRequestInterface;
    FRequest: THttpRequest;

    FStatus: string;
    FContentType: string;
    FContentLength: integer;
    FExpires: integer;
    FExpiresAbsolute: TDateTime;
    FHeaders: TStrings;
    FCookies: THttpResponseCookieList;
    FBuffer: boolean;
    FBufferStream: TStream;

    FOutputStream: TStream;
    FOutputStreamPosition: integer;
    FBytesSent: integer;
    TextFileDriver: TCustomTextFileDriver;
    
    statusLineWritten: boolean;

    inWriteHeader: boolean;
    headerWritten: boolean;

    function    rawOutputWrite(const Buffer; Count: Longint): Longint;
    procedure   rawWriteString(const S: string);
    procedure   rawWritelnString(const S: string);
    function    rawBodyOutputWrite(const Buffer; Count: Longint): Longint;

    function    streamOutputRead(var Buffer; Count: Longint): Longint;
    function    streamOutputWrite(const Buffer; Count: Longint): Longint;
    function    streamOutputSeek(Offset: Longint; Origin: Word): Longint;
    procedure   addCookiesToHeaders;
    procedure   writeHeader;
    procedure   verifyHeaderNotWritten;
    procedure   verifyBuffered;
    procedure   setBuffer(value: boolean);
public
    {: TextFile interface,
     for use with the standard Write and Writeln procedures.

    The most convenient way to send a response to the
    client browser is using <strong>TextOut</strong> with
    Delphi's standard Write and Writeln procedures.
    Example:
    <DelphiCode>
    Writeln(Response.TextOut,
      'This text was written using Delphi''s standard
      Writeln procedure');
    </DelphiCode>
    @seeAlso
      <see property=THttpResponse.OutputStream><br>
      <see property=THttpResponse.ContentType>
    }
    TextOut: TextFile;  // cannot be a property

    {: A constructor, for internal use ony.
      You never need to create new <see class=THttpResponse> instances.
      When you code gets called to process client's HTTP request, both
      <b>Request</b> and <b>Response</b> objects are already created and available
      via <see property=TWapSession.Request> and <see property=TWapSession.Response>
      properties.}
    constructor Create(Request: THttpRequest; RequestInterface: TAbstractHttpRequestInterface);
    {: A standard destructor, for internal use only }
    destructor  Destroy; override;

    { Specifies the status line returned by the server.
     The value should be in the format specified in the HTTP
     specifications. Use the <see routine=FormatStatusString>
     function to create a properly formatted status string.<p>
     By default, the value of this property is "200 OK" }
    property    Status: string read FStatus write FStatus;

    {: Adds an HTTP header with a specified value.
     This method always adds a new HTTP header to the response.
     It will not replace an existing header of the same name.
     Therefore, you can use this method to send multiple copies
     of the same header with different values, as with "WWW-Authenticate"
     headers. <p>
     This method is for advanced use only. If another <see class=THttpResponse>
     method will provide the functionality you require, it is
     recommended that you use that method instead. <p>
     Because HTTP protocol requires that all headers be
     sent before content, you must call <strong>AddHeader</strong>
     before any output is sent to the client. The exception to
     this rule is when the <see property=THttpResponse.Buffer> property is set
     to <strong>True</strong>. If the output is buffered,
     you can call the <strong>AddHeader</strong>
     method at any point in the script, as long as it precedes
     any calls to <see method=THttpResponse.FlushBuffer>.
     Otherwise, the call to <strong>AddHeader</strong> will
     generate an exception. }
    procedure   AddHeader(const Name, Value: string);

    {: Sends a "401 Unauthorized" response to the browser, requesting that
    the user be authenticated using "Basic Authentication". For more information
    on Basic Authentication, see the HTTP standard.
    <p>The Basic Authentication response can be decoded using the
    <see routine=DecodeBasicAuthorization> procedure.}
    procedure   RequestBasicAuthentication(const Realm: string);

    {: Erases any buffered HTML output.
      However, the <strong>Clear </strong>method
      only erases the response body--it does not erase response
      headers. You can use this method to handle error cases.
      Note that this method will cause an exception if the
      <see property=THttpResponse.Buffer> property
      has not been set to TRUE.
    @example
      The following code discards buffered output in case of exception:
      <DelphiCode><RawData>
      Response.Buffer := true;
      try
        // Do stuff
      except
        on E: Exception do begin
          Response.Status :=   FormatStatusString(hsInternalServerError);
          Writeln(Response.TextOut, '<TITLE>',   FormatStatusString(hsInternalServerError), '</TITLE>');
          Writeln(Response.TextOut, '<H1>',   FormatStatusString(hsInternalServerError), '</H1>');
          Writeln(Response.TextOut, 'Error : ', E.Message);
        end;
      end;
      </RawData></DelphiCode>
    @seeAlso
      <see property=THttpResponse.Headers>,
      <see property=THttpResponse.Buffer>,
      <see property=THttpResponse.FlushBuffer>
    }
    procedure   ClearBuffer;

    {: Sends buffered output immediately.
     This method will cause an exception
     if the <see property=THttpResponse.Buffer> property
     has not been set to <strong>True</strong>.
    @seeAlso
      <see property=THttpResponse.Buffer>,
      <see property=THttpResponse.ClearBuffer>
    }
    procedure   FlushBuffer;

    {: Use this property to send HTTP cookies to the client browser. <p>
      The <strong>Cookies[</strong><em>cookie-name</em><strong>]</strong>
      property is indexed by the cookie name. Each entry in the
      <strong>Cookies</strong> array contains a <see class=THttpResponseCookie>
      instance. Accessing a cookie which does not exists creates it.<p>
      For cookies which were sent <i>from</i> the client browser to your
      server, see <see property=THttpRequest.Cookies>.
    @example
      The following code will write the user
      name to a cookie. The cookie will be sent by the browser
      to every page in the site, and will expire a week from
      the time it was generated: <p>
      <DelphiCode>
      with Response.Cookies['UserId'] do
      begin
        Value := GetUserName;
        Path := '/';
        ExpiresOnLocalTime := Now + 7;
      end;
      </DelphiCode>
      Now whenever the browser access any URL in the web
      site that generated this cookie, it will send along the
      cookie. The following code will access the stored user id
      using the <see property=THttpRequest.Cookies> property :
      <DelphiCode>
      Writeln(Response.TextOut, Request.Cookies['UserId'].Value;
      </DelphiCode>    }
    property    Cookies: THttpResponseCookieList read FCookies;

    {: A stream interface to the output.<p>
     Use the <strong>OutputStream</strong> to send binary
     data, streams or files to the client browser
     (using <strong>TextOut</strong> is more convenient for textual
     information).
    @example
    The following code will send a GIF image to the browser :
    <delphiCode>
     Response.ContentType := 'image/gif';
     Stream := TFileStream.Create('logo.gif', fmOpenRead);
     try
       Response.ContentLength := Stream.Size;
       Response.OutputStream.CopyFrom(Stream, Stream.Size);
     finally
       Stream.Free;
     end;
    </delphiCode>
    @seeAlso
      <see property=THttpResponse.TextOut>
      <see property=THttpResponse.ContentLength><br>
      <see property=THttpResponse.ContentType>     }
    property    OutputStream: TStream read FOutputStream;

    {: Specifies the length of time (in minutes) before a page cached on a
      browser expires. If the user makes the same request before it expires,
      the cached version is displayed. <p>
      By default the value of this parameter is 0, causing the
      cached page to expire immediately
      (unless the <see property=THttpResponse.ExpiresAbsolute> property
      is set to a value other than 0)...
    @seeAlso  <see property=THttpResponse.ExpiresAbsolute>      }
    property    Expires: integer read FExpires write FExpires;

    {: Specifies the date and time at which a page cached on a
      browser expires. If the user makes the same request
      before that date and time, the cached version is
      displayed. <p>
      The value specified by this property takes precedence of the one
      specified in the <see property=THttpResponse.Expires> property.
      By default, the value of this property is 0, indicating
      that the response should expire immediately.     }
    property    ExpiresAbsolute: TDateTime read FExpiresAbsolute write FExpiresAbsolute;

    {: Specifies the HTTP content type for the response. <p>
       By default the value of this property is 'text/html'.<p>
    <bh>Example</bh><p>
      The following statement sets the content type to "text/plain",
      instructing the browser to interpret the contents of the response as
      non-HTML text. The browser will ignore any HTML tags in the
      response, and will display them on the screen.<p>
      <DelphiCode>
       Response.ContentType := 'text/plain';
      </DelphiCode>
    @seeAlso
      <see property=THttpResponse.OutputStream><br>
      <see property=THttpResponse.TextOut>     }
    property    ContentType: string read FContentType write FContentType; // text/html by default

    {: Use this property to specify the length in bytes
    of the response body.<p>
    The default value of this property is 0. You don't need to
    modify it when sending text or HTML response, but you
    should set it correctly when sending a binary response,
    such as an image.
    @example
    The following code will send a GIF image to the browser :<p>
    <DelphiCode>
    Response.ContentType := 'image/gif';
    Stream := TFileStream.Create('logo.gif', fmOpenRead);
    try
      Response.ContentLength := Stream.Size;
      Response.OutputStream.CopyFrom(Stream, Stream.Size);
    finally
      Stream.Free;
    end;
    </DelphiCode>
    @seeAlso
      <see property=THttpResponse.OutputStream><br>
      <see property=THttpResponse.ContentType>     }
    property    ContentLength: integer read FContentLength write FContentLength;

    {: Provides access to the raw HTTP headers.
      It is for advanced use only.
    @seeAlso <see method=THttpResponse.AddHeader>    }
    property    Headers: TStrings read FHeaders;

    {: Indicates whether to buffer the output response. <p>
     When page output is buffered, the server does not send a

     response to the client until the application have finished
     processing the request, or until the <see method=THttpResponse.FlushBuffer>
     method has been called. <p>
     The value of the <strong>Buffer</strong> property cannot be changed
     after the server has sent output to the client. <p>
     Buffering prevents any of the response from being
     displayed to the client until the application have
     finished processing the request. For long operations,
     this may cause a perceptible delay.
    @seeAlso
      <see property=THttpResponse.OutputStream> <br>
      <see property=THttpResponse.TextOut>
    }
    property    Buffer: boolean read FBuffer write SetBuffer;

    { Specialized output : }

    {: Internal method. Forces the HTTP response status line to be written right away. }
    procedure   WriteStatusLine;
    {: Internal method. Forces the HTTP response headers to be written right away. }
    procedure   WriteHeaders;

    {: Writes the contents of the specified file to the response.
        The method returns the number of bytes written.<p>
        <b>SendFile</b> can be invoked several times during the generation
        of the response, effectively concatenating the contents of the
        files.
    @example
      <strong>SendFile</strong> is great for sending
      predefined chunks of HTML. For example, if you have a
      collection of pages requiring a standard footer, you can
      put the footer in a seperate HTML file, and use code
      similar to this : <p>
      <DelphiCode>
      procedure TSessionModule.WapSessionExecute(Session: TWapSession);
      begin
        // ... dynamically generate the page, and then :
        Response.SendFile('FOOTER.HTM');
      end;
      </DelphiCode>
    @seeAlso
      <see property=THttpResponse.OutputStream> <br>
      <see property=THttpResponse.TextOut>
    }
    function    SendFile(const Filename: string): integer;

    {: Converts the bitmap to the GIF format and writes the resulting
      GIF image to the response. The method also takes care of
      setting the <see property=THttpResponse.ContentType>
      and <see property=THttpResponse.ContentLength>
      properties to the correct values.<p>
      Use <strong>SendBitmapAsGIF</strong>
      when you need to generate the GIFs on the fly. If the
      bitmaps are static and available beforehand, it is
      usually more efficient to perform the conversion once and
      use reference to the static image files.<p>
        <font color="#FF0000"><strong>IMPORTANT</strong></font>:
        <ul>
            <li>Delphi 3.0 users, please review the description
                of the <jump id=GraphicsBug text="Graphics.pas bug">
                before using this method.</li>
            <li>Please see the <jump id=GIF_Notes text="notes"> for
                information on the GIF conversion and the Unisys
                patent</li>
            <li>If you wish, you can use <jump id=CustImgConv
                text="your own image conversion library">
                to perform the conversion</li>
        </ul>
    @example
       The following example will read a bitmap from a database and send
       it as a GIF file : <p>
       <DelphiCode>
       procedure TSessionModule.WapSessionExecute(Session: TWapSession);
       var
         Bitmap: TBitmap;
       begin
         Bitmap := TBitmap.Create;
         try
           Bitmap.Assign(MyTablePictureBlobField);
           Response.SendBitmapAsGIF(Bitmap);
         finally
           Bitmap.Free;
         end;
       end;
       </DelphiCode>
    @seeAlso <see method THttpResponse.SendBitmapAsJPEG>
    }
    function    SendBitmapAsGIF(Bitmap: Graphics.TBitmap): integer;

    {: Converts the bitmap to the JPEG format and writes the resulting
       JPEG image to the response. <P>
      The method also takes care of setting
      the <see property=THttpResponse.ContentType>
      and <see property=THttpResponse.ContentLength>
      properties to the correct values.<p>
      Use <strong>SendBitmapAsJPEG</strong>
      when you need to generate the JPEGs on the fly. If the
      bitmaps are static and available beforehand, it is
      usually more efficient to perform the conversion once and
      use reference to the static image files.<p>

      If you wish, you can use <jump id=CustImgConv
      text="your own image conversion library">
      to perform the conversion        <p>

    <font color="#FF0000"><strong>IMPORTANT</strong></font>:
        Delphi 3.0 users, please review the description
        of the <jump id=GraphicsBug text="Graphics.pas bug">
        before using this method.

    @example
       The following example will read a bitmap from a database and send
       it as a JPEG file : <p>
       <DelphiCode>
       procedure TSessionModule.WapSessionExecute(Session: TWapSession);
       var
         Bitmap: TBitmap;
       begin
         Bitmap := TBitmap.Create;
         try
           Bitmap.Assign(MyTablePictureBlobField);
           Response.SendBitmapAsJPEG(Bitmap);
         finally
           Bitmap.Free;
         end;
       end;
       </DelphiCode>
    @seeAlso <see method THttpResponse.SendBitmapAsGIF>     }
    function    SendBitmapAsJPEG(Bitmap: Graphics.TBitmap): integer;

    {: Returns the total number of bytes written to the HTTP output stream. }
    property    BytesSent: integer read FBytesSent;


    {: Causes the browser to attempt to connect to the specified URL. <p>
      Any response body content set explicitly in the page is ignored.
     However, the method does send to the client other HTTP headers
     set by the program. An automatic response body containing the
     redirect URL as a link is generated. <p>
     The <strong>Redirect </strong>method sends the
     following explicit header, where <em>URL</em> is the
     value passed to the method: <p>
     <Code>
     HTTP/1.0 302 Object Moved<br>
     Location: <i>URL</i>
     </Code>
     <p>Note that this method also returns a standard response text allowing
     users using older (actually, <i>ancient</i>) browsers to navigate to the
     redirected URL manually.
    }
    procedure   Redirect(const URL: string);

    {: Returns the expiration time of the HTTP response.
    <p>If the <see property=ExpiresAbsolute> property is set,  its value is returned.
    Otherwise, the value is calculated using the current date/time and the value
    of the <see property=Expires> property.}
    function    GetExpirationTime: TDateTime;
end;

{: This class describes a single variable in the <see property=THttpRequest.QueryString>
or the <see property=THttpRequest.Form> collections.
<p>Each variable has a <see property=Name> property and a <see property=Value> property.
<p>Note that in some cases the QueryString or the POSTed information might contain
more than one value for a given variable (e.g. "OS=Win95&OS=WinNT"). In that case,
the Value property will contain the list of values seperated by commas, and the individual values
can be accessed using the <see property=Count>, <see property=Values> and <see property=ValueExists> properties and methods.
  }
TRequestVariable = class
private
    FValues: TStrings;
    FName: string;
    function getCount: integer;
    function getSubValue(index: integer): variant;
    function getValue: variant;
public
    {: A constructor (for internal use only) }
    constructor Create(const Name: string);
    {: A destructor (for internal use only).
      You don't need to call the destructor, since the class library
      manages request variables internally}
    destructor Destroy; override;
    {: The name of the variable }
    property Name: string read FName;
    {: The number of values specified for the variable.
    @seeAlso <see property=Values>
    }
    property Count: integer read getCount;
    {: If more than one value was specified for the variable, each of the individual values
    can be accessed through this indexed property. The number of values can be determined
    using the <see property=Count> property.
    @seeAlso <see method=ValueExists>
    @seeAlso <see property=Count>
    }
    property Values[Index: integer]: variant read getSubValue; default; // values are URL-decoded
    {: Returns True if the specified Value exist in the list of values for
    this variable.
    @seeAlso <see property=Values>
    }
    function ValueExists(const Value: variant): boolean;
    {: The value of the variable. If more than one value was specified for this
    variable, the property will contain the list of values seperated by commas,
    and the individual values can be accessed through the <see propert=Values> array.
    } 
    property Value: variant read getValue;
end;

{: A collection class for storing request variables.
  An object of this class is returned by <see property=THttpRequest.QueryString>
  and <see property=THttpRequest.Form> properties.
  }
TRequestVariables = class
private
    FAsString: string;
    FVariables: TStrings;
    function getVariable(const index: variant): TRequestVariable;
    function getCount: integer;
public
    {: A constructor (for internal use only) }
    constructor Create(const QueryString: string);
    {: A destructor (for internal use only).
      You don't need to call the destructor, since the class library
      manages request variables internally}
    destructor Destroy; override;
    {: Returns the number of variables in the request }
    property Count: integer read getCount;
    {: Accesses individual request variables, either by position or by name }
    property Variables[const Index: variant]: TRequestVariable read getVariable; default;
    {: Checks if a variable with a given name exists in the request string }
    function VariableExists(Index: string): boolean;
    {: Returns all request variables in a single line.
    The value returned by this property is equivalent to the original
    unparsed query string (or POST) passed in the HTTP request.
    }
    property AsString: string read FAsString;
end;

{: <p>An object of this class stores a single 'cookie', passed from a client
  browser to the WebApp application.  Always used as an element of
  the <see class=TRequestCookies> collection, obtained from
  <see property=THttpRequest.Cookies>.
  <p>It is a common practice to store several distinct values in a single cookie
  using URL-encoding (name1=value1&name2=value2&...). TRequestCookies
  supports this practice by allowing access to these values using the
   <see property=Values> property.
}
TRequestCookie = class(TPersistent)
private
    FValues: TStrings;
    FName: string;
    FValue: variant;
    constructor Create(const CookieName, CookieValue: string);
    function getValue(index: variant): variant;
    function getCount: integer;
protected
    procedure AssignTo(Dest: TPersistent); override;
public
    destructor Destroy; override;
    {: The name of the cookie }
    property Name: string read FName;
    {: The Value of the cookie, in its decoded format. }
    property Value: variant read FValue;
    {: Number of cookie values under the same name }
    property Count: integer read getCount;
    {: It is a common practice to store several distinct values in a single cookie
       using URL-encoding (name1=value1&name2=value2&...). The Values property
       provides access to these values. Use a integer-index to access the values
       by their position, or a string-index to access the values by name.}
    property Values[Index: variant]: variant read getValue; default;
    {: Checks if a named value exists in the <see property=Values> collection.}
    function ValueExists(const Index: string): boolean;
end;

{: <p>A collection class for storing request cookies.
  An object of this class is returned by <see property=THttpRequest.Cookie>
  properties.

  To <p>find out the number of cookies sent in the HTTP
  request, use <see property=TRequestCookies.Count text="Request.Cookies.Count">.
  To check if a specific cookie was sent in the HTTP request,
  use <b>Request.Cookies.CookieExists(</b><i>cookie-name</i><b>)</b>.

  <p>To retrieve a specific cookie,
  use <b>Request.Cookies[</b><i>cookie-name</i><b>]</b>,
  or <b>Request.Cookies[</b><i>cookie-index</i><b>]</b>.
}
TRequestCookies = class
private
    FCookies: TStrings;
    FDummyCookies: TStrings; // see .getCookie
    constructor Create(const HeaderCookie: string);
    function getCookie(const index: variant): TRequestCookie;
    function getCount: integer;
public
    destructor Destroy; override;
    {: Returns the number of cookies passed with the request}
    property Count: integer read getCount;
    {: Provides access to individual cookies.
     Use either a string- or a integer- index }
    property Cookies[const Index: variant]: TRequestCookie read getCookie; default;
    {: Checks if a cookie with the specified name exists in the request. }
    function CookieExists(const CookieName: string): boolean;
end;

{: This exception is raised by the <see class=THttpResponse> class methods
when an error occures in the generation of the HTTP response.}
EHttpResponse = class(exception);
{: This exception is raised when a method which assumes that the settings
of the <see property=THttpResponse.Buffer> property is True, while in fact
buffering is turned off (False).
    @seeAlso
      <see property=THttpResponse.FlushBuffer> <br>
      <see method=THttpResponse.ClearBuffer> <br>}
EResponseBuffer = class(EHttpResponse);
{: This exception is raised when an attempt is made to change
a HTTP-header related setting after the header has already been written to
the output stream.
    @seeAlso
      <see property=THttpResponse.Buffer> <br>
      <see method=THttpResponse.WriteStatusLine> <br>}
EResponseHeader = class(EHttpResponse);

{: A prototype for a function which would output a bitmap into
  a JPEG-formatted stream.  For advanced use only.
 @seeAlso <see type=TBitmapToGIFStreamProc>}
TBitmapToJPEGStreamProc = function(Bitmap: Graphics.TBitmap; Stream: TStream): integer;

{: A prototype for a function which would output a bitmap into
  a GIF-formatted stream.  For advanced use only.
 @seeAlso <see type=TBitmapToJPEGStreamProc>}
TBitmapToGIFStreamProc = function(Bitmap: Graphics.TBitmap; Stream: TStream): integer;

var
  {: This variable provides a 'hook' for a custom GIF-producing function.
  @seeAlso <see type=TBitmapToJPEGStreamProc>}
    BitmapToGIFStreamProc: TBitmapToGIFStreamProc = nil;

  {: This variable provides a 'hook' for a custom JPEG-producing function.
  @seeAlso <see type=TBitmapToJPEGStreamProc>}
    BitmapToJPEGStreamProc: TBitmapToJPEGStreamProc = nil;

{: This function decodes the user name and password from a valid Basic
    Authorization headers.
    <p>The Authorization header is returned by the browser in response
    to a "401 (unauthorized)" challange from the server.
    <p>You can generate this challange by calling the
    <see method=THttpResponse.RequestBasicAuthentication> method.
    <p>If the Authorization header is valid, the method returns
    True as the function result, and the decoded User Name and Password
    in the UserName and Password parameters. Otherwise, the function
    returns False and the content of UserName and Password is invalid. 
    @param AuthorizationHeader
        This is the authorization header returned by the browser in response
        to the challange. You can retrieve it using the
        <see property=THTTPRequest.HTTPHeaders> property, with "Authorization"
        as the header name.
    @param UserName
        The decoded User Name
    @param Password
        The decoded Password
}
function DecodeBasicAuthorization(
    const AuthorizationHeader: string;
    var UserName, Password: string
    ): boolean;

{: This function translates a numeric HTTP status code to a standard textual
    description. (e.g. 200 is "OK", 404 is "Not Found", etc.)
  @seeAlso <see routine=FormatStatusString>}
function StatusCodeToReason(StatusCode: integer): string;

{: This functions returns a standard HTTP status string in the format
"nnn reason". (e.g. "200 OK", or "404 Not Found")
<p>It is usefull in the generation of HTML-based error messages.
  @seeAlso <see routine=StatusCodeToReason>}
function FormatStatusString(StatusCode: integer): string;

// HTTP Status Codes :
const
    // Informational
    hsContinue = 100;
    hsSwitchingProtocols = 101;

    // Successful
    hsOK = 200;
    hsCreated = 201;
    hsAccepted = 202;
    hsNonAuthoritativeInformation = 203;
    hsNoContent = 204;
    hsResetContent = 205;
    hsPartialContent = 206;

    // Redirection
    hsMultipleChoices = 300;
    hsMovedPermanently = 301;
    hsMovedTemporarily = 302;
    hsSeeOther = 303;
    hsNotModified = 304;
    hsUseProxy = 305;

    // Client Error
    hsBadRequest = 400;
    hsUnauthorized = 401;
    hsPaymentRequired = 402;
    hsForbidden = 403;
    hsNotFound = 404;
    hsMethodNotAllowed = 405;
    hsNoneAcceptable = 406;
    hsProxyAuthenticationRequired = 407;
    hsRequestTimeout = 408;
    hsConflict = 409;
    hsGone = 410;
    hsLengthRequired = 411;
    hsUnlessTrue = 412;

    // Server Error
    hsInternalServerError = 500;
    hsNotImplemented = 501;
    hsBadGateway = 502;
    hsServiceUnavailable = 503;
    hsGatewayTimeout = 504;

/////////////////////////////////////////////////////////////////////////////
implementation
/////////////////////////////////////////////////////////////////////////////

uses WrdStrms, InetStr, XStrings, TimeUtil, Base64
    ;

function MethodToMethodType(const Method: string): THttpMethodType;
begin
    result := mtAny;
    if (CompareText(Method, 'GET') = 0) then
        result := mtGet
    else if (CompareText(Method, 'PUT') = 0) then
        result := mtPut
    else if (CompareText(Method, 'POST') = 0) then
        result := mtPost
    else if (CompareText(Method, 'HEAD') = 0) then
        result := mtHead;
end;

///////////////////////////////////////////////////////////////////////////
//
//        TRequestCookie
//
///////////////////////////////////////////////////////////////////////////

constructor TRequestCookie.Create(const CookieName, CookieValue: string);
var
    i: integer;
begin
    inherited create;
    FName := CookieName;
    FValue := URLDecode(CookieValue);
    if (pos('&', CookieValue) > 0) then begin
        FValues := CGIQueryStringToStrings(CookieValue);
        for i := 0 to (FValues.count - 1) do
            FValues[i] := URLDecode(FValues[i]);
    end else
        FValues := TStringList.create;
end;

destructor TRequestCookie.Destroy;
begin
    FValues.free;
    inherited destroy;
end;

procedure   TRequestCookie.AssignTo(Dest: TPersistent);

    procedure   AssignToStrings(Strings: TStrings);
    begin
        Strings.BeginUpdate;
        try
            if (Count = 0) then begin
                Strings.clear;
                if (FValue <> '') then
                    Strings.Add(FValue)
            end else begin
                Strings.Assign(FValues);
            end;
        finally
            Strings.EndUpdate;
        end;
    end;

    procedure   AssignToHttpCookie(httpCookie: THttpResponseCookie);
    var
        temp: TStrings;
    begin
        temp := TStringList.Create;
        try
            AssignToStrings(temp);
            httpCookie.Assign(temp);
        finally
            temp.Free;
        end;
    end;

begin
    if (Dest is TStrings) then
        AssignToStrings(TStrings(Dest))
    else if (Dest is THttpResponseCookie) then
        AssignToHttpCookie(THttpResponseCookie(Dest))
    else
        inherited AssignTo(Dest);
end;

type TVarKind = (vkStr, vkInt);

function    getVarKind(const v: variant): TVarKind;
const
    varIntKindMask = varSmallint or varInteger or varByte;
    varStrKindMask = varOleStr or varString;
begin
    if ((varType(v) and varTypeMask and varIntKindMask) <> 0) then
        result := vkInt
    else if ((varType(v) and varTypeMask and varStrKindMask) <> 0) then
        result := vkStr
    else
        raise exception.create('Expecting an integer or a string');
end;

function TRequestCookie.getValue(index: variant): variant;
begin
    case getVarKind(index) of
        vkInt: result := FValues[integer(index)];
        vkStr: result := FValues.values[string(index)]
    end;
end;

function TRequestCookie.getCount: integer;
begin
    result := FValues.count;
end;

function TRequestCookie.ValueExists(const Index: string): boolean;
begin
    result := (FValues.indexOfName(index) <> -1);
end;

///////////////////////////////////////////////////////////////////////////
//
//        TRequestCookies
//
///////////////////////////////////////////////////////////////////////////

constructor TRequestCookies.Create(const HeaderCookie: string);
var
    i: integer;
    cookieName, cookieValue: string;
begin
    inherited create;
    FCookies := TExStringList.create;
    ParseCookieHeader(HeaderCookie, FCookies);
    for i := 0 to (FCookies.Count - 1) do begin
        StringToNameAndValue(FCookies[i], cookieName, cookieValue);
        FCookies.objects[i] := TRequestCookie.Create(cookieName, cookieValue);
    end;
    // see .getCookie for usage of FDummyCookies
    FDummyCookies := TExStringList.create;
end;

destructor TRequestCookies.Destroy;
begin
    FDummyCookies.free;
    FCookies.free;
    inherited destroy;
end;

function TRequestCookies.getCookie(const index: variant): TRequestCookie;
var
    i: integer;
begin
    result := nil;
    case getVarKind(index) of
        vkInt: begin
            result := TRequestCookie(FCookies.objects[integer(index)]);
        end;
        vkStr: begin
            i := FCookies.indexOfName(string(index));
            if (i = -1) then begin
                // if cookie does not exist, we still want to return a valid
                // TRequestCookie instance, to avoid requiring checking for nils,
                // exception handling etc.
                // Therefore, we will create a dummy TRequestCookie (unless one
                // already exists). 
                i := FDummyCookies.indexOfName(string(index));
                if (i = -1) then
                    i := FDummyCookies.addObject(string(index), TRequestCookie.Create(string(index), ''));
                result := TRequestCookie(FDummyCookies.objects[i]);
            end else begin
                result := TRequestCookie(FCookies.objects[i]);
            end; // if
        end; // vkStr
    end; // case
end;

function TRequestCookies.getCount: integer;
begin
    result := FCookies.count;
end;

function TRequestCookies.CookieExists(const CookieName: string): boolean;
begin
    result := (FCookies.indexOfName(cookieName) <> -1);
end;

///////////////////////////////////////////////////////////////////////////
//
//        TRequestVariables
//
///////////////////////////////////////////////////////////////////////////

constructor TRequestVariables.Create(const QueryString: string);

    procedure   add(name, value: string);
    var
        i: integer;
        reqVar: TRequestVariable;
    begin
        i := FVariables.indexOf(name);
        if (i = -1) then begin
            reqVar := TRequestVariable.create(name);
            FVariables.addObject(name, reqVar);
        end else begin
            reqVar := TRequestVariable(FVariables.objects[i]);
        end;
        
        if (name = '') and (value = '') then begin
            ;
        end else begin
            reqVar.FValues.add(urlDecode(value));
        end;
    end;

var
    i: integer;
    tempList: TStringList;
    name, value: string;
begin
    inherited create;
    FAsString := queryString;
    FVariables := TExStringList.create;
    TExStringList(FVariables).sorted := true;
    add('', '');    // special entry to satisfy requests for non-existant keys
    tempList := CGIQueryStringToStrings(queryString);
    try
        for i := 0 to (tempList.count - 1) do begin
            StringToNameAndValue(tempList[i], name, value);
            add(name, value);
        end;
    finally
        tempList.free;
    end;
end;

destructor TRequestVariables.Destroy;
begin
    FVariables.free;
    inherited destroy;
end;

function TRequestVariables.getCount: integer;
begin
    result := FVariables.count;
end;

function TRequestVariables.getVariable(const index: variant): TRequestVariable;
var
    i: integer;
begin
    i := -1;
    case getVarKind(index) of
        vkInt: i := integer(index);
        vkStr: i := FVariables.indexOf(string(index));
    end;
    if (i = -1) then
        i := 0; // return the first entry ('', '') for bad keys
    result := TRequestVariable(FVariables.Objects[i]);
end;

function TRequestVariables.VariableExists(Index: string): boolean;
begin
    result := (FVariables.indexOf(index) <> -1);
end;

///////////////////////////////////////////////////////////////////////////
//
//        TRequestVariable
//
///////////////////////////////////////////////////////////////////////////

constructor TRequestVariable.Create(const Name: string);
begin
    inherited create;
    FValues := TStringList.create;
    FName := Name;
end;

destructor TRequestVariable.Destroy;
begin
    FValues.free;
    inherited destroy;
end;

function TRequestVariable.getCount: integer;
begin
    result := FValues.count;
end;

function TRequestVariable.getSubValue(index: integer): variant;
begin
    result := FValues[index];
end;

function TRequestVariable.ValueExists(const Value: variant): boolean;
begin
    result := (FValues.IndexOf(string(value)) <> -1);
end;

function TRequestVariable.getValue: variant;
var
    i: integer;
    s: string;
begin
    s := '';
    for i := 0 to (FValues.count - 1) do begin
        if (s <> '') then
            s := s + ', ';
        s := s + FValues[i];
    end; // for
    result := s;
end;

///////////////////////////////////////////////////////////////////////////
//
//        TServerInputStream
//
///////////////////////////////////////////////////////////////////////////

type
TServerInputStream = class(TSequentialStream)
private
    FRequest: THttpRequest;
protected
    function GetStreamSize: integer; override;
    function SequentialRead(var Buffer; Count: Longint): Longint; override;
public
    constructor Create(Request: THttpRequest);
end;

constructor TServerInputStream.Create(Request: THttpRequest);
begin
    inherited create;
    FRequest := Request;
end;

function TServerInputStream.GetStreamSize: integer;
begin
    result := FRequest.FHttpInterface.GetInputSize;
end;

function TServerInputStream.SequentialRead(var Buffer; Count: Longint): Longint;
begin
    result := FRequest.FHttpInterface.ReadFromClient(Buffer, Count);
end;

///////////////////////////////////////////////////////////////////////////
//
//        THttpTransaction
//
///////////////////////////////////////////////////////////////////////////

constructor THttpTransaction.Create(RequestInterface: TAbstractHttpRequestInterface; OwnRequestInterface: boolean);
begin
    inherited Create;
    FRequestInterface := RequestInterface;
    FOwnRequestInterface := OwnRequestInterface;
    FRequest := THttpRequest.Create(FRequestInterface);
    FResponse := THttpResponse.Create(FRequest, FRequestInterface);
end;

destructor THttpTransaction.Destroy;
begin
    FResponse.Free;
    FRequest.Free;
    if (FOwnRequestInterface) then
        FRequestInterface.Free;
end;

///////////////////////////////////////////////////////////////////////////
//
//        THttpRequest
//
///////////////////////////////////////////////////////////////////////////

constructor THttpRequest.Create(HttpInterface: TAbstractHttpRequestInterface);
begin
    inherited create;

    FHttpInterface := HttpInterface;

    FInputStream := TServerInputStream.create(self);

    // cache values
    FPhysicalPath := FHttpInterface.GetPhysicalPath;
    FLogicalPath := FHttpInterface.GetLogicalPath;
    FMethod := FHttpInterface.GetMethod;
    FMethodType := MethodToMethodType(FMethod);
    FContentType := FHttpInterface.GetInputContentType;

    FQueryString := TRequestVariables.create(FHttpInterface.GetQueryString);
end;

destructor  THttpRequest.destroy;
begin
    FCookies.free;
    FBrowserCaps.free;
    FInputStream.free;
    FQueryString.free;
    FForm.free;
    inherited destroy;
end;

procedure   THttpRequest.retrieveCookies;
begin
    FCookies := TRequestCookies.create(httpHeaders['Cookie']);
end;

function    THttpRequest.getScriptName: string;
begin
    result := serverVariables['SCRIPT_NAME'];
end;

function    THttpRequest.GetRemoteUser: string;
begin
    result := serverVariables['REMOTE_USER'];
end;

function    THttpRequest.MapPath(const LogicalPath: string): string;
begin
    result := FHttpInterface.MapURLToPath(LogicalPath);
end;

function    THttpRequest.getHttpHeader(const headerName: string): string;
var
    p: integer;
    s: string;
begin
    s := headerName;
    // translate "-" to "_"
    repeat
        p := pos('-', s);
        if (p > 0) then
            s[p] := '_';
    until (p = 0);
    result := FHttpInterface.GetHttpHeader(s);
end;

function    THttpRequest.getServerVariable(const varName: string): string;
begin
    result := FHttpInterface.GetServerVariable(varName);
end;

function    THttpRequest.getCookies: TRequestCookies;
begin
    if (FCookies = nil) then
        retrieveCookies;
    result := FCookies;
end;

function    THttpRequest.getBrowserCaps: TBrowserType;
begin
    if (FBrowserCaps = nil) then begin
        FBrowserCaps := TBrowserType.create(nil);
        FBrowserCaps.UserAgent := serverVariables['HTTP_USER_AGENT'];
    end;
    result := FBrowserCaps;
end;

function    THttpRequest.getForm: TRequestVariables;
var
    TempStrings: TStringList;
    TempStr: string;
begin
    if (FForm = nil) then begin
        if (ContentType = 'application/x-www-form-urlencoded') then begin
            TempStrings := TStringList.Create;
            try
                TempStrings.LoadFromStream(InputStream);
                TempStr := TempStrings.Text;
                // Remove the trailing CRLF appended by TStrings.Text 
                Delete(TempStr, Length(TempStr) - 1, 2);
                FForm := TRequestVariables.Create(TempStr);
            finally
                TempStrings.Free;
            end;
        end else begin
            FForm := TRequestVariables.Create('');
        end;
    end;
    result := FForm;
end;

function    THttpRequest.getLiteral(const name: string): string;
begin
    if (CompareText(name, FCachedLiteralName) = 0) then begin
        result := FCachedLiteralValue;
        exit;
    end;

    if queryString.variableExists(name) then
        result := queryString[name].value
    else if form.variableExists(name) then
        result := form[name].value
    else if cookies.cookieExists(name) then
        result := cookies[name].value
//  tbd : should insert check for ClientCertificate here
    else if (serverVariables[name] <> '') then
        result := serverVariables[name]
    else if (httpHeaders[name] <> '') then 
        result := httpHeaders[name]
    else
        result := '';

    FCachedLiteralName := Name;
    FCachedLiteralValue := result;
end;

///////////////////////////////////////////////////////////////////////////
//
//        TResponseTextDeviceDriver
//
///////////////////////////////////////////////////////////////////////////
type
TResponseTextDeviceDriver = class(TCustomTextFileDriver)
private
    FController: THttpResponse;
protected
    procedure   Open(Mode: word; Append: boolean); override;
    procedure   Close; override;
    procedure   Read(Buffer: pchar; var Count: integer; var AtEOF: boolean); override;
    procedure   Write(Buffer: pchar; Count: integer); override;
public
    constructor create(Controller: THttpResponse);
end;

constructor TResponseTextDeviceDriver.create(Controller: THttpResponse);
begin
    inherited create(controller.textOut);
    FController := Controller;
end;

procedure   TResponseTextDeviceDriver.Open(Mode: word; Append: boolean);
begin
    // nothing to do
end;

procedure   TResponseTextDeviceDriver.Close;
begin
    // nothing to do
end;

procedure   TResponseTextDeviceDriver.Read(Buffer: pchar; var Count: integer; var AtEOF: boolean);
begin
    raise exception.create('Cannot read from response output stream');
end;

procedure   TResponseTextDeviceDriver.Write(Buffer: pchar; Count: integer);
begin
    FController.rawBodyOutputWrite(buffer^, count);
end;


///////////////////////////////////////////////////////////////////////////
//
//        THttpResponse
//
///////////////////////////////////////////////////////////////////////////

constructor THttpResponse.Create(Request: THttpRequest; RequestInterface: TAbstractHttpRequestInterface);
begin
    inherited create;

    FHttpInterface := RequestInterface;
    FRequest := Request;

    FOutputStream := TProxyStream.create(streamOutputRead, streamOutputWrite, streamOutputSeek);

    TextFileDriver := TResponseTextDeviceDriver.create(self);
    TextFileDriver.rewrite;

    FHeaders := TStringList.create;
    FCookies := THttpResponseCookieList.create;

    FContentType := 'text/html';

    FBufferStream := TMemoryStream.create;

    FStatus := FormatStatusString(hsOK);
end;

destructor  THttpResponse.destroy;
begin
    try

{$ifdef webapp_trial}
    if (Copy(ContentType, 1, 5) = 'text/') then begin
        Writeln(TextOut, '<TABLE BGCOLOR="White"><TR><TD><FONT COLOR="Red"><B>',
            'This page was generated using a trial version of ',
            '<A HREF="http://www.hyperact.com">HyperAct WebApp</A>',
            '</B></FONT></TD></TR></TABLE>');
    end;
{$endif webapp_trial}

        if (FBuffer) then
            FlushBuffer;

        if (TextFileDriver <> nil) then
            Flush(TextOut);
    except
        // Ignore exceptions while flushing buffers. Such exceptions are common
        // when the client closes the connection, and should not be considered errors.
        on Exception do
            ;
    end;

    TextFileDriver.Free;
    FOutputStream.Free;

    FCookies.Free;
    FHeaders.Free;

    FBufferStream.Free;

    inherited destroy;
end;

procedure   THttpResponse.verifyHeaderNotWritten;
begin
    if (headerWritten) then
        raise EResponseHeader.create('The HTTP headers are already written to the output');
end;

function    StatusCodeToReason(StatusCode: integer): string;
begin
    case StatusCode of
        100: Result := 'Continue';
        101: Result := 'Switching Protocols';
        200: Result := 'OK';
        201: Result := 'Created';
        202: Result := 'Accepted';
        203: Result := 'Non-Authoritative Information';
        204: Result := 'No Content';
        205: Result := 'Reset Content';
        206: Result := 'Partial Content';
        300: Result := 'Multiple Choices';
        301: Result := 'Moved Permanently';
        302: Result := 'Moved Temporarily';
        303: Result := 'See Other';
        304: Result := 'Not Modified';
        305: Result := 'Use Proxy';
        400: Result := 'Bad Request';
        401: Result := 'Unauthorized';
        402: Result := 'Payment Required';
        403: Result := 'Forbidden';
        404: Result := 'Not Found';
        405: Result := 'Method Not Allowed';
        406: Result := 'None Acceptable';
        407: Result := 'Proxy Authentication Required';
        408: Result := 'Request Timeout';
        409: Result := 'Conflict';
        410: Result := 'Gone';
        411: Result := 'Length Required';
        412: Result := 'Unless True';
        500: Result := 'Internal Server Error';
        501: Result := 'Not Implemented';
        502: Result := 'Bad Gateway';
        503: Result := 'Service Unavailable';
        504: Result := 'Gateway Timeout';
        else
            result := 'Server error ' + IntToStr(StatusCode);
    end; { case }
end;

function    FormatStatusString(StatusCode: integer): string;
begin
    result := IntToStr(StatusCode) + ' ' + StatusCodeToReason(StatusCode);
end;

// This is the most basic output function
function THttpResponse.rawOutputWrite(const Buffer; Count: Longint): Longint;
begin
    result := FHttpInterface.WriteToClient(Buffer, Count);
    inc(FBytesSent, result);
end;

procedure THttpResponse.rawWriteString(const S: string);
begin
    rawOutputWrite(pchar(s)^, length(s));
end;

procedure THttpResponse.rawWritelnString(const S: string);
begin
    RawWriteString(s + #13#10);
end;

// write to the response body
// will automatically write the headers if they were not written yet
function THttpResponse.rawBodyOutputWrite(const Buffer; Count: Longint): Longint;
begin
    if (FBuffer) then begin
        result := FBufferStream.write(buffer, count);
    end else begin
        if ((not headerWritten) and (not inWriteHeader)) then
            writeHeader;
        result := rawOutputWrite(buffer, count);
    end;
end;

procedure   THttpResponse.setBuffer(value: boolean);
begin
    if (FBuffer <> value) then begin
        if (value = true) then
            verifyHeaderNotWritten
        else
            flushBuffer;
        FBuffer := value;
    end;
end;

procedure   THttpResponse.verifyBuffered;
begin
    if (not FBuffer) then
        raise EResponseBuffer.create('Buffering is off');
end;

procedure   THttpResponse.FlushBuffer;
begin
    verifyBuffered;
    flush(textOut); // make sure everything is written to the stream
    // to prevent recursion in rawBodyOutputWrite
    FBuffer := false;
    try
        OutputStream.CopyFrom(FBufferStream, 0);
    finally
        FBuffer := true;
    end;
    ClearBuffer;
end;

procedure   THttpResponse.ClearBuffer;
begin
    verifyBuffered;
    (FBufferStream as TMemoryStream).Clear;
end;

function THttpResponse.streamOutputRead(var Buffer; Count: Longint): Longint;
begin
    raise exception.create('Cannot read from response output stream');
end;

function THttpResponse.streamOutputWrite(const Buffer; Count: Longint): Longint;
begin
    flush(textOut);
    result := rawBodyOutputWrite(buffer, count);
    inc(FOutputStreamPosition, result);
end;

function THttpResponse.streamOutputSeek(Offset: Longint; Origin: Word): Longint;
begin
    if (Offset = 0) then begin
        result := FOutputStreamPosition;
    end else begin
        raise exception.create('internal error : illegal seek on output stream');
    end;
end;

const
    RedirectBody = '<head><title>Object moved</title></head>' + #13#10 +
    '<body><h1>Object Moved</h1>This object may be found <a HREF="%s">here</a>.</body>';

procedure   THttpResponse.Redirect(const URL: string);
begin
    FStatus := FormatStatusString(hsMovedTemporarily);
    AddHeader('Location', url);
    if (CompareText(FRequest.Method, 'HEAD') <> 0) then
        writeln(TextOut, format(RedirectBody, [URL]));
end;

procedure   THttpResponse.WriteStatusLine;
begin
    verifyHeaderNotWritten;
    rawWriteLnString('HTTP/1.0 ' + FStatus);
    statusLineWritten := true;
end;

function THttpResponse.SendBitmapAsGIF(Bitmap: Graphics.TBitmap): integer;
begin
    if (not assigned(BitmapToGIFStreamProc)) then
        raise Exception.Create('Conversion to GIF not available');
    Buffer := true; // Otherwise we won't be able to set ContentLength
    ContentType := 'image/gif';
    result := BitmapToGIFStreamProc(Bitmap, OutputStream);
    ContentLength := result;
end;

function THttpResponse.SendBitmapAsJPEG(Bitmap: Graphics.TBitmap): integer;
begin
    if (not assigned(BitmapToJPEGStreamProc)) then
        raise Exception.Create('Conversion to JPEG not available');
    Buffer := true; // Otherwise we won't be able to set ContentLength
    ContentType := 'image/jpeg';
    result := BitmapToJPEGStreamProc(Bitmap, OutputStream);
    ContentLength := result;
end;

function THttpResponse.SendFile(const Filename: string): integer;
var
    F: TFileStream;
begin
    F := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
    try
        result := OutputStream.CopyFrom(F, 0);
    finally
        F.Free;
    end;
end;

procedure   THttpResponse.AddHeader(const Name, Value: string);
begin
    FHeaders.add(name + ': ' + value);
end;

procedure   THttpResponse.WriteHeaders;
var
    i: integer;
begin
    addCookiesToHeaders;
    for i := 0 to (FHeaders.count - 1) do
        rawWriteLnString(FHeaders[i]);
end;

procedure   THttpResponse.addCookiesToHeaders;
var
    i: integer;
    cookiesStrings: TStringList;
begin
    cookiesStrings := TStringList.create;
    try
        cookies.toStrings(cookiesStrings);
        for i := 0 to (cookiesStrings.count - 1) do
            AddHeader('Set-Cookie', cookiesStrings[i]);
    finally
        cookiesStrings.free;
    end;
end;


function    THttpResponse.GetExpirationTime: TDateTime;
begin
    // if ExpiresAbsolute is specified, use it, otherwise use Expire.
    if (FExpiresAbsolute > 0) then
        result := FExpiresAbsolute
    else
        result := now + (FExpires * MinutesToDateTime);
end;

const
    AuthorizationRequestBody = '<head><title>Authorization Falied</title></head>' + #13#10 +
    '<body><h1>Authorization Falied</h1><p>You are not authorized to access this page';

procedure   THttpResponse.RequestBasicAuthentication(const Realm: string);
begin
    Status := FormatStatusString(hsUnauthorized);
    AddHeader('WWW-Authenticate', 'Basic realm="' + Realm + '"');
    Writeln(TextOut, AuthorizationRequestBody); 
end;

procedure   THttpResponse.writeHeader;
begin
    // prevent accidental recursion, though it should not happen
    if (inWriteHeader) then
        exit;
    inWriteHeader := true;
    try
        if (not statusLineWritten) then
            WriteStatusLine;

        AddHeader('Content-Type', FContentType);
        if (FContentLength > 0) then
            AddHeader('Content-Length', intToStr(FContentLength));

        AddHeader('Expires', LocalDateTimeToInetStdStr(GetExpirationTime));
        if ((FExpires = 0) and (FExpiresAbsolute = 0)) then
            AddHeader('pragma', 'no-cache');

        writeHeaders;

        rawWriteLnString('');

        headerWritten := true;
    finally
        inWriteHeader := false;
    end;
end;

function DecodeBasicAuthorization(
    const AuthorizationHeader: string;
    var UserName, Password: string
    ): boolean;
var
    encodedString: string;
    p: integer;
begin
    result := false;
    p := pos(' ', AuthorizationHeader);
    if (p = 0) then
        exit;
    // check that it indeed Basic authorization
    if (compareText(copy(AuthorizationHeader, 1, p - 1), 'BASIC') <> 0) then
        exit;
    encodedString := Base64ToString(copy(AuthorizationHeader, p + 1, maxInt));
    p := pos(':', encodedString);
    if (p = 0) then
        exit;
    UserName := copy(encodedString, 1, p - 1);
    Password := copy(encodedString, p + 1, maxInt);
    result := true;
end;

end.
