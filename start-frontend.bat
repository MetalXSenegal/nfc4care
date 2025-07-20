@echo off
echo Starting NFC4Care Frontend...
echo.

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if we're in the right directory
if not exist "frontend\package.json" (
    echo Error: package.json not found in frontend directory
    echo Please run this script from the project root directory
    pause
    exit /b 1
)

REM Navigate to frontend directory
cd frontend

REM Install dependencies if node_modules doesn't exist
if not exist "node_modules" (
    echo Installing dependencies...
    npm install
    if %errorlevel% neq 0 (
        echo Error: Failed to install dependencies
        pause
        exit /b 1
    )
)

REM Start the development server
echo Starting development server...
echo Frontend will be available at: http://localhost:5173
echo.
npm run dev

pause 