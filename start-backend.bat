@echo off
echo Starting NFC4Care Backend...
echo.

REM Check if Java is installed
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Java is not installed or not in PATH
    echo Please install Java 17 or later
    pause
    exit /b 1
)

REM Check if Maven is installed
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Maven is not installed or not in PATH
    echo Please install Maven from https://maven.apache.org/
    pause
    exit /b 1
)

REM Check if we're in the right directory
if not exist "backend\pom.xml" (
    echo Error: pom.xml not found in backend directory
    echo Please run this script from the project root directory
    pause
    exit /b 1
)

REM Navigate to backend directory
cd backend

REM Check if Docker is running (for PostgreSQL)
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Warning: Docker is not running
    echo Please start Docker Desktop and ensure PostgreSQL container is running
    echo.
)

REM Start the Spring Boot application
echo Starting Spring Boot application...
echo Backend will be available at: http://localhost:8080
echo API documentation at: http://localhost:8080/swagger-ui.html
echo.

REM Clean and compile
echo Compiling application...
mvn clean compile
if %errorlevel% neq 0 (
    echo Error: Compilation failed
    pause
    exit /b 1
)

REM Start the application
echo Starting application...
mvn spring-boot:run

pause 