@ECHO OFF
SETLOCAL EnableExtensions EnableDelayedExpansion

REM One-command dev workflow:
REM - stop any running stack
REM - (if git working tree is clean) pull latest from origin
REM - rebuild everything (Debug|x64 by default)
REM - run servers + client (use --no-client to skip)
REM
REM Usage:
REM   build_scripts\dev_run.cmd [Configuration] [Platform] [--no-client]

SET "CONFIG=%~1"
SET "PLATFORM=%~2"
SET "OPT3=%~3"

IF "%CONFIG%"=="" SET "CONFIG=Debug"
IF "%PLATFORM%"=="" SET "PLATFORM=x64"

FOR %%I IN ("%~dp0..") DO SET "ROOT=%%~fI"
PUSHD "%ROOT%" >NUL

CALL "%~dp0env_find_git.cmd" >NUL 2>&1
IF ERRORLEVEL 1 (
	SET "GIT=git"
) ELSE (
	SET "GIT=%GitPath%"
)

REM Best-effort: pull latest only if we have git + no tracked local changes.
REM (Ignore untracked files like local MAP/QUESTS assets.)
"%GIT%" rev-parse --is-inside-work-tree >NUL 2>&1
IF NOT ERRORLEVEL 1 (
	FOR /f "delims=" %%B IN ('"%GIT%" branch --show-current 2^>NUL') DO SET "BRANCH=%%B"
	FOR /f "delims=" %%H IN ('"%GIT%" rev-parse --short HEAD 2^>NUL') DO SET "HEAD=%%H"
	IF NOT "!BRANCH!"=="" ECHO Git: !BRANCH! !HEAD!

	FOR /f %%C IN ('"%GIT%" status --porcelain --untracked-files=no 2^>NUL ^| find /c /v ""') DO SET "DIRTY=%%C"
	IF "!DIRTY!"=="0" (
		ECHO Updating from origin...
		"%GIT%" pull --rebase
		IF ERRORLEVEL 1 (
			ECHO ERROR: git pull failed. Aborting.
			POPD >NUL
			EXIT /B 1
		)
	) ELSE (
		ECHO NOTE: Tracked local changes; skipping git pull.
	)
)

CALL "%~dp0stop_stack.cmd"
IF ERRORLEVEL 1 (
	POPD >NUL
	EXIT /B 1
)

CALL "%~dp0rebuild_stack.cmd" "%CONFIG%" "%PLATFORM%"
IF ERRORLEVEL 1 (
	POPD >NUL
	EXIT /B 1
)

CALL "%~dp0run_stack.cmd" "%CONFIG%" "%PLATFORM%" "%OPT3%"
SET "RC=%ERRORLEVEL%"

POPD >NUL
EXIT /B %RC%
