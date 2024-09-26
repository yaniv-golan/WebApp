---

This is an archive of WebApp, an ancient framework for developing "advanced" (as of the early 90s) Web server applications using Delphi 2 (ahhh), Delphi 3 (ahhhhhh), or C++ Builder (ahhhhhhh), that I wrote back in probably 1996, when I was with a startup (we didn't actually use the term startup back then) called HyperAct. 

What follows is the original readme file. None of the links or the email addresses work anymore of course :) 

---

# WebApp 1.0 Trial Version

WebApp is a framework for developing advanced Web server applications using Delphi 2, Delphi 3, or C++ Builder.

### Features

- **Server Independent** - A WebApp Server Application can run unmodified, without re-compilation, on top of any Web server!
- **Automatic Session Management** - The WebApp framework implements transparent cookies-based session state management, keeping track of your users for you.
- **High performance** - WebApp Server Applications are fully multi-threaded, employing thread pooling to maximize the utilization of the server resources. The thread management is optimized for BDE-based Delphi applications.
- **Safe** - WebApp Server Applications run in a separate process from the server, eliminating the risk for a server crash!
- **Easy Debugging** - Live WebApp applications can be debugged easily from within the Delphi or C++Builder environment, without requiring a restart of the server.
- **HTML Templates** - WebApp provides integrated support for HTML templates, facilitating separation between the application logic and the HTML frontend.
- **Server-side Scripts** - WebApp HTML templates are driven with inlined VBScript and JScript scripts, providing unparalleled power and flexibility to the template authors and easy integration with the WebApp Delphi/CBuilder application.
- **Delphi 3 WebModules compatibility** - You can use the standard Delphi 3 Content Producer classes with WebApp.
- **Visual Components Support** - With WebApp, you can use **any** visual component (and not just TeeChart) to create images.
- **BDE-friendly** - The WebApp threading model is optimized for applications using the Borland Database Engine. WebApp makes better use of BDE resources such as Sessions and Database Connections than applications based on Delphi's WebModules.

WebApp supports ISAPI, NSAPI, WSAPI, CGI, and WinCGI servers. It also provides many routines and components which make Web programming a lot easier, such as HTML generation components, data-aware components, SMTP control for sending email, on-the-fly conversion of bitmaps to GIF/JPEG, ad-management component, browser capabilities detection, and a lot more.

### Here's what the professionals have to say about WebApp:

> "I have already fallen in love with WebApp. This is just too cool. Delphi 3 makes ISAPI development much easier but why would I bang my head against the wall when I can have session management and all the other goodies that WebApp gives me?"
>
> **Stephen Genusa** - Consultant, maintainer of IIS, ASP and ISAPI FAQs, author of Que’s *Special Edition Using ISAPI*.
>
> "You've really done an incredible job! I started on my application yesterday, and I think I'll be done by tomorrow. I was certain this project was going to take at least three weeks, not three days! Thanks for all your hard work... I really appreciate it."
>
> **Steve Kramer** [goog@goog.com]

WebApp applications run on top of **any web server**, using the server's *native* interface. WebApp ships with native support for Microsoft Internet Information Server (ISAPI), Microsoft Personal Web Server (ISAPI), Netscape FastTrack (NSAPI), O'reilly WebSite and WebSite Pro (WSAPI), as well as CGI and Win-CGI interfaces which will work with any web server!

Put this great technology to work using WebApp's simple object model (similar to and compatible with the model used in Microsoft Active Server Pages). To get you started as quickly as possible, we've included a variety of common components and sample applications, including:

- Browser Capabilities component, providing your applications with a description of the capabilities of the client's web browser.
- Ad Rotator component, providing automated, controlled rotation of advertisement images.
- Data-aware HTML generation components and functions, simplifying the generation of complex HTML constructs, including generation of HTML tables from DB tables and queries.
- SMTP component, for sending email messages directly from your WebApp application.

### Pricing

WebApp is available in two versions:

- Standard version for $199.
- Pro version for $495.

The Pro version includes full source code, an integrated version of ArGo Software's TSMTP component for sending email programs from your Web applications, and a FREE bonus - our [eAuthor/Site](eAuthorSite.html) template-based website editor.

You can purchase WebApp directly from the HyperAct Web site at [http://www.hyperact.com](http://www.hyperact.com), or by contacting our office:

```
HyperAct, Inc.
3437 335th Street
West Des Moines, IA 50266 USA

Tel/Fax (515) 987-2910
Fax only (515) 987-2909
CIS - 76350,333 or 102703,3274
Internet - [rhalevi@hyperact.com](mailto:rhalevi@hyperact.com)
```

### About the Trial Version

This trial version of WebApp is identical in its features to the Standard version. However, you will be able to run applications created using this trial version only from inside the Delphi or C++ Builder environment. In addition, the trial version will add the following text: "This page was generated using a trial version of HyperAct WebApp" at the end of each HTML page.

---

**Thank you for evaluating WebApp! We value your feedback - please send any comments or questions to** [ygolan@hyperact.com](mailto:ygolan@hyperact.com).
