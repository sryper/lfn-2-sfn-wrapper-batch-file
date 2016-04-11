    @echo %dbgi% off
::  Purpose:
::     call a program that only accepts 8.3 filename arguments
::
::  Usage:
::     vi_wrapper ["file-path-argument"] ...
::  
::  Returns:
::    exit code of %pgm%
::
::  Environment Vars:
::    ZOPT  sets path to vi.ini if needed
::
::  Notes:
::    . Arguments passed are converted to short file name as well as path
::    . Set SHOW var to turn on trace info
::    . Set PGM var to software program
::    . This fixes corruption in "%sfA" when file is < 8 chars with 2 "." 
::      periods eg f.1.txt
::    . Sets inifile to pgm.ini (will search in PATH var if required)
::
::  Modifications:
::
::  TIME/DATE        MOD  AUTHOR/DESCRIPTION
::  ---------------- ---- ------------------
::  22:52 10/03/2016 1.01 S. Ryper (@skipryper)
::                        First release, tested on WIN XP
::

::  set a dummy nonzero errorlevel
    verify other 2>nul
    Setlocal EnableExtensions EnableDelayedExpansion
    if errorlevel 1 goto errmsg1
    
    set pgm=vi.exe
    set rc=0
::  zopt is unquoted SFN 
    if defined zopt (
       if exist "%zopt%" goto step2
    )

::  common inifile setup    
    for /F "tokens=* usebackq" %%A IN (`echo %pgm%`) do (
        set "pgmp=%%~dpnA"
        set "pgmn=%%~nA"
        if exist "!pgmp!.ini" (
            rem ini file in same dir
            set "inifile=!pgmp!.ini"
        ) else (
            for /F "tokens=* usebackq" %%B IN (`echo "!pgmn!.ini"`) do (
                rem search in PATH var
                set "inifile=%%~$PATH:B"
            )
        )
    )
    if defined show echo inifile=%inifile%
::  assign inifile if applicable
    if exist %inifile% (
        call :getsfn zopt="%inifile%"
        if defined show echo "zopt=!zopt!"
    ) else (
        set zopt=
    )   
    goto step2

:step2
    rem call test_args %*
    for /f "usebackq tokens=*" %%A in ( `echo.%*` ) do (
        call :getsfn sname="%%~A"
        set sfnargs=!sfnargs! !sname!
    ) 
    if defined show (
        echo call %pgm% %sfnargs%
        pause
    )
    rem ---------
    rem start PGM
    rem ---------
    call %pgm% %sfnargs%
    echo rc=%errorlevel%
    goto fin

::-- begin subroutine --
:getsfn retvar="lfn"
    :: corect problem with "for /f" short file names
    Setlocal EnableExtensions EnableDelayedExpansion
    @echo %dbgi% off
    set "result=%~1"
    :: set "fixname=%~sn2" will not reliably return sfn
    :: example name: x.y.z.txt
    set "fixname=%~n2"
    set "fullname=%~sf2"

    if "%fixname:~0,7%"=="%fixname%" (
        if "%fixname:*.=%"=="%fixname%" (
            rem name correct
            goto get_stp2
        ) else (
            rem name < 8 chars AND name is has "." in first 7chars
            rem set /p fullname=%%~sfA SFN glitch enter it manually: 
            rem 4th token is short file name
            if defined show dir /x /a "%~2" | findstr /e /i /L "%~nx2"
            for /F "tokens=4 usebackq delims= " %%A in (`
                dir /x /a "%~2" ^| findstr /e /i /L "%~nx2"`) do (
                set "fixname=%%~A"
                if defined show echo 1:"fixname=%%~A"
            )
        )
    )
    if "%fixname%"=="%~sn2" (
        rem no correction
    ) else (
        set "fullname=%~sdp2!fixname!"
    )
    if defined show echo 2:"fullname=!fullname!"  

:get_stp2
    if defined show echo 3:"fullname=!fullname!"
    endlocal & set "%result%=%fullname%"
    exit /b 
:-- end subroutine --

:errmsg1    
    echo Unable to enable extensions
    pause
    goto fin

:fin  
    call win2dos rem
    endlocal & exit /b %errorlevel%
