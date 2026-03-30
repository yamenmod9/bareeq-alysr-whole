@echo off
echo =========================================
echo   Installing Flutter Dependencies
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
echo Running flutter clean...
flutter clean

echo.
echo Getting Flutter dependencies from pubspec.yaml...
echo This may take a few minutes...
echo.

flutter pub get

if %errorlevel% equ 0 (
    echo.
    echo =========================================
    echo   SUCCESS! Flutter dependencies installed
    echo =========================================
    echo.
) else (
    echo.
    echo =========================================
    echo   ERROR: Failed to install dependencies
    echo =========================================
    echo.
    echo Try running these commands manually:
    echo   flutter clean
    echo   flutter pub get
    echo.
)

pause
