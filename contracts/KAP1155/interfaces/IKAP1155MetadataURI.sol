pragma solidity ^0.8.0;

interface IKAP1155MetadataURI {
    function uri(uint256 id) external view returns (string memory);
}