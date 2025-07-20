-- Table pour stocker les tokens JWT
CREATE TABLE IF NOT EXISTS tokens (
    id BIGSERIAL PRIMARY KEY,
    token_value VARCHAR(500) NOT NULL UNIQUE,
    user_email VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL,
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    expired BOOLEAN NOT NULL DEFAULT FALSE,
    user_agent VARCHAR(500),
    ip_address VARCHAR(45)
);

-- Index pour améliorer les performances
CREATE INDEX IF NOT EXISTS idx_tokens_user_email ON tokens(user_email);
CREATE INDEX IF NOT EXISTS idx_tokens_token_value ON tokens(token_value);
CREATE INDEX IF NOT EXISTS idx_tokens_expires_at ON tokens(expires_at);
CREATE INDEX IF NOT EXISTS idx_tokens_valid ON tokens(user_email, revoked, expired, expires_at);

-- Commentaires
COMMENT ON TABLE tokens IS 'Table pour stocker les tokens JWT avec validation en base de données';
COMMENT ON COLUMN tokens.token_value IS 'Valeur du token JWT';
COMMENT ON COLUMN tokens.user_email IS 'Email de l''utilisateur propriétaire du token';
COMMENT ON COLUMN tokens.created_at IS 'Date de création du token';
COMMENT ON COLUMN tokens.expires_at IS 'Date d''expiration du token';
COMMENT ON COLUMN tokens.revoked IS 'Indique si le token a été révoqué';
COMMENT ON COLUMN tokens.expired IS 'Indique si le token a expiré';
COMMENT ON COLUMN tokens.user_agent IS 'User-Agent du navigateur qui a généré le token';
COMMENT ON COLUMN tokens.ip_address IS 'Adresse IP qui a généré le token'; 