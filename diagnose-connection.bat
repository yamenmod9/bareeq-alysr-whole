@echo off
echo ╔════════════════════════════════════════════════════════════╗
echo ║          Bareeq Al-Yusr - Connection Diagnostics          ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

echo [1/5] Checking if backend is running...
echo.
curl -s http://localhost:8000/health > nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Backend is running on localhost:8000
    echo.
    curl http://localhost:8000/health
    echo.
) else (
    echo ❌ Backend is NOT running on localhost:8000
    echo.
    echo SOLUTION: Run START_EVERYTHING.bat to start the backend
    echo.
)

echo.
echo [2/5] Checking your computer's IP address...
echo.
echo Your IPv4 addresses:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /C:"IPv4"') do echo   %%a
echo.
echo If using a PHYSICAL DEVICE, use one of these IPs instead of 10.0.2.2
echo.

echo [3/5] Checking Flutter...
echo.
flutter --version 2>nul
if %errorlevel% neq 0 (
    echo ❌ Flutter not found in PATH
    echo SOLUTION: Install Flutter or add to PATH
) else (
    echo ✅ Flutter is installed
)
echo.

echo [4/5] Checking connected devices...
echo.
flutter devices
echo.

echo [5/5] Current Flutter API Configuration:
echo.
echo File: lib\core\config\app_config.dart
echo Current setting: http://10.0.2.2:8000
echo.
echo This works for: ✅ Android Emulator
echo Does NOT work for: ❌ Physical Device, ❌ iOS Simulator
echo.

echo ════════════════════════════════════════════════════════════
echo RECOMMENDATIONS:
echo ════════════════════════════════════════════════════════════
echo.

if exist "d:\Programming\bareeq-alysr-whole\lib\core\config\app_config.dart" (
    findstr /C:"10.0.2.2" "d:\Programming\bareeq-alysr-whole\lib\core\config\app_config.dart" > nul
    if %errorlevel% equ 0 (
        echo Current config: http://10.0.2.2:8000
        echo.
        echo ✅ IF USING: Android Emulator
        echo    → Config is correct!
        echo    → Make sure backend is running
        echo    → Run: flutter clean && flutter run
        echo.
        echo ❌ IF USING: Physical Device
        echo    → Change config to: http://YOUR_COMPUTER_IP:8000
        echo    → See IP addresses above
        echo    → Edit: lib\core\config\app_config.dart
        echo    → Change line 9 to use your IP
        echo.
        echo ❌ IF USING: iOS Simulator
        echo    → Change config to: http://localhost:8000
        echo    → Edit: lib\core\config\app_config.dart
        echo    → Change line 9 to: defaultValue: 'http://localhost:8000',
        echo.
    )
)

echo ════════════════════════════════════════════════════════════
echo QUICK FIXES:
echo ════════════════════════════════════════════════════════════
echo.
echo 1. Make sure backend is running:
echo    → Run: START_EVERYTHING.bat
echo    → Check: http://localhost:8000/health in browser
echo.
echo 2. Clean and rebuild Flutter app:
echo    → flutter clean
echo    → flutter pub get
echo    → flutter run
echo.
echo 3. Check device type and update config accordingly
echo    → Android Emulator: 10.0.2.2:8000
echo    → iOS Simulator: localhost:8000
echo    → Physical Device: YOUR_COMPUTER_IP:8000
echo.
pause
