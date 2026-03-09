// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./VaultPause.sol";
import "./VaultMerkle.sol";
import "./VaultMultisig.sol";

contract EvictionVault is VaultPause, VaultMerkle, VaultMultisig {
 
    event Deposit(address indexed depositor, uint256 amount);
    event Withdrawal(address indexed withdrawer, uint256 amount);

    constructor(
        address[] memory _owners,
        uint256 _threshold
    )
        VaultOwners(_owners, _threshold)
        payable
    {
        totalVaultValue = msg.value;
    }

    receive() external payable {

        balances[msg.sender] += msg.value;

        totalVaultValue += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function deposit() external payable {

        balances[msg.sender] += msg.value;

        totalVaultValue += msg.value;

        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external notPaused {

        require(balances[msg.sender] >= amount, "insufficient");

        balances[msg.sender] -= amount;

        totalVaultValue -= amount;

        (bool success,) = msg.sender.call{value: amount}("");

        require(success, "withdraw failed");

        emit Withdrawal(msg.sender, amount);
    }

    function emergencyWithdrawAll() external onlyOwner {

        uint256 bal = address(this).balance;

        totalVaultValue = 0;

        (bool success,) = msg.sender.call{value: bal}("");

        require(success, "emergency failed");
    }
}
