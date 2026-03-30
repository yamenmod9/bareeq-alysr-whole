@echo off
echo =========================================
echo   Starting Bareeq Al-Yusr Backend Server
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
echo Starting Flask server on http://localhost:8000
echo Press Ctrl+C to stop the server
echo.

python run.py

pause
