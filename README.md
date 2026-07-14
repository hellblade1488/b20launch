# B20 Launcher

**Deploy your own B20 token on Base in one transaction. No CLI, no Foundry, no Solidity.**

Live: [b20launch.com](https://b20launch.com) *(coming soon)*

## What is this?

[B20](https://docs.base.org/get-started/launch-b20-token) is Base's native token standard — an ERC-20 superset implemented as a precompile (launched in the Beryl upgrade). It's cheaper and faster than a regular ERC-20 contract and ships with built-in roles, supply caps, pausing, memos and permit.

Deploying one today requires `base-foundryup`, `base-forge`, a Solidity script and an `.env` file. **B20 Launcher replaces all of that with a form.**

- Connect your wallet (MetaMask / Rabby / Coinbase Wallet)
- Fill in name, symbol, decimals, supply cap
- Click **Launch** — one transaction, your token is live

Supports both B20 variants:

| | ASSET | STABLECOIN |
|---|---|---|
| Decimals | configurable 6–18 | fixed 6 |
| Extra | multiplier, batch issuance | immutable ISO currency code |

## How it works

The site is a single static page (no backend). Your wallet sends one transaction to the `B20LaunchPad` contract, which calls the canonical B20 Factory precompile at `0xB20f0000...0000`. You are the token's admin — the launcher keeps no roles and no access.

See [docs/how-it-works.md](docs/how-it-works.md) for the technical details.

## Deployments

| Network | B20LaunchPad |
|---|---|
| Base Sepolia | [`0xD29C661d881fA901C6f0a00F56Afb9Ca86b62f90`](https://sepolia.basescan.org/address/0xD29C661d881fA901C6f0a00F56Afb9Ca86b62f90) |
| Base Mainnet | *(pending)* |

## Stack

Single-file HTML + [ethers.js v6](https://docs.ethers.org/v6/) (vendored). No bundlers, no `node_modules`, no backend. Clone and open — that's the whole build process.

## License

[MIT](LICENSE)
