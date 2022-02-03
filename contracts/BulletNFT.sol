// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./KAP1155/abstracts/KAP1155.sol";

contract BulletToken is KAP1155 {
    uint256 public constant PISTAL_BULLET = 0;
    uint256 public constant SHOTGUN_BULLET = 1;
    uint256 public constant RIFLE_BULLET = 2;

    constructor() KAP1155("https://www.facebook.com") {}

    function createPistalBullet(uint256 amount) public {
        _mint(msg.sender, PISTAL_BULLET, amount, "");
    }

    function createShotgunBullet(uint256 amount) public {
        _mint(msg.sender, SHOTGUN_BULLET, amount, "");
    }

    function createRifleBullet(uint256 amount) public {
        _mint(msg.sender, RIFLE_BULLET, amount, "");
    }

    function createSetABullet() public {
        _mint(msg.sender, PISTAL_BULLET, 100, "");
        _mint(msg.sender, SHOTGUN_BULLET, 30, "");
        _mint(msg.sender, RIFLE_BULLET, 200, "");
    }

    function createSetBBullet() public {
        _mint(msg.sender, PISTAL_BULLET, 200, "");
        _mint(msg.sender, SHOTGUN_BULLET, 60, "");
        _mint(msg.sender, RIFLE_BULLET, 300, "");
    }

    function burnBullet(uint256 bulletType, uint256 amount) public {
        _burn(msg.sender, bulletType, amount);
    }
}