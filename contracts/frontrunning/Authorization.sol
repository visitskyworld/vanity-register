// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Simplest authorization system to prevent frontrunning.
 * In fact, it does not completely solve the problem, but minimizes the chance of an attack
 * by hiding sensitive information with a hashing function.
 * It will not be profitable for an attacker to frontrun authorization,
 * because he does not know in advance what real data is hidden behind authorizations.
 * In addition, a spam counterattack can be implemented by authorizing a huge number of random messages,
 * obfuscating and overwhelming the attacker.
 *
 * Additional conditions can also be implemented in the form of locking the balance
 * and setting the authorization validity period.
 */
contract Authorization {
    mapping (bytes32 => address) tokens;

    modifier onlyAuthorized(string calldata message) {
        bytes32 digest = keccak256(abi.encodePacked(message));
        require(tokens[digest] == msg.sender, "Authorization: account not authorized for this message");
        _;
    }

    function authorize(bytes32 digest) external {
        tokens[digest] = msg.sender;
    }
}
