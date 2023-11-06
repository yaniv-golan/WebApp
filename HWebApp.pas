/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////

unit HWebApp;

interface

{$I WapDef.INC}

uses Classes, SysUtils, Windows, Forms, Controls, Graphics,
    IPC, AppSSI, HttpReq, WVarDict, WapActns, MthdsLst, SDS
    ;

type

TWapApp = class;
TWapSession = class;
TWapSessionList = class;
TWapSessionState = class;
{$ifndef wap_cbuilder}
THttpRequest = AppSSI.THttpRequest;
THttpResponse = AppSSI.THttpResponse;
{$endif wap_cbuilder}

{: Notification codes used in the <see event=TWapApp.OnNotify> event.
}
TWapAppNotification = (
    wnApplicationStart,        // WebApp application has started
    wnApplicationEnd,          // WebApp application has ended
    wnSessionStart,            // A new session has started
    wnSessionEnd,              // A session has terminated
    wnRequestStart,            // An HTTP request is received
    wnRequestEnd               //Procesing of an HTTP request is done
);

TWapAppExceptionEvent = procedure(Sender: TObject; E: Exception; Request: THttpRequest; Response: THttpResponse) of object;
TWapAppNotifyEvent = procedure(App: TWapApp) of object;
TWapAppExecuteEvent = procedure(Sender: TObject; Request: THttpRequest; Response: THttpResponse) of object;
TCreateSessionEvent = procedure(Sender: TObject; var Session: TWapSession) of object;
TWapSessionNotifyEvent = procedure(Session: TWapSession) of object;
TWapAppNotificationEvent = procedure(Sender: TObject; Notification: TWapAppNotification) of object;
TSaveStateEvent = procedure(Sender: TObject; State: TWapSessionState) of object;

// Define TCustomForm for Delphi 2.x and C++Builder 1.0
{$ifdef wap_delphi_2_or_cbuilder_1}
TCustomForm = TForm;
TWinControlClass = class of TWinControl;
{$endif wap_delphi_2_or_cbuilder_1}

EWapApp = class(Exception);
EWapSession = class(Exception);

{:
  The <b>TWapApp</b> component represents a single Web Application.
  An application is identified by its <see property=TWapApp.AppId> property.
  Requests that are associated with this application will be handled
  in the <see event=TWapApp.OnExecute> event, and / or by a
  specific <jump id=sessions text="session"> of the application.<p>

  Several Web Applications (<b>TWapApp</b> instances) can live in the same
  executable, each one with its unique AppId.
@component
@seeAlso  <see class=TAdRotator>
}
TWapApp = class(TComponent)
private
    // properties
    FAppId: string;
    FMultiSession: boolean;
    FActiveRequests: integer;
    FDebugMode: boolean;
    FActive: boolean;

    // events
    FOnExecute: TWapAppExecuteEvent;
    FOnStart: TWapAppNotifyEvent;
    FOnEnd: TWapAppNotifyEvent;
    FOnCreateSession: TCreateSessionEvent;
    FOnException: TWapAppExceptionEvent;
    FOnNotify: TWapAppNotificationEvent;

    FScheduler: TObject;
    FRequestsReader: TObject;
    FSessionList: TWapSessionList;
    FAppInitializedEvent: TWin32Event;

    FIsFirstRequest: boolean;

    FOldSessionsCleanerThread: TThreadEx;

    FWebAppModuleHandle: THandle;
    FAppRoot: string;

    FValues: TVariantList;
    function GetValue(Index: string): variant;
    procedure SetValue(Index: string; Value: variant);

    procedure SetAppId(const value: string);

    procedure DispatchToSession(ThreadToken: longint; var Session: TWapSession; Request: THttpRequest; Response: THttpResponse);
    procedure InitSharedCookie(Request: THttpRequest; Response: THttpResponse);
    procedure SetDebugMode(Value: boolean);
    function GetThreadCount: integer;
    procedure InternalOnExceptionHandler(Sender: TObject; E: Exception);
protected
    procedure AppIdChanged; virtual;
    procedure HandleRequestsReaderException(Sender: TObject; E: Exception);
    function CreateSession: TWapSession; virtual;
    procedure AppStart; virtual;
    procedure AppEnd; virtual;
    procedure Execute(Request: THttpRequest; Response: THttpResponse); virtual;
    procedure Notify(Notification: TWapAppNotification); virtual;
public
    //: A standard constructor
    constructor Create(AOwner: TComponent); override;
    //: A standard destructor
    destructor Destroy; override;
    {: This method is called by WebApp when an unhandled exception occurs in the application.
    It's default implementation invokes the <see event=OnException> event if it is defined,
    otherwise it calls the <see method=ReportException> method.
    <p>Usually you will not need to override this method.
    @seeAlso <see method=ReportException>, <see event=OnException>}
    procedure HandleException(Sender: TObject; Request: THttpRequest; Response: THttpResponse); virtual;
    {: This method is called by the <see method=HandleException> method
    in order to write the Exception error message to the HTML output, unless
    you've defined your own <see event=OnException> event handler.
    <p>Override this method to customize this default behavior.
    @seeAlso <see event=OnException>}
    procedure ReportException(Sender: TObject; E: Exception; Request: THttpRequest; Response: THttpResponse); virtual;
    //: Deletes all the values added to through the Values array.
    procedure Clear;
    {: Locks access to the Values array so that it cannot be
    changed by other threads (sessions).
    @seeAlso <see method=TWapApp.UnLock>.  }
    procedure Lock;
    {: Unlocks the Values array after calling <see method=TWapApp.Lock>
    @seeAlso <see method=TWapApp.Lock>. }
    procedure Unlock;

    {: This method activates the WebApp application represented
    by the TWapApp component. Once the Start method is called, the application
    registeres itself as an active application and starts handling requests
    from the Web server.
    @seeAlso <see method=Stop>, <see property=Active>}
    procedure Start;
    {: This method stops the the WebApp application represented
    by the TWapApp component. Once the Stop method is called, the application
    will no longer handle requests from the Web server.
    @seeAlso <see method=Start>, <see property=Active>}
    procedure Stop;

    {: This property indicates if the WebApp application has been started
    by calling the <see method=Start> method. Calling the <see method=Stop> method
    sets this property to False.
    @seeAlso <see method=Start>, <see method=Stop>}
    property Active: boolean read FActive;
    {: This property indicates the number of requests being handled
    by the WebApp application at the moment.
    @seeAlso <see property=WaitingRequests>}
    property ActiveRequests: integer read FActiveRequests;

    {:The <b>Values</b> array property provides a convenient place to store
    application-wide values which needs to be accessed by template scripts.
    The array is accessed by name (a string), and can store any variant value,
    including COM/OLE objects. <b>Values</b> is the default array property
    of <see class=TWapApp>.
    <p>Example:<p>
    <DelphiCode>
      Session.Application['Color'] := clRed;
      Session.Application['Email'] := Request['EmailField'];
    </DelphiCode>

    @seeAlso <see method=TWapApp.Clear>,
      <see method=TWapApp.Lock>, <see method=TWapApp.Unlock>,
      <jump id=Scripts text=Scripts>, <see property=TWapSession.Values>
    }
    property Values[Index: string]: variant read GetValue write SetValue; default;

    {: This property provides access to the list of sessions object
    which are currently in memory.
    @seeAlso <see class=TWapSession>}
    property Sessions: TWapSessionList read FSessionList;
    {: Setting this property to True triggers changes in the behavior
    of WebApp which make debugging WebApp applications easier.
    <p>In the current release, setting it to True changes the timeout
    period to respond to a request from the server to a considerably
    longer amount than the default.
    <p>As a result, when this property is set to True, it is easier
    to step through the code. When it is false, stopping the program
    in the debugger for a long time cause the server to time-out on
    the request.
    <p>It is advised that you set this property to False when
    moving your application to the production environment.}
    property DebugMode: boolean read FDebugMode write SetDebugMode;
    {: This property reports the number of threads used by WebApp
    to handle requests from the server. Please note that this number
    can change through the lifetime of the application based on various
    factors such as the load on the server.}
    property ThreadCount: integer read GetThreadCount;

    {: <p>Returns the max. number of threads which will be created by the WebApp
    scheduling system per each CPU in the machine.</p>
    @seeAlso <see method=TWapApp.SetMaxThreadsPerCPU>, <see method=TWapApp.GetMaxThreads>,
    <see method=TWapApp.SetMaxThreads>, <jump id=Threads text="Threads">
    }
    class function GetMaxThreadsPerCPU: integer;

    {: <p>Sets the max. number of threads which will be created by the WebApp
    scheduling system per each CPU in the machine.</p>
    <p>This value can be changed only before the first TWapApp instance is activated.
    Note that the method is declared with a class scope, so that you can invoke it without
    actually creating a <see class=TWapApp> instance.</p>
    <p>Example:<p>
    <DelphiCode>
      TWapApp.SetMaxThreadsPerCPU(64);
    </DelphiCode>
    @seeAlso <see method=TWapApp.GetMaxThreadsPerCPU>, <see method=TWapApp.GetMaxThreads>,
    <see method=TWapApp.SetMaxThreads>, <jump id=Threads text="Threads">
    }
    class procedure SetMaxThreadsPerCPU(Value: integer);

    {: Returns the max. number of threads which will be created by the WebApp
    scheduling system. In the current version, this is the max number of threads
    per TWapApp instance, it will be changed to max number of threads per system (machine).
    @seeAlso <see method=TWapApp.GetMaxThreadsPerCPU>, <see method=TWapApp.SetMaxThreadsPerCPU>,
    <see method=TWapApp.SetMaxThreads>, <jump id=Threads text="Threads">
    }
    class function GetMaxThreads: integer;

    {: Sets the max. number of threads which will be created by the WebApp
    scheduling system. In the current version, this is the max number of threads
    per TWapApp instance, it will be changed to max number of threads per system (machine).
    <p>This value can be changed only before the first TWapApp instance is activated.
    Note that the method is declared with a class scope, so that you can invoke it without
    actually creating a <see class=TWapApp> instance.</p>
    <p>Example:<p>
    <DelphiCode>
      TWapApp.SetMaxThreads(64);
    </DelphiCode>
    @seeAlso <see method=TWapApp.GetMaxThreadsPerCPU>, <see method=TWapApp.SetMaxThreadsPerCPU>,
    <see method=TWapApp.SetMaxThreads>, <jump id=Threads text="Threads">
    }
    class procedure SetMaxThreads(Value: integer);

    //: This method is for internal use only!
    procedure InternalExecute(ThreadToken: longint; var Session: TWapSession; Request: THttpRequest; Response: THttpResponse);
published
    {: A unique identifier for the application.
     This application identifier will be used to invoke the application.
    You should set the value of this property at design time,
    or at run time before the application services any request.
    Attempting to change the value of this property once the application
    has serviced a request will raise an exception. }
    property AppId: string read FAppId write SetAppId;

    {: Determines if WebApp's automatic session management is enabled.
    If the value of this property is true, you should
    use the <see event=TWapApp.OnCreateSession> event to provide a new
    <see class=TWapSession> instance when required.
    By default the value of this property is <b>True</b>. }
    property MultiSession: boolean read FMultiSession write FMultiSession;

    {: This event occurs before the first new session is
    created. Use it to perform application-level initialization.
    @seeAlso <see event=TWapApp.OnEnd>, <see event=TWapSession.OnStart> }
    property OnStart: TWapAppNotifyEvent read FOnStart write FOnStart;

    {: This event occurs when a new HTTP request arrives from the client. <p>
      If the application supports multiple sessions
      (the <see property=TWapApp.MultiSession> property is set to <b>True</b>),
      the <b>OnExecute</b> event will occur before the request is routed to
      the session. <p>
      Use this event to provide a response to the user's request.
      @seeAlso <see event=TWapSession.OnExecute>}
    property OnExecute: TWapAppExecuteEvent read FOnExecute write FOnExecute;

    {: This event occurs when the application quits,
      after the last session's <see event TWapSession.OnEnd> event is called.
    @seeAlso <see event=TWapApp.OnStart>, <see event=TWapSession.OnEnd> }
    property OnEnd: TWapAppNotifyEvent read FOnEnd write FOnEnd;

    {: This event occurs when the application needs
      to create a new session.
      This event will occur only if the <see property=TWapApp.MultiSession>
      property is set to <b>True</b>.
      The event handler should create a new <see class=TWapSession> instance
      and return it in the <b>Session</b> parameter.
      Typically, instead of creating a <b>TWapSession</b> instance, the event
      will create a new instance of a <b>DataModule</b> which contains
      a <b>TWapSession</b> component, and return this <b>WapSession</b>
      instance:<p>
     <DelphiCode>
     procedure TForm1.WebApp1CreateSession(Sender: TObject; var Session: TWapSession);
     var
       Module: TSessionModule;
     begin
       // Create the data module that contains a TWapSession component
       Module := TSessionModule.Create(Application);
       // Return the TWapSession component instance from the data module
       Session := Module.WebSession1;
     end;
     </DelphiCode>}
    property OnCreateSession: TCreateSessionEvent read FOnCreateSession write FOnCreateSession;

    {: This event occurs when an unhandled exception occurs in the application.
    <p>Use OnException to change the default behavior that occurs during an
    unhandled exception in the application. The OnException event handler is
    called automatically in the HandleException method.
    <p>Note that the Request and Response parameters will be <strong>nill</strong>
    if the exception occurs outside the scope of a request.
    }
    property OnException: TWapAppExceptionEvent read FOnException write FOnException;
    {: This event occurs is triggered by one of the following conditions :
    <ul>
        <li>WebApp application has started
        <li>WebApp application has ended
        <li>A new session has started
        <li>A session has terminated
        <li>An HTTP request is received
        <li>Procesing of an HTTP request is done
    </ul>
    }
    property OnNotify: TWapAppNotificationEvent read FOnNotify write FOnNotify;
end;

{: This set is used by the <see TWapSession.Status> property.
  @enum wsExecuting
    This flag is on while the session is servicing a request
  @enum wsAbandoned
    This flag is on when the session is abandoned
}
TWapSessionStatus = set of (wsExecuting, wsAbandoned);

{: This enumeration type is used by the <see method=TWapSession.AddNotificationHandler>
  method. Values:
  @enum wseRequestStart
    The notification event is fired because a request is about to be started
  @enum wsAbandoned
    The notification event is fired because the request processing is finished
}
TWapSessionEvent = (wseRequestStart, wseRequestEnd);

{: This is a procedure type for event handlers which you could register with
  a <see class=TWapSession> component. When a request processing is either started
  or finished, each of the registered handler procedures is called.

 @param Session
    The <see class=TWapSession> object which sent this notification.
 @param Event
    Tells the procedure what happened (see <see class=TWapSessionEvent>).
}
TWapSessionNotificationEvent = procedure(Session: TWapSession; Event: TWapSessionEvent) of object;

{: The <b>TWapSession</b> component represents a single session with a user.
  This component is usually placed on a DataModule which is created dynamically
  by the <see event=TWapApp.OnCreateSession> event.

See the <jump id=sessions text="WebApp Sessions"> section for more information.

@SeeAlso <see class=TWapApp text="TWapApp component">
@component}
TWapSession = class(TComponent)
private
    { Private declarations }
    FSessionId: string;
    FRequest: THttpRequest;
    FResponse: THttpResponse;
    FApplication: TWapApp;
    FStatus: TWapSessionStatus;
    FWaitingRequests: integer;

    FThreadToken: longint;

    FTimeout: integer; // minutes
    FActions: TWapActionItems;
    FLastAccess: TDateTime;

    FOnStart: TWapSessionNotifyEvent;
    FOnEnd: TWapSessionNotifyEvent;
    FOnExecute: TWapSessionNotifyEvent;

    FFirstTime: boolean;
    FExecuteLock: TWin32CriticalSection;

    // Used by TWapSession.Execute and TWapSession.DispatchAction
    FActionsDispatched: boolean;

    // Used by CreateForm and SynchCreateForm
    FFormClassToCreate: TWinControlClass;
    FFormToDestroy: TWinControl;
    FCreatedForm: TWinControl;

    // Used by GetFormImage and SynchGetFormImage
    FFormToGetImage: TCustomForm;
    FFormImage: TBitmap;

    FNotificationList: TNotificationList;

    FValues: TVariantList;

    SessionEndCalled: boolean;
    VisualComponentsOwner: TComponent; // See CreateForm for information

    function GetValue(Index: string): variant;
    procedure SetValue(Index: string; Value: variant);

    procedure SetActions(Value: TWapActionItems);
    function GetRequest: THttpRequest;
    function GetResponse: THttpResponse;
    function GetStatus: TWapSessionStatus;

    procedure SynchCreateForm;
    procedure SynchFreeForm;
    procedure SynchGetFormImage;
    function UnsafeCreateModule(Owner: TComponent; ModuleClass: TComponentClass): TComponent;
    procedure SynchDestroyVisualComponents;
    // invoked by WapApp
    procedure InternalExecute(Request: THttpRequest; Response: THttpResponse);
protected
    { Protected declarations }
    procedure   Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure   SessionStart; virtual;
    procedure   Execute; virtual;
    procedure   SessionEnd; virtual;
    procedure   LockSession;
    procedure   UnLockSession;
public
    { Public declarations }
    //: A standard constructor
    constructor Create(AOwner: TComponent); override;
    //: A standard destructor
    destructor Destroy; override;

    {: <p>This method adds a procedure to the list of procedures to be called
    on various session-related events.
    <p>When you no longer wish to be notified of such events, call
    the <see method=TWapSession.RemoveNotificationHandler> method}
    procedure AddNotificationHandler(Handler: TWapSessionNotificationEvent);

    {: <p>This method removes a procedure which was added by <see method=TWapSession.AddNotificationHandler>
    from the list of session notification events handlers.}
    procedure RemoveNotificationHandler(Handler: TWapSessionNotificationEvent);

    {: <p>Call this method to manually trigger the action dispatching process for
    the current reqeust. This method is usefull when implementing post-processing of
    requests in the <see event=TWapSession.OnExecute> event.}
    function DispatchActions: boolean;

    {: This method marks a session for deletion. <p>
    Normally <jump id=sessions> are deleted when they
    are not accessed by the user for a time period that
    exceeds the session's <see property=TWapSession.Timeout> property.
    Calling <b>Abandon</b> overrides this behavior.<p>
    <b>Abandon</b> will not actually delete a
    session, it will only queue it for later deletion. In
    particular, a session will not be deleted while it is
    servicing a request. Therefore, it is safe to call <b>Abandon</b>
    from any of the session events.}
    procedure Abandon;

    {: Deletes all the values added to the <see property=TWapSession.Values> array.}
    procedure Clear;

    {: This method creates a
    new instance of the module specified by the ModuleClass
    parameter, and associates it with the rest of the session
    modules. The method returns the new instance.
    <p>To free objects created using this method, use the <see method=FreeModule> method.
    <p>See the "Using multiple Data Modules" section in the WebApp User Guide
    for additional information.
    @seeAlso <see method=FreeModule>, <see method=CreateForm>, <see class=TWapModule>
    }
    function CreateModule(ModuleClass: TComponentClass): TComponent;

    {: FreeModule should be used to free objects which were created
    using the <see method=CreateModule> method.
    @seeAlso <see method=CreateModule>}
    {$ifdef wap_cbuilder_3}
        {$HPPEMIT '// FreeModule is defined in winbase.h as an alias for FreeLibrary.'}
        {$HPPEMIT '// This definition conflicts with the definition of TWapSession.FreeModule.'}
        {$HPPEMIT '// We will un-define FreeModule here :'}
        {$HPPEMIT '#undef FreeModule'}
    {$endif wap_cbuilder_3}
    procedure FreeModule(Module: TComponent);

    {: This method serves the same purpose as
      <see method=TWapSession.CreateModule>, except that it creates forms.
      Use it when you need to create forms (or other visual
      controls) which will be associated with the session
      module.<p>
      To avoid multi-thread conflicts, the <strong>CreateForm</strong>
      method creates the visual control in the main application
      thread.</p>
      <p>The <strong>CreateForm</strong> method is useful when
      you wish to use a visual control (such as a chart) to
      generate an image which will be sent to the browser. Use
      the <see method=TWapSession.GetFormImage>
      function to retrieve the image (bitmap) of a form in a
      thread-safe manner, and Response.<see method=TResponse.SendBitmapAsGIF
      text="SendBitmapAsGIF"> or Response.<see method=TResponse.SendBitmapAsJPEG
      text="SendBitmapAsJPEG"> to send it to the browser.<p>
      <b>NOTE</b>: If you place any of the Delphi
      Data Access components (TTable, TQuery, TDatabase etc.)
      in the data module, you must place a <see class=TDBAutoSession>
      component as well.
    }
    function CreateForm(FormClass: TWinControlClass): TWinControl;
    {: FreeModule should be used to free objects which were created
    using the <see method=CreateForm> method.
    @seeAlso <see method=CreateForm>}
    procedure FreeForm(Form: TWinControl);

    {: Retrieves a bitmap image of the Form in a thread-safe manner.
      It is useful when you wish to use a visual control (such as a chart)
      to generate an image which will be sent to the browser.
      Use Response.<see method=TResponse.SendBitmapAsGIF
      text="SendBitmapAsGIF"> or Response.<see method=TResponse.SendBitmapAsJPEG
      text="SendBitmapAsJPEG"> to send it to the browser. }
    function GetFormImage(Form: TCustomForm): TBitmap;

    {: Retrieves the web application
    (<see class=TWapApp> component) that created the session }
    property Application: TWapApp read FApplication;

    {: This object provides access to the values sent by the client
    browser to the server during a HTTP request.
    The <b>Request</b> object is valid only during the duration of the
    <see event=OnExecute class=TWapSession> and <see event=OnStart class=TWapSession>
    events. Attempting to access it at other time will raise an exception.
    @seeAlso  <see property=TWapSession.Response>}
    property Request: THttpRequest read GetRequest;

    {: This object is used to send output to the client,
    in response to a client browser request.
    The <b>Response</b> object is valid only during the duration of
    the <see event=OnExecute class=TWapSession>
    and <see event=OnStart class=TWapSession> events.
    Attempting to access it at other time will raise an exception.
    @seeAlso  <see property=TWapSession.Request>}
    property Response: THttpResponse read GetResponse;

    {: Contains a unique string that identifies the session during its
    lifetime. This identifier is automatically generated by
    <B>WebApp</b> when the session is created and cannot be changed.
    <p>Do not use the value of the <strong>SessionId</strong>
    property as a key in database applications, since Session
    Ids may be reused.
    @seeAlso <jump id=Sessions Text="WebApp Sessions">}
    property SessionId: string read FSessionId;

    {: Retrieves the date and time when the session has serviced the last
     request.
     @seeAlso <see property=TWapSession.TimeOut>, <see method=TWapSession.Abandon>   }
    property LastAccess: TDateTime read FLastAccess;

    {: This property indicates the number of requests waiting
    in the WebApp queue to be handled.
    @seeAlso <see property=ActiveRequests>}
    property WaitingRequests: integer read FWaitingRequests;

    {: Describes the current state of the session. Read-only.
       It can contain any combination of the following flags:<p>
       @enum wsExecuting
          This flag is on while the session is servicing a request<p>
       @enum wsAbandoned
          This flag is on when the session is abandoned
      @seeAlso <see method=TWapSession.Abandon>    }
    property Status: TWapSessionStatus read GetStatus;

    {:This array property provides a convinient place to store session-wide
     values which needs to be accessed by template scripts.<p>
     The array is accessed by name (a string), and can store any variant
     value, including COM/OLE objects.<p>
     <b>Values</b> is the default array property of <see class=TWapSession>.
     <p>For example:<p>
     <DelphiCode>
     Session['Color'] := clRed;
     Session['Email'] := Request['EmailField'];
     </DelphiCode>
     @seeAlso <see method=TWapSession.Clear>,
        <see property=TWapApp.Values>, <jump id=Scripts>
     }
    property Values[Index: string]: variant read GetValue write SetValue; default;

    //: This property is for internal use only
    property ThreadToken: longint read FThreadToken;
published
    { Published declarations }
    {: The <b>TimeOut</b> property specifies the timeout period for the session,
     in minutes. If the user with which a session is associated with does not
     refresh makes a request within the timeout period, the session ends.
     The default value for this property is 20 minutes.
     To end a session before its timeout period expires,
     use the <see method=Abandon class=TWapSession> method.
    @seeAlso <see property=LastAccess class=TWapSession>, <see event=TWapSession.OnEnd>
    }
    property Timeout: integer read FTimeout write FTimeout;


    {: This is the collection of action items maintained by the session.
     See <see class=TWapActionItems> and <see class=TWapActionItem> for more
     details. At design time, use the Actions property editor to maintain
     the collection. }
    property Actions: TWapActionItems read FActions write SetActions stored true;

    {: The <b>OnStart</b> event occurs when the server creates the session, before
    the <see event=TWapSession.OnExecute> event. This event is useful for performing
    session initialization, such as opening database tables.
    The <see property=TWapSession.Request> and <see property=TWapSession.Response>
    objects are available during this event.
    @example
    <DelphiCode>
    procedure TSampleSessionWebSession1.OnStart(Session: TWapSession);
    begin
      Counter := 0;
    end;
    procedure TSampleSessionWebSession1.OnExecute(Session: TWapSession);
    begin
      Inc(Counter);
      Writeln(Response.TextOut, 'This is the ', Counter, 'th time this session is accessed');
    end;
    </DelphiCode>
    @seeAlso <see event=TWapSession.OnExecute>, <see event=TWapSession.OnEnd>  }
    property OnStart: TWapSessionNotifyEvent read FOnStart write FOnStart;

    {: The OnExecute event occurs when the session needs to service a request.
    The <see property=TWapSession.Request> and <see property=TWapSession.Response>
    objects are available during this event.

    @example
    <DelphiCode>
    procedure TSampleSessionWebSession1.OnExecute(Session: TWapSession);
    begin
      Writeln(Response.TextOut, 'Hello World');
    end;
    </DelphiCode>

    <p>The OnExecute event is called <strong>before</strong> the actions are
    dispatched, so it's a good place to insert code which should be executed before
    any of the actions, such as user authentication.
    <p>You can also use the OnExecute event to write code which will be executed <strong>after</strong>
    the last action is dispatched, by calling the <see method=TWapSession.DispatchActions> method,
    and adding the post processing code after it (if the DispatchActions method is not called
    during the OnExecute event, it will be automatically called after it completes).

    @example
    <DelphiCode>
    procedure TSampleSessionWebSession1.OnExecute(Session: TWapSession);
    begin
      if not UserValidated then
      begin
        Response.Redirect('/ValidateUser.html');
        exit;
      end;

      WapSession1.DispatchActions;

      Log('Yet another page was served at ' + TimeToStr(Now));
    end;
    </DelphiCode>
    }
    property OnExecute: TWapSessionNotifyEvent read FOnExecute write FOnExecute;

    {: This event occurs when the session is abandoned or times out.<p>
    The <see property=TWapSession.Request> and <see property=TWapSession.Response>
    objects are available during this event.
    @seeAlso <see event=TWapSession.OnExecute>, <see event=TWapSession.OnStart>  }
    property OnEnd: TWapSessionNotifyEvent read FOnEnd write FOnEnd;
end;

{:  This class is used by the <see TWapApp.Sessions> property. It is a thread-safe collection
    of <see class=TSession> objects. Use it to access and manipulate the session list.
}
TWapSessionList = class(TComponent)
private
    FSessions: TStringList;
    FLock: TWin32CriticalSection;
    FEmptyEvent: TWin32Event;
    function GetCount: integer;
    function GetSessionByIndex(Index: integer): TWapSession;
    property EmptyEvent: TWin32Event read FEmptyEvent write FEmptyEvent;
protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
public
    //: A standard constructor
    constructor Create(AOwner: TComponent); override;
    //: A standard destructor
    destructor Destroy; override;

    {: Locks access to the Sessions list so that it cannot be
    manipulated by code running in other threads.
    <p>You should call the Lock method before attempting to perform
    a multi-step operation on the sessions list, to prevent other threads
    from changing the list.
    <p>Each call to the Lock method must be followed by a call to <see method=Unlock>.
    <p>Example:<p>
    <DelphiCode>
      WapApp1.Sessions.Lock;
      try
        Writeln(Response.TextOut, 'Currently runnig sessions:');
        for i := 0 to (WapApp1.Sessions.Count - 1) do
        begin
          Writeln(Response.TextOut, WapApp1.Sessions[i].SessionId);
        end;
      finally
        WapApp1.Sessions.Unlock;
      end;
    </DelphiCode>
    @seeAlso <see method=UnLock>.  }
    procedure Lock;
    {: Unlocks access to the Sessions list, allowing other threads
    to manipulate the list again.
    <p>Each call to the <see method=Lock> method must be followed by a call to Unlock.
    @seeAlso <see method=UnLock>.  }
    procedure Unlock;

    {: Adds a session to the list }
    procedure Add(Session: TWapSession);
    {: Deletes a session from the list }
    procedure Delete(Session: TWapSession);
    {: Finds in the list and returns a session by its ID or NIL if the session
      isn't found. If you need to enumerate all sessions in the list,
      use the default <see property=TWapSessionList.Sessions text="Sessions[]">
      property instead. }
    function GetSession(const SessionId: string): TWapSession;

    {: Use this instead of Session.Free to free the Session container (Owner)
     as well }
    procedure FreeSession(Session: TWapSession);

    {: Returns the number of <see class=TSession> objects in the list}
    property Count: integer read GetCount;
    {: This is the default array property which allows you to access the
     sessions by index. You can omit the <b>Sessions</b> property name,
     appending the <i>[index]</i> right after
     the <see class=TWapSessionList> instance.}
    property Sessions[Index: integer]: TWapSession read GetSessionByIndex; default;
end;

{: The <strong>TWapModule </strong>component
  should be placed on data modules or forms which are
  associated with a <see class=TWapSession>
  component on another module, if you need access to the
  session, request or response from these modules and
  forms.<p>
  Such modules and forms are created using
  <see method=TWapSession.CreateModule> and
  <see method=TWapSession.CreateForm> methods.
  @component  
}
TWapModule = class(TComponent)
private
    FSession: TWapSession;
    function GetRequest: THttpRequest;
    function GetResponse: THttpResponse;
    procedure VerifySession;
public
    {: Through this property you can access the session's
    associated <see class=THttpRequest> object, once
    the <see property=TWapModule.Session text=Session> property
    is assigned. <b>Runtime, read-only. </b>}
    property Request: THttpRequest read GetRequest;
    {: Through this property you can access the session's
    associated <see class=THttpResponse> object, once
    the <see property=TWapModule.Session text=Session> property
    is assigned. <b>Runtime, read-only. </b>}
    property Response: THttpResponse read GetResponse;
published
    {: The associated <see class=TWapSession> instance.
    It should point to the <b>TWapSession</b>
    instance on the main session module. Before you
    can point it to this instance, you will need to
    add the session module unit to your USES clause
    using the <i>File|Use Unit</i> option in the Delphi
    IDE.}
    property Session: TWapSession read FSession write FSession;
end;

{: @todo  describe }
TWapSessionState = class(TObject)
private
    FValues: TVariantList;
    FObjects: TExStringList;
    function GetObject(const Name: string): TComponent;
    procedure SetObject(const Name: string; Instance: TComponent);
public
    // constructor can't be private, BCB doesn't like it. 
    constructor Create;
    destructor Destroy; override;
    property Values: TVariantList read FValues;
    property Objects[const Name: string]: TComponent read GetObject write SetObject;
end;

////////////////////////////////////////////////////////////////////////////////////////////////////
implementation
////////////////////////////////////////////////////////////////////////////////////////////////////

uses InetStr, CookUtil, TimeUtil, HAWRIntf, WIpcShrd
    ,WapSchdl, WapTXRdr, WCP, Registry

{$ifdef wap_delphi_2_or_cbuilder_1}
    ,Ole2 // for CoCreateGuid
{$endif wap_delphi_2_or_cbuilder_1}

{$ifdef wap_delphi_3_or_delphi_4_or_cbuilder_3}
    ,ActiveX // for CoCreateGuid
{$endif wap_delphi_3_or_delphi_4_or_cbuilder_3}
    ;

{$include wcp.inc}

const
    DebugModeStubTimeout = 5 * 60; // 5 miutes
    DefaultStubTimeout = 30;    // 30 seconds

var
    OriginalFindGlobalComponent: TFindGlobalComponent = nil;
    FindGlobalComponentLock: TWin32CriticalSection = nil;
    FindGlobalComponentActiveSession: TWapSession = nil;
    ComponentDestructionLock: TWin32CriticalSection = nil;

function WaitForWithProcessMessages(Win32Object: TWin32StdWaitableObject; TimeOut: integer): TWaitResult;
var
    Start: TDateTime;
    TimeLeft: integer;
begin
    Result := wrTimeOut;
    Start := Now;
    Application.ProcessMessages;
    repeat
        TimeLeft := Trunc(TimeOut - ((Now - Start) * MSecsPerDay));
        if (TimeLeft <= 0) then begin
            Result := wrTimeOut;
            break;
        end;
        Result := Win32Object.MsgWaitFor(TimeLeft, QS_ALLINPUT);
        if (Application.Terminated) then begin
            result := wrTimeOut
        end else if (Result = wrInputAvailable) then begin
            Application.ProcessMessages;
        end;
    until (result <> wrInputAvailable);
end;

    
////////////////////////////////////////////////////////////////////////////////////////////////////
//
// TWapSessionNotificationEventList
//
////////////////////////////////////////////////////////////////////////////////////////////////////
type

TWapSessionNotificationEventList = class(TNotificationList)
protected
    procedure   DispatchNotification(const Method: TMethod; Params: TObject; var Continue: boolean); override;
public
    procedure   Notify(Session: TWapSession; Event: TWapSessionEvent);
    procedure   Add(Event: TWapSessionNotificationEvent);
    procedure   Delete(Event: TWapSessionNotificationEvent);
end;

TWapSessionNotificationEventListParams = class
public
    Session: TWapSession;
    Event: TWapSessionEvent;
end;

procedure TWapSessionNotificationEventList.DispatchNotification(const Method: TMethod; Params: TObject; var Continue: boolean); 
var
    Handler: TMethod;
begin
    Handler := Method;
    with TWapSessionNotificationEventListParams(Params) do
        TWapSessionNotificationEvent(Handler)(Session, Event);
end;

procedure TWapSessionNotificationEventList.Notify(Session: TWapSession; Event: TWapSessionEvent);
var
    p: TWapSessionNotificationEventListParams;
begin
    p := TWapSessionNotificationEventListParams.Create;
    p.Session := Session;
    p.Event := Event;
    DoNotify(p);
end;

procedure   TWapSessionNotificationEventList.Add(Event: TWapSessionNotificationEvent);
var
    m: TMethod;
begin
    m := TMethod(event);
    DoAdd(m);
end;

procedure   TWapSessionNotificationEventList.Delete(Event: TWapSessionNotificationEvent);
var
    m: TMethod;
begin
    m := TMethod(event);
    DoRemove(m);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////
//
// TOldSessionsCleanerThread
//
// The thread is used internally by the list to dispose of expired sessions.
//
////////////////////////////////////////////////////////////////////////////////////////////////////
type
TOldSessionsCleanerThread = class(TThreadEx)
private
    FScheduler: TWapScheduler;
    FSessionList: TWapSessionList;
protected
    procedure   DoExecute(Thread: TThreadEx);
public
    constructor Create(SessionList: TWapSessionList; Scheduler: TWapScheduler);
end;

constructor TOldSessionsCleanerThread.Create(SessionList: TWapSessionList; Scheduler: TWapScheduler);
begin
    inherited Create(true, DoExecute);
    FSessionList := SessionList;
    FScheduler := Scheduler;
    Priority := tpLower;
    Resume;
end;

procedure   TOldSessionsCleanerThread.DoExecute(Thread: TThreadEx);
var
    i: integer;
    Session: TWapSession;
begin
    while (not Terminated) do begin
        i := 0;
        while (true) do begin
            Sleep(1);   // give up time slice
            if (Terminated) then
                BREAK;
            FSessionList.Lock;
            try
                // end of Sessions list ?
                if (i >= FSessionList.Count) then
                    BREAK;
                Session := TWapSession(FSessionList.Sessions[i]);
                // Session expired ?
                if ((Session.LastAccess + (Session.TimeOut * MinutesToDateTime)) < Now) then begin
                    Session.Abandon;
                    FScheduler.ScheduleForRemoval(FSessionList, Session); // Destroy it in its thread
                end;
                inc(i);
            finally
                FSessionList.Unlock;
            end;
        end; // while forever
    end; // while not terminated
end;


////////////////////////////////////////////////////////////////////////////////////////////////////
//
//      TWapApp
//
////////////////////////////////////////////////////////////////////////////////////////////////////

{$ifdef webapp_trial}
function IsIDERunning: boolean;
var
        wnd: HWnd;
    sz: array[byte] of char;
    s: string;
begin
        result := false;
    { check for a window with the class TAppBuilder }
        wnd := FindWindow('TAppBuilder', nil);
    if (wnd = 0) then
        exit;
    { check that it has the word delphi in the title }
    GetWindowText(wnd, sz, sizeof(sz)-1);
    s := UpperCase(StrPas(sz));
    if ((Pos('DELPHI', s) = 0) and (Pos('BUILDER', s) = 0)) then
        exit;
    result := true;
end;
{$endif webapp_trial}

constructor TWapApp.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);

{$ifdef webapp_trial}
    if (not IsIDERunning) then
        raise Exception.Create('This is a trial version of WebApp. This trial ' +
            'version can only be run when the Delphi or C++ Builder IDE is running');
{$endif webapp_trial}

    FMultiSession := true;
    FIsFirstRequest := true;

    FValues := TVariantList.Create;

    if (not (csDesigning in ComponentState)) then begin
        FSessionList := TWapSessionList.Create(nil);
        FScheduler := TWapScheduler.Create(nil);

        // Load the DLL even though we don't need it. This will reduce the load time
        // of non-persistant stubs, such as the CGI or the WinCGI stubs, since the DLL
        // will already be in memory.
        FWebAppModuleHandle := LoadLibrary('HAWEBAPP.DLL');
        if (FWebAppModuleHandle = 0) then begin
            raise Exception.Create('Unable to load the WebApp Runtime DLL (HAWEBAPP.DLL), due ' +
                'to the following error : "' + SysErrorMessage(GetLastError) + '". Please reinstall ' +
                'WebApp.');
        end;

        Start;
    end;
end;

destructor  TWapApp.Destroy;
begin
    if (not (csDesigning in ComponentState)) then begin
        Stop;

        FRequestsReader.Free;
        FScheduler.Free;
        FSessionList.Free;
    end;

    FValues.Free;

    inherited destroy;
end;

procedure TWapApp.InternalOnExceptionHandler(Sender: TObject; E: Exception);
begin
    raise E at ExceptAddr;
end;

procedure TWapApp.Start;
begin
    if (FActive) then
        exit;

    TWapScheduler(FScheduler).Start;
    FOldSessionsCleanerThread := TOldSessionsCleanerThread.Create(FSessionList, TWapScheduler(FScheduler));

    FAppInitializedEvent := TWin32Event.Create(FormatSharedName(AppInitializedEventName, AppId), true, @NoSecurityAttributes);
    FAppInitializedEvent.Signal;

    FActive := true;
end;

procedure TWapApp.Stop;
var
    i: integer;
const
    SessionsTerminateTimeout = 30 * 1000;
    ThreadsTerminateTimeout = 30 * 1000;
begin
    {$ifdef cp_on}cp(1, '<TWapApp.Stop');{$endif cp_on}
    if (not FActive) then
        exit;

    FActive := false;

    FAppInitializedEvent.Reset;
    FAppInitializedEvent.Free;
    FAppInitializedEvent := nil;

    // First we need to dispose of the cleaner thread, so that it doesn't
    // try to do stuff while we are cleaning up.
    // Locking the Sessions list will prevent a possible dead-Lock
    if (FOldSessionsCleanerThread <> nil) then begin
        FSessionList.Lock;
        try
            // ask the thread to terminate
            FOldSessionsCleanerThread.SignalTerminate;
            // wait for the thread to terminate
            FOldSessionsCleanerThread.WaitFor;
            FOldSessionsCleanerThread.Free;
            FOldSessionsCleanerThread := nil;
        finally
            FSessionList.Unlock;
        end;
    end;

    FSessionList.Lock;
    try
        for i := (FSessionList.Count - 1) downto 0 do begin
            TWapScheduler(FScheduler).ScheduleForRemoval(FSessionList, FSessionList.Sessions[i]); // Destroy it in its thread
        end;
    finally
        FSessionList.Unlock;
    end;

    {$ifdef cp_on}cp(0, 'TWapApp.Stop.BeforeEmptyEvent');{$endif cp_on}
    // Wait up to 30 seconds for the sessions to terminate
    WaitForWithProcessMessages(FSessionList.EmptyEvent, SessionsTerminateTimeout);
    {$ifdef cp_on}cp(0, 'TWapApp.Stop.AfterEmptyEvent');{$endif cp_on}

    // Wait up to 30 seconds for the sessions to terminate
    TWapScheduler(FScheduler).Stop(ThreadsTerminateTimeout);
    
    // AppStart will be called only on the First Request, so call
    // AppEnd only if at least one Request was made
    if (not FIsFirstRequest) then
        AppEnd;
    {$ifdef cp_on}cp(-1, 'TWapApp.Stop>');{$endif cp_on}
end;

procedure TWapApp.InitSharedCookie(Request: THttpRequest; Response: THttpResponse);
begin
    with Response.cookies[SharedCookieName] do begin
        Assign(Request.Cookies[SharedCookieName]);
        Delete('WA_APPID');
        Delete('WA_SID');

        // setup the shared cookie properties
        ExpiresOnLocalTime := 0;    // expires on end of browser Session
        Path := URLRemoveFilename(Request.ScriptName);
        Domain := '';
        Secure := false;
    end;
end;

procedure TWapApp.AppStart;
begin
    Notify(wnApplicationStart);
    if assigned(FOnStart) then
        FOnStart(self);
end;

procedure TWapApp.AppEnd;
begin
    if assigned(FOnEnd) then
        FOnEnd(self);
    Notify(wnApplicationEnd);
end;

// If session was created, it is returned in the Session parameter
procedure TWapApp.InternalExecute(ThreadToken: longint; var Session: TWapSession; Request: THttpRequest; Response: THttpResponse);
begin
    InterlockedIncrement(FActiveRequests);
    Notify(wnRequestStart);
    try
        try
            if (FIsFirstRequest) then begin
                AppStart;
                FIsFirstRequest := false;
            end;

            InitSharedCookie(Request, Response);

            // if (Request.Cookies[SharedCookieName]['WA_APPID'] <> AppId) then
            Response.Cookies[SharedCookieName]['WA_APPID'] := AppId;

            // always give the app a chance to process the Request before the Session
            // kicks in
            Execute(Request, Response);
            // allow Session code to execute. DispatchToSession will add its own
            // entries to the shared cookie, and modify the expiration date
            if (FMultiSession) then
                DispatchToSession(ThreadToken, Session, Request, Response);
        except
            on e: Exception do
                HandleException(Self, Request, Response);
        end;
    finally
        InterlockedDecrement(FActiveRequests);
        Notify(wnRequestEnd);
    end;
end;

procedure TWapApp.Execute(Request: THttpRequest; Response: THttpResponse);
begin
    if assigned(FOnExecute) then
        FOnExecute(self, Request, Response);
end;

// If session is nil, will create it and return it in the Session parameter.
// Note that even though the session may be created, the Session parameter
// may still be nil if the session was abandoned!
procedure TWapApp.DispatchToSession(
    ThreadToken: longint;
    var Session: TWapSession;
    Request: THttpRequest;
    Response: THttpResponse);
var
    OldOnException: TExceptionEvent;
begin
    // nil Session indicitas that we need to create a new session
    if (Session = nil) then begin
        FindGlobalComponentLock.Enter;
        OldOnException := Forms.Application.OnException;
        Forms.Application.OnException := InternalOnExceptionHandler;
        try
            Session := CreateSession;
        finally
            Forms.Application.OnException := OldOnException;
            FindGlobalComponentLock.Leave;
        end;
        if (Session = nil) then
            raise EWapApp.Create('Session not created by CreateSession');
        Session.FApplication := self;
        Session.FThreadToken := ThreadToken;
        FSessionList.Add(Session);
    end;

    // if (Request.cookies[sharedCookieName]['WA_SID'] <> Session.SessionId) then
    Response.Cookies[SharedCookieName]['WA_SID'] := Session.SessionId;

    Session.internalExecute(Request, Response);
    // Delete abandoned sessions immediatly
    if ((wsAbandoned in Session.Status) and (Session.WaitingRequests = 0)) then begin
        FSessionList.FreeSession(Session);
        Session := nil;
    end;
end;

procedure TWapApp.Notify(Notification: TWapAppNotification);
begin
    if assigned(FOnNotify) then
        FOnNotify(Self, Notification);
end;

function TWapApp.CreateSession: TWapSession;
begin
    result := nil;
    if assigned(FOnCreateSession) then
        FOnCreateSession(self, result);
end;

// called for Exceptions that originated in the proxy, before it called back into
// us, possibly in another thread.
procedure TWapApp.HandleRequestsReaderException(Sender: TObject; E: Exception);
begin
    HandleException(Self, nil, nil);
end;

function RegReadString(RootKey: HKEY; const Key, Name: string): string;
var
    R: TRegistry;
begin
    R := TRegistry.Create;
    try
        R.RootKey := RootKey;
        if (R.OpenKey(Key, false) and R.ValueExists(Name)) then
            result := R.ReadString(Name)
        else
            result := '';
    finally
        R.Free;
    end;
end;

function ReadAppRoot(const AppId: string): string;
begin
    result := RegReadString(HKEY_LOCAL_MACHINE, 'Software\HyperAct\WebApp\Applications\' + AppId + '\URLMap', 'Root');
end;

procedure   TWapApp.AppIdChanged;
begin
    // Create new proxy if needed
    if ((FAppId <> '') and (not (csDesigning in componentState))) then begin
        FAppRoot := ReadAppRoot(FAppId);
        FRequestsReader := TWapRequestsReader.Create(
            Self,
            TWapScheduler(FScheduler),
            FSessionList
            );
        TWapRequestsReader(FRequestsReader).OnException := HandleRequestsReaderException;
        TWapRequestsReader(FRequestsReader).StubTimeout := DefaultStubTimeout;
        TWapRequestsReader(FRequestsReader).Start;
    end;
end;

procedure   TWapApp.SetAppId(const Value: string);
begin
    try
        if (value <> FAppId) then begin
            if ((FAppId <> '') and (not (csDesigning in componentState))) then
                raise EWapApp.Create('AppId cannot be changed while the application is running');
            FAppId := Value;
            AppIdChanged;
        end; { if }
    except
        on E: Exception do
            Application.HandleException(Self);
    end;
end;

procedure TWapApp.ReportException(Sender: TObject; E: Exception; Request: THttpRequest; Response: THttpResponse);
begin
    if (Response <> nil) then begin
        with Response do begin
            writeln(TextOut, '<p>');
            writeln(TextOut, '<h1>Error</h1>');
            writeln(TextOut, '<p>');
            writeln(TextOut, 'Exception : ' + e.message);
            if (Request <> nil) then begin
                writeln(TextOut, '<p>');
                writeln(TextOut, 'QueryString : ' + Request.QueryString.AsString);
                writeln(TextOut, '<p>');
                writeln(TextOut, 'LogicalPath : ' + Request.LogicalPath);
            end;
        end;
    end;
    // tbd : should add writing to the NT event log
end;

procedure TWapApp.HandleException(Sender: TObject; Request: THttpRequest; Response: THttpResponse);
begin
    try
        if (ExceptObject is Exception) then begin
            if (not (ExceptObject is EAbort)) then begin
                if assigned(FOnException) then
                    FOnException(Sender, Exception(ExceptObject), Request, Response)
                else
                    ReportException(Sender, Exception(ExceptObject), Request, Response);
            end;
        end else begin
    // tbd        ReportException(Sender, ExceptObject, Request, Response);
        end;
    except
        ;
    end;
end;

function TWapApp.GetValue(Index: string): variant;
begin
    result := FValues[Index];
end;

procedure TWapApp.SetValue(Index: string; Value: variant);
begin
    FValues[Index] := Value;
end;

procedure TWapApp.Clear;
begin
    FValues.Clear;
end;

procedure TWapApp.Lock;
begin
    FValues.Lock;
end;

procedure TWapApp.Unlock;
begin
    FValues.UnLock;
end;

function TWapApp.GetThreadCount: integer;
begin
    result := TWapScheduler(FScheduler).ThreadCount;
end;

class function TWapApp.GetMaxThreadsPerCPU: integer;
begin
    result := TWapScheduler.GetMaxThreadsPerCPU;
end;

class procedure TWapApp.SetMaxThreadsPerCPU(Value: integer);
begin
    TWapScheduler.SetMaxThreadsPerCPU(Value);
end;

class function TWapApp.GetMaxThreads: integer;
begin
    result := TWapScheduler.GetMaxThreads;
end;

class procedure TWapApp.SetMaxThreads(Value: integer);
begin
    TWapScheduler.SetMaxThreads(Value);
end;

procedure TWapApp.SetDebugMode(Value: boolean);
begin
    if (Value <> FDebugMode) then begin
        FDebugMode := Value;
        if (FDebugMode) then begin
            if (FRequestsReader <> nil) then
                TWapRequestsReader(FRequestsReader).StubTimeout := DebugModeStubTimeout;
        end else begin
            if (FRequestsReader <> nil) then
                TWapRequestsReader(FRequestsReader).StubTimeout := DefaultStubTimeout;
        end;
    end;
end;

function CreateStringGUID: string;
var
    GUID: TGUID;
    P: PWideChar;
begin
    CoCreateGUID(GUID);
    StringFromCLSID(GUID, P);
    result := WideCharToString(P);
    CoTaskMemFree(P);
end;

function    GenerateUniqueSessionId: string;
var
    p: integer;
begin
    result := CreateStringGUID;
    // remove the leading "{" and trailing "}"
    result := copy(result, 2, length(result) - 2);
    // remove the embedded "-"
    repeat
        p := pos('-', result);
        if (p > 0) then
            Delete(result, p, 1);
    until (p = 0);
end;


constructor TWapSession.Create(AOwner: TComponent);
begin
    inherited Create(AOwner);
    FExecuteLock := TWin32CriticalSection.Create;
    FFirstTime := true;
    FSessionId := GenerateUniqueSessionId;
    FTimeout := 20; // default expiration time (in minutes)
    FLastAccess := now;
    FValues := TVariantList.Create;
    FActions := TWapActionItems.Create(Self);
    FNotificationList := TWapSessionNotificationEventList.Create;
    VisualComponentsOwner := TComponent.Create(Forms.Application);
    VisualComponentsOwner.FreeNotification(Self);
end;

destructor TWapSession.Destroy;
begin
    // CallInMainThread cannot be called while the application is being terminated,
    // so we'll have to let the visual components destroyed by the Application object
    // in due time. This will happen because all visual components created by
    // the session are owned by VisualComponentsOwner, which is in turn owned
    // by the Forms.Application object.
    ComponentDestructionLock.Enter;
    try
        if (not Forms.Application.Terminated) then
            CallInMainThread(SynchDestroyVisualComponents);
    finally
        ComponentDestructionLock.Leave;
    end;

    SessionEnd;

    FNotificationList.Free;

    FExecuteLock.Free;
    FExecuteLock := nil;
    FActions.Free;
    FValues.Free;

    inherited destroy;
end;

procedure TWapSession.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited;
    if ((AComponent = VisualComponentsOwner) and (Operation = opRemove)) then
        VisualComponentsOwner := nil;
end;


// Visual components must be destroyed in the main thread.
// This method is called by the destructor after switching to the main thread!
procedure TWapSession.SynchDestroyVisualComponents;
begin
    // Destroying the visual components owner will destroy them as well.
    // See CreateForm for additional information
    VisualComponentsOwner.Free;
    VisualComponentsOwner := nil;
end;

procedure TWapSession.AddNotificationHandler(Handler: TWapSessionNotificationEvent);
begin
    TWapSessionNotificationEventList(FNotificationList).Add(Handler);
end;

procedure TWapSession.RemoveNotificationHandler(Handler: TWapSessionNotificationEvent);
begin
    TWapSessionNotificationEventList(FNotificationList).Delete(Handler);
end;

procedure   TWapSession.LockSession;
begin
    FExecuteLock.Enter;
end;

procedure   TWapSession.UnLockSession;
begin
    FExecuteLock.Leave;
end;

procedure TWapSession.InternalExecute(Request: THttpRequest; Response: THttpResponse);
begin
    InterlockedIncrement(FWaitingRequests);
    LockSession;
    try
        FStatus := FStatus + [wsExecuting];
        try
            FLastAccess := now;
            FRequest := Request;
            FResponse := Response;
            try
                if (FFirstTime) then begin
                    SessionStart;
                    FFirstTime := false;
                end;
                FActionsDispatched := false;

                TWapSessionNotificationEventList(FNotificationList).Notify(Self, wseRequestStart);
                try
                    Execute;
                    if (not FActionsDispatched) then
                        DispatchActions;
                finally
                    TWapSessionNotificationEventList(FNotificationList).Notify(Self, wseRequestEnd);
                end;
            finally
                FRequest := nil;
                FResponse := nil;
            end;
        finally
            FStatus := FStatus - [wsExecuting];
        end;
    finally
        InterlockedDecrement(FWaitingRequests);
        UnLockSession;
    end;
end;

procedure   TWapSession.Execute;
begin
    if assigned(FOnExecute) then
        FOnExecute(self);
end;

procedure TWapSession.SetActions(Value: TWapActionItems);
begin
    FActions.Assign(Value);
end;

function TWapSession.GetRequest: THttpRequest;
begin
    if (FRequest = nil) then
        raise EWapSession.Create('Request not available while Session is not executing');
    result := FRequest;
end;

function TWapSession.GetResponse: THttpResponse;
begin
    if (FResponse = nil) then
        raise EWapSession.Create('Response not available while Session is not executing');
    result := FResponse;
end;

procedure   TWapSession.SessionStart;
begin
    if (FApplication <> nil) then
        FApplication.Notify(wnSessionStart);
    if assigned(FOnStart) then
        FOnStart(self);
end;

function TWapSession.GetStatus: TWapSessionStatus;
begin
    LockSession;
    try
        result := FStatus;
    finally
        UnLockSession;
    end;
end;

procedure   TWapSession.SessionEnd;
begin
    if (SessionEndCalled) then
        Exit;

    SessionEndCalled := true;

    if assigned(FOnEnd) then
        FOnEnd(self);
    if (FApplication <> nil) then
        FApplication.Notify(wnSessionEnd);
end;

function TWapSession.DispatchActions: boolean;
begin
    if (not (wsExecuting in Status)) then
        raise Exception.Create('DispatchActions must be called only when the session is executing');
    result := FActions.DispatchActions(Request, Response);
    FActionsDispatched := true;
end;

procedure TWapSession.Abandon;
begin
    // this will make sure new requests to this session will not find us
    if ((FApplication <> nil) and (FApplication.FSessionList <> nil)) then
        FApplication.FSessionList.Delete(Self);
    // We cannot just destroy this session, since the current request
    // is still executing - and there may be other requests waiting in the
    // queue for this session.
    // We will just set this flag, indicating that we wish to be destroyed
    // when the last standing request for this session finishes.
    FStatus := FStatus + [wsAbandoned];
end;

function TWapSession.GetValue(Index: string): variant;
begin
    result := FValues[Index];
end;

procedure TWapSession.SetValue(Index: string; Value: variant);
begin
    FValues[Index] := Value;
end;

procedure TWapSession.Clear;
begin
    FValues.Clear;
end;

function GetCanonicComponentName(Instance: TComponent): string;
begin
    result := Copy(Instance.ClassName, 2, MaxInt);
end;

function FindComponentByCanonicName(Owner: TComponent; const Name: string): TComponent;
var
    i: integer;
begin
    if (CompareText(GetCanonicComponentName(Owner), Name) = 0) then begin
        result := Owner;
        exit;
    end;

    for i := 0 to (Owner.ComponentCount - 1) do begin
        result := Owner.Components[i];
        if (CompareText(GetCanonicComponentName(result), Name) = 0) then
            exit;
    end;
    result := nil;
end;

function WapFindGlobalComponent(const Name: string): TComponent;
begin
    result := nil;
    if (FindGlobalComponentActiveSession <> nil) then begin
        result := FindComponentByCanonicName(FindGlobalComponentActiveSession, Name);
        if ((result = nil) and (FindGlobalComponentActiveSession.Owner <> nil)) then
            result := FindComponentByCanonicName(FindGlobalComponentActiveSession.Owner, Name);
    end;
    if (result = nil) then
        result := OriginalFindGlobalComponent(Name);
end;

function TWapSession.UnsafeCreateModule(Owner: TComponent; ModuleClass: TComponentClass): TComponent;
var
    Instance: TComponent;
    OldOnException: TExceptionEvent;
begin
    FindGlobalComponentActiveSession := Self;
    try
        Instance := TComponent(ModuleClass.NewInstance);
        TComponent(Result) := Instance;
        try
            OldOnException := Forms.Application.OnException;
            Forms.Application.OnException := Application.InternalOnExceptionHandler;
            try
                Instance.Create(Owner);
            finally
                Forms.Application.OnException := OldOnException;
            end;
        except
            TComponent(Result) := nil;
            ComponentDestructionLock.Enter;
            try
                Instance.Free;
            finally
                ComponentDestructionLock.Leave;
            end;
            raise;
        end;
    finally
        FindGlobalComponentActiveSession := nil;
    end;
end;

function TWapSession.CreateModule(ModuleClass: TComponentClass): TComponent;
begin
    {$ifdef cp_on}cp(1, '<TWapSession.CreateModule');{$endif cp_on}
    FindGlobalComponentLock.Enter;
    try
        result := UnsafeCreateModule(Self, ModuleClass);
    finally
        FindGlobalComponentLock.Leave;
    end;
    {$ifdef cp_on}cp(-1, 'TWapSession.CreateModule>');{$endif cp_on}
end;

procedure TWapSession.FreeModule(Module: TComponent);
begin
    {$ifdef cp_on}cp(1, '<TWapSession.FreeModule');{$endif cp_on}
    // just in case... :
    if (Module is TWinControl) then begin
        FreeForm(TWinControl(Module));
    end else begin
        ComponentDestructionLock.Enter;
        try
            Module.Free;
        finally
            ComponentDestructionLock.Leave;
        end;
    end;
    {$ifdef cp_on}cp(-1, 'TWapSession.FreeModule>');{$endif cp_on}
end;

function TWapSession.CreateForm(FormClass: TWinControlClass): TWinControl;
begin
    {$ifdef cp_on}cp(1, '<TWapSession.CreateForm');{$endif cp_on}
    FFormClassToCreate := FormClass;
    FindGlobalComponentLock.Enter;
    try
        CallInMainThread(SynchCreateForm);
    finally
        FindGlobalComponentLock.Leave;
    end;
    result := FCreatedForm;
    {$ifdef cp_on}cp(-1, 'TWapSession.CreateForm>');{$endif cp_on}
end;

procedure TWapSession.SynchFreeForm;
begin
    FFormToDestroy.Free;
end;

procedure TWapSession.FreeForm(Form: TWinControl);
begin
    {$ifdef cp_on}cp(1, '<TWapSession.FreeForm');{$endif cp_on}
    FFormToDestroy := Form;
    ComponentDestructionLock.Enter;
    try
        CallInMainThread(SynchFreeForm);
    finally
        ComponentDestructionLock.Leave;
    end;
    {$ifdef cp_on}cp(-1, 'TWapSession.FreeForm>');{$endif cp_on}
end;

procedure TWapSession.SynchCreateForm;
begin
    // 1. We call UnsafeCreateModule because CreateForm already entered
    // the lock for us. We can't enter the lock here, because we are now
    // running in the main thread, while the lock could already by owned
    // by the session thread (if we are now in the Session's OnCreate event).
    //
    // 2. We set the owner of the created visual control to be VisualComponentsOwner.
    // VisualComponentsOwner is owned by the Forms.Application object, which will
    // destroy it on application termination.
    // Visual components, which are created here in the main application thread,
    // must also be destroyed in the main thread. We will try to do so in the session's
    // destructor, but we cannot switch to the main thread while the application is being
    // terminated - in this case the Application object itself will take care of
    // destroying the visual controls.
    FCreatedForm := TWinControl(UnsafeCreateModule(VisualComponentsOwner, FFormClassToCreate));
end;

function TWapSession.GetFormImage(Form: TCustomForm): Graphics.TBitmap;
begin
    FFormToGetImage := Form;
    CallInMainThread(SynchGetFormImage);
    result := FFormImage;
end;

procedure TWapSession.SynchGetFormImage;
begin
    FFormImage := FFormToGetImage.GetFormImage;
end;

procedure WriteToStreamCallback(Instance: pointer; Data: pointer; Size: integer); stdcall; export;
begin
    TStream(Instance).WriteBuffer(Data^, Size);
end;

////////////////////////////////////////////////////////////////////////////////////////////////////
//
//      TWapSessionList
//
////////////////////////////////////////////////////////////////////////////////////////////////////

constructor TWapSessionList.Create(AOwner: TComponent);
begin
    inherited;

    FLock := TWin32CriticalSection.Create;
    FSessions := TStringList.Create;
    // we want to be able to search on it :
    TStringList(FSessions).sorted := true;
    TStringList(FSessions).duplicates := dupError;

    FEmptyEvent := TWin32Event.Create('', true, nil);
    FEmptyEvent.Signal;
end;

destructor TWapSessionList.Destroy;
begin
    Lock;
    try
        while (Count > 0) do begin
            try
                FreeSession(Sessions[0]);
            except
                Application.HandleException(Self);
            end;
        end;
        FSessions.Free;
        FSessions := nil;
    finally
        Unlock;
    end;

    FLock.Free;
    FEmptyEvent.Free;
    inherited Destroy;
end;

procedure   TWapSessionList.Notification(AComponent: TComponent; Operation: TOperation);
begin
    inherited;
    if ((AComponent is TWapSession) and (Operation = opRemove)) then
        Delete(TWapSession(AComponent));
end;

procedure TWapSessionList.Lock;
begin
    FLock.Enter;
end;

procedure TWapSessionList.Unlock;
begin
    FLock.Leave;
end;

procedure TWapSessionList.Add(Session: TWapSession);
begin
    Lock;
    try
        Session.FreeNotification(Self);
        FSessions.AddObject(Session.SessionId, Session);
        FEmptyEvent.Reset;
    finally
        Unlock;
    end;
end;

procedure TWapSessionList.Delete(Session: TWapSession);
var
    i: integer;
begin
    Lock;
    try
        i := FSessions.indexOf(Session.SessionId);
        if (i <> -1) then
            FSessions.Delete(i);
        if (FSessions.Count = 0) then
            FEmptyEvent.Signal;
    finally
        Unlock;
    end;
end;

function TWapSessionList.GetCount: integer;
begin
    Lock;
    try
        result := FSessions.Count;
    finally
        Unlock;
    end;
end;

function TWapSessionList.GetSession(const SessionId: string): TWapSession;
var
    i: integer;
begin
    Lock;
    try
        i := FSessions.indexOf(SessionId);
        if (i = -1) then
            result := nil
        else
            result := TWapSession(FSessions.objects[i]);
    finally
        UnLock;
    end;
end;

function TWapSessionList.GetSessionByIndex(Index: integer): TWapSession;
begin
    Lock;
    try
        result := TWapSession(FSessions.objects[Index]);
    finally
        Unlock;
    end;
end;

procedure TWapSessionList.FreeSession(Session: TWapSession);
begin
//    Lock;
    try
        // This is a good chance to invoke this... all components
        // still exists etc.
        Session.SessionEnd;

        // Screen.RemoveDataModule, which is called during TDataModule.Destroy
        // is not thread-safe. We need to lock access to this area :
        ComponentDestructionLock.Enter;
        try
            // a hack : to support the common case where the TWapSession is placed
            // on a TDataModule or other container:
            // If the Session has an owner, we will free the owner instead of
            // freeing the Session component directly.
            if (Session.Owner <> nil) then
                Session.Owner.Free
            else
                Session.Free;
        finally
            ComponentDestructionLock.Leave;
        end;
    finally
//        Unlock;
    end;
end;

//////////////////////////////////////////////////////////////////////////
//
// TWapModule
//
//////////////////////////////////////////////////////////////////////////

procedure TWapModule.VerifySession;
begin
    if (FSession = nil) then
        raise Exception.Create('Session not assigned');
end;

function TWapModule.GetRequest: THttpRequest;
begin
    VerifySession;
    result := FSession.Request;
end;

function TWapModule.GetResponse: THttpResponse;
begin
    VerifySession;
    result := FSession.Response;
end;

//////////////////////////////////////////////////////////////////////////
//
// TWapSessionState
//
//////////////////////////////////////////////////////////////////////////
constructor TWapSessionState.Create;
begin
    inherited;
    FValues := TVariantList.Create;
    FObjects := TExStringList.Create;
    FObjects.Sorted := true;
    FObjects.Duplicates := dupError;
end;

destructor TWapSessionState.Destroy;
begin
    FValues.Free;
    FObjects.Free;
    inherited;
end;

function TWapSessionState.GetObject(const Name: string): TComponent;
var
    i: integer;
begin
    i := FObjects.IndexOf(UpperCase(Name));
    if (i = -1) then
        result := nil
    else
        result := FObjects.Objects[i] as TComponent;
end;

procedure TWapSessionState.SetObject(const Name: string; Instance: TComponent);
var
    i: integer;
begin
    i := FObjects.IndexOf(UpperCase(Name));
    if (i = -1) then
        FObjects.AddObject(UpperCase(Name), Instance)
    else
        FObjects.Objects[i] := Instance;
end;

//////////////////////////////////////////////////////////////////////////
//
// BitmapToJPEGStream
//
//////////////////////////////////////////////////////////////////////////

type

TBitmapToJPEGStreamHelper = class
private
    FStream: TStream;
    FBitmap: TBitmap;
    FResult: integer;
    procedure SynchExecute;
end;

procedure TBitmapToJPEGStreamHelper.SynchExecute;
var
    BitmapMemStream: TMemoryStream;
begin
    BitmapMemStream := TMemoryStream.Create;
    try
        FBitmap.SaveToStream(BitmapMemStream);
//        FResult := BitmapToJPEG(BitmapMemStream.Memory, BitmapMemStream.Size, FStream, WriteToStreamCallback);
    finally
        BitmapMemStream.free;
    end;
end;

function BitmapToJPEGStream(Bitmap: Graphics.TBitmap; Stream: TStream): integer;
var
    Helper: TBitmapToJPEGStreamHelper;
    JpegMemStream: TMemoryStream;
begin
    JpegMemStream := TMemoryStream.Create;
    try
        Helper := TBitmapToJPEGStreamHelper.Create;
        try
            Helper.FStream := JpegMemStream;
            Helper.FBitmap := Bitmap;
            CallInMainThread(Helper.SynchExecute);
            result := Helper.FResult;
            JpegMemStream.Position := 0;
            Stream.CopyFrom(JpegMemStream, 0);
        finally
            Helper.Free;
        end;
    finally
        JpegMemStream.Free;
    end;
end;

initialization
begin
    // Use HAWapRun.DLL to perform the conversion
    BitmapToJPEGStreamProc := BitmapToJPEGStream;

    OriginalFindGlobalComponent := Classes.FindGlobalComponent;
    Classes.FindGlobalComponent := WapFindGlobalComponent;
    FindGlobalComponentLock := TWin32CriticalSection.Create;

    ComponentDestructionLock := TWin32CriticalSection.Create;
end;

finalization
begin
    try
        Classes.FindGlobalComponent := OriginalFindGlobalComponent;
        FindGlobalComponentLock.Free;
        ComponentDestructionLock.Free;
    except
        // It's finalization, nothing to do.
    end;
end;

end.
