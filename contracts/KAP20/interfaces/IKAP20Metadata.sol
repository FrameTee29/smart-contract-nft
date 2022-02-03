pragma solidity ^0.8.0;

import "./IKAP20.sol";

interface IKAP20Metadata is IKAP20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}
