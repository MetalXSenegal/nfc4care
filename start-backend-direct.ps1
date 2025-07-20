# Script pour démarrer le backend Spring Boot directement
Write-Host "🚀 Démarrage du backend Spring Boot..." -ForegroundColor Green

# Vérifier que Java est installé
try {
    $javaVersion = java -version 2>&1
    Write-Host "✅ Java détecté" -ForegroundColor Green
} catch {
    Write-Host "❌ Java non trouvé. Veuillez installer Java 17 ou supérieur." -ForegroundColor Red
    exit 1
}

# Aller dans le dossier backend
Set-Location backend

# Vérifier que Maven est installé
try {
    $mavenVersion = mvn -version 2>&1
    Write-Host "✅ Maven détecté" -ForegroundColor Green
} catch {
    Write-Host "❌ Maven non trouvé. Veuillez installer Maven." -ForegroundColor Red
    exit 1
}

# Nettoyer et compiler le projet
Write-Host "🔨 Compilation du projet..." -ForegroundColor Yellow
mvn clean compile

# Démarrer l'application Spring Boot
Write-Host "🚀 Démarrage de l'application..." -ForegroundColor Yellow
Write-Host "Le backend sera accessible sur http://localhost:8080" -ForegroundColor Cyan
Write-Host "Appuyez sur Ctrl+C pour arrêter" -ForegroundColor Yellow

mvn spring-boot:run 