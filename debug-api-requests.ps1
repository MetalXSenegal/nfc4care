# Script PowerShell pour déboguer les requêtes API
Write-Host "🔧 Debug des requêtes API..." -ForegroundColor Green

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

# Vérifier que les logs de debug sont présents
Write-Host "🔍 Vérification des logs de debug..." -ForegroundColor Yellow

$apiFile = "src/services/api.ts"
if (Test-Path $apiFile) {
    $content = Get-Content $apiFile -Raw
    if ($content -match "TOKEN COMPLET DANS GETAUTHHEADERS") {
        Write-Host "✅ Logs de debug API présents" -ForegroundColor Green
    } else {
        Write-Host "❌ Logs de debug API manquants" -ForegroundColor Red
    }
} else {
    Write-Host "❌ api.ts non trouvé" -ForegroundColor Red
}

# Démarrer le serveur de développement
Write-Host "🚀 Démarrage du serveur de développement..." -ForegroundColor Yellow
Write-Host ""
Write-Host "🔧 Problème identifié:" -ForegroundColor Cyan
Write-Host "   - Le backend authentifie correctement l'utilisateur" -ForegroundColor Cyan
Write-Host "   - Mais les requêtes du dashboard arrivent sans token" -ForegroundColor Cyan
Write-Host "   - Les URLs sont correctes (/api/dashboard/stats)" -ForegroundColor Cyan
Write-Host "   - Le problème semble être dans l'envoi du token" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Instructions de test:" -ForegroundColor Green
Write-Host "   1. Ouvrez http://localhost:5173 dans votre navigateur" -ForegroundColor White
Write-Host "   2. Ouvrez la console du navigateur (F12)" -ForegroundColor White
Write-Host "   3. Connectez-vous avec vos identifiants" -ForegroundColor White
Write-Host "   4. Surveillez les logs de token et requêtes API" -ForegroundColor White
Write-Host "   5. Vérifiez que le token est envoyé dans les requêtes" -ForegroundColor White
Write-Host ""
Write-Host "🔍 Logs à surveiller:" -ForegroundColor Yellow
Write-Host "   - '🔑 TOKEN COMPLET DANS GETAUTHHEADERS: ...'" -ForegroundColor Gray
Write-Host "   - '🔑 Token envoyé dans la requête: Oui/Non'" -ForegroundColor Gray
Write-Host "   - '🌐 Requête API: GET http://localhost:8080/api/dashboard/stats'" -ForegroundColor Gray
Write-Host "   - '📡 Réponse API: 200 OK' (au lieu de 401/403)" -ForegroundColor Gray
Write-Host ""
Write-Host "🔧 Commandes de debugging dans la console:" -ForegroundColor Cyan
Write-Host "   // Vérifier le token dans localStorage" -ForegroundColor Gray
Write-Host "   console.log('Token:', localStorage.getItem('authToken'));" -ForegroundColor Gray
Write-Host ""
Write-Host "   // Tester une requête API manuellement" -ForegroundColor Gray
Write-Host "   fetch('http://localhost:8080/api/dashboard/stats', {" -ForegroundColor Gray
Write-Host "     headers: { 'Authorization': 'Bearer ' + localStorage.getItem('authToken') }" -ForegroundColor Gray
Write-Host "   }).then(r => r.json()).then(data => console.log('API Response:', data));" -ForegroundColor Gray
Write-Host ""
Write-Host "   // Vérifier les erreurs réseau" -ForegroundColor Gray
Write-Host "   console.log('localStorage disponible:', typeof localStorage !== 'undefined');" -ForegroundColor Gray
Write-Host ""
Write-Host "📱 Frontend accessible sur: http://localhost:5173" -ForegroundColor Green
Write-Host "🔄 Appuyez sur Ctrl+C pour arrêter le serveur" -ForegroundColor Gray

try {
    npm run dev
} catch {
    Write-Host "❌ Erreur lors du démarrage du serveur de développement" -ForegroundColor Red
    exit 1
} 