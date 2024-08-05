// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../../src/TokenizedRegistrar/TokenizedRegistrar.sol";

contract TokenizedRegistrarMock is TokenizedRegistrar {
    constructor(
        address _ensRegistry,
        bytes32 _nameHash,
        address initialOwner
    ) TokenizedRegistrar(_ensRegistry, _nameHash, initialOwner) {}

    function registerName(
        string memory name,
        address owner_,
        address resolver_,
        uint64 ttl_
    ) public {
        _registerName(name, owner_, resolver_, ttl_);
    }

    function registerNames(
        string[] calldata names,
        address[] calldata owners,
        address[] calldata resolvers,
        uint64[] calldata ttls
    ) public {
        _registerNames(names, owners, resolvers, ttls);
    }
}
