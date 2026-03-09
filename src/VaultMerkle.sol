// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./VaultOwners.sol";

abstract contract VaultMerkle is VaultOwners {
    event MerkleRootSet(bytes32 indexed newRoot);
    event Claim(address indexed claimant, uint256 amount);

    function setMerkleRoot(bytes32 root) external onlyOwner {
        merkleRoot = root;

        emit MerkleRootSet(root);
    }

    function claim(bytes32[] calldata proof, uint256 amount) external {
        require(!paused, "paused");

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));

        require(MerkleProof.verify(proof, merkleRoot, leaf), "invalid proof");

        require(!claimed[msg.sender], "already claimed");

        claimed[msg.sender] = true;
        totalVaultValue -= amount;
        (bool success, ) = payable(msg.sender).call{value: amount}("");

        require(success, "transfer failed");

        emit Claim(msg.sender, amount);
    }
}
