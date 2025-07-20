# Script pour tester la compilation du backend avec le nouveau PatientDTO
Write-Host "🔍 Test de compilation du backend..." -ForegroundColor Cyan

# Vérifier que nous sommes dans le bon répertoire
Write-Host "`n📁 Vérification du répertoire..." -ForegroundColor Blue
if (Test-Path "backend/pom.xml") {
    Write-Host "✅ Fichier pom.xml trouvé" -ForegroundColor Green
} else {
    Write-Host "❌ Fichier pom.xml non trouvé. Assurez-vous d'être dans le répertoire racine du projet." -ForegroundColor Red
    exit 1
}

# Nettoyer et compiler le projet
Write-Host "`n🧹 Nettoyage du projet..." -ForegroundColor Yellow
Set-Location "backend"
try {
    mvn clean
    Write-Host "✅ Nettoyage réussi" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors du nettoyage: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "`n🔨 Compilation du projet..." -ForegroundColor Yellow
try {
    mvn compile
    Write-Host "✅ Compilation réussie" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur de compilation: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n🔍 Vérification des fichiers créés:" -ForegroundColor Blue
    Write-Host "  - DashboardController.java: $(Test-Path 'src/main/java/com/nfc4care/controller/DashboardController.java')" -ForegroundColor Gray
    Write-Host "  - DashboardService.java: $(Test-Path 'src/main/java/com/nfc4care/service/DashboardService.java')" -ForegroundColor Gray
    Write-Host "  - DashboardStatsDTO.java: $(Test-Path 'src/main/java/com/nfc4care/dto/DashboardStatsDTO.java')" -ForegroundColor Gray
    Write-Host "  - PatientDTO.java: $(Test-Path 'src/main/java/com/nfc4care/dto/PatientDTO.java')" -ForegroundColor Gray
    exit 1
}

# Vérifier que tous les fichiers nécessaires existent
Write-Host "`n📋 Vérification des fichiers créés..." -ForegroundColor Blue
$files = @(
    "src/main/java/com/nfc4care/controller/DashboardController.java",
    "src/main/java/com/nfc4care/service/DashboardService.java",
    "src/main/java/com/nfc4care/dto/DashboardStatsDTO.java",
    "src/main/java/com/nfc4care/dto/PatientDTO.java"
)

foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file manquant" -ForegroundColor Red
    }
}

Write-Host "`n🚀 Démarrage du backend..." -ForegroundColor Green
try {
    Start-Process -FilePath "mvn" -ArgumentList "spring-boot:run" -NoNewWindow
    Write-Host "✅ Backend démarré" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors du démarrage: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n⏳ Attente du démarrage..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Test des endpoints
Write-Host "`n🔍 Test des endpoints dashboard..." -ForegroundColor Blue

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/dashboard/stats" -Method GET -TimeoutSec 10
    Write-Host "✅ Endpoint /api/dashboard/stats accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur sur /api/dashboard/stats: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/dashboard/recent-patients" -Method GET -TimeoutSec 10
    Write-Host "✅ Endpoint /api/dashboard/recent-patients accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur sur /api/dashboard/recent-patients: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n✅ Test de compilation terminé!" -ForegroundColor Green 