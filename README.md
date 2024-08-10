# ENS Registrars

This repository contains a set of **Registrar** contracts designed for managing and assigning subnames under specific domains like `.eth` or `.protocol.eth`. These Registrars are responsible for creating and maintaining subnames such as `0xYamen.eth` or `0xYamen.protocol.eth`.

## Overview

Registrars are versatile contracts that can be tailored to different naming conventions and subdomains. For example, a domain like `protocol.eth` can have a dedicated Registrar that manages the registration of subnames like `name.protocol.eth`. The flexibility of these Registrars allows for various implementations where each protocol implements custom logic for assigning subnames, ensuring that different use cases and requirements can be met.

## Available Registrars

- **TokenizedRegistrar**: A Registrar that tokenizes the subnames, making them transferrable and sellable as ERC721 tokens.
- **OwnableRegistrar**: A Registrar where only the owner has the authority to assign subnames.

More Registrars are being developed and will be available soon.

## Installation

To install and set up the ENS Registrars in your project, follow these steps:

1. Clone the repository:
```sh
$ git clone https://github.com/Patronum-Labs/ens-registrars.git
```

2. Navigate to the project directory:

```sh
$ cd ens-registrars
```

3. Install the dependencies:

```sh
$ forge install
```

4. Build the contracts:

```sh
$ forge build
```

5. Run the tests:

```sh
$ forge test
```

## Contributing

Contributions are welcome! If you have ideas for new Registrars or improvements to existing ones, feel free to submit a Pull Request.

## License

This project is licensed under the [MIT License](LICENSE).
