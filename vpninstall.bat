@echo off
setlocal EnableDelayedExpansion

:: Enable debug mode (set DEBUG=1 for verbose output)
set DEBUG=1

:: Debug function
if %DEBUG%==1 (
    echo [DEBUG] Debug mode enabled.
    @echo on
)

:: Functions for output
:info
echo [INFO] %*
goto :eof

:warning
echo [WARNING] %*
goto :eof

:error
echo [ERROR] %*
exit /b 1
goto :eof

:: Welcome Message
call :info ======================================
call :info |||      Swift Peak Hosting LTD     |||
call :info ======================================

:: Check CURL
call :info Checking for CURL installation...
where curl >nul 2>nul
if %errorlevel% neq 0 (
    call :error CURL is not installed. Please install CURL and try again.
)

call :info CURL is installed.

:: Prompt for License Key
set /p LICENSE_KEY=Please enter your license key: 
if "%LICENSE_KEY%"=="" (
    call :error License key cannot be empty!
)

:: Prompt for Installation Directory
set /p TARGET_DIR=Please enter the installation directory path: 
if "%TARGET_DIR%"=="" (
    call :error Target directory cannot be empty!
)

:: Create Directory if it doesn't exist
if not exist "%TARGET_DIR%" (
    call :info Creating directory: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
    if %errorlevel% neq 0 (
        call :error Failed to create directory. Check permissions.
    )
)

:: Define Variables
set PACKAGE_NAME=VPN
set RESOURCE_NAME=VPN
set DOWNLOAD_API_URL=https://store.swiftpeakhosting.co.uk/api/v1/licenses/public/download

:: Debug variables
if %DEBUG%==1 (
    echo [DEBUG] License Key: %LICENSE_KEY%
    echo [DEBUG] Target Directory: %TARGET_DIR%
)

:: Call API and Fetch Download URL
call :info Connecting to API...

set PAYLOAD={"license":"%LICENSE_KEY%","packages":"%PACKAGE_NAME%","resource_name":"%RESOURCE_NAME%"}

:: Send API Request
for /f "delims=" %%A in ('curl -s -X POST %DOWNLOAD_API_URL% -H "Content-Type: application/json" -d "{ \"license\": \"%LICENSE_KEY%\", \"packages\": \"%PACKAGE_NAME%\", \"resource_name\": \"%RESOURCE_NAME%\" }"') do (
    set RESPONSE=%%A
)

:: Debug Response
if %DEBUG%==1 echo [DEBUG] API Response: !RESPONSE!

:: Parse Download URL from Response
for /f "tokens=2 delims=:," %%A in ('echo !RESPONSE! ^| findstr /C:"download_url"') do set DOWNLOAD_URL=%%~A
set DOWNLOAD_URL=!DOWNLOAD_URL:"=!
set DOWNLOAD_URL=!DOWNLOAD_URL: }=!

:: Debug Download URL
if %DEBUG%==1 echo [DEBUG] Download URL: !DOWNLOAD_URL!

:: Validate Download URL
if "!DOWNLOAD_URL!"=="" (
    call :error Failed to extract download URL.
)

:: Download ZIP File
set ZIP_FILE=%TEMP%\%RESOURCE_NAME%.zip
call :info Downloading ZIP file...
curl -L -o "!ZIP_FILE!" "!DOWNLOAD_URL!"
if not exist "!ZIP_FILE!" (
    call :error Failed to download the ZIP file.
)
call :info Download complete.

:: Extract ZIP File
call :info Extracting ZIP file...
powershell -Command "Expand-Archive -Force '!ZIP_FILE!' '!TARGET_DIR!'"
if %errorlevel% neq 0 (
    call :error Failed to extract the ZIP file.
)
call :info Extraction complete.

:: Cleanup
del "!ZIP_FILE!"
call :info Installation completed successfully!

endlocal
