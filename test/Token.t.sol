// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Token} from "../src/Token.sol";
import {MockTokenV2} from "../src/mocks/MockTokenV2.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

contract TokenTest is Test {
    uint256 public constant initialSupply = 1_000_000_000 ether;
    string public constant name = "Nexade";
    string public constant symbol = "NEX";

    Token public token;
    address deployer;

    address newOwner;

    function setUp() public {
        deployer = msg.sender;

        // new owner for testing
        newOwner = address(0x456);

        console2.log("Deployer address:", deployer);

        // Deploy implementation and admin contracts
        vm.startPrank(deployer);
        token = Token(
            Upgrades.deployTransparentProxy(
                "Token.sol", deployer, abi.encodeCall(Token.initialize, (name, symbol, initialSupply))
            )
        );

        vm.stopPrank();

        // console2.log("Proxied Token deployed at:", address(token));
        // // log implementation address
        // console2.log("Implementation deployed at:", Upgrades.getImplementationAddress(address(token)));
        // // log proxy admin address
        // console2.log("Proxy admin deployed at:", Upgrades.getAdminAddress(address(token)));
        // // log proxy admin owner
        // console2.log("ProxyAdmin Owner", ProxyAdmin(Upgrades.getAdminAddress(address(token))).owner());
        // // log token owner
        // console2.log("Token Owner", token.owner());
    }

    function test_Name() public view {
        assertEq(token.name(), "Nexade");
    }

    function test_Version() public view {
        assertEq(token.version(), "1.0.0");
    }

    function test_TotalSupply() public view {
        assertEq(token.totalSupply(), initialSupply);
    }

    function test_Decimals() public view {
        assertEq(token.decimals(), 18);
    }

    function test_Burn(uint256 amountToBurn) public {
        vm.startPrank(deployer);

        assertEq(token.totalSupply(), initialSupply);
        assertEq(token.balanceOf(deployer), initialSupply);

        vm.assume(amountToBurn <= initialSupply);
        vm.assume(amountToBurn <= token.balanceOf(deployer));
        token.burn(amountToBurn);

        assertEq(token.totalSupply(), initialSupply - amountToBurn);
        assertEq(token.balanceOf(deployer), initialSupply - amountToBurn);

        vm.stopPrank();
    }

    function test_Upgrade() public {
        console2.log(msg.sender);

        Upgrades.upgradeProxy(address(token), "MockTokenV2.sol", "", deployer);

        assertEq(token.version(), "2.0.0");
    }
}
