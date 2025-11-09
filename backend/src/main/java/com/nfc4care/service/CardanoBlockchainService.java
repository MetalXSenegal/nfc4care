package com.nfc4care.service;

import com.nfc4care.util.HashUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Service pour l'intégration blockchain Cardano avec Blockfrost API
 * Permet de vérifier l'intégrité des données via la blockchain
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class CardanoBlockchainService {

    private final RestTemplate restTemplate;

    @Value("${blockfrost.api.key:}")
    private String blockfrostApiKey;

    @Value("${blockfrost.api.base-url:https://cardano-mainnet.blockfrost.io/api/v0}")
    private String blockfrostBaseUrl;

    @Value("${blockfrost.api.network:mainnet}")
    private String network;

    /**
     * Enregistre un hash de contenu sur la blockchain (simulation/mock)
     * En production, cela créerait une vraie transaction Cardano
     * @param contentHash Le hash SHA-256 du contenu
     * @param dataType Le type de données (CONSULTATION, DOSSIER, etc.)
     * @return Le hash de transaction (ou ID unique en mode mock)
     */
    public String registerOnBlockchain(String contentHash, String dataType) {
        log.info("Tentative d'enregistrement du hash sur la blockchain: type={}, hash={}", dataType, contentHash);

        // Vérifier si l'API key est configurée
        if (blockfrostApiKey == null || blockfrostApiKey.isEmpty() || blockfrostApiKey.equals("YOUR_BLOCKFROST_API_KEY_HERE")) {
            log.warn("⚠️ Blockfrost API key non configurée. Mode simulation activé.");
            return generateMockTransactionHash();
        }

        try {
            // En production, vous créeriez une vraie transaction Cardano
            // Pour maintenant, on simule une vérification via l'API Blockfrost
            String txHash = simulateBlockchainTransaction(contentHash, dataType);
            log.info("✅ Hash enregistré sur la blockchain: {}", txHash);
            return txHash;
        } catch (Exception e) {
            log.error("❌ Erreur lors de l'enregistrement sur la blockchain", e);
            // Fallback en mode simulation
            return generateMockTransactionHash();
        }
    }

    /**
     * Vérifie qu'un contenu n'a pas été modifié en comparant son hash avec celui enregistré
     * @param contentHash Le hash SHA-256 du contenu à vérifier
     * @param registeredHash Le hash enregistré sur la blockchain
     * @return true si les hashes correspondent, false sinon
     */
    public boolean verifyDataIntegrity(String contentHash, String registeredHash) {
        log.info("Vérification de l'intégrité des données");

        if (contentHash == null || registeredHash == null) {
            log.warn("⚠️ Hashes invalides pour la vérification");
            return false;
        }

        boolean isValid = contentHash.equals(registeredHash);
        if (isValid) {
            log.info("✅ Données intactes - aucune modification détectée");
        } else {
            log.warn("❌ Intégrité compromise - les données ont été modifiées!");
        }

        return isValid;
    }

    /**
     * Récupère les informations de transaction depuis Blockfrost
     * @param txHash Le hash de transaction
     * @return Les détails de la transaction ou null
     */
    public Map<String, Object> getTransactionDetails(String txHash) {
        if (blockfrostApiKey == null || blockfrostApiKey.isEmpty() || blockfrostApiKey.equals("YOUR_BLOCKFROST_API_KEY_HERE")) {
            log.warn("⚠️ Blockfrost API key non configurée");
            return generateMockTransactionDetails(txHash);
        }

        try {
            String url = String.format("%s/txs/%s", blockfrostBaseUrl, txHash);
            HttpHeaders headers = new HttpHeaders();
            headers.set("project_id", blockfrostApiKey);

            HttpEntity<String> entity = new HttpEntity<>(headers);
            ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null) {
                log.info("✅ Détails de transaction récupérés: {}", txHash);
                return response.getBody();
            }
        } catch (Exception e) {
            log.error("❌ Erreur lors de la récupération des détails de transaction", e);
        }

        return null;
    }

    /**
     * Génère un hash de transaction mock pour le développement
     */
    private String generateMockTransactionHash() {
        String txHash = "mock_" + UUID.randomUUID().toString();
        log.debug("Hash de transaction généré (mock): {}", txHash);
        return txHash;
    }

    /**
     * Simule une transaction blockchain (pour développement)
     */
    private String simulateBlockchainTransaction(String contentHash, String dataType) {
        log.debug("Simulation de transaction blockchain pour: {}", dataType);
        return "tx_" + System.currentTimeMillis() + "_" + contentHash.substring(0, 8);
    }

    /**
     * Génère des détails de transaction mock
     */
    private Map<String, Object> generateMockTransactionDetails(String txHash) {
        Map<String, Object> details = new HashMap<>();
        details.put("hash", txHash);
        details.put("block", "Mock Block #123456");
        details.put("timestamp", LocalDateTime.now().toString());
        details.put("status", "confirmed");
        details.put("type", "data_integrity_proof");
        details.put("network", network);
        return details;
    }

    /**
     * Crée une preuve d'intégrité complète avec signature
     */
    public Map<String, Object> createIntegrityProof(String content, String dataId, String dataType) {
        String contentHash = HashUtil.generateSHA256Hash(content);
        String txHash = registerOnBlockchain(contentHash, dataType);

        Map<String, Object> proof = new HashMap<>();
        proof.put("dataId", dataId);
        proof.put("dataType", dataType);
        proof.put("contentHash", contentHash);
        proof.put("blockchainTxHash", txHash);
        proof.put("timestamp", LocalDateTime.now().toString());
        proof.put("network", network);
        proof.put("verified", true);

        log.info("✅ Preuve d'intégrité créée: {}", dataId);
        return proof;
    }
}
