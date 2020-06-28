@echo off
if NOT [%2]==[] call %2
call cmd /c build-tess-win.bat %1 Debug
if %errorlevel% neq 0 exit /b %errorlevel%
call cmd /c build-tess-win.bat %1 Release
if %errorlevel% neq 0 exit /b %errorlevel%
