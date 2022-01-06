// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev The interface of LifespanFee Oracle is responsible for estimating and calculating the price of a record
 * in the RecordRegister based on the size of this record and the desired storage time.
 */
interface LifespanFee {
    function estimate(uint256 length, uint256 time) external view returns (uint256);
    function lifespan(uint256 length, uint256 value) external view returns (uint256);
}
