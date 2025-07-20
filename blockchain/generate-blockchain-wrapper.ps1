# Ce script compile PatientHistory.sol et génère le wrapper Java pour web3j
# Prérequis : solc (npm install -g solc), web3j CLI (https://docs.web3j.io/4.8.7/command_line_tools/)

$ErrorActionPreference = 'Stop'

# Paths
$solFile = "PatientHistory.sol"
$buildDir = "build"
$javaPackage = "com.nfc4care.blockchain"
$javaOutputDir = "../backend/src/main/java/com/nfc4care/blockchain"

# Create build dir if not exists
if (!(Test-Path $buildDir)) { mkdir $buildDir }
if (!(Test-Path $javaOutputDir)) { mkdir $javaOutputDir -Force }

# Compile Solidity to ABI and BIN
solc --abi --bin $solFile -o $buildDir

# Find contract name
$contractName = "PatientHistory"
$abiFile = "$buildDir/$contractName.abi"
$binFile = "$buildDir/$contractName.bin"

if (!(Test-Path $abiFile) -or !(Test-Path $binFile)) {
    Write-Error "Compilation failed: ABI or BIN file not found."
    exit 1
}

# Générer le wrapper Java avec web3j
web3j solidity generate --javaTypes $binFile $abiFile -p $javaPackage -o $javaOutputDir

Write-Host "Wrapper Java généré dans $javaOutputDir" 