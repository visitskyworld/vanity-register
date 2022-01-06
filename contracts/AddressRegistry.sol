// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RecordRegistry.sol";
import "./oracles/LifespanFee.sol";
import "./utils/StringUtils.sol";

/**
 * @dev Implementation of the address register, where the data is an Ethereum address without "0x"
 * consisting of 40 characters and corresponding to the HEX alphabet.
 * The record key is a hash of any string selected as a key.
 */
contract AddressRegistry is RecordRegistry {
    using StringUtils for string;

    string constant ADDR_ALPHABET = "0123456789ABCDEFabcdef";
    uint64 constant ADDR_LENGTH = 40;

    constructor(LifespanFee addrLifespanFee)
        RecordRegistry (addrLifespanFee)
    {
    }

    modifier onlyValidAddress(string calldata addr) {
        require(isAddressValid(addr), "AddressRegistry: the address is not valid");
        _;
    }

    function isAddressValid(string calldata addr) public pure
        returns (bool)
    {
        return addr.lengthIs(ADDR_LENGTH) && addr.isAllowed(ADDR_ALPHABET);
    }

    function getRecordLabel(string calldata name) public pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(name));
    }

    function isAddressExists(string calldata name) external view
        returns (bool)
    {
        return _isRecordExists(getRecordLabel(name));
    }

    function isAddressExpired(string calldata name) external view
        returns (bool)
    {
        return _isRecordExpired(getRecordLabel(name));
    }

    function estimateRegistrationFee(uint256 time) external view
        returns (uint256)
    {
        return oracleLifespanFee.estimate(ADDR_LENGTH, time);
    }

    function getAddress(string calldata name) external view
        returns (string memory)
    {
        return records[getRecordLabel(name)].data;
    }

    function registerAddress(string calldata name, string calldata addr) external payable
        onlyValidAddress(addr)
    {
        _registerRecord(getRecordLabel(name), msg.value, addr);
    }

    function clearExpiredAddress(string calldata name) external
    {
        Record memory record = _clearExpiredRecord(getRecordLabel(name));
        payable(record.owner).transfer(record.value);
    }

    function renewAddress(string calldata name) external
    {
        _renewRecord(getRecordLabel(name));
    }

    function transferAddressOwnership(string calldata name, address newOwner) external
    {
        _transferRecordOwnership(getRecordLabel(name), newOwner);
    }
}
