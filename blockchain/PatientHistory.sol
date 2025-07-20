// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PatientHistory {
    struct Modification {
        uint256 timestamp;
        string action; // e.g., "create", "update", "delete"
        string entityType; // e.g., "DossierMedical", "Consultation"
        uint256 entityId;
        string hashContenu;
        address professionnel;
    }

    event ModificationLogged(uint256 indexed entityId, string entityType, string action, string hashContenu, address professionnel, uint256 timestamp);

    mapping(uint256 => Modification[]) public modificationsByEntity;

    function logModification(uint256 entityId, string memory entityType, string memory action, string memory hashContenu) public {
        Modification memory mod = Modification({
            timestamp: block.timestamp,
            action: action,
            entityType: entityType,
            entityId: entityId,
            hashContenu: hashContenu,
            professionnel: msg.sender
        });
        modificationsByEntity[entityId].push(mod);
        emit ModificationLogged(entityId, entityType, action, hashContenu, msg.sender, block.timestamp);
    }

    function getModifications(uint256 entityId) public view returns (Modification[] memory) {
        return modificationsByEntity[entityId];
    }
} 