// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../3dparty/SafeMath.sol";
import "../3dparty/Ownable.sol";
import "./LifespanFee.sol";

contract LifespanFeeDummyImpl is LifespanFee, Ownable {
    /**
     * NOTE: Since Solidity 0.8 `SafeMath` is not necessary,
     * but is left for backward compatibility when deploying
     * with a different compiler version.
     */
    using SafeMath for uint256;

    uint256 public feePerByte = 2;
    uint256 public feePerSecond = 5;

    function setFeePerByte(uint256 fee) external
        onlyOwner
    {
        require(fee > 0, "LifespanFee: fee cannot be zero");
        feePerByte = fee;
    }

    function setFeePerSecond(uint256 fee) external
        onlyOwner
    {
        require(fee > 0, "LifespanFee: fee cannot be zero");
        feePerSecond = fee;
    }

    function estimate(uint256 length, uint256 time) override external view
        returns (uint256)
    {
        require(length > 0, "LifespanFee: length cannot be zero");
        return time.mul(length).mul(feePerByte).mul(feePerSecond);
    }

    function lifespan(uint256 length, uint256 value) override external view
        returns (uint256)
    {
        require(length > 0, "LifespanFee: length cannot be zero");
        uint256 fee = length.mul(feePerByte).mul(feePerSecond);
        return value.div(fee);
    }
}
