// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {ENSRegistry} from "ens-contracts/contracts/registry/ENSRegistry.sol";
import {OwnableRegistrar} from "../src/OwnableRegistrar/OwnableRegistrar.sol";

contract OwnableRegistrarTest is Test {
    ENSRegistry public ensRegistry;
    OwnableRegistrar public ownableRegistrar;

    bytes32 public constant ROOT_NODE = bytes32(0);

    address public constant TEST_OWNER = address(0x123);

    function setUp() public {
        // Deploy the ENS Registry
        ensRegistry = new ENSRegistry();

        // Deploy the OwnableRegistrar with the ENS registry, root node, and test owner
        ownableRegistrar = new OwnableRegistrar(
            address(ensRegistry),
            ROOT_NODE,
            address(this)
        );

        // Transfer ownership of the root node to the OwnableRegistrar contract
        ensRegistry.setOwner(ROOT_NODE, address(ownableRegistrar));
    }

    function testSetRecord() public {
        // Set a new owner, resolver, and TTL for the root node using the OwnableRegistrar
        ownableRegistrar.setRecord(TEST_OWNER, address(this), 86400);

        // Verify the changes in the ENS registry
        assertEq(ensRegistry.owner(ROOT_NODE), TEST_OWNER);
        assertEq(ensRegistry.resolver(ROOT_NODE), address(this));
        assertEq(ensRegistry.ttl(ROOT_NODE), 86400);
    }

    function testSetOwner() public {
        // Set a new owner for the root node using the OwnableRegistrar
        ownableRegistrar.setOwner(TEST_OWNER);

        // Verify the owner has been updated in the ENS registry
        assertEq(ensRegistry.owner(ROOT_NODE), TEST_OWNER);
    }

    function testSetResolver() public {
        // Set a new resolver for the root node using the OwnableRegistrar
        ownableRegistrar.setResolver(address(this));

        // Verify the resolver has been updated in the ENS registry
        assertEq(ensRegistry.resolver(ROOT_NODE), address(this));
    }

    function testSetTTL() public {
        // Set a new TTL for the root node using the OwnableRegistrar
        ownableRegistrar.setTTL(86400);

        // Verify the TTL has been updated in the ENS registry
        assertEq(ensRegistry.ttl(ROOT_NODE), 86400);
    }

    function testRegisterName() public {
        // Register a subnode under the root node using the OwnableRegistrar
        ownableRegistrar.registerName("test", TEST_OWNER, address(this), 86400);

        // Verify the subnode record in the ENS registry
        bytes32 label = keccak256(abi.encodePacked("test"));
        bytes32 subnode = keccak256(abi.encodePacked(ROOT_NODE, label));

        assertEq(ensRegistry.owner(subnode), TEST_OWNER);
        assertEq(ensRegistry.resolver(subnode), address(this));
        assertEq(ensRegistry.ttl(subnode), 86400);
    }

    function testReassignName() public {
        // Register a subnode under the root node using the OwnableRegistrar
        ownableRegistrar.registerName("test", TEST_OWNER, address(this), 86400);

        // Verify the subnode record in the ENS registry
        bytes32 label = keccak256(abi.encodePacked("test"));
        bytes32 subnode = keccak256(abi.encodePacked(ROOT_NODE, label));

        assertEq(ensRegistry.owner(subnode), TEST_OWNER);

        // Reassign the subnode to a new owner
        address newOwner = address(0x456);
        ownableRegistrar.registerName("test", newOwner, address(this), 86400);

        // Verify the subnode owner has been updated in the ENS registry
        assertEq(ensRegistry.owner(subnode), newOwner);
    }

    function testRegisterNamesWithEmptyArrays() public {
        string[] memory names;
        address[] memory owners;
        address[] memory resolvers;
        uint64[] memory ttls;

        vm.expectRevert(OwnableRegistrar.EmptyArrayProvided.selector);
        ownableRegistrar.registerNames(names, owners, resolvers, ttls);
    }

    function testRegisterNamesWithArrayLengthMismatch() public {
        string[] memory names = new string[](2);
        names[0] = "test1";

        address[] memory owners = new address[](1);
        owners[0] = TEST_OWNER;

        address[] memory resolvers = new address[](1);
        resolvers[0] = address(this);

        uint64[] memory ttls = new uint64[](1);
        ttls[0] = 86400;

        vm.expectRevert(OwnableRegistrar.ArraysLengthMismatch.selector);
        ownableRegistrar.registerNames(names, owners, resolvers, ttls);
    }

    function testRegisterNames() public {
        // Register multiple subnodes under the root node using the OwnableRegistrar
        string[] memory names = new string[](2);
        names[0] = "test1";
        names[1] = "test2";

        address[] memory owners = new address[](2);
        owners[0] = TEST_OWNER;
        owners[1] = TEST_OWNER;

        address[] memory resolvers = new address[](2);
        resolvers[0] = address(this);
        resolvers[1] = address(this);

        uint64[] memory ttls = new uint64[](2);
        ttls[0] = 86400;
        ttls[1] = 86400;

        ownableRegistrar.registerNames(names, owners, resolvers, ttls);

        // Verify the subnode records in the ENS registry
        for (uint256 i = 0; i < names.length; i++) {
            bytes32 label = keccak256(abi.encodePacked(names[i]));
            bytes32 subnode = keccak256(abi.encodePacked(ROOT_NODE, label));

            assertEq(ensRegistry.owner(subnode), owners[i]);
            assertEq(ensRegistry.resolver(subnode), resolvers[i]);
            assertEq(ensRegistry.ttl(subnode), ttls[i]);
        }
    }
}
