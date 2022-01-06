// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NameRegistry.sol";
import "./oracles/LifespanFee.sol";
import "./frontrunning/Authorization.sol";
import "./frontrunning/GasPriceLimiter.sol";

contract ProtectedNameRegistry is NameRegistry, Authorization, GasPriceLimiter {

    constructor(LifespanFee addrLifespanFee, GasStation addrGasStation)
        NameRegistry (addrLifespanFee)
        GasPriceLimiter (addrGasStation)
    {
    }

    function registerName(string calldata) override external payable
    {
        revert("ProtectedNameRegistry: use protected functions");
    }

    function authorizedRegisterName(string calldata name) external payable
        onlyAuthorized(name)
    {
        _registerRecord(getRecordLabel(name), msg.value, name);
    }

    function throttledRegisterName(string calldata name) external payable
        gasThrottled
    {
        _registerRecord(getRecordLabel(name), msg.value, name);
    }
}
