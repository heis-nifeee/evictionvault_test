// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VaultOwners.sol";

abstract contract VaultPause is VaultOwners {

    modifier notPaused() {
        require(!paused, "paused");
        _;
    }

    function pause() external onlyOwner {
        paused = true;
    }

    function unpause() external onlyOwner {
        paused = false;
    }
}
