package com.nfc4care.controller;

import com.nfc4care.dto.ApiResponse;
import com.nfc4care.service.CardanoBlockchainService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Contrôleur pour les opérations blockchain et vérification d'intégrité
 */
@RestController
@RequestMapping("/blockchain")
@RequiredArgsConstructor
@Slf4j
public class BlockchainController {

    private final CardanoBlockchainService blockchainService;

    /**
     * Vérifie l'intégrité d'un contenu en comparant les hashes
     */
    @PostMapping("/verify")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> verifyIntegrity(
            @RequestParam String currentHash,
            @RequestParam String registeredHash) {
        log.info("Vérification de l'intégrité des données");

        try {
            boolean isValid = blockchainService.verifyDataIntegrity(currentHash, registeredHash);

            Map<String, Object> result = new HashMap<>();
            result.put("valid", isValid);
            result.put("message", isValid ? "Données intactes" : "Données modifiées");

            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            log.error("❌ Erreur lors de la vérification de l'intégrité", e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("VERIFICATION_ERROR", e.getMessage()));
        }
    }

    /**
     * Récupère les détails d'une transaction blockchain
     */
    @GetMapping("/tx/{txHash}")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getTransactionDetails(
            @PathVariable String txHash) {
        log.info("Récupération des détails de transaction: {}", txHash);

        try {
            Map<String, Object> details = blockchainService.getTransactionDetails(txHash);
            if (details != null) {
                return ResponseEntity.ok(ApiResponse.success(details));
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            log.error("❌ Erreur lors de la récupération des détails de transaction", e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("TRANSACTION_ERROR", e.getMessage()));
        }
    }

    /**
     * Enregistre un contenu sur la blockchain
     */
    @PostMapping("/register")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> registerOnBlockchain(
            @RequestParam String contentHash,
            @RequestParam String dataType) {
        log.info("Enregistrement du contenu sur la blockchain: type={}", dataType);

        try {
            String txHash = blockchainService.registerOnBlockchain(contentHash, dataType);

            Map<String, Object> result = new HashMap<>();
            result.put("txHash", txHash);
            result.put("contentHash", contentHash);
            result.put("dataType", dataType);
            result.put("status", "registered");

            return ResponseEntity.ok(ApiResponse.success(result));
        } catch (Exception e) {
            log.error("❌ Erreur lors de l'enregistrement sur la blockchain", e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("REGISTRATION_ERROR", e.getMessage()));
        }
    }

    /**
     * Crée une preuve d'intégrité complète
     */
    @PostMapping("/create-proof")
    @PreAuthorize("hasRole('MEDECIN')")
    public ResponseEntity<ApiResponse<Map<String, Object>>> createIntegrityProof(
            @RequestParam String content,
            @RequestParam String dataId,
            @RequestParam String dataType) {
        log.info("Création d'une preuve d'intégrité: dataId={}", dataId);

        try {
            Map<String, Object> proof = blockchainService.createIntegrityProof(content, dataId, dataType);
            return ResponseEntity.ok(ApiResponse.success(proof));
        } catch (Exception e) {
            log.error("❌ Erreur lors de la création de la preuve d'intégrité", e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("PROOF_ERROR", e.getMessage()));
        }
    }

    /**
     * Status de la connexion blockchain
     */
    @GetMapping("/status")
    public ResponseEntity<ApiResponse<Map<String, Object>>> getBlockchainStatus() {
        log.info("Vérification du statut blockchain");

        Map<String, Object> status = new HashMap<>();
        status.put("available", true);
        status.put("network", "Cardano");
        status.put("mode", "Development/Mock");
        status.put("message", "Service blockchain disponible avec données de test");

        return ResponseEntity.ok(ApiResponse.success(status));
    }
} 