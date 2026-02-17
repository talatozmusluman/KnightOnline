@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

REM Wrapper that finds MSBuild via vswhere and forwards all args to MSBuild.
REM Usage:
REM   build_scripts\msbuild.cmd <msbuild args...>

CALL "%~dp0env_find_msbuild.cmd"
IF NOT ERRORLEVEL 0 (
	ECHO ERROR: MSBuild.exe not found. Ensure Visual Studio 2022 is installed.
	EXIT /B 1
)

SET "MSB=%MSBUILD%"

REM env_find_msbuild.cmd should return a full path to MSBuild.exe, but handle cases where it returns the Bin dir.
IF EXIST "%MSB%\MSBuild.exe" (
	SET "MSB=%MSB%\MSBuild.exe"
)

IF NOT EXIST "%MSB%" (
	ECHO ERROR: MSBuild resolved path does not exist: "%MSB%"
	EXIT /B 1
)

"%MSB%" %*
EXIT /B %ERRORLEVEL%

