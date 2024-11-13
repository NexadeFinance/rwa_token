## Nexade Token

Contracts:
- `Token.sol`: upgradeable ERC20 token with transparent proxy.
- `Vesting.sol`: vesting wallet with cliff.

Scripts:
- `Token.s`: to deploy and/or upgrade the token
- `Vesting.s`: to deploy vesting with cliff

Tokenomics: 
- Name: Nexade
- Symbol: NEXD 
- Initial Supply: 1 billion NEXD Tokens

## Dependencies

### just (optional)
https://github.com/casey/just
mkdir -p ~/bin
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin
export PATH="$PATH:$HOME/bin"

### foundry/forge
https://book.getfoundry.sh/getting-started/installation
mkdir foundry
cd foundry
curl -L https://foundry.paradigm.xyz | bash
source ~/.bashrc 
foundryup

### node 18
https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-22-04

## Usage
For convenience the just command runner runs tasks defined in justfile.
It is also possible to type the commands directly in the terminal.

### Build

```shell
$ forge clean && forge build
```

Or

```shell
$ just build
```

### Test

Start anvil in another terminal first (see below section Anvil) and:

```shell
$ forge clean && forge test -vv
```

Or

```shell
$ just test
```


Note: run `forge clean` before script or test if it's failing (requirement of the foundry upgrades plugin).

### Format

```shell
$ forge fmt
```

### Anvil

To run a localhost instance:
```shell
$ anvil
```


### Deploy

To deploy on a local testnet, first launch anvil, then export your private key like this:

```shell 
$ export PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
```

Then:

```shell
$ just deploy_token_localhost
```
and take note of the last contract address displayed in case of success.

You can also try deploying the vesting contracts: 
```shell
$ just deploy_vesting_localhost
```

And finally, upgrade to a new version:
Edit script/Token.s.sol
At line 43, insert the address of the deployed contract to be upgraded:

Then use the following script:
```shell
$ just upgrade_token_localhost
```

### Bridging the token from Ethereum to Arbitrum
https://docs.arbitrum.io/build-decentralized-apps/token-bridging/bridge-tokens-programmatically/how-to-bridge-tokens-standard
ERC-20 tokens are bridgeable by default using the standard Abritrum bridge, through transactions or with its UI at:

https://bridge.arbitrum.io/

