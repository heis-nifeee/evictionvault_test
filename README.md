# Eviction Vault (Refactored)

Date: March 09, 2026

This project refactors the original single-file `EvictionVault` into a modular structure and applies immediate mitigation for critical vulnerabilities.

## Project Structure

- `src/EvictionVault.sol`: main vault logic (deposits, withdrawals, claims, emergency flow)
- `src/interfaces/IEvictionVault.sol`: shared struct and events
- `src/modules/EvictionAccessControl.sol`: owner/threshold/paused state and modifiers
- `src/modules/EvictionMultisig.sol`: submit/confirm/timelocked execution for privileged actions
- `test/EvictionVault.t.sol`: basic passing Foundry tests

## Critical Fixes Implemented

1. `setMerkleRoot` callable by anyone
- Fixed: `setMerkleRoot(bytes32)` is now `onlySelf`.
- Effect: Merkle root changes can only happen through the timelocked multisig execution path.

2. `emergencyWithdrawAll` public drain
- Fixed: `emergencyWithdrawAll(address payable)` is now `onlySelf` and requires `paused == true`.
- Effect: full-balance withdrawals require multisig approval, timelock delay, and paused state.

3. `pause/unpause` single-owner control
- Fixed: `pause()` and `unpause()` are now `onlySelf`.
- Effect: pausing and unpausing require multisig confirmations + timelock.

4. `receive()` using `tx.origin`
- Fixed: `receive()` now credits `balances[msg.sender]`.
- Effect: no `tx.origin` trust boundary risk.

5. `withdraw` and `claim` using `.transfer`
- Fixed: replaced with `Address.sendValue` (safe call forwarding gas).
- Effect: avoids `.transfer` gas stipend fragility and call-failure edge cases.

6. Timelock execution hardening
- Fixed: execution requires:
  - tx exists
  - not already executed
  - confirmations `>= threshold`
  - timelock set and elapsed (`executionTime != 0 && block.timestamp >= executionTime`)
- Effect: privileged operations are delayed and auditable.

## Build and Test

```bash
forge build
forge test
```

## Current Security Posture

The direct public attack paths from the original monolith are removed. High-impact administrative actions are now restricted to the vault itself and must pass through the timelocked multisig workflow.
