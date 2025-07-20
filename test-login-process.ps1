# Script de test du processus de login complet
Write-Host "🔍 Test du processus de login complet..." -ForegroundColor Cyan

Write-Host "`n📋 Étapes de test:" -ForegroundColor Yellow
Write-Host "  1. Vérifier que le backend est démarré"
Write-Host "  2. Tester la connexion API"
Write-Host "  3. Vérifier les identifiants de test"
Write-Host "  4. Tester le login via l'interface"

Write-Host "`n🚀 Démarrage du test..." -ForegroundColor Green

# Vérifier si le backend est démarré
Write-Host "`n🔍 Vérification du backend..." -ForegroundColor Blue
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/health" -Method GET -TimeoutSec 5
    Write-Host "✅ Backend accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend non accessible: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Assurez-vous que le backend est démarré sur le port 8080" -ForegroundColor Yellow
}

# Tester la connexion API avec les identifiants de test
Write-Host "`n🔐 Test de connexion API..." -ForegroundColor Blue
try {
    $loginData = @{
        email = "doctor@example.com"
        password = "password"
    } | ConvertTo-Json

    $headers = @{
        "Content-Type" = "application/json"
    }

    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -Headers $headers -TimeoutSec 10
    
    if ($response.success) {
        Write-Host "✅ Login API réussi" -ForegroundColor Green
        Write-Host "📋 Token reçu: $($response.data.token.Substring(0, 20))..." -ForegroundColor Cyan
        Write-Host "👤 Utilisateur: $($response.data.prenom) $($response.data.nom)" -ForegroundColor Cyan
    } else {
        Write-Host "❌ Login API échoué: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📝 Instructions pour tester le frontend:" -ForegroundColor Magenta
Write-Host "  1. Ouvrir http://localhost:5173 dans le navigateur"
Write-Host "  2. Utiliser les identifiants: doctor@example.com / password"
Write-Host "  3. Vérifier les logs dans la console du navigateur"
Write-Host "  4. Vérifier que le token est stocké dans localStorage"

Write-Host "`n🔧 Commandes utiles:" -ForegroundColor Yellow
Write-Host "  # Démarrer le backend:"
Write-Host "  cd backend && mvn spring-boot:run"
Write-Host ""
Write-Host "  # Démarrer le frontend:"
Write-Host "  cd frontend && npm run dev"
Write-Host ""
Write-Host "  # Vérifier les logs du backend:"
Write-Host "  # Regarder la console où le backend est démarré"

Write-Host "`n✅ Test terminé!" -ForegroundColor Green 