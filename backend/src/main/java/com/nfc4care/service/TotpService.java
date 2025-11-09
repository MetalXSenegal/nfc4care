package com.nfc4care.service;

import com.google.common.io.BaseEncoding;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.nio.ByteBuffer;
import java.security.SecureRandom;
import java.time.Instant;

/**
 * Service pour gérer l'authentification TOTP (Time-based One-Time Password)
 * Compatible avec Google Authenticator, Microsoft Authenticator, etc.
 */
@Service
@Slf4j
public class TotpService {

    private static final int TIME_STEP = 30; // 30 seconds
    private static final int CODE_DIGITS = 6;
    private static final String HMAC_ALGORITHM = "HmacSHA1";
    private static final long ALLOWED_TIME_DISCREPANCY = 1; // Allow ±1 time window

    /**
     * Génère une clé secrète aléatoire pour TOTP
     * @return Clé secrète en base32
     */
    public String generateSecretKey() {
        byte[] buffer = new byte[20]; // 160 bits
        SecureRandom random = new SecureRandom();
        random.nextBytes(buffer);
        return BaseEncoding.base32().encode(buffer);
    }

    /**
     * Génère l'URI pour un QR code compatible Google Authenticator
     * @param secretKey La clé secrète en base32
     * @param email L'email de l'utilisateur
     * @param issuer Le nom de l'application
     * @return URI otpauth://
     */
    public String generateQrCodeUri(String secretKey, String email, String issuer) {
        return String.format(
            "otpauth://totp/%s:%s?secret=%s&issuer=%s",
            issuer, email, secretKey, issuer
        );
    }

    /**
     * Valide un code TOTP
     * @param secretKey La clé secrète en base32
     * @param code Le code TOTP à vérifier (6 chiffres)
     * @return true si le code est valide
     */
    public boolean validateTotp(String secretKey, String code) {
        try {
            // Get current time window
            long timeCounter = System.currentTimeMillis() / 1000 / TIME_STEP;

            // Check current and adjacent time windows (allows for time skew)
            for (long i = -ALLOWED_TIME_DISCREPANCY; i <= ALLOWED_TIME_DISCREPANCY; i++) {
                String expectedCode = generateTotpCode(secretKey, timeCounter + i);
                if (expectedCode.equals(code)) {
                    log.info("✅ TOTP code validé");
                    return true;
                }
            }

            log.warn("❌ TOTP code invalide: {}", code);
            return false;
        } catch (Exception e) {
            log.error("❌ Erreur lors de la validation du code TOTP", e);
            return false;
        }
    }

    /**
     * Génère un code TOTP pour une clé secrète donnée et un compteur de temps
     * @param secretKey La clé secrète en base32
     * @param timeCounter Le compteur de temps
     * @return Code TOTP à 6 chiffres
     */
    private String generateTotpCode(String secretKey, long timeCounter) throws Exception {
        // Decode secret key from base32
        byte[] decodedKey = BaseEncoding.base32().decode(secretKey);

        // Create HMAC-SHA1 instance
        Mac mac = Mac.getInstance(HMAC_ALGORITHM);
        SecretKeySpec keySpec = new SecretKeySpec(decodedKey, 0, decodedKey.length, HMAC_ALGORITHM);
        mac.init(keySpec);

        // Convert time counter to bytes
        byte[] timeCounterBytes = ByteBuffer.allocate(8).putLong(timeCounter).array();

        // Generate HMAC
        byte[] hmacResult = mac.doFinal(timeCounterBytes);

        // Dynamic truncation (RFC 4226)
        int offset = hmacResult[hmacResult.length - 1] & 0xf;
        int code = ((hmacResult[offset] & 0x7f) << 24)
                | ((hmacResult[offset + 1] & 0xff) << 16)
                | ((hmacResult[offset + 2] & 0xff) << 8)
                | (hmacResult[offset + 3] & 0xff);

        // Get code digits
        code = code % (int) Math.pow(10, CODE_DIGITS);
        return String.format("%06d", code);
    }

    /**
     * Génère le code TOTP actuel (pour les tests)
     * @param secretKey La clé secrète en base32
     * @return Code TOTP à 6 chiffres
     */
    public String getCurrentCode(String secretKey) {
        try {
            long timeCounter = System.currentTimeMillis() / 1000 / TIME_STEP;
            return generateTotpCode(secretKey, timeCounter);
        } catch (Exception e) {
            log.error("Erreur lors de la génération du code TOTP", e);
            return null;
        }
    }
}
