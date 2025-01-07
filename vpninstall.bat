@echo off
setlocal EnableDelayedExpansion

:: Enable debug mode (set to 1 for detailed output)
set DEBUG=1

:: Debugging log output
if %DEBUG%==1 echo [DEBUG] Debug mode enabled.
if %DEBUG%==1 @echo on

:: Functions
:info
set "MSG=%*"
echo [INFO] !MSG!
goto :eof

:warning
set "MSG=%*"
echo [WARNING] !MSG!
goto :eof

:error
set "MSG=%*"
echo [ERROR] !MSG!
exit /b
goto :eof

:: Welcome Message
call :info ======================================
call :info |||      Swift Peak Hosting LTD     |||
call :info ======================================

:: Example Debug Output
call :info Debug mode active!

:: Check CURL
call :info Checking for CURL...
where curl >nul 2>nul
if %errorlevel% neq 0 (
    call :error CURL is not installed. Install CURL and try again.
    exit /b
)
call :info CURL is installed.

:: Prompt for license key
set /p LICENSE_KEY=Please enter your license key: 
if "%LICENSE_KEY%"=="" (
    call :error License key cannot be empty.
    exit /b
)

:: Prompt for installation directory
set /p TARGET_DIR=Please enter the installation directory path: 
if "%TARGET_DIR%"=="" (
    call :error Target directory cannot be empty.
    exit /b
)

:: Check directory
if not exist "%TARGET_DIR%" (
    call :info Creating directory: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
    if %errorlevel% neq 0 (
        call :error Failed to create directory. Check permissions.
        exit /b
    )
)

:: Variables
set PACKAGE_NAME=VPN
set RESOURCE_NAME=VPN
set DOWNLOAD_API_URL=https://store.swiftpeakhosting.co.uk/api/v1/licenses/public/download

:: Debug variables
if %DEBUG%==1 (
    echo [DEBUG] License Key: %LICENSE_KEY%
    echo [DEBUG] Target Directory: %TARGET_DIR%
)

:: API Call
call :info Connecting to API...
set PAYLOAD={"license":"%LICENSE_KEY%","packages":"%PACKAGE_NAME%","resource_name":"%RESOURCE_NAME%"}

:: CURL command for response
for /f "delims=" %%A in ('curl -s -X POST %DOWNLOAD_API_URL% -H "Content-Type: application/json" -d "{ \"license\": \"%LICENSE_KEY%\", \"packages\": \"%PACKAGE_NAME%\", \"resource_name\": \"%RESOURCE_NAME%\" }"') do set RESPONSE=%%A

:: Debug Response
if %DEBUG%==1 echo [DEBUG] API Response: !RESPONSE!

:: Validate response
echo !RESPONSE! | findstr /C:"true" >nul
if %errorlevel% neq 0 (
    call :error API call failed. Invalid response.
    exit /b
)

:: Extract download URL
for /f "tokens=2 delims=:," %%A in ('echo !RESPONSE! ^| findstr /C:"download_url"') do set DOWNLOAD_URL=%%~A
set DOWNLOAD_URL=!DOWNLOAD_URL:"=!

:: Debug Download URL
if %DEBUG%==1 echo [DEBUG] Download URL: !DOWNLOAD_URL!

if "!DOWNLOAD_URL!"=="" (
    call :error Failed to extract download URL.
    exit /b
)

:: Download ZIP
set ZIP_FILE=%TEMP%\%RESOURCE_NAME%.zip
call :info Downloading ZIP file...
curl -L -o "!ZIP_FILE!" "!DOWNLOAD_URL!"
if not exist "!ZIP_FILE!" (
    call :error Failed to download the ZIP file.
    exit /b
)
call :info Download complete.

:: Extract ZIP
call :info Extracting ZIP file...
powershell -Command "Expand-Archive -Force '!ZIP_FILE!' '!TARGET_DIR!'"
if %errorlevel% neq 0 (
    call :error Failed to extract the ZIP file.
    exit /b
)
call :info Extraction complete.

:: Cleanup
del "!ZIP_FILE!"
call :info Installation completed successfully.
endlocal
