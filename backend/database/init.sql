-- Script d'initialisation de la base de données NFC4Care pour PostgreSQL

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
    actif BOOLEAN NOT NULL DEFAULT TRUE
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

-- Insertion de professionnels de santé
INSERT INTO professionnels (
    email, password, nom, prenom, specialite, numero_rpps, role, date_creation, derniere_connexion, actif
) VALUES 
('doctor@example.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Dubois', 'Martin', 'Médecine générale', '12345678901', 'MEDECIN', NOW() - INTERVAL '2 years', NOW() - INTERVAL '1 hour', TRUE),
('dr.bernard@clinique.fr', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Bernard', 'Marie', 'Cardiologie', '12345678902', 'MEDECIN', NOW() - INTERVAL '1 year', NOW() - INTERVAL '30 minutes', TRUE),
('dr.petit@clinique.fr', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Petit', 'Jean', 'Dermatologie', '12345678903', 'MEDECIN', NOW() - INTERVAL '6 months', NOW() - INTERVAL '2 hours', TRUE),
('infirmier.dupont@clinique.fr', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'Dupont', 'Sophie', 'Infirmier', '12345678904', 'INFIRMIER', NOW() - INTERVAL '3 months', NOW() - INTERVAL '15 minutes', TRUE)
ON CONFLICT (email) DO NOTHING;

-- Insertion de patients avec données réalistes
INSERT INTO patients (
    numero_dossier, nom, prenom, date_naissance, sexe, adresse, telephone, email, numero_securite_sociale, groupe_sanguin, numero_nfc, date_creation, derniere_consultation, actif
) VALUES 
('PA-2024-001', 'Laurent', 'Sophie', '1981-03-15', 'F', '123 Rue de la Paix, 75001 Paris', '0123456789', 'sophie.laurent@email.com', '123456789012345', 'A+', 'nfc-001-sophie', NOW() - INTERVAL '1 year', NOW() - INTERVAL '2 days', TRUE),
('PA-2024-002', 'Dupont', 'Marc', '1956-07-22', 'M', '456 Avenue des Champs, 75008 Paris', '0123456790', 'marc.dupont@email.com', '123456789012346', 'O+', 'nfc-002-marc', NOW() - INTERVAL '1 year', NOW() - INTERVAL '1 week', TRUE),
('PA-2024-003', 'Moreau', 'Émilie', '1994-11-08', 'F', '789 Boulevard Saint-Germain, 75006 Paris', '0123456791', 'emilie.moreau@email.com', '123456789012347', 'B+', 'nfc-003-emilie', NOW() - INTERVAL '1 year', NOW() - INTERVAL '3 days', TRUE),
('PA-2024-004', 'Petit', 'Thomas', '1969-05-12', 'M', '321 Rue de Rivoli, 75001 Paris', '0123456792', 'thomas.petit@email.com', '123456789012348', 'AB+', 'nfc-004-thomas', NOW() - INTERVAL '1 year', NOW() - INTERVAL '5 days', TRUE),
('PA-2024-005', 'Martin', 'Claire', '1988-12-03', 'F', '654 Rue du Commerce, 75015 Paris', '0123456793', 'claire.martin@email.com', '123456789012349', 'A-', 'nfc-005-claire', NOW() - INTERVAL '8 months', NOW() - INTERVAL '1 day', TRUE),
('PA-2024-006', 'Rousseau', 'Pierre', '1975-09-18', 'M', '987 Avenue de la République, 75011 Paris', '0123456794', 'pierre.rousseau@email.com', '123456789012350', 'O-', 'nfc-006-pierre', NOW() - INTERVAL '6 months', NOW() - INTERVAL '4 days', TRUE),
('PA-2024-007', 'Leroy', 'Anne', '1991-04-25', 'F', '147 Rue de la Pompe, 75016 Paris', '0123456795', 'anne.leroy@email.com', '123456789012351', 'B-', 'nfc-007-anne', NOW() - INTERVAL '4 months', NOW() - INTERVAL '6 hours', TRUE),
('PA-2024-008', 'Simon', 'Michel', '1962-11-30', 'M', '258 Boulevard Haussmann, 75008 Paris', '0123456796', 'michel.simon@email.com', '123456789012352', 'AB-', 'nfc-008-michel', NOW() - INTERVAL '3 months', NOW() - INTERVAL '12 hours', TRUE),
('PA-2024-009', 'Garcia', 'Isabelle', '1985-07-14', 'F', '369 Rue de la Bourse, 75002 Paris', '0123456797', 'isabelle.garcia@email.com', '123456789012353', 'A+', 'nfc-009-isabelle', NOW() - INTERVAL '2 months', NOW() - INTERVAL '1 day', TRUE),
('PA-2024-010', 'Lefevre', 'François', '1978-01-20', 'M', '741 Rue du Faubourg Saint-Honoré, 75008 Paris', '0123456798', 'francois.lefevre@email.com', '123456789012354', 'O+', 'nfc-010-francois', NOW() - INTERVAL '1 month', NOW() - INTERVAL '2 days', TRUE)
ON CONFLICT (numero_dossier) DO NOTHING;

-- Insertion de dossiers médicaux
INSERT INTO dossiers_medicaux (
    patient_id, antecedents_medicaux, antecedents_chirurgicaux, antecedents_familiaux, traitements_en_cours, allergies, observations_generales, hash_contenu, date_creation, date_modification, professionnel_creation_id
) VALUES 
(1, 'Douleurs lombaires chroniques, Migraines occasionnelles', 'Appendicectomie (2010)', 'Diabète type 2 (père), Hypertension (mère)', 'Paracétamol 500mg si nécessaire', 'Pénicilline (Modérée)', 'Patient en bonne santé générale, surveillance des lombalgies', 'hash_001_sophie_laurent_2024', NOW() - INTERVAL '1 year', NOW() - INTERVAL '2 days', 1),
(2, 'Hypertension artérielle, Cholestérol élevé', 'Pose de stent coronarien (2018)', 'Infarctus (père), Diabète (mère)', 'Amlodipine 5mg/j, Atorvastatine 20mg/j', 'Aucune', 'Surveillance tensionnelle régulière, régime pauvre en sel', 'hash_002_marc_dupont_2024', NOW() - INTERVAL '1 year', NOW() - INTERVAL '1 week', 1),
(3, 'Anxiété, Troubles du sommeil', 'Aucun', 'Dépression (mère)', 'Alprazolam 0.25mg si nécessaire', 'Arachides (Sévère), Latex (Modérée)', 'Symptômes anxieux améliorés, suivi psychologique recommandé', 'hash_003_emilie_moreau_2024', NOW() - INTERVAL '1 year', NOW() - INTERVAL '3 days', 1),
(4, 'Diabète type 2, Rétinopathie diabétique', 'Chirurgie de la cataracte (2022)', 'Diabète (père et mère)', 'Metformine 1000mg 2x/j, Insuline glargine', 'Aucune', 'Équilibre glycémique correct, surveillance ophtalmologique', 'hash_004_thomas_petit_2024', NOW() - INTERVAL '1 year', NOW() - INTERVAL '5 days', 1),
(5, 'Asthme, Rhinite allergique', 'Aucun', 'Asthme (père)', 'Ventoline si nécessaire, Fostair 200/6', 'Acariens, Pollens (Sévère)', 'Asthme bien contrôlé, éviction des allergènes', 'hash_005_claire_martin_2024', NOW() - INTERVAL '8 months', NOW() - INTERVAL '1 day', 1),
(6, 'Arthrose du genou, Hypertension', 'Arthroscopie genou droit (2019)', 'Arthrose (mère)', 'Ibuprofène 400mg si nécessaire, Amlodipine 5mg/j', 'Aucune', 'Douleurs articulaires modérées, activité physique adaptée', 'hash_006_pierre_rousseau_2024', NOW() - INTERVAL '6 months', NOW() - INTERVAL '4 days', 1),
(7, 'Dépression, Troubles alimentaires', 'Aucun', 'Dépression (mère)', 'Sertraline 50mg/j', 'Aucune', 'Amélioration de l''humeur, suivi psychiatrique', 'hash_007_anne_leroy_2024', NOW() - INTERVAL '4 months', NOW() - INTERVAL '6 hours', 1),
(8, 'BPCO, Insuffisance cardiaque', 'Pose de pacemaker (2020)', 'BPCO (père)', 'Ventoline, Symbicort, Furosémide 40mg/j', 'Aucune', 'Fonction respiratoire stable, surveillance cardiaque', 'hash_008_michel_simon_2024', NOW() - INTERVAL '3 months', NOW() - INTERVAL '12 hours', 1),
(9, 'Hypothyroïdie, Anémie ferriprive', 'Thyroïdectomie partielle (2017)', 'Hypothyroïdie (mère)', 'Lévothyroxine 75µg/j, Fer 80mg/j', 'Aucune', 'TSH normalisée, ferritine en amélioration', 'hash_009_isabelle_garcia_2024', NOW() - INTERVAL '2 months', NOW() - INTERVAL '1 day', 1),
(10, 'Ulcère gastrique, Reflux gastro-œsophagien', 'Aucun', 'Cancer gastrique (père)', 'Oméprazole 20mg/j', 'Aucune', 'Symptômes bien contrôlés, régime adapté', 'hash_010_francois_lefevre_2024', NOW() - INTERVAL '1 month', NOW() - INTERVAL '2 days', 1)
ON CONFLICT (patient_id) DO NOTHING;

-- Insertion de consultations récentes
INSERT INTO consultations (
    dossier_medical_id, professionnel_id, date_consultation, motif_consultation, examen_clinique, diagnostic, traitement_prescrit, ordonnance, observations, prochain_rdv, hash_contenu, date_creation, date_modification
) VALUES 
(1, 1, NOW() - INTERVAL '2 days', 'Douleurs lombaires persistantes', 'Douleur à la palpation L4-L5, limitation de la flexion', 'Lombalgie chronique mécanique', 'Kinésithérapie 10 séances, Paracétamol 1g 3x/j', 'Paracétamol 500mg - 1 comprimé 3 fois par jour pendant 7 jours', 'Amélioration des douleurs, poursuite de la kinésithérapie', NOW() + INTERVAL '1 month', 'hash_consult_001_2024', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
(2, 1, NOW() - INTERVAL '1 week', 'Contrôle tensionnel', 'TA: 135/85 mmHg, FC: 72/min', 'Hypertension bien contrôlée', 'Poursuite du traitement actuel', 'Amlodipine 5mg - 1 comprimé par jour', 'Tension artérielle stabilisée, surveillance trimestrielle', NOW() + INTERVAL '3 months', 'hash_consult_002_2024', NOW() - INTERVAL '1 week', NOW() - INTERVAL '1 week'),
(3, 1, NOW() - INTERVAL '3 days', 'Anxiété et troubles du sommeil', 'Patient calme, pas de signes de dépression', 'Anxiété généralisée améliorée', 'Poursuite de l''Alprazolam si nécessaire', 'Alprazolam 0.25mg - 1 comprimé au coucher si nécessaire', 'Symptômes anxieux en nette amélioration', NOW() + INTERVAL '2 months', 'hash_consult_003_2024', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
(4, 1, NOW() - INTERVAL '5 days', 'Contrôle diabète', 'Glycémie à jeun: 1.26 g/l, HbA1c: 6.8%', 'Diabète type 2 équilibré', 'Ajustement de l''insuline', 'Insuline glargine - 12 unités le soir', 'Équilibre glycémique satisfaisant', NOW() + INTERVAL '1 month', 'hash_consult_004_2024', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
(5, 1, NOW() - INTERVAL '1 day', 'Crise d''asthme', 'Sibilances bilatérales, dyspnée modérée', 'Crise d''asthme modérée', 'Ventoline 2 bouffées 4x/j pendant 48h', 'Ventoline 100µg - 2 bouffées 4 fois par jour pendant 48h', 'Amélioration rapide sous Ventoline', NOW() + INTERVAL '1 week', 'hash_consult_005_2024', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
(6, 1, NOW() - INTERVAL '4 days', 'Douleur genou droit', 'Douleur à la palpation, limitation de la flexion', 'Poussée d''arthrose du genou droit', 'Anti-inflammatoires, repos relatif', 'Ibuprofène 400mg - 1 comprimé 3 fois par jour pendant 5 jours', 'Douleurs en amélioration, éviter les escaliers', NOW() + INTERVAL '2 weeks', 'hash_consult_006_2024', NOW() - INTERVAL '4 days', NOW() - INTERVAL '4 days'),
(7, 1, NOW() - INTERVAL '6 hours', 'Suivi dépression', 'Humeur améliorée, pas d''idées suicidaires', 'Dépression en rémission', 'Poursuite de la Sertraline', 'Sertraline 50mg - 1 comprimé par jour', 'Nette amélioration de l''humeur et du sommeil', NOW() + INTERVAL '1 month', 'hash_consult_007_2024', NOW() - INTERVAL '6 hours', NOW() - INTERVAL '6 hours'),
(8, 1, NOW() - INTERVAL '12 hours', 'Essoufflement', 'Crépitants bilatéraux, œdèmes des membres inférieurs', 'Décompensation cardiaque modérée', 'Augmentation du Furosémide', 'Furosémide 80mg - 1 comprimé par jour pendant 3 jours', 'Amélioration de l''essoufflement sous diurétiques', NOW() + INTERVAL '1 week', 'hash_consult_008_2024', NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours'),
(9, 1, NOW() - INTERVAL '1 day', 'Contrôle thyroïde', 'Pas de goitre, pas de signes d''hyperthyroïdie', 'Hypothyroïdie équilibrée', 'Ajustement de la Lévothyroxine', 'Lévothyroxine 75µg - 1 comprimé par jour', 'TSH normalisée, bien tolérance', NOW() + INTERVAL '3 months', 'hash_consult_009_2024', NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),
(10, 1, NOW() - INTERVAL '2 days', 'Douleurs épigastriques', 'Douleur à la palpation épigastrique', 'Ulcère gastrique en cicatrisation', 'Poursuite de l''Oméprazole', 'Oméprazole 20mg - 1 comprimé par jour pendant 1 mois', 'Douleurs en nette amélioration', NOW() + INTERVAL '1 month', 'hash_consult_010_2024', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),
(1, 2, NOW() - INTERVAL '1 month', 'Consultation cardiologique', 'Auscultation normale, pas de signes d''insuffisance cardiaque', 'Pas de pathologie cardiaque', 'Aucun traitement cardiaque nécessaire', 'Aucune ordonnance', 'Cœur normal, surveillance tensionnelle', NOW() + INTERVAL '6 months', 'hash_consult_011_2024', NOW() - INTERVAL '1 month', NOW() - INTERVAL '1 month'),
(3, 3, NOW() - INTERVAL '2 weeks', 'Éruption cutanée', 'Plaques érythémateuses prurigineuses', 'Urticaire allergique', 'Antihistaminiques', 'Cétirizine 10mg - 1 comprimé par jour pendant 7 jours', 'Éruption en régression, éviter les allergènes', NOW() + INTERVAL '1 month', 'hash_consult_012_2024', NOW() - INTERVAL '2 weeks', NOW() - INTERVAL '2 weeks')
ON CONFLICT DO NOTHING; 