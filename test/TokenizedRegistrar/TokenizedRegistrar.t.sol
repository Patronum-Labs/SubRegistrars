// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "ens-contracts/contracts/registry/ENSRegistry.sol";
import "./mocks/TokenizedRegistrarMock.sol";
import "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

contract TokenizedRegistrarTest is Test {
    ENSRegistry public ensRegistry;
    TokenizedRegistrarMock public tokenizedRegistrar;

    bytes32 public constant ROOT_NODE = bytes32(0);
    address public constant TEST_OWNER = address(0x123);

    function setUp() public {
        // Deploy the ENS Registry
        ensRegistry = new ENSRegistry();

        // Deploy the TokenizedRegistrar with the ENS registry, root node, and test owner
        tokenizedRegistrar = new TokenizedRegistrarMock(
            address(ensRegistry),
            ROOT_NODE,
            address(this)
        );

        // Transfer ownership of the root node to the TokenizedRegistrar contract
        ensRegistry.setOwner(ROOT_NODE, address(tokenizedRegistrar));
    }

    function testRegisterName() public {
        // Register a subnode under the root node using the TokenizedRegistrar
        tokenizedRegistrar.registerName(
            "test",
            TEST_OWNER,
            address(this),
            86400
        );

        // Verify the subnode record in the ENS registry
        bytes32 label = keccak256(abi.encodePacked("test"));
        bytes32 subnode = keccak256(abi.encodePacked(ROOT_NODE, label));

        assertEq(ensRegistry.owner(subnode), TEST_OWNER);
        assertEq(ensRegistry.resolver(subnode), address(this));
        assertEq(ensRegistry.ttl(subnode), 86400);

        // Verify the ERC721 token was minted correctly
        uint256 tokenId = uint256(label);
        assertEq(tokenizedRegistrar.ownerOf(tokenId), TEST_OWNER);
    }

    function testRegisterNames() public {
        // Register multiple subnodes under the root node using the TokenizedRegistrar
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
        ttls[1] = 43200;

        tokenizedRegistrar.registerNames(names, owners, resolvers, ttls);

        for (uint256 i = 0; i < names.length; i++) {
            bytes32 label = keccak256(abi.encodePacked(names[i]));
            bytes32 subnode = keccak256(abi.encodePacked(ROOT_NODE, label));
            uint256 tokenId = uint256(label);

            assertEq(ensRegistry.owner(subnode), owners[i]);
            assertEq(ensRegistry.resolver(subnode), resolvers[i]);
            assertEq(ensRegistry.ttl(subnode), ttls[i]);

            assertEq(tokenizedRegistrar.ownerOf(tokenId), owners[i]);
        }
    }

    function testTransferUpdatesRegistry() public {
        // Register a subnode under the root node using the TokenizedRegistrar
        tokenizedRegistrar.registerName(
            "test",
            TEST_OWNER,
            address(this),
            86400
        );

        bytes32 label = keccak256(abi.encodePacked("test"));
        uint256 tokenId = uint256(label);
        bytes32 subnode = keccak256(abi.encodePacked(ROOT_NODE, label));

        // Transfer the token to a new owner
        address newOwner = address(0x456);
        vm.prank(TEST_OWNER);
        tokenizedRegistrar.transferFrom(TEST_OWNER, newOwner, tokenId);

        // Verify the ownership has been updated in the ENS registry
        assertEq(ensRegistry.owner(subnode), newOwner);
        assertEq(tokenizedRegistrar.ownerOf(tokenId), newOwner);
    }

    function testReRegisteringSubnameFails() public {
        // Register a subname under the root node using the TokenizedRegistrar
        tokenizedRegistrar.registerName(
            "test",
            TEST_OWNER,
            address(this),
            86400
        );

        // Attempt to re-register the same subname
        // vm.expectRevert("ERC721: token already minted");
        vm.expectRevert(
            abi.encodeWithSelector(
                IERC721Errors.ERC721InvalidSender.selector,
                address(0)
            )
        );
        tokenizedRegistrar.registerName(
            "test",
            TEST_OWNER,
            address(this),
            86400
        );
    }
}
