// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/EvictionVault.sol";

contract EvictionVaultTest is Test {
    EvictionVault vault;

    address owner1 = makeAddr("owner1");
    address owner2 = makeAddr("owner2");
    address owner3 = makeAddr("owner3");
    address user = makeAddr("user");
    address recipient = makeAddr("recipient");

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        vm.deal(owner1, 20 ether);
        vm.prank(owner1);
        vault = new EvictionVault{value: 10 ether}(owners, 2);
    }

    function testDepositAndWithdrawFlow() public {
        vm.deal(user, 2 ether);

        vm.prank(user);
        vault.deposit{value: 1 ether}();

        assertEq(vault.balances(user), 1 ether);
        assertEq(vault.totalVaultValue(), 11 ether);

        vm.prank(user);
        vault.withdraw(0.4 ether);

        assertEq(vault.balances(user), 0.6 ether);
        assertEq(vault.totalVaultValue(), 10.6 ether);
    }

    function testWithdrawRevertsWhenPaused() public {
        vm.deal(user, 1 ether);
        vm.prank(user);
        vault.deposit{value: 1 ether}();

        vm.prank(owner1);
        vault.pause();

        vm.prank(user);
        vm.expectRevert(bytes("paused"));
        vault.withdraw(0.1 ether);
    }

    function testMerkleClaimWithSingleLeaf() public {
        uint256 claimAmount = 1 ether;
        bytes32 root = keccak256(abi.encodePacked(user, claimAmount));

        vm.prank(owner1);
        vault.setMerkleRoot(root);

        bytes32[] memory proof = new bytes32[](0);

        uint256 before = user.balance;
        vm.prank(user);
        vault.claim(proof, claimAmount);

        assertEq(user.balance, before + claimAmount);
        assertTrue(vault.claimed(user));
        assertEq(vault.totalVaultValue(), 9 ether);
    }

    function testMultisigExecuteAfterTimelock() public {
        vm.prank(owner1);
        vault.submitTransaction(recipient, 1 ether, "");

        uint256 txId = 0;
        uint256 expectedExecutionTime = block.timestamp + vault.TIMELOCK_DURATION();

        vm.prank(owner2);
        vault.confirmTransaction(txId);

        (, , , , uint256 confirmations, , uint256 executionTime) = vault.transactions(txId);
        assertEq(confirmations, 2);
        assertEq(executionTime, expectedExecutionTime);

        vm.warp(expectedExecutionTime);
        vault.executeTransaction(txId);

        assertEq(recipient.balance, 1 ether);
        (, , , bool executed, , , ) = vault.transactions(txId);
        assertTrue(executed);
    }

    function testExecuteRevertsBeforeTimelockExpires() public {
        vm.prank(owner1);
        vault.submitTransaction(recipient, 1 ether, "");

        vm.prank(owner2);
        vault.confirmTransaction(0);

        vm.expectRevert(bytes("timelock active"));
        vault.executeTransaction(0);
    }
}
