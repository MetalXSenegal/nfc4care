package com.nfc4care.util;

import lombok.extern.slf4j.Slf4j;

import java.security.MessageDigest;

/**
 * Classe utilitaire pour les opérations de hashing SHA-256
 */
@Slf4j
public class HashUtil {

    private static final String HASH_ALGORITHM = "SHA-256";

    /**
     * Génère un hash SHA-256 à partir d'une string
     * @param content Le contenu à hasher
     * @return Hex string du hash SHA-256
     */
    public static String generateSHA256Hash(String content) {
        if (content == null || content.trim().isEmpty()) {
            return "";
        }

        try {
            MessageDigest digest = MessageDigest.getInstance(HASH_ALGORITHM);
            byte[] hashBytes = digest.digest(content.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            log.error("❌ Erreur lors de la génération du hash SHA-256", e);
            return "";
        }
    }
}
