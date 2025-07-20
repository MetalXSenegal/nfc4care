# Blockchain Integration (Ganache + Solidity)

## Prérequis
- Node.js (pour installer solc)
- solc (compilateur Solidity) : `npm install -g solc`
- web3j CLI : [Télécharger ici](https://docs.web3j.io/4.8.7/command_line_tools/)
- Java (pour le backend)

## Génération du wrapper Java

1. Placez-vous dans le dossier `blockchain/`
2. Exécutez le script PowerShell :
   
   ```powershell
   ./generate-blockchain-wrapper.ps1
   ```

Cela va :
- Compiler `PatientHistory.sol` en ABI et bytecode
- Générer le wrapper Java dans `../backend/src/main/java/com/nfc4care/blockchain/`

## Utilisation dans le backend

Vous pouvez maintenant utiliser la classe Java générée pour interagir avec le smart contract depuis le backend Spring Boot (voir service à créer). 