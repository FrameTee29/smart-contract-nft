// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IKAP1155.sol";

interface IKAP1155MetadataURI is IKAP1155 {
    function uri(uint256 id) external view returns (string memory);
}