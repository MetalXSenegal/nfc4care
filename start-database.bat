@echo off
echo Starting NFC4Care Database...
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Docker is not installed or not in PATH
    echo Please install Docker Desktop from https://www.docker.com/products/docker-desktop/
    pause
    exit /b 1
)

REM Check if Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Docker is not running
    echo Please start Docker Desktop
    pause
    exit /b 1
)

REM Check if we're in the right directory
if not exist "docker-compose.yml" (
    echo Error: docker-compose.yml not found
    echo Please run this script from the project root directory
    pause
    exit /b 1
)

REM Stop any existing containers
echo Stopping existing containers...
docker-compose down

REM Start the database
echo Starting PostgreSQL database...
echo Database will be available at: localhost:5432
echo Username: nfc4care
echo Password: nfc4care
echo Database: nfc4care
echo.

docker-compose up -d postgres

if %errorlevel% neq 0 (
    echo Error: Failed to start database
    pause
    exit /b 1
)

REM Wait for database to be ready
echo Waiting for database to be ready...
timeout /t 10 /nobreak >nul

REM Check if database is running
docker-compose ps postgres | findstr "Up" >nul
if %errorlevel% neq 0 (
    echo Error: Database failed to start properly
    echo Checking logs...
    docker-compose logs postgres
    pause
    exit /b 1
)

echo.
echo Database started successfully!
echo.
echo To stop the database, run: docker-compose down
echo To view logs, run: docker-compose logs postgres
echo.

pause 