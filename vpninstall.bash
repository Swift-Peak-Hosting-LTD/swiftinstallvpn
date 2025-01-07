@echo off
setlocal EnableDelayedExpansion

REM Function to display info messages
:info
echo [INFO] %~1
goto :eof

REM Function to display warning messages
:warning
echo [WARNING] %~1
goto :eof

REM Function to display error messages
:error
echo [ERROR] %~1
goto :eof

REM Display welcome message
call :info "======================================"
call :info "|||      Swift Peak Hosting LTD     |||"
call :info "======================================"

REM Check if Git is installed
call :info "Checking for Git..."
where git >nul 2>nul
if %errorlevel% neq 0 (
    call :error "Git is not installed. Please install Git and try again."
    exit /b
)
call :info "Git is installed."

REM Prompt for repository URL
set /p GITHUB_URL="Enter the GitHub repository URL (e.g., https://github.com/user/repo.git): "

REM Validate URL
echo %GITHUB_URL% | findstr /R "https://github.com/[a-zA-Z0-9_-]\+/[a-zA-Z0-9_-]\+.git" >nul
if %errorlevel% neq 0 (
    call :error "Invalid GitHub repository URL. Please enter a valid URL ending with .git."
    exit /b
)

REM Prompt for installation directory
set /p TARGET_DIR="Enter the installation directory path: "

REM Check if target directory exists
if not exist "%TARGET_DIR%" (
    call :info "Creating directory: %TARGET_DIR%"
    mkdir "%TARGET_DIR%"
    if %errorlevel% neq 0 (
        call :error "Failed to create directory. Please check permissions."
        exit /b
    )
)

REM Clone repository
call :info "Cloning repository..."
git clone "%GITHUB_URL%" "%TARGET_DIR%"
if %errorlevel% neq 0 (
    call :error "Failed to clone repository. Please check the URL and your internet connection."
    exit /b
)
call :info "Repository cloned successfully."

REM Navigate to directory
cd /d "%TARGET_DIR%"

REM Check if installation script exists
if not exist "install.bat" (
    call :error "Installation script (install.bat) not found in repository."
    exit /b
)

REM Execute the installation script
call :info "Running installation script..."
call install.bat
if %errorlevel% neq 0 (
    call :error "Installation script failed. Please check for errors."
    exit /b
)

call :info "Installation completed successfully!"
endlocal
