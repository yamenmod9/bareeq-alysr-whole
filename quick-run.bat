@echo off
echo ════════════════════════════════════════════════════════════
echo    Quick Flutter Run (No Clean)
echo ════════════════════════════════════════════════════════════
echo.
echo This skips flutter clean and just runs the app.
echo Use this if rebuild-and-run.bat is hanging.
echo.
pause

cd /d "%~dp0"

echo.
echo Checking devices...
flutter devices

echo.
echo Running app...
echo.
flutter run

pause
