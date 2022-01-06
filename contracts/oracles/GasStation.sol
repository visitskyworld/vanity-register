// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev GasStation contract interface, the implementation of which contains
 * the current gas price and can be maintained by the responsible foundation
 * or the interested community.
 */
interface GasStation {
    function suggestedGasPrice() external view returns (uint256);
}
