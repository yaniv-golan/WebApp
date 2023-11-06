unit NTSecurity;

interface

uses Windows;

const
    RTN_OK = 0;
    RTN_ERROR = 13;

    WINSTA_ALL = (WINSTA_ACCESSCLIPBOARD  or WINSTA_ACCESSGLOBALATOMS or
       WINSTA_CREATEDESKTOP    or WINSTA_ENUMDESKTOPS      or
       WINSTA_ENUMERATE        or WINSTA_EXITWINDOWS       or
       WINSTA_READATTRIBUTES   or WINSTA_READSCREEN        or
       WINSTA_WRITEATTRIBUTES  or _DELETE                   or
       READ_CONTROL            or WRITE_DAC                or
       WRITE_OWNER);

   DESKTOP_ALL = (DESKTOP_CREATEMENU      or DESKTOP_CREATEWINDOW  or
       DESKTOP_ENUMERATE       or DESKTOP_HOOKCONTROL   or
       DESKTOP_JOURNALPLAYBACK or DESKTOP_JOURNALRECORD or
       DESKTOP_READOBJECTS     or DESKTOP_SWITCHDESKTOP or
       DESKTOP_WRITEOBJECTS    or _DELETE                or
       READ_CONTROL            or WRITE_DAC             or
       WRITE_OWNER);

   GENERIC_ACCESS = (GENERIC_READ    or GENERIC_WRITE or
       GENERIC_EXECUTE or GENERIC_ALL);

   function ObtainSid(
        hToken: THandle;    // handle to an process access token
        var Sid: PSID       // ptr to the buffer of the logon sid
        ): bool;

   procedure RemoveSid(
    var Sid: PSID         // ptr to the buffer of the logon sid
    );

   function AddTheAceWindowStation(
        hwinsta: HWINSTA;         // handle to a windowstation
        psid: PSID                 // logon sid of the process
        ): bool;



   function AddTheAceDesktop(
        hdesk: HDESK;             // handle to a desktop
        psid: PSID                 // logon sid of the process
        ): bool;


implementation

   function ObtainSid(
        hToken: THandle;    // handle to an process access token
        var Sid: PSID       // ptr to the buffer of the logon sid
        ): bool;
    var
        bSuccess: boolean;
        dwIndex: dword;
        dwLength: dword;
        tic: TOKEN_INFORMATION_CLASS;
        ptg: PTOKEN_GROUPS;
    begin
        bSuccess := false; // assume function will fail
        dwLength := 0;
        tic := TokenGroups;
        ptg := nil;

        try
             //
             // determine the size of the buffer
        //
             if (not GetTokenInformation(
                 hToken,
                 tic,
                 ptg,
                 0,
                 @dwLength
                 ))
             then begin
                  if (GetLastError := ERROR_INSUFFICIENT_BUFFER) then begin
                       ptg := PTOKEN_GROUPS(HeapAlloc(
                            GetProcessHeap(),
                              HEAP_ZERO_MEMORY,
                          dwLength
                          ));
                       if (ptg := nil) then
                            __leave;
                       end;
                   else
                       __leave;
         end;

             //
             // obtain the groups the access token belongs to
             //
             if (not GetTokenInformation(
                  hToken,
             tic,
             (LPVOID)ptg,
             dwLength,
             @dwLength
             ))
                  __leave;

             //
             // determine which group is the logon sid
             //
             for (dwIndex := 0; dwIndex < ptg->GroupCount; dwIndex++)
                  begin
             if ((ptg->Groups[dwIndex].Attributes @ SE_GROUP_LOGON_ID)
                  =  SE_GROUP_LOGON_ID)
                       begin
                       //
                       // determine the length of the sid
                       //
                       dwLength := GetLengthSid(ptg->Groups[dwIndex].Sid);

                       //
                       // allocate a buffer for the logon sid
                       //
                       *psid := (PSID)HeapAlloc(
                            GetProcessHeap(),
                  HEAP_ZERO_MEMORY,
                  dwLength
                  );
                  if (*psid = NULL)
                       __leave;

                  //
                  // obtain a copy of the logon sid
                  //
                  if (not CopySid(dwLength, *psid, ptg->Groups[dwIndex].Sid))
                       __leave;

                  //
                  // break out of the loop since the logon sid has been
                  // found
                  //
                  break;
                  end;
             end;

             //
             // indicate success
             //
             bSuccess := TRUE;
             end;
        __finally
             begin
             //
        // free the buffer for the token group
        //
             if (ptg <>  NULL)
                  HeapFree(GetProcessHeap(), 0, (LPVOID)ptg);
             end;

        return bSuccess;
   end;

   void RemoveSid(PSID *psid)
   begin
        HeapFree(GetProcessHeap(), 0, (LPVOID)*psid);
   end;

end.





   BOOL AddTheAceWindowStation(HWINSTA hwinsta, PSID psid)
   begin
        ACCESS_ALLOWED_ACE   *pace;
        ACL_SIZE_INFORMATION aclSizeInfo;
        BOOL                 bDaclExist;
        BOOL                 bDaclPresent;
        BOOL                 bSuccess  := FALSE; // assume function will
                                                //fail
        DWORD                dwNewAclSize;
        DWORD                dwSidSize := 0;
        DWORD                dwSdSizeNeeded;
        PACL                 pacl;
        PACL                 pNewAcl;
        PSECURITY_DESCRIPTOR psd       := NULL;
        PSECURITY_DESCRIPTOR psdNew    := NULL;
        PVOID                pTempAce;
        SECURITY_INFORMATION si        := DACL_SECURITY_INFORMATION;
        unsigned int         i;

        __try
             begin
             //
             // obtain the dacl for the windowstation
             //
             if (not GetUserObjectSecurity(
                  hwinsta,
             @si,
             psd,
                  dwSidSize,
             @dwSdSizeNeeded
                  ))
             if (GetLastError() = ERROR_INSUFFICIENT_BUFFER)
                  begin
                  psd := (PSECURITY_DESCRIPTOR)HeapAlloc(
                       GetProcessHeap(),
                       HEAP_ZERO_MEMORY,
                       dwSdSizeNeeded
             );
                  if (psd = NULL)
                       __leave;

                  psdNew := (PSECURITY_DESCRIPTOR)HeapAlloc(
                       GetProcessHeap(),
                       HEAP_ZERO_MEMORY,
                       dwSdSizeNeeded
                       );
                  if (psdNew = NULL)
                       __leave;

                  dwSidSize := dwSdSizeNeeded;

                  if (not GetUserObjectSecurity(
                       hwinsta,
                       @si,
                       psd,
                       dwSidSize,
                       @dwSdSizeNeeded
                       ))
                       __leave;
         end;
             else
                   __leave;

             //
             // create a new dacl
        //
             if (not InitializeSecurityDescriptor(
                  psdNew,
                  SECURITY_DESCRIPTOR_REVISION
                  ))
                  __leave;

             //
        // get dacl from the security descriptor
             //
             if (not GetSecurityDescriptorDacl(
                  psd,
                  @bDaclPresent,
                  @pacl,
                  @bDaclExist
                  ))
                  __leave;

             //
             // initialize
             //
             ZeroMemory(@aclSizeInfo, sizeof(ACL_SIZE_INFORMATION));
             aclSizeInfo.AclBytesInUse := sizeof(ACL);

             //
             // call only if the dacl is not NULL
             //
             if (pacl <>  NULL)
                  begin
                  // get the file ACL size info
                  if (not GetAclInformation(
                       pacl,
                       (LPVOID)@aclSizeInfo,
                       sizeof(ACL_SIZE_INFORMATION),
                       AclSizeInformation
                       ))
                       __leave;
                   end;

             //
             // compute the size of the new acl
             //
             dwNewAclSize := aclSizeInfo.AclBytesInUse + (2 *
             sizeof(ACCESS_ALLOWED_ACE)) + (2 * GetLengthSid(psid)) - (2 *
             sizeof(DWORD));

             //
             // allocate memory for the new acl
             //
             pNewAcl := (PACL)HeapAlloc(
                  GetProcessHeap(),
                  HEAP_ZERO_MEMORY,
                  dwNewAclSize
                  );
             if (pNewAcl = NULL)
                  __leave;

             //
             // initialize the new dacl
             //
             if (not InitializeAcl(pNewAcl, dwNewAclSize, ACL_REVISION))
                  __leave;

             //
             // if DACL is present, copy it to a new DACL
             //
             if (bDaclPresent) // only copy if DACL was present
                  begin
                  // copy the ACEs to our new ACL
                  if (aclSizeInfo.AceCount)
                       begin
                       for (i:=0; i < aclSizeInfo.AceCount; i++)
                            begin
                            // get an ACE
                            if (not GetAce(pacl, i, @pTempAce))
                                 __leave;

                            // add the ACE to the new ACL
                            if (not AddAce(
                  pNewAcl,
                                 ACL_REVISION,
                                 MAXDWORD,
                                 pTempAce,
                  ((PACE_HEADER)pTempAce)->AceSize
                                 ))
                                 __leave;
                             end;
                        end;
                  end;

             //
             // add the first ACE to the windowstation
             //
             pace := (ACCESS_ALLOWED_ACE *)HeapAlloc(
                  GetProcessHeap(),
                  HEAP_ZERO_MEMORY,
             sizeof(ACCESS_ALLOWED_ACE) + GetLengthSid(psid) -
                  sizeof(DWORD
                  ));
             if (pace = NULL)
                  __leave;

             pace->Header.AceType  := ACCESS_ALLOWED_ACE_TYPE;
             pace->Header.AceFlags := CONTAINER_INHERIT_ACE or
                                     INHERIT_ONLY_ACE      or

                                     OBJECT_INHERIT_ACE;
             pace->Header.AceSize  := sizeof(ACCESS_ALLOWED_ACE) +

                                     GetLengthSid(psid) - sizeof(DWORD);
             pace->Mask            := GENERIC_ACCESS;

             if (not CopySid(GetLengthSid(psid), @pace->SidStart, psid))
                  __leave;

             if (not AddAce(
                  pNewAcl,
                  ACL_REVISION,
             MAXDWORD,
                  (LPVOID)pace,
                  pace->Header.AceSize
                  ))
                  __leave;

             //
             // add the second ACE to the windowstation
             //
             pace->Header.AceFlags := NO_PROPAGATE_INHERIT_ACE;
             pace->Mask            := WINSTA_ALL;

             if (not AddAce(
                  pNewAcl,
                  ACL_REVISION,
                  MAXDWORD,
                  (LPVOID)pace,
                  pace->Header.AceSize
                  ))
                  __leave;

                  //
                  // set new dacl for the security descriptor
                  //
                  if (not SetSecurityDescriptorDacl(
                       psdNew,
                       TRUE,
                       pNewAcl,
                       FALSE
                       ))
                       __leave;

                   //
         // set the new security descriptor for the windowstation
         //
         if (not SetUserObjectSecurity(hwinsta, @si, psdNew))
            __leave;

         //
         // indicate success
         //
         bSuccess := TRUE;
             end;
        __finally
             begin
             //
             // free the allocated buffers
             //
             if (pace <>  NULL)
                  HeapFree(GetProcessHeap(), 0, (LPVOID)pace);

             if (pNewAcl <>  NULL)
                  HeapFree(GetProcessHeap(), 0, (LPVOID)pNewAcl);

             if (psd <>  NULL)
                  HeapFree(GetProcessHeap(), 0, (LPVOID)psd);

             if (psdNew <>  NULL)
                  HeapFree(GetProcessHeap(), 0, (LPVOID)psdNew);
             end;

        return bSuccess;
   end;

   BOOL AddTheAceDesktop(HDESK hdesk, PSID psid)
   begin
        ACL_SIZE_INFORMATION aclSizeInfo;
        BOOL                 bDaclExist;
        BOOL                 bDaclPresent;
        BOOL                 bSuccess  := FALSE; // assume function will
                                                // fail
        DWORD                dwNewAclSize;
        DWORD                dwSidSize := 0;
        DWORD                dwSdSizeNeeded;
        PACL                 pacl;
        PACL                 pNewAcl;
        PSECURITY_DESCRIPTOR psd       := NULL;
        PSECURITY_DESCRIPTOR psdNew    := NULL;
        PVOID                pTempAce;
        SECURITY_INFORMATION si        := DACL_SECURITY_INFORMATION;
        unsigned int         i;

        __try
             begin
             //
             // obtain the security descriptor for the desktop object
             //
             if (not GetUserObjectSecurity(
                  hdesk,
                  @si,
                  psd,
                  dwSidSize,
                  @dwSdSizeNeeded
                  ))
                  begin
                  if (GetLastError() = ERROR_INSUFFICIENT_BUFFER)
                       begin
                       psd := (PSECURITY_DESCRIPTOR)HeapAlloc(
                            GetProcessHeap(),
                            HEAP_ZERO_MEMORY,
             dwSdSizeNeeded
             );
                       if (psd = NULL)
                            __leave;

                       psdNew := (PSECURITY_DESCRIPTOR)HeapAlloc(
                            GetProcessHeap(),
                            HEAP_ZERO_MEMORY,
                            dwSdSizeNeeded
             );
                       if (psdNew = NULL)
                            __leave;

                       dwSidSize := dwSdSizeNeeded;

                       if (not GetUserObjectSecurity(
                            hdesk,
                            @si,
                            psd,
                            dwSidSize,
                            @dwSdSizeNeeded
                            ))
                            __leave;
                       end;
                  else
                       __leave;
                  end;

             //
             // create a new security descriptor
             //
             if (not InitializeSecurityDescriptor(
                  psdNew,
                  SECURITY_DESCRIPTOR_REVISION
                  ))
               _   _leave;

             //
             // obtain the dacl from the security descriptor
             //
             if (not GetSecurityDescriptorDacl(
                  psd,
                  @bDaclPresent,
                  @pacl,
                  @bDaclExist
                  ))
                  __leave;

             //
             // initialize
             //
             ZeroMemory(@aclSizeInfo, sizeof(ACL_SIZE_INFORMATION));
             aclSizeInfo.AclBytesInUse := sizeof(ACL);

             //
             // call only if NULL dacl
             //
             if (pacl <>  NULL)
                  begin
                  //
                  // determine the size of the ACL info
                  //
                  if (not GetAclInformation(
                       pacl,
                       (LPVOID)@aclSizeInfo,
                       sizeof(ACL_SIZE_INFORMATION),
                       AclSizeInformation
                       ))
                       __leave;
                   end;

             //
             // compute the size of the new acl
             //
        dwNewAclSize := aclSizeInfo.AclBytesInUse +
                            sizeof(ACCESS_ALLOWED_ACE) +
                            GetLengthSid(psid) - sizeof(DWORD);

             //
             // allocate buffer for the new acl
             //
             pNewAcl := (PACL)HeapAlloc(
                  GetProcessHeap(),
                  HEAP_ZERO_MEMORY,
                  dwNewAclSize
                  );
             if (pNewAcl = NULL)
                  __leave;

             //
             // initialize the new acl
             //
             if (not InitializeAcl(pNewAcl, dwNewAclSize, ACL_REVISION))
                  __leave;

             //
             // if DACL is present, copy it to a new DACL
             //
             if (bDaclPresent) // only copy if DACL was present
                  begin
                  // copy the ACEs to our new ACL
                  if (aclSizeInfo.AceCount)
                       begin
                       for (i:=0; i < aclSizeInfo.AceCount; i++)
                            begin
                            // get an ACE
                            if (not GetAce(pacl, i, @pTempAce))
                                 __leave;

                            // add the ACE to the new ACL
                            if (not AddAce(
                                 pNewAcl,
                                 ACL_REVISION,
                                 MAXDWORD,
                                 pTempAce,
                                 ((PACE_HEADER)pTempAce)->AceSize
                                 ))
                                 __leave;
                             end;
                        end;
                  end;

             //
             // add ace to the dacl
             //
             if (not AddAccessAllowedAce(
                  pNewAcl,
                  ACL_REVISION,
                  DESKTOP_ALL,
                  psid
                  ))
                  __leave;

             //
             // set new dacl to the new security descriptor
             //
             if (not SetSecurityDescriptorDacl(
                       psdNew,
                       TRUE,
                       pNewAcl,
                       FALSE
                       ))
                  __leave;

             //
             // set the new security descriptor for the desktop object
             //
             if (not SetUserObjectSecurity(hdesk, @si, psdNew))
                  __leave;

             //
             // indicate success
             //
             bSuccess := TRUE;
             end;
        __finally
            begin
            //
            // free buffers
            //
            if (pNewAcl <>  NULL)
                 HeapFree(GetProcessHeap(), 0, (LPVOID)pNewAcl);

             if (psd <>  NULL)
                  HeapFree(GetProcessHeap(), 0, (LPVOID)psd);

             if (psdNew <>  NULL)
                  HeapFree(GetProcessHeap(), 0, (LPVOID)psdNew);
             end;

        return bSuccess;
   end;

   int main(void)
   begin
        HANDLE              hToken;
        HDESK               hdesk;
        HWINSTA             hwinsta;
        PROCESS_INFORMATION pi;
        PSID                psid;
        STARTUPINFO         si;

        //
        // obtain an access token for the user fester
        //
        if (not LogonUser(
             "franki",
             NULL,
             "franki",
             LOGON32_LOGON_INTERACTIVE,
             LOGON32_PROVIDER_DEFAULT,
             @hToken
             ))
             return RTN_ERROR;

        //
        // obtain a handle to the interactive windowstation
        //
        hwinsta := OpenWindowStation(
             "winsta0",
             FALSE,
             READ_CONTROL or WRITE_DAC
             );
        if (hwinsta = NULL)
             return RTN_ERROR;

        //
        // set the windowstation to winsta0 so that you obtain the
        // correct default desktop
        //
        if (not SetProcessWindowStation(hwinsta))
             return RTN_ERROR;

        //
        // obtain a handle to the "default" desktop
        //
        hdesk := OpenDesktop(
             "default",
             0,
             FALSE,
             READ_CONTROL or WRITE_DAC or
             DESKTOP_WRITEOBJECTS or DESKTOP_READOBJECTS
             );
        if (hdesk = NULL)
             return RTN_ERROR;

        //
        // obtain the logon sid of the user fester
        //
        if (not ObtainSid(hToken, @psid))
             return RTN_ERROR;

        //
        // add the user to interactive windowstation
        //
        if (not AddTheAceWindowStation(hwinsta, psid))
             return RTN_ERROR;

        //
        // add user to "default" desktop
        //
        if (not AddTheAceDesktop(hdesk, psid))
             return RTN_ERROR;

        //
        // free the buffer for the logon sid
        //
        RemoveSid(@psid);

        //
        // close the handles to the interactive windowstation and desktop
        //
        CloseWindowStation(hwinsta);

        CloseDesktop(hdesk);

        //
        // initilize STARTUPINFO structure
        //
        ZeroMemory(@si, sizeof(STARTUPINFO));
        si.cb        := sizeof(STARTUPINFO);
        si.lpDesktop := "winsta0\\default";

        //
        // launch the process
        //
        if (not CreateProcessAsUser(
             hToken,
             NULL,
             "cmd.exe",
             NULL,
             NULL,
             FALSE,
             NORMAL_PRIORITY_CLASS or CREATE_NEW_CONSOLE,
             NULL,
             NULL,
             @si,
             @pi
             ))
             return RTN_ERROR;

        //
        // close the handles
        //
        CloseHandle(pi.hProcess);

        CloseHandle(pi.hThread);

        return RTN_OK;
   end;

