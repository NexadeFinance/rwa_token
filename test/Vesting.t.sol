// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";
import {Vesting} from "../src/Vesting.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract VestingTest is Test {
    Token public token;

    // team vesting example
    uint64 startTimestamp = uint64(block.timestamp); // start now
    uint64 cliffDuration = 9 * 30 days; // 9 month cliff
    uint64 totalDuration = 27 * 30 days; // 27 month duration
    Vesting public vesting;

    address deployer;
    address beneficiary = address(0x987);

    function setUp() public {
        deployer = msg.sender;

        vm.startPrank(deployer);
        token = Token(
            Upgrades.deployTransparentProxy(
                "Token.sol", deployer, abi.encodeCall(Token.initialize, ("Nexade", "NEXD", 1_000_000_000 ether))
            )
        );

        vesting = new Vesting(beneficiary, startTimestamp, totalDuration, cliffDuration);

        // transfer 100 NEXD to vesting contract
        token.transfer(address(vesting), 100 ether);
        assertEq(token.balanceOf(address(vesting)), 100 ether);

        vm.stopPrank();
    }

    function test_Duration() public view {
        assertEq(vesting.duration(), totalDuration);
    }

    function test_End() public view {
        assertEq(vesting.end(), startTimestamp + totalDuration);
    }

    function test_Start() public view {
        assertEq(vesting.start(), startTimestamp);
    }

    function test_Cliff() public view {
        assertEq(vesting.cliff(), startTimestamp + cliffDuration);
    }

    function test_Relesable_And_Release() public {
        assertEq(vesting.releasable(address(token)), 0);

        vesting.release(address(token)); // try to release the tokens before cliff
        assertEq(token.balanceOf(beneficiary), 0); // nothing in beneficiary wallet yet


        // advance time to 3 months - has not passed cliff yet
        vm.warp(block.timestamp + 3 * 30 days);
        assertEq(vesting.releasable(address(token)), 0);
        assertEq(vesting.released(address(token)), 0);

        // advance time to 6 months - 1 day - has not passed cliff yet
        vm.warp(block.timestamp + 6 * 30 days - 1 days);
        assertEq(vesting.releasable(address(token)), 0);
        assertEq(vesting.released(address(token)), 0);

        // we are now 9 months later. cliff has passed we should unlock 1/3 of the tokens 9/27
        vm.warp(block.timestamp + 1 days);
        assertGt(vesting.releasable(address(token)), 0); // > 0
        assertEq(vesting.releasable(address(token)), 33.333333333333333333 ether); // == 1/3 of vesting
        assertEq(vesting.released(address(token)), 0); // nothing released yet
        assertEq(token.balanceOf(beneficiary), 0); // nothing in beneficiary wallet yet

        // release the tokens
        vesting.release(address(token));
        assertEq(token.balanceOf(beneficiary), 33.333333333333333333 ether);
        assertEq(vesting.released(address(token)), 33.333333333333333333 ether);

        // advance time to 9 + 9 months we should have 2/3 of the tokens unlocked
        vm.warp(block.timestamp + 9 * 30 days);
        assertGt(vesting.releasable(address(token)), 0); // > 0
        assertEq(vesting.releasable(address(token)), 33.333333333333333333 ether); // == second third of vesting
        assertEq(vesting.released(address(token)), 33.333333333333333333 ether); // 1/3 released
        assertEq(token.balanceOf(beneficiary), 33.333333333333333333 ether); // 1/3 released

        // release the tokens
        vesting.release(address(token));
        assertEq(token.balanceOf(beneficiary), 66.666666666666666666 ether);
        assertEq(vesting.released(address(token)), 66.666666666666666666 ether);

        // advance time to 9 + 9 + 9 months = total duration  we should have all tokens unlocked
        vm.warp(block.timestamp + 9 * 30 days);
        assertGt(vesting.releasable(address(token)), 0); // > 0
        assertEq(vesting.releasable(address(token)), 33.333333333333333334 ether); // == third third of vesting
        assertEq(vesting.released(address(token)), 66.666666666666666666 ether); // 2/3 released
        assertEq(token.balanceOf(beneficiary), 66.666666666666666666 ether); // 2/3 released

        // release the tokens
        vesting.release(address(token));
        assertEq(token.balanceOf(beneficiary), 100 ether); // all tokens released
        assertEq(token.balanceOf(address(vesting)), 0); // no tokens left in vesting contract
        assertEq(vesting.released(address(token)), 100 ether); // all tokens released
    }
}
