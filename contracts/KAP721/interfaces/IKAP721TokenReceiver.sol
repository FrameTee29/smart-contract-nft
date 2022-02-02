pragma solidity ^0.8.0;

interface IKAP721TokenReceiver {
    function onKAP721Received(address operator, address from, uint256 tokenId, bytes memory _data) external returns(bytes4);
}