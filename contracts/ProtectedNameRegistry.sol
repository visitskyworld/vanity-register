// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NameRegistry.sol";
import "./oracles/LifespanFee.sol";
import "./frontrunning/Authorization.sol";

contract ProtectedNameRegistry is NameRegistry, Authorization {

    constructor(LifespanFee addrLifespanFee)
        NameRegistry (addrLifespanFee)
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
}
