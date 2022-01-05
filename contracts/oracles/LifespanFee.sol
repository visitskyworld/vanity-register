// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LifespanFee {
    function lifespan(uint256 length, uint256 value) external returns (uint256);
}
