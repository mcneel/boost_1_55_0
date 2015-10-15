REM Clearing out stage\lib, because switching between
REM platforms doesn't necessarily rebuild these libs
REM properly.

@RMDIR /S /Q .\bin.v2
@RMDIR /S /Q .\stage%1
@RMDIR /S /Q .\stage%1static

ECHO Bootstrapping and building boost. %1 %2.
CALL .\bootstrap.bat


REM The following libraries can be built for boost:
REM    atomic
REM    chrono
REM    context
REM    coroutine
REM    date_time
REM    exception
REM    filesystem
REM    graph
REM    graph_parallel
REM    iostreams
REM    locale
REM    log
REM    math
REM    mpi
REM    program_options
REM    python
REM    random
REM    regex
REM    serialization
REM    signals
REM    system
REM    test
REM    thread
REM    timer
REM    wave
REM To build only specific libraries use --with-<libname> on the
REM command-line to b2
REM
REM Adding NOMINMAX as define, otherwise build of serialization will
REM fail hard on x64


SETLOCAL ENABLEDELAYEDEXPANSION

@ECHO OFF

ECHO Handle shared libs

CALL .\b2 toolset=msvc warnings=off variant=%1 link=shared threading=multi address-model=%2 -d0 --with-chrono --with-filesystem --with-system --with-thread --stagedir=./stage%1

PUSHD stage%1\lib
IF "%1" == "debug" (
	FOR /f "tokens=*" %%f IN ('dir /b *gd-1_55.lib') DO (
		SET PTH=%%~dpf
		SET newname=!PTH!lib%%f
		MOVE "!PTH!%%f" "!newname!"
	)
	POPD
	copy .\stage%1\lib\*gd-1_55.dll ..\bin\Debug\
)

IF "%1" == "release" (
	FOR /f "tokens=*" %%f IN ('dir /b *mt-1_55.lib') DO (
		SET PTH=%%~dpf
		SET newname=!PTH!lib%%f
		MOVE "!PTH!%%f" "!newname!"
	)
	POPD
	copy .\stage%1\lib\*mt-1_55.dll ..\bin\Release\
)

ECHO Handle static libs

CALL .\b2 toolset=msvc warnings=off variant=%1 link=static threading=multi address-model=%2 -d0 --with-date_time --with-regex --with-serialization --with-locale --stagedir=./stage%1static

PUSHD stage%1static\lib
IF "%1" == "debug" (
	FOR /f "tokens=*" %%f IN ('dir /b *gd-1_55.lib') DO (
		SET OPTH=%%~dpf
		SET PTH=%%~dpf..\..\stage%1\lib\
		SET newname=!PTH!%%f
		MOVE "!OPTH!%%f" "!newname!"
	)
	POPD
)

IF "%1" == "release" (
	FOR /f "tokens=*" %%f IN ('dir /b *mt-1_55.lib') DO (
		SET OPTH=%%~dpf
		SET PTH=%%~dpf..\..\stage%1\lib\
		SET newname=!PTH!%%f
		MOVE "!OPTH!%%f" "!newname!"
	)
	POPD
)

ENDLOCAL
