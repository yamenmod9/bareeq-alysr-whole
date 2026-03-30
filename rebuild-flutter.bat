@echo off
echo ╔════════════════════════════════════════════════════════════╗
echo ║       Rebuild Flutter App with New Configuration          ║
echo ╚════════════════════════════════════════════════════════════╝
echo.
echo This will:
echo   1. Clean Flutter cache
echo   2. Get dependencies
echo   3. Rebuild the app
echo.
echo This is needed after changing the API URL configuration.
echo.
pause

cd /d "%~dp0"

echo.
echo [1/3] Cleaning Flutter cache...
flutter clean

echo.
echo [2/3] Getting dependencies...
flutter pub get

echo.
echo [3/3] Ready to run!
echo.
echo Now run: flutter run
echo Or double-click: start-flutter.bat
echo.
pause
