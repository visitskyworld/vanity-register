// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../oracles/GasStation.sol";

/**
 * @dev
 */
contract GasPriceLimiter {
    GasStation public oracleGasStation;

    constructor(GasStation addrGasStation)
    {
        oracleGasStation = addrGasStation;
    }

    modifier gasThrottled() {
        uint256 suggested = oracleGasStation.suggestedGasPrice();
        require(tx.gasprice == suggested, "GasPriceLimiter: the gas price should be the same as the one suggested");
        _;
    }

    function suggestedGasPrice() external view returns (uint256) {
        return oracleGasStation.suggestedGasPrice();
    }
}
