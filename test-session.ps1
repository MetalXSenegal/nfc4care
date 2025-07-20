# Script de test pour la persistance de session NFC4Care
Write-Host "🔐 Test de persistance de session NFC4Care..." -ForegroundColor Green
Write-Host ""

# Test 1: Authentification
Write-Host "Test 1: Authentification..." -ForegroundColor Yellow
try {
    $loginBody = @{
        email = "doctor@example.com"
        password = "password"
    } | ConvertTo-Json

    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method POST -Body $loginBody -ContentType "application/json" -TimeoutSec 10
    
    if ($loginResponse.token) {
        Write-Host "✅ Authentification réussie" -ForegroundColor Green
        $token = $loginResponse.token
        Write-Host "Token obtenu: $($token.Substring(0, 20))..." -ForegroundColor Cyan
        
        # Test 2: Validation du token
        Write-Host ""
        Write-Host "Test 2: Validation du token..." -ForegroundColor Yellow
        
        $headers = @{
            "Authorization" = "Bearer $token"
            "Content-Type" = "application/json"
        }
        
        try {
            $validateResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/validate" -Method GET -Headers $headers -TimeoutSec 10
            Write-Host "✅ Token validé avec succès" -ForegroundColor Green
            Write-Host "Utilisateur: $($validateResponse.prenom) $($validateResponse.nom)" -ForegroundColor Cyan
        } catch {
            Write-Host "❌ Erreur validation token: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Test 3: Accès aux données protégées
        Write-Host ""
        Write-Host "Test 3: Accès aux données protégées..." -ForegroundColor Yellow
        
        try {
            $patientsResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/patients" -Method GET -Headers $headers -TimeoutSec 10
            Write-Host "✅ Accès aux patients réussi" -ForegroundColor Green
            Write-Host "Nombre de patients: $($patientsResponse.Count)" -ForegroundColor Cyan
        } catch {
            Write-Host "❌ Erreur accès patients: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Test 4: Test de persistance (simulation)
        Write-Host ""
        Write-Host "Test 4: Simulation de persistance..." -ForegroundColor Yellow
        Write-Host "Le token devrait persister dans le localStorage du navigateur" -ForegroundColor Cyan
        Write-Host "Pour tester la persistance:" -ForegroundColor Yellow
        Write-Host "1. Connectez-vous sur http://localhost:5173" -ForegroundColor White
        Write-Host "2. Actualisez la page (F5)" -ForegroundColor White
        Write-Host "3. Vous devriez rester connecté" -ForegroundColor White
        
    } else {
        Write-Host "❌ Pas de token dans la réponse" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur d'authentification: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Tests terminés!" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Conseils pour tester la persistance:" -ForegroundColor Cyan
Write-Host "• Ouvrez http://localhost:5173 dans votre navigateur" -ForegroundColor White
Write-Host "• Connectez-vous avec doctor@example.com / password" -ForegroundColor White
Write-Host "• Actualisez la page (F5)" -ForegroundColor White
Write-Host "• Vous devriez rester connecté" -ForegroundColor White
Write-Host "• Vérifiez la console du navigateur pour les logs" -ForegroundColor White

Read-Host "Press Enter to exit" 