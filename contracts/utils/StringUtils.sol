// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library StringUtils {
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

    function lengthIs(string memory str, uint256 len) internal pure
        returns (bool)
    {
        return bytes(str).length == len;
    }
}
