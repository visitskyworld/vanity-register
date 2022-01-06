// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./3dparty/SafeMath.sol";
import "./oracles/LifespanFee.sol";

/**
 * @dev The basic contract of a records register, where the key is a 32-byte digest and the value
 * is an object with the characteristics of this record and string data. To register a record,
 * you need pass the record label, balance to lock, and data as a string. The lifespan is calculated
 * according to the rules specified in the LifespanFee Oracle and directly depends on the
 * size of the data and the locked balance. After the expiration of the record lifespan,
 * it can be renewed and the balance will be left locked.
 */
abstract contract RecordRegistry {
    /**
     * NOTE: Since Solidity 0.8 `SafeMath` is not necessary,
     * but is left for backward compatibility when deploying
     * with a different compiler version.
     */
    using SafeMath for uint256;

    struct Record {
        address owner;
        uint256 value;
        uint256 timestamp;
        uint256 lifespan;
        string data;
    }

    event RecordOwnershipTransferred(bytes32 indexed label, address indexed oldOwner, address indexed newOwner);
    event NewRecordRegistered(bytes32 indexed label, address indexed owner, uint256 expires);
    event RecordRenewed(bytes32 indexed label, address indexed owner, uint256 expires);
    event ExpiredRecordCleared(bytes32 indexed label, address indexed owner, address indexed cleaner);

    LifespanFee public oracleLifespanFee;
    mapping (bytes32 => Record) public records;
    uint256 public renewThreshold = 20 seconds; // hardcoded for a given implementation

    constructor(LifespanFee addrLifespanFee)
    {
        oracleLifespanFee = addrLifespanFee;
    }

    modifier onlyExistingRecord (bytes32 label) {
        require(_isRecordExists(label), "RecordRegistry: the record does not exist");
        _;
    }

    modifier onlyRecordOwner(bytes32 label) {
        require(records[label].owner == msg.sender, "RecordRegistry: the caller is not the owner of the record");
        _;
    }

    function _isRecordExists(bytes32 label) internal view
        returns (bool)
    {
        return records[label].lifespan > 0;
    }

    function _isRecordExpired(bytes32 label) internal view
        returns (bool)
    {
        // NOTE: There is no need to check if a record exists, a nonexistent record is equal to an expired record.
        Record memory record = records[label];
        uint256 expires = record.timestamp.add(record.lifespan);
        return block.timestamp > expires;
    }

    function _registerRecord(bytes32 label, uint256 value, string calldata data) internal
    {
        if (_isRecordExists(label)) {
            _clearExpiredRecord(label);
        }

        uint256 length = bytes(data).length;
        uint256 lifespan = oracleLifespanFee.lifespan(length, value);
        require(lifespan > 0, "RecordRegistry: insufficient funds transferred, record lifespan is zero");

        Record storage record = records[label];
        record.owner = msg.sender;
        record.value = value;
        record.timestamp = block.timestamp;
        record.lifespan = lifespan;
        record.data = data;

        emit NewRecordRegistered(label, record.owner, record.timestamp.add(record.lifespan));
    }

    /**
     * Anyone can clear the expired record, the locked balance will be returned to the owner of the record.
     */
    function _clearExpiredRecord(bytes32 label) internal
        onlyExistingRecord(label)
        returns (Record memory)
    {
        require(_isRecordExpired(label), "RecordRegistry: the record has not expired yet");

        Record memory record = records[label];
        delete records[label];
        emit ExpiredRecordCleared(label, record.owner, msg.sender);

        return record;
    }

    function _renewRecord(bytes32 label) internal
        onlyExistingRecord(label)
        onlyRecordOwner(label)
    {
        // Here is the simplest implementation to allow the owner of a record to renew it shortly before it expires.
        // NOTE: Here the threshold is hardcoded as a contract field,
        // but it can be placed in a separate contract where its value can be controlled,
        // for example, using a DAO.
        Record storage record = records[label];
        uint256 expiresSoon = record.timestamp.add(record.lifespan).sub(renewThreshold);
        require(block.timestamp > expiresSoon, "RecordRegistry: the record cannot be renewed yet");

        record.timestamp = block.timestamp;

        emit RecordRenewed(label, record.owner, record.timestamp.add(record.lifespan));
    }

    /**
     * Upon transfer of ownership, the new owner also claims the balance that was originally locked.
     */
    function _transferRecordOwnership(bytes32 label, address newOwner) internal
        onlyExistingRecord(label)
        onlyRecordOwner(label)
    {
        require(newOwner != address(0), "RecordRegistry: new owner is the zero address");

        address oldOwner = records[label].owner;
        records[label].owner = newOwner;

        emit RecordOwnershipTransferred(label, oldOwner, newOwner);
    }
}
