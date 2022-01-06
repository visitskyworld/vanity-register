// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../3dparty/Ownable.sol";
import "./GasStation.sol";

/**
 * @dev The simplest implementation of a GasStation, where the gas price
 * is set by the administrator, who is also the owner of the contract.
 */
contract GasStationDummyImpl is GasStation, Ownable {
    uint256 override public suggestedGasPrice = 1 gwei;

    function setSuggestedGasPrice(uint256 gasPrice) external
        onlyOwner
    {
        suggestedGasPrice = gasPrice;
    }
}
