//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./KAP20/abstracts/KAP20.sol";

contract Bullet is KAP20 {
    constructor(string memory name_, string memory symbol_)
        KAP20(name_, symbol_)
    {}

    function deposit(uint256 amount) public payable {
        require(amount > 0, "amount is zero");

        _mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(
            amount > 0 && amount <= balanceOf(msg.sender),
            "withdraw amount exceeds balance"
        );

        // payable(msg.sender).transfer(amount);
        _burn(msg.sender, amount);
    }
}
