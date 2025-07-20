Write-Host "🔧 Fixing Jackson LocalDate serialization issue..." -ForegroundColor Yellow

# Stop any running backend process
Write-Host "Stopping existing backend processes..." -ForegroundColor Cyan
Get-Process -Name "java" -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -eq "java" } | Stop-Process -Force

# Clean and rebuild
Write-Host "Cleaning and rebuilding backend..." -ForegroundColor Cyan
Set-Location backend
./mvnw clean compile -q

# Start backend
Write-Host "Starting backend with Jackson JSR310 fix..." -ForegroundColor Green
./mvnw spring-boot:run

Write-Host "✅ Backend restarted with Jackson JSR310 module enabled" -ForegroundColor Green
Write-Host "📝 LocalDate serialization should now work properly" -ForegroundColor Green 