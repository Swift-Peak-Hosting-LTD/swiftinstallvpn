@echo off
setlocal EnableDelayedExpansion

:: Enable debug mode (set to 1 for detailed output)
set DEBUG=1

:: Debugging log output
if %DEBUG%==1 echo [DEBUG] Debug mode enabled.
if %DEBUG%==1 @echo on

:: Functions
:info
set MSG=%*
echo [INFO] !MSG!
goto :eof

:warning
set MSG=%*
echo [WARNING] !MSG!
goto :eof

:error
set MSG=%*
echo [ERROR] !MSG!
exit /b
goto :eof

:: Welcome Message
call :info ======================================
call :info |||      Swift Peak Hosting LTD     |||
call :info ======================================

:: Example Debug Output
call :info Debug mode active!
