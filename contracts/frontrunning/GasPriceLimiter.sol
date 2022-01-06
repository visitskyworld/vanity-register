// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../oracles/GasStation.sol";

/**
 * @dev This limits attackers from seeking preferential treatment from miners due to the higher gas price.
 * The problem here is that such a solution must be constantly maintained as the gas price is very volatile.
 * Therefore, it makes sense to use this solution together with an GasStation Oracle,
 * the relevance of the values of which will be supported by the interested community.
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
