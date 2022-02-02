pragma solidity ^0.8.0;

interface IKAP1155Metadata_URI {
    function uri(uint256 tokenId) external view returns (string memory);
}
