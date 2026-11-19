-include .env

.PHONY: build test deploy-busd deploy-ccnft verify-busd verify-ccnft

build:; forge build
test:; forge test -vv

deploy-busd:
	forge script script/Deploy.s.sol:DeployBUSD --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

deploy-ccnft:
	forge script script/Deploy.s.sol:DeployCCNFT --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

verify-busd:
	forge verify-contract $(BUSD_ADDRESS) src/BUSD.sol:BUSD --chain sepolia --etherscan-api-key $(ETHERSCAN_API_KEY)

verify-ccnft:
	forge verify-contract $(CCNFT_ADDRESS) src/CCNFT.sol:CCNFT --chain sepolia --etherscan-api-key $(ETHERSCAN_API_KEY)
