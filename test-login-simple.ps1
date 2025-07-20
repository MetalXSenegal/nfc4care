# Test simple de connexion
Write-Host "🔍 Test de connexion simple..." -ForegroundColor Cyan

# Test 1: Vérifier que le backend répond
Write-Host "`n📡 Test 1: Vérification du backend..." -ForegroundColor Blue
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/health" -Method GET -TimeoutSec 5
    Write-Host "✅ Backend accessible" -ForegroundColor Green
} catch {
    Write-Host "❌ Backend non accessible: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Assurez-vous que le backend est démarré" -ForegroundColor Yellow
    exit 1
}

# Test 2: Test de connexion API
Write-Host "`n🔐 Test 2: Test de connexion API..." -ForegroundColor Blue
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
        Write-Host "✅ Connexion API réussie" -ForegroundColor Green
        Write-Host "📋 Token reçu: $($response.data.token.Substring(0, 20))..." -ForegroundColor Cyan
        Write-Host "👤 Utilisateur: $($response.data.prenom) $($response.data.nom)" -ForegroundColor Cyan
        
        # Test 3: Test des endpoints dashboard avec le token
        Write-Host "`n📊 Test 3: Test des endpoints dashboard..." -ForegroundColor Blue
        
        $authHeaders = @{
            "Content-Type" = "application/json"
            "Authorization" = "Bearer $($response.data.token)"
        }
        
        try {
            $statsResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/dashboard/stats" -Method GET -Headers $authHeaders -TimeoutSec 10
            Write-Host "✅ Endpoint /api/dashboard/stats accessible" -ForegroundColor Green
            Write-Host "📋 Réponse: $($statsResponse | ConvertTo-Json)" -ForegroundColor Gray
        } catch {
            Write-Host "❌ Erreur sur /api/dashboard/stats: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        try {
            $patientsResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/dashboard/recent-patients" -Method GET -Headers $authHeaders -TimeoutSec 10
            Write-Host "✅ Endpoint /api/dashboard/recent-patients accessible" -ForegroundColor Green
            Write-Host "📋 Réponse: $($patientsResponse | ConvertTo-Json)" -ForegroundColor Gray
        } catch {
            Write-Host "❌ Erreur sur /api/dashboard/recent-patients: $($_.Exception.Message)" -ForegroundColor Red
        }
        
    } else {
        Write-Host "❌ Connexion API échouée: $($response.error)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors du test API: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📝 Instructions pour le frontend:" -ForegroundColor Magenta
Write-Host "  1. Ouvrir http://localhost:5173"
Write-Host "  2. Ouvrir les outils de développement (F12)"
Write-Host "  3. Aller dans l'onglet Console"
Write-Host "  4. Tenter de se connecter avec doctor@example.com / password"
Write-Host "  5. Observer les logs de connexion"

Write-Host "`n✅ Test terminé!" -ForegroundColor Green 