@echo off
echo ╔════════════════════════════════════════════════════════════╗
echo ║   Rebuild Flutter App with Physical Device Configuration  ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo Configuration: http://192.168.1.7:8000
echo Make sure phone is on SAME WiFi network!
echo.

cd /d "%~dp0"

echo ════════════════════════════════════════════════════════════
echo Step 1: Cleaning Flutter cache
echo ════════════════════════════════════════════════════════════
echo Running: flutter clean
echo Please wait, this may take 30-60 seconds...
echo.

call flutter clean

if %errorlevel% neq 0 (
    echo.
    echo ❌ ERROR: flutter clean failed!
    echo.
    echo Try running manually:
    echo   1. Open Command Prompt
    echo   2. cd d:\Programming\bareeq-alysr-whole
    echo   3. flutter clean
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Clean completed!
echo.

echo ════════════════════════════════════════════════════════════
echo Step 2: Getting dependencies
echo ════════════════════════════════════════════════════════════
echo Running: flutter pub get
echo Please wait, this may take 30-60 seconds...
echo.

call flutter pub get

if %errorlevel% neq 0 (
    echo.
    echo ❌ ERROR: flutter pub get failed!
    echo.
    echo Try running manually:
    echo   1. Open Command Prompt
    echo   2. cd d:\Programming\bareeq-alysr-whole
    echo   3. flutter pub get
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Dependencies installed!
echo.

echo ════════════════════════════════════════════════════════════
echo Step 3: Checking devices
echo ════════════════════════════════════════════════════════════
echo.

call flutter devices

echo.
echo ════════════════════════════════════════════════════════════
echo Ready to run!
echo ════════════════════════════════════════════════════════════
echo.
echo If you see your device above, press any key to continue.
echo If not, make sure USB debugging is enabled.
echo.
pause

echo.
echo Starting: flutter run
echo This will build and install the app on your device.
echo Please wait, first build may take 5-10 minutes...
echo.

call flutter run

pause
