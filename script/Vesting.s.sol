// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";
import {Vesting} from "../src/Vesting.sol";

// Deploy Vesting contract
contract Deploy is Script {
    Vesting public vesting;

    // team vesting example
    address beneficiary = address(0x987);
    uint64 startTimestamp = uint64(block.timestamp); // start now
    uint64 cliffDuration = 9 * 30 days; // 9 month cliff
    uint64 totalDuration = 27 * 30 days; // 27 month duration

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // deploy Vesting contract
        vesting = new Vesting(beneficiary, startTimestamp, totalDuration, cliffDuration);

        vm.stopBroadcast();
    }
}
