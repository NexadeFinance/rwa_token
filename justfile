# Clean and build the project
build:
    forge clean && forge build

# Clean and run tests with verbose output
test:
    forge clean && forge test -vv

# Clean and deploy the token contract locally. Must be running a local node (e.g anvil)
deploy_token_localhost:
    forge clean && forge script --chain 31337 script/Token.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --broadcast -vvvv

deploy_token_amoy_testnet:
    forge clean && forge script --chain 80002 script/Token.s.sol:Deploy --rpc-url https://rpc-amoy.polygon.technology -vvvv --broadcast --verify --etherscan-api-key DTTZGII2YP5N3HRA7NUGR6Z5U31672N5MM --verifier-url https://api-amoy.polygonscan.com/api --slow

upgrade_token_localhost:
    forge clean && forge script --chain 31337 script/Token.s.sol:Upgrade --rpc-url http://127.0.0.1:8545 --broadcast -vvvv

update_token_proxy_owner:
    forge clean && forge script --chain 31337 script/Token.s.sol:TransferOwner --rpc-url http://127.0.0.1:8545 --broadcast -vvvv
    
deploy_vesting_localhost:
    forge clean && forge script --chain 31337 script/Vesting.s.sol:Deploy --rpc-url http://127.0.0.1:8545 --broadcast -vvvv

deploy_vesting_amoy_testnet:
    forge clean && forge script --chain 80002 script/Vesting.s.sol:Deploy --rpc-url https://rpc-amoy.polygon.technology -vvvv --broadcast --verify --etherscan-api-key DTTZGII2YP5N3HRA7NUGR6Z5U31672N5MM --verifier-url https://api-amoy.polygonscan.com/api --slow
