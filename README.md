# EvictionVault re worked on 

## Overview

The original EvictionVault contract was a single-file monolithic contract with  vulnerabilities.

This project repaired  the contract into a modular architecture and fix all  vulnerabilities.

## Fixed Vulnerabilities

### 1. setMerkleRoot Callable by Anyone
Fixed by restricting access with `onlyOwner`.

### 2. emergencyWithdrawAll Public Drain
Restricted to owners only.

### 3. pause/unpause Single Owner Control
Access now restricted to owners.

### 4. receive() Uses tx.origin
Replaced with `msg.sender`.

### 5. withdraw & claim Using transfer
Replaced `.transfer` with low level `.call`.

### 6. Timelock Execution
Execution requires:

- threshold confirmations
- timelock expiration


## Project Structure

src/

- VaultStorage.sol
- VaultOwners.sol
- VaultPause.sol
- VaultMultisig.sol
- VaultMerkle.sol
- EvictionVault.sol

test/

- EvictionVault.t.sol
