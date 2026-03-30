@echo off
echo =========================================
echo   Bareeq Al-Yusr - Complete Setup
echo =========================================
echo.
echo This will:
echo 1. Start the Backend Server (Port 8000)
echo 2. Wait for you to start Flutter app manually
echo.
echo Press any key to continue...
pause > nul

echo.
echo ========================================
echo STEP 1: Starting Backend Server
echo ========================================
echo.

cd /d "%~dp0backend"
start "Bareeq Backend Server" cmd /k "python run.py"

echo Backend server starting...
echo Waiting 5 seconds for server to initialize...
timeout /t 5 /nobreak > nul

echo.
echo ========================================
echo STEP 2: Testing Backend Connection
echo ========================================
echo.
echo Opening health check in browser...
start http://localhost:8000/health

timeout /t 3 /nobreak > nul

echo.
echo ========================================
echo STEP 3: Ready for Flutter App
echo ========================================
echo.
echo Backend is running!
echo.
echo NOW DO THIS:
echo 1. Open a NEW Command Prompt window
echo 2. Run: cd d:\Programming\bareeq-alysr-whole
echo 3. Run: flutter run
echo.
echo OR simply double-click: start-flutter.bat
echo.
echo Keep this window open - it's running the backend!
echo Press Ctrl+C to stop the backend when done.
echo.
pause
