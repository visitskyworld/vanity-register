// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface GasStation {
    function suggestedGasPrice() external view returns (uint256);
}
