# TokenizedRegistrar

The **TokenizedRegistrar** is a smart contract designed to manage a specific parent name and assign subnames as **ERC721** NFTs.

1. Tokenization for Trade and Transfer: By tokenizing subnames as ERC721 tokens, this contract enables users to buy, sell, and transfer ownership of domain names easily. The ownership of a name can be transferred simply by transferring the corresponding NFT.

2. Direct Registry Updates on NFT: Unlike the default implementation of the baseRegistrar on Ethereum, where transferring ownership of an NFT does not automatically update the ENS registry, the **TokenizedRegistrar** automatically updates the registry when an NFT is transferred. This saves users the additional cost and effort of submitting a separate transaction to update ownership in the ENS registry.

3. Flexible Ownership and Minting Logic: The contract exposes no public methods for registering or minting names. Instead, it is designed to be extended by other contracts, allowing developers to define their own logic for setting ownership and minting subdomains. Whether the logic follows an Ownable pattern, a buyable model, or something else.
