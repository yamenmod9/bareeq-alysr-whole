@echo off
echo =========================================
echo   Starting Bareeq Al-Yusr Flutter App
echo =========================================
echo.

cd /d "%~dp0"

echo Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/
    pause
    exit /b 1
)

echo.
echo Starting Flutter app...
echo This will launch the app on your connected device/emulator
echo.

flutter run

pause
