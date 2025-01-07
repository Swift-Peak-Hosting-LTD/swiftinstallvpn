@echo on
setlocal EnableDelayedExpansion

:: Enable debug mode (set to 1 for debug messages)
set DEBUG=0

REM Function to display info messages
:info
echo [INFO] %~1
if %DEBUG%==1 echo [DEBUG] %~1
goto :eof

REM Function to display warning messages
:warning
echo [WARNING] %~1
goto :eof

REM Function to display error messages
:error
echo [ERROR] %~1
if %DEBUG%==1 echo [DEBUG-ERROR] %~1
exit /b
goto :eof

REM Display welcome message
call :info "======================================"
call :info "|||      Swift Peak Hosting LTD     |||"
call :info "======================================"

REM Check if CURL is installed
call :info "Checking for CURL..."
where curl >nul 2>nul
if %errorlevel% neq 0 (
    call :error "CURL is not installed. Please install CURL and try again."
)
call :info "CURL is installed."

REM Prompt for license key
set /p LICENSE_KEY="Please enter your license key: "

REM Prompt for installation directory
set /p TARGET_DIR="Please enter the installation directory path: "

REM Check if target directory exists
if not exist "%TARGET_DIR%" (
    call :info "Creating directory: %TARGET_DIR%"
    mkdir "%TARGET_DIR%"
    if %errorlevel% neq 0 (
        call :error "Failed to create directory. Please check permissions."
    )
)

REM Set variables
set PACKAGE_NAME=VPN
set RESOURCE_NAME=VPN
set DOWNLOAD_API_URL=https://store.swiftpeakhosting.co.uk/api/v1/licenses/public/download

REM Attempt to connect and get the download URL
call :info "Attempting to connect to API..."
set PAYLOAD={"license":"%LICENSE_KEY%","packages":"%PACKAGE_NAME%","resource_name":"%RESOURCE_NAME%"}

for /f "delims=" %%A in ('curl -s -X POST %DOWNLOAD_API_URL% -H "Content-Type: application/json" -d "%PAYLOAD%"') do set RESPONSE=%%A
if %DEBUG%==1 echo [DEBUG-RESPONSE]: %RESPONSE%

echo %RESPONSE% | findstr /C:"true" >nul
if %errorlevel% neq 0 (
    call :error "Failed to validate the license key or download URL."
)

for /f "tokens=2 delims=:," %%A in ('echo %RESPONSE% ^| findstr /C:"download_url"') do set DOWNLOAD_URL=%%~A
set DOWNLOAD_URL=%DOWNLOAD_URL:"=%

REM Verify download URL
if "%DOWNLOAD_URL%"=="" (
    call :error "Failed to parse download URL."
)

REM Download the ZIP file
set ZIP_FILE=%TEMP%\%RESOURCE_NAME%.zip
call :info "Downloading ZIP file..."
curl -L -o "%ZIP_FILE%" "%DOWNLOAD_URL%"
if not exist "%ZIP_FILE%" (
    call :error "Failed to download the zip file."
)
call :info "Download complete."

REM Extract the ZIP file
call :info "Extracting ZIP file..."
powershell -Command "Expand-Archive -Force '%ZIP_FILE%' '%TARGET_DIR%'"
if %errorlevel% neq 0 (
    call :error "Failed to extract the zip file."
)
call :info "Extraction complete."

REM Cleanup
del "%ZIP_FILE%"
call :info "Installation of VPN has been completed successfully. Please check if there are any errors."
endlocal
