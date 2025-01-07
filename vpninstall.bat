@echo off
setlocal enabledelayedexpansion

:: Welcome Message
echo ======================================
echo |||      Swift Peak Hosting LTD     |||
echo ======================================

:: Check CURL
echo [INFO] Checking for CURL installation...
where curl >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] CURL is not installed. Please install CURL and try again.
    exit /b
)
echo [INFO] CURL is installed.

:: Prompt for License Key
set /p LICENSE_KEY=Please enter your license key: 
if "%LICENSE_KEY%"=="" (
    echo [ERROR] License key cannot be empty!
    exit /b
)

:: Prompt for Installation Directory
set /p TARGET_DIR=Please enter the installation directory path: 
if "%TARGET_DIR%"=="" (
    echo [ERROR] Target directory cannot be empty!
    exit /b
)

:: Create Directory if it doesn't exist
if not exist "%TARGET_DIR%" (
    echo [INFO] Creating directory: %TARGET_DIR%
    mkdir "%TARGET_DIR%"
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to create directory. Check permissions.
        exit /b
    )
)

:: Variables
set PACKAGE_NAME=VPN
set RESOURCE_NAME=VPN
set DOWNLOAD_API_URL=https://store.swiftpeakhosting.co.uk/api/v1/licenses/public/download

:: Send API Request and Capture Response
echo [INFO] Connecting to API...
curl -s -X POST %DOWNLOAD_API_URL% -H "Content-Type: application/json" -d "{ \"license\": \"%LICENSE_KEY%\", \"packages\": \"%PACKAGE_NAME%\", \"resource_name\": \"%RESOURCE_NAME%\" }" > api_response.json

:: Validate Response
if not exist api_response.json (
    echo [ERROR] Failed to connect to the API.
    exit /b
)

:: Read API Response
set DOWNLOAD_URL=
for /f "tokens=2 delims=:," %%A in ('findstr "download_url" api_response.json') do set DOWNLOAD_URL=%%A
set DOWNLOAD_URL=%DOWNLOAD_URL:"=%
set DOWNLOAD_URL=%DOWNLOAD_URL: }=%

:: Check if Download URL is valid
if "%DOWNLOAD_URL%"=="" (
    echo [ERROR] Failed to retrieve download URL from the API response.
    echo [DEBUG] API Response:
    type api_response.json
    del api_response.json
    exit /b
)

:: Download ZIP File
set ZIP_FILE=%TEMP%\%RESOURCE_NAME%.zip
echo [INFO] Downloading ZIP file...
curl -L -o "%ZIP_FILE%" "%DOWNLOAD_URL%"
if not exist "%ZIP_FILE%" (
    echo [ERROR] Failed to download the ZIP file.
    exit /b
)
echo [INFO] Download complete.

:: Extract ZIP File
echo [INFO] Extracting ZIP file...
powershell -Command "Expand-Archive -Force '%ZIP_FILE%' '%TARGET_DIR%'"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to extract the ZIP file.
    exit /b
)
echo [INFO] Extraction complete.

:: Cleanup
del "%ZIP_FILE%"
del "api_response.json"
echo [INFO] Installation completed successfully!

endlocal
exit /b 0
