//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./KAP721/abstracts/KAP721.sol";

contract GNFT is KAP721 {
    constructor(string memory name_, string memory symbol_)
        KAP721(name_, symbol_)
    {}

    function create(uint256 tokenId, string memory uri) public {
        _mint(msg.sender, tokenId, uri);
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId);
    }
}
