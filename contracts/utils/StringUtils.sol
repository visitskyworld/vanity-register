// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Library containing additional set of functions for working with strings.
 */
library StringUtils {
    /**
    * @dev Checks if a string matches a given alphabet
    * NOTE: This implementation is not optimal
    */
    function isAllowed(string memory str, string memory alphabet) internal pure
        returns (bool)
    {
        uint64 allowed = 0;
        bytes memory byteString = bytes(str);
        bytes memory byteAlphabet = bytes(alphabet);
        for (uint64 i = 0; i < byteString.length; i++) {
            for (uint64 j = 0; j < byteAlphabet.length; j++) {
                if (byteString[i] == byteAlphabet[j]) {
                    allowed++;
                }
            }
        }
        return allowed == byteString.length;
    }

    /**
    * @dev Сhecks the length of the string for compliance with the given one
    * NOTE: Suitable only for strings with ASCII characters, where one character equals one byte
    */
    function lengthIs(string memory str, uint256 len) internal pure
        returns (bool)
    {
        return bytes(str).length == len;
    }
}
