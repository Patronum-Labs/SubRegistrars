# OwnableRegistrar

The **OwnableRegistrar** is a smart contract designed to manage a specific parent name and assign subnames.

1. No Point in Restricting Subdomain Ownership Changes: Given that the ownership of the parent name can be reassigned to a new owner, there is no utility in restricting the ability to change the owner of individual subdomains. The new registrar can inherently gains control over all subdomain logic and ownership.

2. Designed for On-Chain, Not Large Applications: This contract is not intended for large-scale applications that might benefit from off-chain resolution. It operates entirely on-chain, making it suitable for use cases that require on-chain visibility and management.

3. Importance of Emitting the Name: The ENS system is heavily reliant on hashed values for names (labelhashes). By emitting events with the plain text name alongside the labelhash, the contract makes it easier to index and discover activities related to specific names.
