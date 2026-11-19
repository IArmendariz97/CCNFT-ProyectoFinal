# CCNFT - Proyecto Final

NFT (CCNFT) que se compra con el token ERC20 BUSD. Hecho con Foundry y OpenZeppelin v4.5.0, desplegado en Sepolia.

## Contratos desplegados (Sepolia)

- BUSD: https://sepolia.etherscan.io/address/0x06d4ffe93cf93b0ecbdf17bf4f711a5516c6eb14
- CCNFT: https://sepolia.etherscan.io/address/0x8AD0B567742F05A286C795Ec04322dfc63aC955e

## Interacciones

| Accion | Transaccion |
|---|---|
| Deploy BUSD | https://sepolia.etherscan.io/tx/0x40484341dca9e41d47d5fe3c13e312284bfa7605f532a4303b5372d34a2b9c01 |
| Deploy CCNFT | https://sepolia.etherscan.io/tx/0xb839f977aa8f6f5a08d62effd109ba4ed4d1207fb03674e0c2f371a139f5b6ff |
| setFundsToken | https://sepolia.etherscan.io/tx/0xbef9a12a376f49f676b49d667ea5b2d1a155cfaaba3c53a282c652a250d90878 |
| setFundsCollector | https://sepolia.etherscan.io/tx/0xbcfe3880284f6ca32bfc2a63c35692130d2f91df7b1ac9ff8234503f771d5e0f |
| setFeesCollector | https://sepolia.etherscan.io/tx/0x3f33f5cf71b4d2c07d38a4e34c4be2455eeb25ba021dee7970464f404d981ddc |
| setCanBuy | https://sepolia.etherscan.io/tx/0x1ff13728077e8aeff34c5699a80187e2de70484e724060a1b91a4bacf6b7953d |
| setCanClaim | https://sepolia.etherscan.io/tx/0x0f6f7553f47a2bd852a4e02cfea7ee0b5a1e3a89b0c8257434e48f12f8d5656e |
| setCanTrade | https://sepolia.etherscan.io/tx/0x15511898e56de1643981f1d3791a87509afb89dd9e425a4eb9f3cb7dc84f08c7 |
| setMaxBatchCount | https://sepolia.etherscan.io/tx/0x8b8577597af95178d4e90b4d9b6eaf6dda1a2df6ded21291da9b255de6a247ab |
| setMaxValueToRaise | https://sepolia.etherscan.io/tx/0xd9916cd07d39adf965a977ea8244ecec40ab2352862074fa2c41f5efef4fd632 |
| addValidValues | https://sepolia.etherscan.io/tx/0x73d3a4efd0821ac9ed9cae54e82d4eade8bf951e35d88205d393b04b921177dc |
| setBuyFee | https://sepolia.etherscan.io/tx/0x284f0a679395c1121026fd292e232f39637ef418636bf4fe852a6896e19e135b |
| setTradeFee | https://sepolia.etherscan.io/tx/0xae879c1f00f94c5d5c5002e527c56a1c17dddf2e471031dc5a2d226a8f2e81c9 |
| setProfitToPay | https://sepolia.etherscan.io/tx/0x91709f1a9581247780d5b0eb32f2b0201f99d19b41ac6dda640f304b20eb18e0 |
| approve (BUSD a CCNFT) | https://sepolia.etherscan.io/tx/0xe51f3fe9da55ee2702d6bf466cf06c7ec3a03f3cb8942cfb251bd594afca9813 |
| buy (1 NFT de 100 BUSD) | https://sepolia.etherscan.io/tx/0x548e2122ac53cfe3601bb91b0d0c436cc93e647f07bca56d5fc27a64046a46d5 |

## Uso

```shell
forge install
forge test
cp .env.example .env   # completar SEPOLIA_RPC_URL, PRIVATE_KEY, ETHERSCAN_API_KEY
make deploy-busd
make deploy-ccnft
```
