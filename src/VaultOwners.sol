// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VaultStorage.sol";

contract VaultOwners is VaultStorage {
 
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    constructor(address[] memory _owners, uint256 _threshold) {

        require(_owners.length > 0, "no owners");
        require(_threshold <= _owners.length, "invalid threshold");

        threshold = _threshold;

        for (uint i = 0; i < _owners.length; i++) {

            address o = _owners[i];

            require(o != address(0), "zero owner");

            isOwner[o] = true;
            owners.push(o);
        }
    }
}
