@echo off
title NFC4Care - Medical Management System
echo ========================================
echo    NFC4Care - Medical Management System
echo ========================================
echo.

REM Check if we're in the right directory
if not exist "docker-compose.yml" (
    echo Error: docker-compose.yml not found
    echo Please run this script from the project root directory
    pause
    exit /b 1
)

echo Starting NFC4Care complete system...
echo.

REM Step 1: Start Database
echo [1/4] Starting PostgreSQL database...
call start-database.bat
if %errorlevel% neq 0 (
    echo Failed to start database
    pause
    exit /b 1
)

REM Step 2: Start Backend
echo.
echo [2/4] Starting Spring Boot backend...
start "NFC4Care Backend" cmd /k "call start-backend.bat"

REM Wait for backend to start
echo Waiting for backend to start...
timeout /t 30 /nobreak >nul

REM Step 3: Start Frontend
echo.
echo [3/4] Starting React frontend...
start "NFC4Care Frontend" cmd /k "call start-frontend.bat"

REM Step 4: Open browser
echo.
echo [4/4] Opening application in browser...
timeout /t 10 /nobreak >nul
start http://localhost:5173

echo.
echo ========================================
echo    NFC4Care is starting up!
echo ========================================
echo.
echo Frontend: http://localhost:5173
echo Backend:  http://localhost:8080
echo Database: localhost:5432
echo.
echo Default login credentials:
echo Email:    doctor@example.com
echo Password: password
echo.
echo Press any key to exit this launcher...
pause >nul 