# Test de la Recherche NFC4Care

## 🧪 Tests de la recherche en temps réel

### Prérequis
- Application NFC4Care démarrée
- Base de données avec les 10 patients de test
- Frontend accessible sur http://localhost:5173
- Backend accessible sur http://localhost:8080

### 🔍 Tests de recherche par nom/prénom

#### Test 1: Recherche par prénom
1. Aller sur la page de recherche
2. Taper "Sophie" dans la barre de recherche
3. **Résultat attendu**: Sophie Laurent doit apparaître

#### Test 2: Recherche par nom
1. Taper "Laurent" dans la barre de recherche
2. **Résultat attendu**: Sophie Laurent doit apparaître

#### Test 3: Recherche par nom complet
1. Taper "Sophie Laurent" dans la barre de recherche
2. **Résultat attendu**: Sophie Laurent doit apparaître

#### Test 4: Recherche partielle
1. Taper "Mar" dans la barre de recherche
2. **Résultat attendu**: Marc Dupont et Claire Martin doivent apparaître

### 📞 Tests de recherche par téléphone

#### Test 5: Recherche par téléphone
1. Taper "0123456789" dans la barre de recherche
2. **Résultat attendu**: Sophie Laurent doit apparaître

#### Test 6: Recherche partielle téléphone
1. Taper "012345" dans la barre de recherche
2. **Résultat attendu**: Plusieurs patients doivent apparaître

### 📧 Tests de recherche par email

#### Test 7: Recherche par email
1. Taper "sophie.laurent@email.com" dans la barre de recherche
2. **Résultat attendu**: Sophie Laurent doit apparaître

#### Test 8: Recherche partielle email
1. Taper "sophie" dans la barre de recherche
2. **Résultat attendu**: Sophie Laurent doit apparaître

### 📋 Tests de recherche par numéro de dossier

#### Test 9: Recherche par numéro de dossier
1. Taper "PA-2024-001" dans la barre de recherche
2. **Résultat attendu**: Sophie Laurent doit apparaître

#### Test 10: Recherche partielle numéro de dossier
1. Taper "PA-2024" dans la barre de recherche
2. **Résultat attendu**: Tous les patients doivent apparaître

### ⚡ Tests de performance

#### Test 11: Recherche en temps réel
1. Taper rapidement "S" puis "o" puis "p" puis "h" puis "i" puis "e"
2. **Résultat attendu**: La recherche doit se déclencher automatiquement avec un debounce de 300ms

#### Test 12: Recherche avec filtres
1. Taper "Sophie" dans la barre de recherche
2. Activer le filtre "A+" pour le groupe sanguin
3. **Résultat attendu**: Sophie Laurent doit toujours apparaître (groupe A+)

### 🔧 Tests de cas d'erreur

#### Test 13: Recherche inexistante
1. Taper "PatientInexistant" dans la barre de recherche
2. **Résultat attendu**: Message "Aucun patient trouvé"

#### Test 14: Recherche vide
1. Effacer complètement la barre de recherche
2. **Résultat attendu**: Aucun résultat affiché

### 📊 Données de test disponibles

#### Patients pour les tests :
1. **Sophie Laurent** - PA-2024-001 - 0123456789 - sophie.laurent@email.com - A+
2. **Marc Dupont** - PA-2024-002 - 0123456790 - marc.dupont@email.com - O+
3. **Émilie Moreau** - PA-2024-003 - 0123456791 - emilie.moreau@email.com - B+
4. **Thomas Petit** - PA-2024-004 - 0123456792 - thomas.petit@email.com - AB+
5. **Claire Martin** - PA-2024-005 - 0123456793 - claire.martin@email.com - A-
6. **Pierre Rousseau** - PA-2024-006 - 0123456794 - pierre.rousseau@email.com - O-
7. **Anne Leroy** - PA-2024-007 - 0123456795 - anne.leroy@email.com - B-
8. **Michel Simon** - PA-2024-008 - 0123456796 - michel.simon@email.com - AB-
9. **Isabelle Garcia** - PA-2024-009 - 0123456797 - isabelle.garcia@email.com - A+
10. **François Lefevre** - PA-2024-010 - 0123456798 - francois.lefevre@email.com - O+

### ✅ Critères de succès

- [ ] Recherche en temps réel fonctionne
- [ ] Recherche par nom/prénom fonctionne
- [ ] Recherche par téléphone fonctionne
- [ ] Recherche par email fonctionne
- [ ] Recherche par numéro de dossier fonctionne
- [ ] Debounce de 300ms fonctionne
- [ ] Filtres avancés fonctionnent
- [ ] Interface responsive
- [ ] Messages d'erreur appropriés
- [ ] Historique des recherches fonctionne

### 🐛 Dépannage

#### Problème: La recherche ne fonctionne pas
1. Vérifier que le backend est démarré sur http://localhost:8080
2. Vérifier que la base de données contient les données de test
3. Vérifier les logs du backend pour les erreurs
4. Vérifier la console du navigateur pour les erreurs JavaScript

#### Problème: Recherche lente
1. Vérifier la connexion à la base de données
2. Vérifier les index sur la base de données
3. Vérifier les logs de performance

#### Problème: Résultats incorrects
1. Vérifier que les données de test sont correctement insérées
2. Vérifier la requête SQL dans PatientRepository
3. Vérifier les logs du backend 