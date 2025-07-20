# Script PowerShell pour redémarrer le backend avec les corrections de transaction
Write-Host "🔧 Redémarrage du backend avec corrections de transaction..." -ForegroundColor Green

# Arrêter le backend s'il tourne
Write-Host "🛑 Arrêt du backend en cours..." -ForegroundColor Yellow
try {
    # Chercher le processus Java qui tourne sur le port 8080
    $javaProcess = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | 
                   Where-Object { $_.State -eq "Listen" } | 
                   ForEach-Object { Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue } |
                   Where-Object { $_.ProcessName -eq "java" }
    
    if ($javaProcess) {
        Write-Host "✅ Processus Java trouvé, arrêt en cours..." -ForegroundColor Green
        Stop-Process -Id $javaProcess.Id -Force
        Start-Sleep -Seconds 3
        Write-Host "✅ Backend arrêté" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Aucun processus backend trouvé" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Erreur lors de l'arrêt du backend: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Aller dans le répertoire backend
if (Test-Path "backend") {
    Set-Location "backend"
    Write-Host "📁 Répertoire backend trouvé" -ForegroundColor Green
} else {
    Write-Host "❌ Répertoire backend non trouvé" -ForegroundColor Red
    Write-Host "Assurez-vous d'être dans le répertoire racine du projet" -ForegroundColor Yellow
    exit 1
}

# Vérifier si Maven est installé
try {
    $mvnVersion = mvn --version
    Write-Host "✅ Maven détecté" -ForegroundColor Green
} catch {
    Write-Host "❌ Maven n'est pas installé ou n'est pas dans le PATH" -ForegroundColor Red
    Write-Host "Veuillez installer Maven" -ForegroundColor Yellow
    exit 1
}

# Nettoyer et compiler le projet
Write-Host "🧹 Nettoyage et compilation du projet..." -ForegroundColor Yellow
try {
    mvn clean compile
    Write-Host "✅ Compilation réussie" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur lors de la compilation" -ForegroundColor Red
    exit 1
}

# Démarrer le backend
Write-Host "🚀 Démarrage du backend..." -ForegroundColor Yellow
Write-Host "🔧 Corrections appliquées:" -ForegroundColor Cyan
Write-Host "   - @Transactional ajouté aux méthodes @Modifying" -ForegroundColor Cyan
Write-Host "   - Gestion d'erreurs améliorée dans cleanExpiredTokens" -ForegroundColor Cyan
Write-Host "   - Retour du nombre de lignes affectées" -ForegroundColor Cyan
Write-Host ""
Write-Host "📡 Backend accessible sur: http://localhost:8080/api" -ForegroundColor Green
Write-Host "🔄 Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Gray

try {
    mvn spring-boot:run
} catch {
    Write-Host "❌ Erreur lors du démarrage du backend" -ForegroundColor Red
    Write-Host "Vérifiez les logs pour plus de détails" -ForegroundColor Yellow
    exit 1
} 