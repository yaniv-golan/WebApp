@ECHO .
@ECHO .
@ECHO HWAP10
@ECHO .
@ECHO .
g:\delphi3\bin\dcc32.exe -q -b -ud:\src\misc;g:\delphi3\lib hwap10.dpk
move /q hwap10.dcp g:\delphi3\lib
move /q hwap10.dpl f:\winnt40\system32

@ECHO .
@ECHO .
@ECHO HWAPDB10
@ECHO .
@ECHO .
g:\delphi3\bin\dcc32.exe -q -b -ud:\src\misc;g:\delphi3\lib hwapdb10.dpk
move /q hwapdb10.dcp g:\delphi3\lib
move /q hwapdb10.dpl f:\winnt40\system32

@ECHO .
@ECHO .
@ECHO DCLWAP10
@ECHO .
@ECHO .
g:\delphi3\bin\dcc32.exe -q -b -ud:\src\misc;g:\delphi3\lib dclwap10.dpk
move /q dclwap10.dcp g:\delphi3\lib


