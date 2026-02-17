@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

REM Rebuild the full stack (shared libs + servers + client).
REM Usage:
REM   build_scripts\rebuild_stack.cmd [Configuration] [Platform]
REM Defaults to Debug x64.

SET "CONFIG=%~1"
SET "PLATFORM=%~2"

IF "%CONFIG%"=="" SET "CONFIG=Debug"
IF "%PLATFORM%"=="" SET "PLATFORM=x64"

SET "COMMON=/t:Rebuild /m /v:m /p:Configuration=%CONFIG% /p:Platform=%PLATFORM%"

ECHO Rebuilding stack [%CONFIG%^|%PLATFORM%]...

CALL "%~dp0msbuild.cmd" "src\shared\shared.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Server\shared-server\shared-server.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Server\AIServer\AIServer.Core.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Server\AIServer\AIServer.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Server\Ebenezer\Ebenezer.Core.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Server\Ebenezer\Ebenezer.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Server\Aujard\Aujard.Core.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Server\Aujard\Aujard.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Server\ItemManager\ItemManager.Core.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Server\ItemManager\ItemManager.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Server\VersionManager\VersionManager.Core.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Server\VersionManager\VersionManager.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Client\WarFare\WarFare.Core.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

CALL "%~dp0msbuild.cmd" "src\Client\WarFare\WarFare.vcxproj" %COMMON%
IF ERRORLEVEL 1 EXIT /B 1

ECHO Rebuild complete.
EXIT /B 0
