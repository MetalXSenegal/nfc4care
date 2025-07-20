# Script PowerShell pour tester le stockage du token avant dashboard
Write-Host "🔧 Test du stockage du token avant accès au dashboard..." -ForegroundColor Green

# Arrêter le frontend s'il tourne
Write-Host "🛑 Arrêt du frontend en cours..." -ForegroundColor Yellow
try {
    $nodeProcess = Get-NetTCPConnection -LocalPort 5173 -ErrorAction SilentlyContinue | 
                   Where-Object { $_.State -eq "Listen" } | 
                   ForEach-Object { Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue } |
                   Where-Object { $_.ProcessName -eq "node" }
    
    if ($nodeProcess) {
        Write-Host "✅ Processus Node.js trouvé, arrêt en cours..." -ForegroundColor Green
        Stop-Process -Id $nodeProcess.Id -Force
        Start-Sleep -Seconds 3
        Write-Host "✅ Frontend arrêté" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Aucun processus frontend trouvé" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Erreur lors de l'arrêt du frontend: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Aller dans le répertoire frontend
if (Test-Path "frontend") {
    Set-Location "frontend"
    Write-Host "📁 Répertoire frontend trouvé" -ForegroundColor Green
} else {
    Write-Host "❌ Répertoire frontend non trouvé" -ForegroundColor Red
    exit 1
}

# Vérifier si Node.js est installé
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js détecté: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js n'est pas installé" -ForegroundColor Red
    exit 1
}

# Vérifier si npm est installé
try {
    $npmVersion = npm --version
    Write-Host "✅ npm détecté: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ npm n'est pas installé" -ForegroundColor Red
    exit 1
}

# Installer les dépendances si nécessaire
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installation des dépendances..." -ForegroundColor Yellow
    try {
        npm install
        Write-Host "✅ Dépendances installées avec succès" -ForegroundColor Green
    } catch {
        Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Dépendances déjà installées" -ForegroundColor Green
}

# Vérifier que les corrections ont été appliquées
Write-Host "🔍 Vérification des corrections..." -ForegroundColor Yellow

$correctedFiles = @(
    "src/context/AuthContext.tsx",
    "src/pages/Login.tsx"
)

foreach ($file in $correctedFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($file -eq "src/pages/Login.tsx" -and $content -match "Vérification du stockage avant redirection") {
            Write-Host "✅ $file - Vérification avant redirection ajoutée" -ForegroundColor Green
        } elseif ($file -eq "src/context/AuthContext.tsx" -and $content -match "Vérification finale réussie") {
            Write-Host "✅ $file - Vérification finale ajoutée" -ForegroundColor Green
        } else {
            Write-Host "⚠️  $file - Corrections à vérifier" -ForegroundColor Yellow
        }
    } else {
        Write-Host "❌ $file manquant" -ForegroundColor Red
    }
}

# Démarrer le serveur de développement
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Corrections appliquées:" -ForegroundColor Cyan
Write-Host "   - Vérification du stockage avant redirection vers dashboard" -ForegroundColor Cyan
Write-Host "   - Vérification finale dans AuthContext" -ForegroundColor Cyan
Write-Host "   - Logs détaillés pour le debugging" -ForegroundColor Cyan
Write-Host "   - Gestion d'erreur si stockage échoue" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Instructions de test:" -ForegroundColor Green
Write-Host "   1. Ouvrez http://localhost:5173 dans votre navigateur" -ForegroundColor White
Write-Host "   2. Ouvrez la console du navigateur (F12)" -ForegroundColor White
Write-Host "   3. Connectez-vous avec vos identifiants" -ForegroundColor White
Write-Host "   4. Surveillez les logs de vérification" -ForegroundColor White
Write-Host "   5. Vérifiez que vous arrivez sur le dashboard" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Logs à surveiller:" -ForegroundColor Yellow
Write-Host "   - '🔐 Début de la tentative de connexion...'" -ForegroundColor Gray
Write-Host "   - '📋 Résultat de la connexion: ...'" -ForegroundColor Gray
Write-Host "   - '🔍 Vérification du stockage avant redirection:'" -ForegroundColor Gray
Write-Host "   - '✅ Token et données stockés, redirection vers le dashboard'" -ForegroundColor Gray
Write-Host "   - '✅ Vérification finale réussie - Session complètement établie'" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Commandes de debugging dans la console:" -ForegroundColor Cyan
Write-Host "   // Vérifier le localStorage après connexion" -ForegroundColor Gray
Write-Host "   console.log('Token:', localStorage.getItem('authToken'));" -ForegroundColor Gray
Write-Host "   console.log('Données:', localStorage.getItem('doctorData'));" -ForegroundColor Gray
Write-Host ""
Write-Host "   // Vérifier l'URL actuelle" -ForegroundColor Gray
Write-Host "   console.log('URL actuelle:', window.location.pathname);" -ForegroundColor Gray
Write-Host ""
Write-Host "📱 Frontend accessible sur: http://localhost:5173" -ForegroundColor Green
Write-Host "🔄 Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Gray

try {
    npm run dev
} catch {
    Write-Host "❌ Erreur lors du démarrage du serveur de développement" -ForegroundColor Red
    exit 1
} 