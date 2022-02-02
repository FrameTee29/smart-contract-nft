//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./KAP721/abstracts/KAP721.sol";

contract GNFT is KAP721 {
    
    constructor() KAP721("Game NFT","GNFT"){}

    function create(uint tokenId,string memory uri ) public{
        _mint(msg.sender,tokenId,uri);
    }

    function burn(uint tokenId) public {
        _burn(tokenId);
    }
}
