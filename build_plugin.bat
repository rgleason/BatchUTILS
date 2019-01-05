@setlocal enableextensions enabledelayedexpansion
@echo off
if "%1"=="noconfig" goto :noconfig
@echo Trying to configure...
rem ******************************************
rem * This script will configure using Cmake *
rem * to build plugins. Run this in the      *
rem * plugin\build folder.                   *
rem ******************************************
pushd ..
for /f %%i in ('cd') do set SRCFOLDER=%%i
popd

call findvc.bat

if "%vcgen%"=="" goto :noVC

set "var=%vcts%"
set "search=_xp"
CALL set "test=%%var:%search%=%%"
if "%test%" NEQ "%var%" (set "XP_FLAG=,5.01") else set XP_FLAG=

if not exist .\CMakeCache.txt goto :nocache
del .\CMakeCache.txt
:nocache

if  not exist .\Debug\NUL mkdir .\Debug
if  not exist .\Release\NUL mkdir .\Release

echo configuring generator "%vcgen%" and toolset v%vcts%
rem @echo cmake -Wno-dev -G "%vcgen%" -T v%vcts% -D CMAKE_CXX_FLAGS="/D_USING_V110_SDK71_ /MP /EHsc" -D CMAKE_C_FLAGS="/MP /D_USING_V110_SDK71_" CMAKE_EXE_LINKER_FLAGS=/SUBSYSTEM:WINDOWS"%XP_FLAG%" CMAKE_MODULE_LINKER_FLAGS=/SUBSYSTEM:WINDOWS"%XP_FLAG%" CMAKE_SHARED_MODULE_LINKER_FLAGS=/SUBSYSTEM:WINDOWS"%XP_FLAG%" ..

@cmake -Wno-dev -G "%vcgen%" -T v%vcts% -D CMAKE_CXX_FLAGS="/D_USING_V110_SDK71_ /MP /EHsc" -D CMAKE_C_FLAGS="/MP /D_USING_V110_SDK71_" CMAKE_EXE_LINKER_FLAGS=/SUBSYSTEM:WINDOWS""%XP_FLAG%"" CMAKE_MODULE_LINKER_FLAGS=/SUBSYSTEM:WINDOWS""%XP_FLAG%"" CMAKE_SHARED_MODULE_LINKER_FLAGS=/SUBSYSTEM:WINDOWS""%XP_FLAG%"" ..
if %ERRORLEVEL% GTR 0 goto :quit

cmake --build . --config Debug --target clean
cmake --build . --config Release --target clean
:noconfig
copy /y \storage\transmitterdan\OpenCPN\build\debug\opencpn.lib .\
if %ERRORLEVEL% GTR 0 goto :quit
del /f /q .\*.exe
del /f /q .\debug\*.exe
cmake --build . --config Debug --target package
if %ERRORLEVEL% GTR 0 goto :quit
move *.exe debug

for %%F in (".\debug\*.exe") do (
    set file=%%~nxF
    echo .\debug\!file! /D=%OpenCPNDIR%\build\debug
	.\debug\!file! /D=%OpenCPNDIR%\build\debug
)

copy /y \storage\transmitterdan\OpenCPN\build\release\opencpn.lib .\
if %ERRORLEVEL% GTR 0 goto :quit
del /f /q .\*.exe
cmake --build . --config Release --target package
if %ERRORLEVEL% GTR 0 goto :quit

@echo SUCCESS!
exit /b 0

:quit
set __ts__=
set __gen__=
exit /b 1

:noVC
@echo Error: No compatible Visual Studio installed.
@echo VCINSTALLDIR=%VCINSTALLDIR%
goto :quit

:VS2013
echo Configuring for VS2013
set "__gen__=Visual Studio 12 2013"
set "__ts__=v120_xp"
goto :EOF

:VS2015
echo Configuring for VS2015
set "__gen__=Visual Studio 14 2015"
set "__ts__=v140_xp"
goto :EOF

:VS2017
echo Configuring for VS2017
set "__gen__=Visual Studio 15 2017"
set "__ts__=v141_xp"
goto :EOF
