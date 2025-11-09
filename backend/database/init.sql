-- Script d'initialisation de la base de données NFC4Care pour PostgreSQL (version Sénégal)

-- Table des professionnels de santé
CREATE TABLE IF NOT EXISTS professionnels (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    specialite VARCHAR(100) NOT NULL,
    numero_rpps VARCHAR(20) NOT NULL UNIQUE,
    role VARCHAR(20) NOT NULL DEFAULT 'MEDECIN',
    date_creation TIMESTAMP NOT NULL,
    derniere_connexion TIMESTAMP,
    actif BOOLEAN NOT NULL DEFAULT TRUE,
    two_fa_secret VARCHAR(255),
    two_fa_enabled BOOLEAN NOT NULL DEFAULT FALSE
);
CREATE INDEX IF NOT EXISTS idx_email ON professionnels(email);
CREATE INDEX IF NOT EXISTS idx_rpps ON professionnels(numero_rpps);

-- Table des patients
CREATE TABLE IF NOT EXISTS patients (
    id SERIAL PRIMARY KEY,
    numero_dossier VARCHAR(50) NOT NULL UNIQUE,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    date_naissance DATE NOT NULL,
    sexe VARCHAR(1) NOT NULL,
    adresse TEXT NOT NULL,
    telephone VARCHAR(20) NOT NULL,
    email VARCHAR(255),
    numero_securite_sociale VARCHAR(15) NOT NULL UNIQUE,
    groupe_sanguin VARCHAR(5),
    numero_nfc VARCHAR(100) UNIQUE,
    date_creation TIMESTAMP NOT NULL,
    derniere_consultation TIMESTAMP,
    actif BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX IF NOT EXISTS idx_numero_dossier ON patients(numero_dossier);
CREATE INDEX IF NOT EXISTS idx_nss ON patients(numero_securite_sociale);
CREATE INDEX IF NOT EXISTS idx_nfc ON patients(numero_nfc);
CREATE INDEX IF NOT EXISTS idx_nom_prenom ON patients(nom, prenom);

-- Table des dossiers médicaux
CREATE TABLE IF NOT EXISTS dossiers_medicaux (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL UNIQUE,
    antecedents_medicaux TEXT,
    antecedents_chirurgicaux TEXT,
    antecedents_familiaux TEXT,
    traitements_en_cours TEXT,
    allergies TEXT,
    observations_generales TEXT,
    hash_contenu VARCHAR(64) NOT NULL,
    blockchain_txn_hash VARCHAR(255),
    date_creation TIMESTAMP NOT NULL,
    date_modification TIMESTAMP NOT NULL,
    professionnel_creation_id INTEGER NOT NULL,
    professionnel_modification_id INTEGER,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (professionnel_creation_id) REFERENCES professionnels(id),
    FOREIGN KEY (professionnel_modification_id) REFERENCES professionnels(id)
);
CREATE INDEX IF NOT EXISTS idx_patient_id ON dossiers_medicaux(patient_id);
CREATE INDEX IF NOT EXISTS idx_blockchain_hash ON dossiers_medicaux(blockchain_txn_hash);

-- Table des consultations
CREATE TABLE IF NOT EXISTS consultations (
    id SERIAL PRIMARY KEY,
    dossier_medical_id INTEGER NOT NULL,
    professionnel_id INTEGER NOT NULL,
    date_consultation TIMESTAMP NOT NULL,
    motif_consultation TEXT NOT NULL,
    examen_clinique TEXT,
    diagnostic TEXT,
    traitement_prescrit TEXT,
    ordonnance TEXT,
    observations TEXT,
    prochain_rdv TIMESTAMP,
    hash_contenu VARCHAR(64) NOT NULL,
    blockchain_txn_hash VARCHAR(255),
    date_creation TIMESTAMP NOT NULL,
    date_modification TIMESTAMP NOT NULL,
    FOREIGN KEY (dossier_medical_id) REFERENCES dossiers_medicaux(id) ON DELETE CASCADE,
    FOREIGN KEY (professionnel_id) REFERENCES professionnels(id)
);
CREATE INDEX IF NOT EXISTS idx_dossier_medical_id ON consultations(dossier_medical_id);
CREATE INDEX IF NOT EXISTS idx_professionnel_id ON consultations(professionnel_id);
CREATE INDEX IF NOT EXISTS idx_date_consultation ON consultations(date_consultation);
CREATE INDEX IF NOT EXISTS idx_blockchain_hash ON consultations(blockchain_txn_hash);

-- Insertion de professionnels de santé sénégalais
INSERT INTO professionnels (
    email, password, nom, prenom, specialite, numero_rpps, role, date_creation, derniere_connexion, actif
) VALUES 
('mbaye.bocar@hopital.sn', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Mbaye', 'Bocar', 'Médecine générale', 'SN1000001', 'MEDECIN', NOW() - INTERVAL '2 years', NOW() - INTERVAL '1 hour', TRUE),
('ndiaye.aminata@hopital.sn', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ndiaye', 'Aminata', 'Pédiatrie', 'SN1000002', 'MEDECIN', NOW() - INTERVAL '1 year', NOW() - INTERVAL '30 minutes', TRUE),
('diop.moussa@hopital.sn', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Diop', 'Moussa', 'Cardiologie', 'SN1000003', 'MEDECIN', NOW() - INTERVAL '6 months', NOW() - INTERVAL '2 hours', TRUE),
('fall.fatou@hopital.sn', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Fall', 'Fatou', 'Gynécologie', 'SN1000004', 'MEDECIN', NOW() - INTERVAL '3 months', NOW() - INTERVAL '15 minutes', TRUE),
('sow.abdoulaye@hopital.sn', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Sow', 'Abdoulaye', 'Dermatologie', 'SN1000005', 'MEDECIN', NOW() - INTERVAL '1 year', NOW() - INTERVAL '1 day', TRUE),
('ba.mariama@hopital.sn', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Ba', 'Mariama', 'Infirmier', 'SN1000006', 'INFIRMIER', NOW() - INTERVAL '8 months', NOW() - INTERVAL '2 hours', TRUE),
('faye.cheikh@hopital.sn', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Faye', 'Cheikh', 'Médecine interne', 'SN1000007', 'MEDECIN', NOW() - INTERVAL '2 years', NOW() - INTERVAL '3 hours', TRUE),
('gueye.astou@hopital.sn', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Gueye', 'Astou', 'Infirmier', 'SN1000008', 'INFIRMIER', NOW() - INTERVAL '1 year', NOW() - INTERVAL '4 hours', TRUE)
ON CONFLICT (email) DO NOTHING;

-- Insertion de patients sénégalais
INSERT INTO patients (
    numero_dossier, nom, prenom, date_naissance, sexe, adresse, telephone, email, numero_securite_sociale, groupe_sanguin, numero_nfc, date_creation, derniere_consultation, actif
) VALUES 
('SN-2024-001', 'Sarr', 'Awa', '1990-04-12', 'F', 'Dakar, Médina', '771234567', 'awa.sarr@email.sn', 'SN9000001', 'A+', 'nfc-001-awa', NOW() - INTERVAL '1 year', NOW() - INTERVAL '2 days', TRUE),
('SN-2024-002', 'Sy', 'Mamadou', '1982-09-23', 'M', 'Thiès, Grand Standing', '772345678', 'mamadou.sy@email.sn', 'SN9000002', 'O+', 'nfc-002-mamadou', NOW() - INTERVAL '1 year', NOW() - INTERVAL '1 week', TRUE),
('SN-2024-003', 'Diouf', 'Fatoumata', '1995-06-30', 'F', 'Saint-Louis, Sor', '773456789', 'fatoumata.diouf@email.sn', 'SN9000003', 'B+', 'nfc-003-fatoumata', NOW() - INTERVAL '1 year', NOW() - INTERVAL '3 days', TRUE),
('SN-2024-004', 'Ndoye', 'Ibrahima', '1978-12-15', 'M', 'Kaolack, Kasnak', '774567890', 'ibrahima.ndoye@email.sn', 'SN9000004', 'AB+', 'nfc-004-ibrahima', NOW() - INTERVAL '1 year', NOW() - INTERVAL '5 days', TRUE),
('SN-2024-005', 'Kane', 'Aminata', '1987-03-08', 'F', 'Ziguinchor, Lyndiane', '775678901', 'aminata.kane@email.sn', 'SN9000005', 'A-', 'nfc-005-aminata', NOW() - INTERVAL '8 months', NOW() - INTERVAL '1 day', TRUE),
('SN-2024-006', 'Camara', 'Cheikh', '1975-11-19', 'M', 'Touba, Darou Khoudoss', '776789012', 'cheikh.camara@email.sn', 'SN9000006', 'O-', 'nfc-006-cheikh', NOW() - INTERVAL '6 months', NOW() - INTERVAL '4 days', TRUE),
('SN-2024-007', 'Diallo', 'Mariama', '1992-02-27', 'F', 'Rufisque, Tivaouane Peulh', '777890123', 'mariama.diallo@email.sn', 'SN9000007', 'B-', 'nfc-007-mariama', NOW() - INTERVAL '4 months', NOW() - INTERVAL '6 hours', TRUE),
('SN-2024-008', 'Cissé', 'Abdou', '1965-08-10', 'M', 'Mbour, Saly', '778901234', 'abdou.cisse@email.sn', 'SN9000008', 'AB-', 'nfc-008-abdou', NOW() - INTERVAL '3 months', NOW() - INTERVAL '12 hours', TRUE),
('SN-2024-009', 'Faye', 'Khady', '1984-05-21', 'F', 'Louga, Ndiagne', '779012345', 'khady.faye@email.sn', 'SN9000009', 'A+', 'nfc-009-khady', NOW() - INTERVAL '2 months', NOW() - INTERVAL '1 day', TRUE),
('SN-2024-010', 'Gueye', 'Moussa', '1979-01-05', 'M', 'Fatick, Ndoulo', '770123456', 'moussa.gueye@email.sn', 'SN9000010', 'O+', 'nfc-010-moussa', NOW() - INTERVAL '1 month', NOW() - INTERVAL '2 days', TRUE),
('SN-2024-011', 'Ba', 'Astou', '1993-07-14', 'F', 'Dakar, Parcelles Assainies', '771112233', 'astou.ba@email.sn', 'SN9000011', 'B+', 'nfc-011-astou', NOW() - INTERVAL '2 months', NOW() - INTERVAL '3 days', TRUE),
('SN-2024-012', 'Sow', 'Ousmane', '1980-10-28', 'M', 'Saint-Louis, Pikine', '772223344', 'ousmane.sow@email.sn', 'SN9000012', 'AB+', 'nfc-012-ousmane', NOW() - INTERVAL '3 months', NOW() - INTERVAL '4 days', TRUE),
('SN-2024-013', 'Fall', 'Aissatou', '1989-12-01', 'F', 'Kaolack, Léona', '773334455', 'aissatou.fall@email.sn', 'SN9000013', 'A-', 'nfc-013-aissatou', NOW() - INTERVAL '4 months', NOW() - INTERVAL '5 days', TRUE),
('SN-2024-014', 'Seck', 'Mamadou', '1976-06-18', 'M', 'Ziguinchor, Tilène', '774445566', 'mamadou.seck@email.sn', 'SN9000014', 'O-', 'nfc-014-mamadou', NOW() - INTERVAL '5 months', NOW() - INTERVAL '6 days', TRUE),
('SN-2024-015', 'Diagne', 'Fatou', '1991-09-09', 'F', 'Dakar, Grand Yoff', '775556677', 'fatou.diagne@email.sn', 'SN9000015', 'B-', 'nfc-015-fatou', NOW() - INTERVAL '6 months', NOW() - INTERVAL '7 days', TRUE)
ON CONFLICT (numero_dossier) DO NOTHING;

-- Insertion de dossiers médicaux pour chaque patient
INSERT INTO dossiers_medicaux (
    patient_id, antecedents_medicaux, antecedents_chirurgicaux, antecedents_familiaux, traitements_en_cours, allergies, observations_generales, hash_contenu, date_creation, date_modification, professionnel_creation_id
) VALUES 
(1, 'Drépanocytose, Paludisme à répétition', 'Appendicectomie (2012)', 'Hypertension (mère), Diabète (père)', 'Paracétamol 500mg si douleur', 'Arachides (Sévère)', 'Bonne évolution, suivi régulier', 'hash_001_awa_sarr', NOW() - INTERVAL '1 year', NOW() - INTERVAL '2 days', 1),
(2, 'Asthme, Allergies respiratoires', 'Aucun', 'Asthme (père)', 'Ventoline si crise', 'Aucune', 'Asthme bien contrôlé', 'hash_002_mamadou_sy', NOW() - INTERVAL '1 year', NOW() - INTERVAL '1 week', 2),
(3, 'Anémie, Paludisme', 'Aucun', 'Anémie (mère)', 'Fer 80mg/j', 'Fruits de mer (Modérée)', 'Suivi nutritionnel conseillé', 'hash_003_fatoumata_diouf', NOW() - INTERVAL '1 year', NOW() - INTERVAL '3 days', 3),
(4, 'Hypertension artérielle', 'Cholécystectomie (2015)', 'Hypertension (père)', 'Amlodipine 5mg/j', 'Aucune', 'Surveillance tensionnelle', 'hash_004_ibrahima_ndoye', NOW() - INTERVAL '1 year', NOW() - INTERVAL '5 days', 4),
(5, 'Diabète type 2', 'Aucun', 'Diabète (mère)', 'Metformine 1000mg 2x/j', 'Aucune', 'Équilibre glycémique correct', 'hash_005_aminata_kane', NOW() - INTERVAL '8 months', NOW() - INTERVAL '1 day', 5),
(6, 'Rhumatisme articulaire aigu', 'Prothèse hanche (2018)', 'Rhumatisme (père)', 'Ibuprofène 400mg si douleur', 'Aucune', 'Mobilité réduite, kinésithérapie', 'hash_006_cheikh_camara', NOW() - INTERVAL '6 months', NOW() - INTERVAL '4 days', 6),
(7, 'Migraine chronique', 'Aucun', 'Migraine (mère)', 'Paracétamol 1g si crise', 'Aucune', 'Suivi neurologique', 'hash_007_mariama_diallo', NOW() - INTERVAL '4 months', NOW() - INTERVAL '6 hours', 7),
(8, 'Insuffisance cardiaque', 'Pose de pacemaker (2020)', 'Cardiopathie (père)', 'Furosémide 40mg/j', 'Aucune', 'Surveillance cardiaque', 'hash_008_abdou_cisse', NOW() - INTERVAL '3 months', NOW() - INTERVAL '12 hours', 1),
(9, 'Hypothyroïdie', 'Thyroïdectomie partielle (2017)', 'Hypothyroïdie (mère)', 'Lévothyroxine 75µg/j', 'Aucune', 'TSH normalisée', 'hash_009_khady_faye', NOW() - INTERVAL '2 months', NOW() - INTERVAL '1 day', 2),
(10, 'Ulcère gastrique', 'Aucun', 'Ulcère (père)', 'Oméprazole 20mg/j', 'Aucune', 'Symptômes bien contrôlés', 'hash_010_moussa_gueye', NOW() - INTERVAL '1 month', NOW() - INTERVAL '2 days', 3),
(11, 'Drépanocytose', 'Aucun', 'Drépanocytose (père)', 'Hydroxyurée 500mg/j', 'Aucune', 'Surveillance hématologique', 'hash_011_astou_ba', NOW() - INTERVAL '2 months', NOW() - INTERVAL '3 days', 4),
(12, 'Tuberculose traitée', 'Aucun', 'Tuberculose (mère)', 'Rifampicine 600mg/j', 'Aucune', 'Suivi post-traitement', 'hash_012_ousmane_sow', NOW() - INTERVAL '3 months', NOW() - INTERVAL '4 days', 5),
(13, 'Asthme', 'Aucun', 'Asthme (père)', 'Ventoline si crise', 'Aucune', 'Asthme bien contrôlé', 'hash_013_aissatou_fall', NOW() - INTERVAL '4 months', NOW() - INTERVAL '5 days', 6),
(14, 'Diabète type 1', 'Aucun', 'Diabète (mère)', 'Insuline 20U/j', 'Aucune', 'Équilibre glycémique', 'hash_014_mamadou_seck', NOW() - INTERVAL '5 months', NOW() - INTERVAL '6 days', 7),
(15, 'Hypertension artérielle', 'Aucun', 'Hypertension (père)', 'Amlodipine 5mg/j', 'Aucune', 'Surveillance tensionnelle', 'hash_015_fatou_diagne', NOW() - INTERVAL '6 months', NOW() - INTERVAL '7 days', 8)
ON CONFLICT (patient_id) DO NOTHING;

-- Insertion de consultations (2 par patient, motifs adaptés)
INSERT INTO consultations (
    dossier_medical_id, professionnel_id, date_consultation, motif_consultation, examen_clinique, diagnostic, traitement_prescrit, ordonnance, observations, prochain_rdv, hash_contenu, date_creation, date_modification
) VALUES 
-- Patient 1
(1, 1, NOW() - INTERVAL '2 months', 'Fièvre et douleurs articulaires', 'Température 38.5°C, douleurs diffuses', 'Paludisme', 'Artemether-Lumefantrine', 'Artemether-Lumefantrine 1cp matin/soir 3j', 'Amélioration après traitement', NOW() + INTERVAL '1 month', 'hash_consult_001_awa_1', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
(1, 2, NOW() - INTERVAL '1 month', 'Douleurs abdominales', 'Douleur FID, défense abdominale', 'Appendicite', 'Chirurgie', 'Hospitalisation et chirurgie', 'Appendicectomie réalisée', NOW() + INTERVAL '2 months', 'hash_consult_001_awa_2', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month'),
-- Patient 2
(2, 3, NOW() - INTERVAL '3 months', 'Crise d''asthme', 'Sibilances, dyspnée', 'Asthme aigu', 'Ventoline', 'Ventoline 2 bouffées 4x/j', 'Asthme contrôlé', NOW() + INTERVAL '1 month', 'hash_consult_002_sy_1', NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 months'),
(2, 4, NOW() - INTERVAL '1 month', 'Toux persistante', 'Râles bronchiques', 'Bronchite', 'Amoxicilline', 'Amoxicilline 1g 2x/j 7j', 'Amélioration nette', NOW() + INTERVAL '2 months', 'hash_consult_002_sy_2', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month'),
-- Patient 3
(3, 5, NOW() - INTERVAL '4 months', 'Fatigue et pâleur', 'Conjonctives pâles', 'Anémie', 'Fer', 'Fer 80mg/j 3 mois', 'Correction de l''anémie', NOW() + INTERVAL '1 month', 'hash_consult_003_diouf_1', NOW() - INTERVAL '4 months', NOW() - INTERVAL '4 months'),
(3, 6, NOW() - INTERVAL '2 months', 'Fièvre', 'Température 39°C', 'Paludisme', 'ACT', 'ACT 1cp matin/soir 3j', 'Guérison', NOW() + INTERVAL '2 months', 'hash_consult_003_diouf_2', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
-- Patient 4
(4, 7, NOW() - INTERVAL '5 months', 'Céphalées', 'TA 160/100 mmHg', 'Hypertension', 'Amlodipine', 'Amlodipine 5mg/j', 'TA stabilisée', NOW() + INTERVAL '1 month', 'hash_consult_004_ndoye_1', NOW() - INTERVAL '5 months', NOW() - INTERVAL '5 months'),
(4, 1, NOW() - INTERVAL '2 months', 'Douleurs abdominales', 'Douleur HCD', 'Lithiase vésiculaire', 'Chirurgie', 'Cholécystectomie', 'Chirurgie réalisée', NOW() + INTERVAL '2 months', 'hash_consult_004_ndoye_2', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
-- Patient 5
(5, 2, NOW() - INTERVAL '6 months', 'Polyurie et soif', 'Glycémie à jeun 2.1g/l', 'Diabète type 2', 'Metformine', 'Metformine 1000mg 2x/j', 'Équilibre glycémique', NOW() + INTERVAL '1 month', 'hash_consult_005_kane_1', NOW() - INTERVAL '6 months', NOW() - INTERVAL '6 months'),
(5, 3, NOW() - INTERVAL '2 months', 'Contrôle glycémique', 'Glycémie 1.3g/l', 'Diabète équilibré', 'Régime', 'Régime adapté', 'Bon contrôle', NOW() + INTERVAL '2 months', 'hash_consult_005_kane_2', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
-- Patient 6
(6, 4, NOW() - INTERVAL '7 months', 'Douleurs articulaires', 'Gonflement hanche', 'Rhumatisme', 'Ibuprofène', 'Ibuprofène 400mg 2x/j', 'Amélioration', NOW() + INTERVAL '1 month', 'hash_consult_006_camara_1', NOW() - INTERVAL '7 months', NOW() - INTERVAL '7 months'),
(6, 5, NOW() - INTERVAL '3 months', 'Mobilité réduite', 'Boiterie', 'Prothèse hanche', 'Rééducation', 'Kinésithérapie', 'Mobilité améliorée', NOW() + INTERVAL '2 months', 'hash_consult_006_camara_2', NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 months'),
-- Patient 7
(7, 6, NOW() - INTERVAL '5 months', 'Céphalées fréquentes', 'Examen neuro normal', 'Migraine', 'Paracétamol', 'Paracétamol 1g si crise', 'Crises moins fréquentes', NOW() + INTERVAL '1 month', 'hash_consult_007_diallo_1', NOW() - INTERVAL '5 months', NOW() - INTERVAL '5 months'),
(7, 7, NOW() - INTERVAL '2 months', 'Troubles du sommeil', 'Fatigue', 'Insomnie', 'Conseils hygiène', 'Hygiène de vie', 'Amélioration', NOW() + INTERVAL '2 months', 'hash_consult_007_diallo_2', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
-- Patient 8
(8, 1, NOW() - INTERVAL '8 months', 'Essoufflement', 'Crépitants', 'Insuffisance cardiaque', 'Furosémide', 'Furosémide 40mg/j', 'Amélioration', NOW() + INTERVAL '1 month', 'hash_consult_008_cisse_1', NOW() - INTERVAL '8 months', NOW() - INTERVAL '8 months'),
(8, 2, NOW() - INTERVAL '3 months', 'Palpitations', 'ECG: BAV', 'Trouble du rythme', 'Pacemaker', 'Pose de pacemaker', 'Surveillance', NOW() + INTERVAL '2 months', 'hash_consult_008_cisse_2', NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 months'),
-- Patient 9
(9, 3, NOW() - INTERVAL '4 months', 'Fatigue', 'TSH élevée', 'Hypothyroïdie', 'Lévothyroxine', 'Lévothyroxine 75µg/j', 'TSH normalisée', NOW() + INTERVAL '1 month', 'hash_consult_009_faye_1', NOW() - INTERVAL '4 months', NOW() - INTERVAL '4 months'),
(9, 4, NOW() - INTERVAL '1 month', 'Contrôle thyroïde', 'TSH normale', 'Hypothyroïdie équilibrée', 'Régime', 'Régime adapté', 'Bon contrôle', NOW() + INTERVAL '2 months', 'hash_consult_009_faye_2', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month'),
-- Patient 10
(10, 5, NOW() - INTERVAL '5 months', 'Douleurs épigastriques', 'Douleur à la palpation', 'Ulcère gastrique', 'Oméprazole', 'Oméprazole 20mg/j', 'Amélioration', NOW() + INTERVAL '1 month', 'hash_consult_010_gueye_1', NOW() - INTERVAL '5 months', NOW() - INTERVAL '5 months'),
(10, 6, NOW() - INTERVAL '2 months', 'Reflux', 'Pyrosis', 'RGO', 'Régime', 'Régime adapté', 'Moins de symptômes', NOW() + INTERVAL '2 months', 'hash_consult_010_gueye_2', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
-- Patient 11
(11, 7, NOW() - INTERVAL '3 months', 'Douleurs osseuses', 'Douleur fémur', 'Drépanocytose', 'Hydroxyurée', 'Hydroxyurée 500mg/j', 'Moins de crises', NOW() + INTERVAL '1 month', 'hash_consult_011_ba_1', NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 months'),
(11, 1, NOW() - INTERVAL '1 month', 'Fièvre', 'Température 38°C', 'Infection', 'Amoxicilline', 'Amoxicilline 1g 2x/j 7j', 'Guérison', NOW() + INTERVAL '2 months', 'hash_consult_011_ba_2', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month'),
-- Patient 12
(12, 2, NOW() - INTERVAL '6 months', 'Toux chronique', 'Râles', 'Tuberculose', 'Rifampicine', 'Rifampicine 600mg/j', 'Amélioration', NOW() + INTERVAL '1 month', 'hash_consult_012_sow_1', NOW() - INTERVAL '6 months', NOW() - INTERVAL '6 months'),
(12, 3, NOW() - INTERVAL '2 months', 'Contrôle post-traitement', 'Examen normal', 'Guérison', 'Surveillance', 'Surveillance régulière', 'Pas de rechute', NOW() + INTERVAL '2 months', 'hash_consult_012_sow_2', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
-- Patient 13
(13, 4, NOW() - INTERVAL '5 months', 'Crise d''asthme', 'Sibilances', 'Asthme', 'Ventoline', 'Ventoline 2 bouffées 4x/j', 'Asthme contrôlé', NOW() + INTERVAL '1 month', 'hash_consult_013_fall_1', NOW() - INTERVAL '5 months', NOW() - INTERVAL '5 months'),
(13, 5, NOW() - INTERVAL '2 months', 'Allergie', 'Éruption cutanée', 'Allergie alimentaire', 'Antihistaminique', 'Cétirizine 10mg/j', 'Disparition des symptômes', NOW() + INTERVAL '2 months', 'hash_consult_013_fall_2', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months'),
-- Patient 14
(14, 6, NOW() - INTERVAL '7 months', 'Polyurie', 'Glycémie élevée', 'Diabète type 1', 'Insuline', 'Insuline 20U/j', 'Équilibre glycémique', NOW() + INTERVAL '1 month', 'hash_consult_014_seck_1', NOW() - INTERVAL '7 months', NOW() - INTERVAL '7 months'),
(14, 7, NOW() - INTERVAL '3 months', 'Contrôle glycémique', 'Glycémie normale', 'Diabète équilibré', 'Régime', 'Régime adapté', 'Bon contrôle', NOW() + INTERVAL '2 months', 'hash_consult_014_seck_2', NOW() - INTERVAL '3 months', NOW() - INTERVAL '3 months'),
-- Patient 15
(15, 8, NOW() - INTERVAL '6 months', 'Céphalées', 'TA 150/90 mmHg', 'Hypertension', 'Amlodipine', 'Amlodipine 5mg/j', 'TA stabilisée', NOW() + INTERVAL '1 month', 'hash_consult_015_diagne_1', NOW() - INTERVAL '6 months', NOW() - INTERVAL '6 months'),
(15, 1, NOW() - INTERVAL '2 months', 'Vertiges', 'Examen neuro normal', 'Migraine', 'Paracétamol', 'Paracétamol 1g si crise', 'Crises moins fréquentes', NOW() + INTERVAL '2 months', 'hash_consult_015_diagne_2', NOW() - INTERVAL '2 months', NOW() - INTERVAL '2 months')
ON CONFLICT DO NOTHING; 