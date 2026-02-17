@ECHO OFF
SETLOCAL EnableExtensions

REM Stop common server/client processes.

FOR %%P IN (KnightOnLine VersionManager ItemManager Aujard Ebenezer AIServer) DO (
	TASKKILL /IM "%%P.exe" /F >NUL 2>&1
)

EXIT /B 0

