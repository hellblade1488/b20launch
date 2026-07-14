# How B20 Launcher works

## The pieces

1. **B20 Factory precompile** — `0xB20f0000...0000`, same address on every Base network. Canonical, built into the chain itself. Single entry point:
   ```solidity
   createB20(uint8 variant, bytes32 salt, bytes params, bytes[] initCalls) returns (address token)
   ```
2. **B20LaunchPad** ([contracts/B20LaunchPad.sol](../contracts/B20LaunchPad.sol)) — a thin, verified pass-through contract. It calls the factory, emits an indexable `TokenLaunched(creator, token, variant, salt)` event, and nothing else. It holds **no roles and no access** to your token.
3. **The site** — one static HTML page. Builds the calldata in your browser, your wallet signs one transaction.

## What exactly gets sent

For an ASSET token the site ABI-encodes (validated byte-for-byte against the live factory):

```
params = abi.encode(B20AssetCreateParams{
  version: 1, name, symbol, initialAdmin: <your admin address>, decimals
})
```

Optional `initCalls`, executed by the factory on the new token inside the creation window:

- `grantRole(MINT_ROLE, admin)` — checked by default
- `grantRole(PAUSE_ROLE, admin)` + `grantRole(UNPAUSE_ROLE, admin)` — optional
- `updateSupplyCap(cap)` — when you set a cap
- `batchMint([admin], [initialSupply])` — when you set an initial supply

## Address derivation & salt

The factory derives the token address from `(variant, msg.sender, salt)`. The launchpad mixes your wallet address into the salt (`keccak256(creator ‖ salt)`), so nobody can occupy or front-run your token address.

## Trust model

- Your token's `DEFAULT_ADMIN_ROLE` goes to the address **you** put in the Admin field — granted directly by the factory, not by the launchpad.
- The launchpad cannot mint, pause, upgrade or touch your token after creation. Read the contract — it's ~100 lines.
- The site simulates the exact transaction (`eth_call`) before your wallet ever opens, so encoding errors cost you nothing.

## Roles cheat-sheet (bytes32 = keccak256 of the name)

| Role | Grants |
|---|---|
| `DEFAULT_ADMIN_ROLE` (`0x00`) | manage all roles, full control |
| `MINT_ROLE` | mint new supply |
| `BURN_ROLE` | burn |
| `PAUSE_ROLE` / `UNPAUSE_ROLE` | freeze / unfreeze transfers |
| `METADATA_ROLE` | update name / contractURI |
| `OPERATOR_ROLE` (ASSET) | batch issuance ops |

Full spec: [base-std](https://github.com/base/base-std) · [B20 docs](https://docs.base.org/get-started/launch-b20-token)
