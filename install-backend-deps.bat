@echo off
echo =========================================
echo   Installing Backend Dependencies
echo =========================================
echo.

cd /d "%~dp0backend"

echo Checking Python installation...
python --version
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://www.python.org/
    pause
    exit /b 1
)

echo.
echo Installing Python packages from requirements.txt...
echo This may take a few minutes...
echo.

pip install -r requirements.txt

if %errorlevel% equ 0 (
    echo.
    echo =========================================
    echo   SUCCESS! Backend dependencies installed
    echo =========================================
    echo.
) else (
    echo.
    echo =========================================
    echo   ERROR: Failed to install dependencies
    echo =========================================
    echo.
    echo Try running this command manually:
    echo   pip install --upgrade pip
    echo   pip install -r backend\requirements.txt
    echo.
)

pause
