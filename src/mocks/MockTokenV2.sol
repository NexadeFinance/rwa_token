// SPDX-License-Identifier: MIT
// FOR TESTING PURPOSES ONLY. DO NOT USE IN PRODUCTION.
pragma solidity ^0.8.20;

import "../Token.sol";

/// @custom:oz-upgrades-from Token
contract MockTokenV2 is Token {
    function version() public pure override returns (string memory) {
        return "2.0.0";
    }
}
