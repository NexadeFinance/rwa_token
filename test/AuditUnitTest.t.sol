// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";
import {Vesting} from "../src/Vesting.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract AuditUnitTest is Test {
    Token public token;
    Vesting public vesting;

    address deployer;
    address beneficiary = address(0x987);

    //using deploy instead of setup so that each unit test has its own deployment
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

    // if cliff is 0
    function test_cliffIsZero() public {
        uint64 startTime = uint64(block.timestamp); // start now
        uint64 cliffDuration = 0; // 0 month cliff
        uint64 totalDuration = 27 * 30 days; // 27 month duration,
        uint256 amount = 100 ether;
        Deploy(startTime, cliffDuration, totalDuration, amount);
        vm.startPrank(deployer);
        vm.warp(block.timestamp + 27 * 30 days);
        assertEq(
            vesting.vestedAmount(
                address(token),
                (uint64(block.timestamp) + totalDuration + 1 days)
            ),
            amount
        );
        assertEq(vesting.releasable(address(token)), amount);
        vesting.release(address(token));
        assertEq(token.balanceOf(beneficiary), amount);
        vm.stopPrank();
    }

    //try deploying with startTime in the past
    function test_DeployAfterStartTime() public {
        vm.warp(block.timestamp + 27 * 30 days);
        uint64 startTime = uint64(block.timestamp - 30 days); // start 30 days ago
        uint64 cliffDuration = 3;
        uint64 totalDuration = 27 * 30 days; // 27 month duration,
        uint256 amount = 100 ether;
        Deploy(startTime, cliffDuration, totalDuration, amount);
        vm.startPrank(deployer);
        vm.warp(block.timestamp + 26 * 30 days);
        assertEq(
            vesting.vestedAmount(
                address(token),
                (uint64(block.timestamp) + totalDuration + 1 days)
            ),
            amount
        );
        assertEq(vesting.releasable(address(token)), amount);
        vesting.release(address(token));
        assertEq(token.balanceOf(beneficiary), amount);
        vm.stopPrank();
    }

    // fuzz on invariant vestedAmount == releasable + released any ang given time
    function testFuzzVestedAmount(uint64 _time) public {
        uint64 startTime = uint64(block.timestamp);
        uint64 cliffDuration = 13;
        uint64 totalDuration = 59 * 30 days; 
        uint256 amount = 10000 ether;
        vm.assume(_time >= startTime && _time <= startTime + totalDuration); // start 30 days ago
        Deploy(startTime, cliffDuration, totalDuration, amount);
        vm.warp(_time);
        vesting.release(address(token));
        assertEq(
            vesting.vestedAmount(address(token), uint64(block.timestamp)),
            vesting.releasable(address(token)) + token.balanceOf(beneficiary)
        );
    }

    // multi release fuzz test
    function testFuzzMultiWithdraw(uint64 _time) public {
        uint64 startTime = uint64(block.timestamp);
        uint64 cliffDuration = 1;
        uint64 totalDuration = 3 * 30 days;
        uint64 endTime = startTime + totalDuration;
        uint256 amount = 10000 ether;
        vm.assume(_time > 3600 && _time <= 10 days); // time between 1 hour and 10 days
        Deploy(startTime, cliffDuration, totalDuration, amount);
        //Loop while increasing time by _time and release funds at random times until vesting windows ends.
        while (block.timestamp <= endTime) {
            vm.warp(block.timestamp + _time);
            vesting.release(address(token));
            assertEq(
                vesting.vestedAmount(address(token), uint64(block.timestamp)),
                vesting.releasable(address(token)) +
                    token.balanceOf(beneficiary)
            );
        }
        vm.warp(endTime + 1 days);
        vesting.release(address(token));
        assertEq(token.balanceOf(beneficiary), amount);
    }

    function testMaxDuration() public {
        uint64 startTime = uint64(block.timestamp);
        uint64 cliffDuration = 1;
        uint64 totalDuration = 61 * 30 days; // 5 years
        uint256 amount = 10000 ether;
        vm.expectRevert(); // We expect this to revert because the duration is too long
        vesting = new Vesting(
            beneficiary,
            startTime,
            totalDuration,
            cliffDuration
        );
        
    }
}
