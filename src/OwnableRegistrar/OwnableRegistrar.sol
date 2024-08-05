// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ENS as IENS} from "ens-contracts/contracts/registry/ENS.sol";

contract OwnableRegistrar is Ownable {
    /// @notice Emitted when a subname is registered.
    /// @param name The label of the subname.
    /// @param label The keccak256 hash of the subname.
    /// @param owner The address of the owner of the subname.
    /// @param resolver The address of the resolver for the subname.
    /// @param ttl The time-to-live (TTL) value for the subname.
    event SubnameRegistered(
        string name,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    );

    /// @notice Error thrown when the lengths of the input arrays do not match.
    error ArraysLengthMismatch();

    /// @notice Error thrown when an empty array is provided.
    error EmptyArrayProvided();

    /// @notice The namehash of the parent name.
    bytes32 public immutable nameHash;

    /// @notice Address of the ENS Registry.
    address public immutable ensRegistry;

    /// @param _ensRegistry Address of the ENS Registry contract.
    /// @param _nameHash The namehash of the parent name.
    /// @param initialOwner The initial owner of the contract.
    constructor(
        address _ensRegistry,
        bytes32 _nameHash,
        address initialOwner
    ) Ownable(initialOwner) {
        ensRegistry = _ensRegistry;
        nameHash = _nameHash;
    }

    /// @notice Set the owner, resolver, and TTL of the name.
    /// @param owner_ The address to set as the owner of the name.
    /// @param resolver_ The address of the resolver for the name.
    /// @param ttl_ The time-to-live (TTL) value for the name.
    function setRecord(
        address owner_,
        address resolver_,
        uint64 ttl_
    ) public onlyOwner {
        IENS(ensRegistry).setRecord(nameHash, owner_, resolver_, ttl_);
    }

    /// @notice Set the owner of the name.
    /// @param owner_ The address to set as the owner of the name.
    function setOwner(address owner_) public onlyOwner {
        IENS(ensRegistry).setOwner(nameHash, owner_);
    }

    /// @notice Set the resolver of the name.
    /// @param _resolver The address of the resolver for the name.
    function setResolver(address _resolver) public onlyOwner {
        IENS(ensRegistry).setResolver(nameHash, _resolver);
    }

    /// @notice Set the TTL of the name.
    /// @param _ttl The time-to-live (TTL) value for the name.
    function setTTL(uint64 _ttl) public onlyOwner {
        IENS(ensRegistry).setTTL(nameHash, _ttl);
    }

    /// @notice Register a subname under the parent name.
    /// @param name The label of the subname to be registered.
    /// @param owner_ The address to set as the owner of the subname.
    /// @param resolver_ The address of the resolver for the subname.
    /// @param ttl_ The time-to-live (TTL) value for the subname.
    function registerName(
        string memory name,
        address owner_,
        address resolver_,
        uint64 ttl_
    ) public onlyOwner {
        _registerName(name, owner_, resolver_, ttl_);
    }

    /// @notice Register multiple subnames under the parent name.
    /// @param names An array of labels for the subnames to be registered.
    /// @param owners An array of addresses to set as the owners of the subnames.
    /// @param resolvers An array of addresses of the resolvers for the subnames.
    /// @param ttls An array of TTL values for the subnames.
    function registerNames(
        string[] calldata names,
        address[] calldata owners,
        address[] calldata resolvers,
        uint64[] calldata ttls
    ) public onlyOwner {
        if (
            names.length != owners.length ||
            names.length != resolvers.length ||
            names.length != ttls.length
        ) {
            revert ArraysLengthMismatch();
        }

        if (names.length == 0) {
            revert EmptyArrayProvided();
        }

        for (uint256 i = 0; i < names.length; i++) {
            _registerName(names[i], owners[i], resolvers[i], ttls[i]);
        }
    }

    /// @notice Register a subname under the parent name.
    /// @param name The label of the subname to be registered.
    /// @param owner_ The address to set as the owner of the subname.
    /// @param resolver_ The address of the resolver for the subname.
    /// @param ttl_ The time-to-live (TTL) value for the subname.
    function _registerName(
        string memory name,
        address owner_,
        address resolver_,
        uint64 ttl_
    ) internal {
        bytes32 label = keccak256(abi.encodePacked(name));

        IENS(ensRegistry).setSubnodeRecord(
            nameHash,
            label,
            owner_,
            resolver_,
            ttl_
        );

        emit SubnameRegistered(name, label, owner_, resolver_, ttl_);
    }
}
