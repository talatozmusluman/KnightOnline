@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

REM Run the server stack + optional client from the repo layout.
REM Usage:
REM   build_scripts\run_stack.cmd [Configuration] [Platform] [--no-client]

SET "CONFIG=%~1"
SET "PLATFORM=%~2"
SET "OPT3=%~3"

IF "%CONFIG%"=="" SET "CONFIG=Debug"
IF "%PLATFORM%"=="" SET "PLATFORM=x64"

SET "BIN_SUBDIR=%CONFIG%-%PLATFORM%"
IF /I "%CONFIG%"=="Debug" IF /I "%PLATFORM%"=="x64" SET "BIN_SUBDIR=Debug-x64"
IF /I "%CONFIG%"=="Release" IF /I "%PLATFORM%"=="x64" SET "BIN_SUBDIR=Release-x64"

FOR %%I IN ("%~dp0..") DO SET "ROOT=%%~fI"

SET "BIN=%ROOT%\bin\%BIN_SUBDIR%"
SET "MAP=%ROOT%\assets\Server\MAP"
SET "QUESTS=%ROOT%\assets\Server\QUESTS"
SET "CLIENT_ASSETS=%ROOT%\assets\Client"

IF NOT EXIST "%BIN%\AIServer.exe" (
	ECHO ERROR: Missing "%BIN%\AIServer.exe" ^(did you build %CONFIG%^|%PLATFORM%^?^)
	EXIT /B 1
)

ECHO Starting servers from: "%BIN%"

START "" /D "%BIN%" "%BIN%\AIServer.exe" --map-dir "%MAP%" --event-dir "%MAP%"
TIMEOUT /T 2 /NOBREAK >NUL

START "" /D "%BIN%" "%BIN%\Ebenezer.exe" --map-dir "%MAP%" --quests-dir "%QUESTS%"
TIMEOUT /T 2 /NOBREAK >NUL

START "" /D "%BIN%" "%BIN%\Aujard.exe"
START "" /D "%BIN%" "%BIN%\ItemManager.exe"
START "" /D "%BIN%" "%BIN%\VersionManager.exe"

IF /I "%OPT3%"=="--no-client" GOTO :done

IF NOT EXIST "%BIN%\KnightOnLine.exe" (
	ECHO ERROR: Missing "%BIN%\KnightOnLine.exe"
	EXIT /B 1
)

IF NOT EXIST "%CLIENT_ASSETS%\Data\Zones.tbl" (
	ECHO ERROR: Client assets missing under "%CLIENT_ASSETS%".
	ECHO Expected "%CLIENT_ASSETS%\Data\Zones.tbl".
	EXIT /B 1
)

START "" /D "%CLIENT_ASSETS%" "%BIN%\KnightOnLine.exe"

:done
ECHO Stack launched.
EXIT /B 0
