// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TrustfulOracle.sol";
import "./Exchange.sol";

contract Comp_POC {
    TrustfulOracle public oracle;
    Exchange public exchange;
    DamnValuableNFT public token;

    constructor(TrustfulOracle _oracle, Exchange _exchange, DamnValuableNFT _token) {
        oracle = _oracle;
        exchange = _exchange;
        token = _token;
    }

    function get_price(string calldata symbol) external view returns(uint256) {
        return oracle.getMedianPrice(symbol);
    }
}
