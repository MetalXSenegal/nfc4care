package com.nfc4care.controller;

import com.nfc4care.service.CardanoService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/blockchain")
@RequiredArgsConstructor
@Slf4j
public class BlockchainController {
    
    private final CardanoService cardanoService;
    
    @GetMapping("/verify/{id}")
    public ResponseEntity<Map<String, Object>> verifyIntegrity(@PathVariable String id) {
        log.info("Vérification de l'intégrité pour l'ID: {}", id);
        
        try {
            // Cette implémentation est simplifiée
            // En production, vous devriez récupérer l'entité par ID et vérifier son hash
            boolean isValid = cardanoService.verifyTransaction(id, "expected_hash");
            
            Map<String, Object> response = new HashMap<>();
            response.put("id", id);
            response.put("valid", isValid);
            response.put("timestamp", System.currentTimeMillis());
            
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("Erreur lors de la vérification de l'intégrité", e);
            return ResponseEntity.badRequest().build();
        }
    }
} 