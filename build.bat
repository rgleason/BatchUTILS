@echo off
if "%1"=="" goto notarget
cmake --build . --config release --target %1
if %ERRORLEVEL% GTR 0 goto quit
goto install
:notarget
cmake --build . --config release
if %ERRORLEVEL% GTR 0 goto quit
call docopyAll Release
goto finish
:install
move opencpn*.exe "%USERPROFILE%\Google Drive\"
:finish
date /t
time /t
exit /b 0
:quit
@echo Build failed!
@echo Maybe you should use "package" as the target instead of "%1".
exit /b 1