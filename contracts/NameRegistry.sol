// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RecordRegistry.sol";
import "./oracles/LifespanFee.sol";

/**
 * @dev The simplest application implementation of the name registry,
 * where data is any string value and the record key - the hash of this data.
 */
contract NameRegistry is RecordRegistry {

    constructor(LifespanFee addrLifespanFee)
        RecordRegistry (addrLifespanFee)
    {
    }

    function getRecordLabel(string calldata name) public pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(name));
    }

    function isNameExists(string calldata name) external view
        returns (bool)
    {
        return _isRecordExists(getRecordLabel(name));
    }

    function isNameExpired(string calldata name) external view
        returns (bool)
    {
        return _isRecordExpired(getRecordLabel(name));
    }

    function estimateRegistrationFee(string calldata name, uint256 time) external view
        returns (uint256)
    {
        uint256 length = bytes(name).length;
        return oracleLifespanFee.estimate(length, time);
    }

    function registerName(string calldata name) virtual external payable
    {
        _registerRecord(getRecordLabel(name), msg.value, name);
    }

    function clearExpiredName(string calldata name) external
    {
        Record memory record = _clearExpiredRecord(getRecordLabel(name));
        payable(record.owner).transfer(record.value);
    }

    function renewName(string calldata name) external
    {
        _renewRecord(getRecordLabel(name));
    }

    function transferNameOwnership(string calldata name, address newOwner) external
    {
        _transferRecordOwnership(getRecordLabel(name), newOwner);
    }
}
