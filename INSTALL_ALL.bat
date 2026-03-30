@echo off
echo ╔════════════════════════════════════════════════════════════╗
echo ║     Bareeq Al-Yusr - Install ALL Dependencies             ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo This will install:
echo   1. Python backend dependencies (pip)
echo   2. Flutter app dependencies (pub get)
echo.
echo This may take 5-10 minutes depending on your internet speed.
echo.
pause

echo.
echo ========================================
echo STEP 1/2: Installing Backend Dependencies
echo ========================================
echo.

cd /d "%~dp0backend"

python --version
if %errorlevel% neq 0 (
    echo ERROR: Python is not installed!
    echo Please install Python 3.8+ from https://www.python.org/
    pause
    exit /b 1
)

echo Installing Python packages...
pip install -r requirements.txt

if %errorlevel% neq 0 (
    echo.
    echo WARNING: Some backend packages failed to install
    echo Continuing anyway...
    timeout /t 3 /nobreak > nul
)

echo.
echo ========================================
echo STEP 2/2: Installing Flutter Dependencies
echo ========================================
echo.

cd /d "%~dp0"

flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed!
    echo Please install Flutter from https://flutter.dev/
    pause
    exit /b 1
)

echo Running flutter clean...
flutter clean

echo.
echo Getting Flutter packages...
flutter pub get

if %errorlevel% equ 0 (
    echo.
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║              ✅ ALL DEPENDENCIES INSTALLED!                ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    echo Next steps:
    echo   1. Double-click: START_EVERYTHING.bat
    echo   2. Or run backend: start-backend.bat
    echo   3. Or run flutter: start-flutter.bat
    echo.
) else (
    echo.
    echo ╔════════════════════════════════════════════════════════════╗
    echo ║            ⚠️ SOME DEPENDENCIES FAILED                     ║
    echo ╚════════════════════════════════════════════════════════════╝
    echo.
    echo Please check the error messages above
    echo You may need to run commands manually
    echo.
)

pause
