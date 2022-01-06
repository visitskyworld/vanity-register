// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface LifespanFee {
    function estimate(uint256 length, uint256 time) external view returns (uint256);
    function lifespan(uint256 length, uint256 value) external view returns (uint256);
}
