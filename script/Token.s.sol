// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {Token} from "../src/Token.sol";
import {ProxyAdmin} from "@openzeppelin/contracts/proxy/transparent/ProxyAdmin.sol";

// Deploy Token contract
contract Deploy is Script {
    uint256 public constant initialSupply = 1_000_000_000 ether;
    string public constant name = "Nexade";
    string public constant symbol = "NEXD";

    Token public token;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        address deployerAddress = vm.addr(deployerPrivateKey);

        // Deploy implementation and admin contracts
        token = Token(
            Upgrades.deployTransparentProxy(
                "Token.sol", deployerAddress, abi.encodeCall(Token.initialize, (name, symbol, initialSupply))
            )
        );

        console2.log("Proxied Token deployed at:", address(token));
        // log implementation address
        console2.log("Implementation deployed at:", Upgrades.getImplementationAddress(address(token)));
        // log proxy admin address
        console2.log("Proxy admin deployed at:", Upgrades.getAdminAddress(address(token)));
        // log proxy admin owner
        console2.log("ProxyAdmin Owner", ProxyAdmin(Upgrades.getAdminAddress(address(token))).owner());

        vm.stopBroadcast();
    }
}

contract Upgrade is Script {
    // change proxied Token address here before upgrading
    Token public token = Token(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512); 

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

        console2.log("Attempting to upgrade Token from address:", deployerAddress);

        vm.startBroadcast(deployerPrivateKey);
        console2.log("Previous implementation is located at:", Upgrades.getImplementationAddress(address(token)));

        Upgrades.upgradeProxy(address(token), "MockTokenV2.sol", "", deployerAddress);

        console2.log("New Implementation deployed at:", Upgrades.getImplementationAddress(address(token)));
        console2.log("New version is:", token.version());

        vm.stopBroadcast();
    }
}

contract TransferOwner is Script {
    // change proxied Token address here before upgrading
    Token public token = Token(0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512); 

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey);

	uint256 newDeployerPrivateKey = vm.envUint("NEW_PRIVATE_KEY");
	address newDeployerAddress = vm.addr(newDeployerPrivateKey);

        console2.log("Attempting to transfer Token ProxyAdmin ownership from address:", deployerAddress);

        vm.startBroadcast(deployerPrivateKey);
	console2.log("This operation should only succeed when using current owner key.");
        console2.log("Previous implementation is located at:", Upgrades.getImplementationAddress(address(token)));
	console2.log("ProxyAdmin is located at:", Upgrades.getAdminAddress(address(token)));
        ProxyAdmin proxyAdmin = ProxyAdmin(Upgrades.getAdminAddress(address(token)));

	console2.log("ProxyAdmin current owner location: ", proxyAdmin.owner());
	console2.log("ProxyAdmin aimed new owner location: ", newDeployerAddress);
	console2.log("ProxyAdmin attempting transferOwnership...");
	proxyAdmin.transferOwnership(newDeployerAddress);

	console2.log("ProxyAdmin current owner location after transfer attempt: ", proxyAdmin.owner());

        vm.stopBroadcast();
    }
}

