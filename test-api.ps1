# Script de test pour l'API NFC4Care
Write-Host "🧪 Test de l'API NFC4Care" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""

# Test 1: Vérifier que le backend répond
Write-Host "🔍 Test 1: Vérification du backend..." -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body '{"email":"test","password":"test"}' -ContentType "application/json" -TimeoutSec 10
    Write-Host "✅ Backend répond correctement" -ForegroundColor Green
} catch {
    if ($_.Exception.Message -like "*401*" -or $_.Exception.Message -like "*400*") {
        Write-Host "✅ Backend répond (erreur attendue pour test)" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur backend: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "💡 Assurez-vous que le backend est démarré avec: .\start-backend-docker.ps1" -ForegroundColor Yellow
        exit 1
    }
}

# Test 2: Test de connexion avec les identifiants de test
Write-Host ""
Write-Host "🔍 Test 2: Test de connexion..." -ForegroundColor Yellow
try {
    $loginData = @{
        email = "doctor@example.com"
        password = "password"
    } | ConvertTo-Json

    $response = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginData -ContentType "application/json" -TimeoutSec 10
    
    if ($response.token) {
        Write-Host "✅ Connexion réussie" -ForegroundColor Green
        Write-Host "   Token reçu: $($response.token.Substring(0, 20))..." -ForegroundColor Cyan
        Write-Host "   Utilisateur: $($response.prenom) $($response.nom)" -ForegroundColor Cyan
        
        $token = $response.token
        
        # Test 3: Test d'accès à une route protégée
        Write-Host ""
        Write-Host "🔍 Test 3: Test d'accès à une route protégée..." -ForegroundColor Yellow
        try {
            $headers = @{
                "Authorization" = "Bearer $token"
                "Content-Type" = "application/json"
            }
            
            $dashboardResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/dashboard/stats" -Method GET -Headers $headers -TimeoutSec 10
            Write-Host "✅ Accès au dashboard réussi" -ForegroundColor Green
        } catch {
            Write-Host "❌ Erreur d'accès au dashboard: $($_.Exception.Message)" -ForegroundColor Red
        }
        
    } else {
        Write-Host "❌ Connexion échouée: pas de token reçu" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur de connexion: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "💡 Vérifiez que les identifiants sont corrects" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Tests terminés!" -ForegroundColor Green
Write-Host "Si tous les tests sont verts, l'API fonctionne correctement." -ForegroundColor Cyan 