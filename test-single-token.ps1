# Script PowerShell pour tester la logique de token unique
Write-Host "🔧 Test de la logique de token unique..." -ForegroundColor Green

# Arrêter le backend s'il tourne
Write-Host "🛑 Arrêt du backend en cours..." -ForegroundColor Yellow
try {
    $javaProcess = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue | 
                   Where-Object { $_.State -eq "Listen" } | 
                   ForEach-Object { Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue } |
                   Where-Object { $_.ProcessName -eq "java" }
    
    if ($javaProcess) {
        Write-Host "✅ Processus Java trouvé, arrêt en cours..." -ForegroundColor Green
        Stop-Process -Id $javaProcess.Id -Force
        Start-Sleep -Seconds 5
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
    exit 1
}

# Vérifier si Maven est installé
try {
    $mavenVersion = mvn --version
    Write-Host "✅ Maven détecté" -ForegroundColor Green
} catch {
    Write-Host "❌ Maven n'est pas installé" -ForegroundColor Red
    exit 1
}

# Vérifier que les corrections ont été appliquées
Write-Host "🔍 Vérification des corrections..." -ForegroundColor Yellow

$correctedFiles = @(
    "src/main/java/com/nfc4care/service/TokenService.java",
    "src/main/java/com/nfc4care/service/JwtService.java",
    "src/main/java/com/nfc4care/repository/TokenRepository.java"
)

foreach ($file in $correctedFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($file -like "*TokenService.java" -and $content -match "ensureSingleActiveToken") {
            Write-Host "✅ $file - Logique de token unique ajoutée" -ForegroundColor Green
        } elseif ($file -like "*JwtService.java" -and $content -match "Token unique généré") {
            Write-Host "✅ $file - Génération de token unique ajoutée" -ForegroundColor Green
        } elseif ($file -like "*TokenRepository.java" -and $content -match "findUsersWithActiveTokens") {
            Write-Host "✅ $file - Méthode de nettoyage ajoutée" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $file - Corrections à vérifier" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ $file manquant" -ForegroundColor Red
    }
}

# Compiler le projet
Write-Host "🔨 Compilation du projet..." -ForegroundColor Yellow
try {
    mvn clean compile
    Write-Host "✅ Compilation réussie" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur de compilation" -ForegroundColor Red
    exit 1
}

# Démarrer le backend
Write-Host "🚀 Démarrage du backend..." -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Logique de token unique implémentée:" -ForegroundColor Cyan
Write-Host "   - Un seul token actif par utilisateur" -ForegroundColor Cyan
Write-Host "   - Désactivation automatique des anciens tokens" -ForegroundColor Cyan
Write-Host "   - Nettoyage des tokens multiples" -ForegroundColor Cyan
Write-Host "   - Tâches planifiées de maintenance" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Instructions de test:" -ForegroundColor Green
Write-Host "   1. Connectez-vous plusieurs fois avec le même utilisateur" -ForegroundColor White
Write-Host "   2. Vérifiez les logs du backend" -ForegroundColor White
Write-Host "   3. Surveillez les messages de désactivation" -ForegroundColor White
Write-Host "   4. Vérifiez qu'il n'y a qu'un seul token actif" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Logs à surveiller:" -ForegroundColor Yellow
Write-Host "   - 'Désactivation de X tokens actifs existants'" -ForegroundColor Gray
Write-Host "   - 'Nouveau token actif créé'" -ForegroundColor Gray
Write-Host "   - 'Nombre de tokens actifs pour X: 1'" -ForegroundColor Gray
Write-Host "   - 'Token unique généré et sauvegardé'" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Commandes de test dans la base de données:" -ForegroundColor Cyan
Write-Host "   -- Vérifier les tokens actifs" -ForegroundColor Gray
Write-Host "   SELECT user_email, COUNT(*) as active_tokens" -ForegroundColor Gray
Write-Host "   FROM tokens" -ForegroundColor Gray
Write-Host "   WHERE revoked = false AND expired = false AND expires_at > NOW()" -ForegroundColor Gray
Write-Host "   GROUP BY user_email;" -ForegroundColor Gray
Write-Host ""
Write-Host "📱 Backend accessible sur: http://localhost:8080" -ForegroundColor Green
Write-Host "🔄 Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Gray

try {
    mvn spring-boot:run
} catch {
    Write-Host "❌ Erreur lors du démarrage du backend" -ForegroundColor Red
    exit 1
} 