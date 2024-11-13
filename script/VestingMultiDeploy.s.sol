// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";
import {Vesting} from "../src/Vesting.sol";

/* **
    * @title Deployment Script for Nexade Vesting Contract
    * @dev Network: Arbitrum (RPC set in foundry config)
    * Script reads data from vestingConfig.csv and deploys a Nexade Vesting Contract for each entry in the data
    * Outputs the beneficiary address and the deployed contract address to vestingOutput.csv
    * to run: forge script script/Deployment.s.sol:Deploy --broadcast --verify -vvvv
*/

contract Deploy is Script {
    function run() public {

        string memory inputFile = vm.readFile("./script/files/vestingConfig.csv");
        string[] memory inputLines = vm.split(inputFile, "\r\n");

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        for (uint i = 0; i < inputLines.length; i++) {
            string[] memory fields = vm.split(inputLines[i], ",");

            /// @dev Deploy the Vesting contract
            Vesting vesting = new Vesting(
                vm.parseAddress(fields[0]),      // beneficiary
                uint64(vm.parseUint(fields[1])), // startTimestamp
                uint64(vm.parseUint(fields[2])), // durationSeconds
                uint64(vm.parseUint(fields[3]))  // cliffSeconds
            );
            /// @dev save outputs to a csv file
            string memory outputLine = string.concat(fields[0], ",", vm.toString(address(vesting)));
            vm.writeLine("./script/files/vestingOutput.csv", outputLine);

            console2.log("Vesting contract deployed:", address(vesting));
            console2.log("Vesting contract beneficiary:",fields[0]);
            console2.log("Vesting contract startTimestamp:",fields[1]);
            console2.log("Vesting contract durationSeconds:",fields[2]);
            console2.log("Vesting contract cliffSeconds:",fields[3]);
            console2.log("-----------------------------------");
        }

        vm.stopBroadcast();
    
    }
}
