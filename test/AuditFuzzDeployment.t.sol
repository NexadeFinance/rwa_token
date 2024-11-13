// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";
import {Vesting} from "../src/Vesting.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract AuditFuzzDeployment is Test {
    Token public token;
    Vesting public vesting;

    address deployer;
    address beneficiary = address(0x987);

    function Deploy(
        uint64 startTimestamp,
        uint64 cliffDuration,
        uint64 totalDuration,
        uint256 amount
    ) public {

        deployer = msg.sender;
        vm.startPrank(deployer);

        token = Token(
            Upgrades.deployTransparentProxy(
                "Token.sol",
                deployer,
                abi.encodeCall(
                    Token.initialize,
                    ("Nexade", "NEXD", 1_000_000_000 ether)
                )
            )
        );

        vesting = new Vesting(
            beneficiary,
            startTimestamp,
            totalDuration,
            cliffDuration
        );

        // transfer 100 NEXD to vesting contract
        token.transfer(address(vesting), amount);
        assertEq(token.balanceOf(address(vesting)), amount);

        vm.stopPrank();
    }

    // fuzz test deployment
    function test_StartTimeInPassed(
        uint64 _cliffDuration,
        uint64 _totalDuration,
        uint256 _amount
    ) public {
        vm.assume(_cliffDuration < _totalDuration);
        vm.assume(_totalDuration < 60 * 30 days); //MAX DURATION = 5 years
        vm.assume(_amount <= 1_000_000_000 ether);
        vm.warp(90 * 1 days);
        vm.assume(_totalDuration < type(uint64).max - uint64(block.timestamp));
        Deploy(
            uint64(block.timestamp - 1 days),
            _cliffDuration,
            _totalDuration,
            _amount
        );
        uint256 amount = vesting.vestedAmount(
            address(token),
            (uint64(block.timestamp) + _totalDuration + 1 days)
        );
        assertEq(amount, _amount);
    }
}
