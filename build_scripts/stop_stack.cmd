@ECHO OFF
SETLOCAL EnableExtensions

REM Stop common server/client processes.

FOR %%P IN (KnightOnLine VersionManager ItemManager Aujard Ebenezer AIServer) DO (
	TASKKILL /IM "%%P.exe" /F /T >NUL 2>&1
)

REM Wait (briefly) until everything is actually gone.
SET "DEADLINE=20"
:wait_loop
SET /A DEADLINE-=1
SET "ANY="
FOR %%P IN (KnightOnLine VersionManager ItemManager Aujard Ebenezer AIServer) DO (
	TASKLIST /FI "IMAGENAME eq %%P.exe" 2>NUL | FIND /I "%%P.exe" >NUL 2>&1 && SET "ANY=1"
)
IF NOT DEFINED ANY GOTO :done
IF %DEADLINE% LEQ 0 GOTO :done
TIMEOUT /T 1 /NOBREAK >NUL
GOTO :wait_loop

:done

EXIT /B 0
