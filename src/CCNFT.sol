// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CCNFT is ERC721Enumerable, Ownable, ReentrancyGuard {
    // EVENTOS
    event Buy(address indexed buyer, uint256 indexed tokenId, uint256 value);
    event Claim(address indexed claimer, uint256 indexed tokenId);
    event Trade(address indexed buyer, address indexed seller, uint256 indexed tokenId, uint256 value);
    event PutOnSale(uint256 indexed tokenId, uint256 price);

    // Estado de venta de un NFT.
    struct TokenSale {
        bool onSale; // Indica si el NFT está en venta.
        uint256 price; // Precio del NFT si está en venta.
    }

    using Counters for Counters.Counter;

    Counters.Counter private tokenIdTracker;

    mapping(uint256 => uint256) public values;
    mapping(uint256 => bool) public validValues;
    mapping(uint256 => TokenSale) public tokensOnSale;
    uint256[] public listTokensOnSale;

    address public fundsCollector;
    address public feesCollector;

    bool public canBuy;
    bool public canClaim;
    bool public canTrade;

    uint256 public totalValue;
    uint256 public maxValueToRaise;

    uint16 public buyFee;
    uint16 public tradeFee;

    uint16 public maxBatchCount;

    uint32 public profitToPay;

    IERC20 public fundsToken;

    constructor() ERC721("CCNFT", "CCNFT") {}

    // PUBLIC FUNCTIONS

    function buy(uint256 value, uint256 amount) external nonReentrant {
        require(canBuy, "Buy disabled");
        require(amount > 0 && amount <= maxBatchCount, "Amount out of range");
        require(validValues[value], "Invalid value");
        require(totalValue + (value * amount) <= maxValueToRaise, "Max value to raise exceeded");

        totalValue += value * amount;

        for (uint256 i = 1; i <= amount; i++) {
            values[tokenIdTracker.current()] = value;
            _safeMint(_msgSender(), tokenIdTracker.current());
            emit Buy(_msgSender(), tokenIdTracker.current(), value);
            tokenIdTracker.increment();
        }

        if (!fundsToken.transferFrom(_msgSender(), fundsCollector, value * amount)) {
            revert("Cannot send funds tokens");
        }

        if (!fundsToken.transferFrom(_msgSender(), feesCollector, value * amount * buyFee / 10000)) {
            revert("Cannot send fees tokens");
        }
    }

    function claim(uint256[] calldata listTokenId) external nonReentrant {
        require(canClaim, "Claim disabled");
        require(listTokenId.length > 0 && listTokenId.length <= maxBatchCount, "Invalid claim amount");

        uint256 claimValue = 0;
        TokenSale storage tokenSale;
        for (uint256 i = 0; i < listTokenId.length; i++) {
            require(_exists(listTokenId[i]), "Token does not exist");
            require(ownerOf(listTokenId[i]) == _msgSender(), "Only owner can Claim");
            claimValue += values[listTokenId[i]];
            values[listTokenId[i]] = 0;

            tokenSale = tokensOnSale[listTokenId[i]];
            tokenSale.onSale = false;
            tokenSale.price = 0;

            removeFromArray(listTokensOnSale, listTokenId[i]);
            _burn(listTokenId[i]);
            emit Claim(_msgSender(), listTokenId[i]);
        }

        totalValue -= claimValue;

        if (!fundsToken.transferFrom(fundsCollector, _msgSender(), claimValue + (claimValue * profitToPay / 10000))) {
            revert("cannot send funds");
        }
    }

    function trade(uint256 tokenId) external nonReentrant {
        require(canTrade, "Trade disabled");
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) != _msgSender(), "Buyer is the Seller");

        TokenSale storage tokenSale = tokensOnSale[tokenId];

        require(tokenSale.onSale, "Token not On Sale");

        address seller = ownerOf(tokenId);
        uint256 price = tokenSale.price;

        if (!fundsToken.transferFrom(_msgSender(), seller, price)) {
            revert("Cannot send funds to seller");
        }

        if (!fundsToken.transferFrom(_msgSender(), feesCollector, price * tradeFee / 10000)) {
            revert("Cannot send fees tokens");
        }

        emit Trade(_msgSender(), seller, tokenId, price);

        _safeTransfer(seller, _msgSender(), tokenId, "");

        tokenSale.onSale = false;
        tokenSale.price = 0;
        removeFromArray(listTokensOnSale, tokenId);
    }

    function putOnSale(uint256 tokenId, uint256 price) external {
        require(canTrade, "Trade disabled");
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == _msgSender(), "Only owner can put on sale");

        TokenSale storage tokenSale = tokensOnSale[tokenId];

        tokenSale.onSale = true;
        tokenSale.price = price;

        addToArray(listTokensOnSale, tokenId);

        emit PutOnSale(tokenId, price);
    }

    // SETTERS

    function setFundsToken(address token) external onlyOwner {
        require(token != address(0), "Invalid token address");
        fundsToken = IERC20(token);
    }

    function setFundsCollector(address _address) external onlyOwner {
        require(_address != address(0), "Invalid address");
        fundsCollector = _address;
    }

    function setFeesCollector(address _address) external onlyOwner {
        require(_address != address(0), "Invalid address");
        feesCollector = _address;
    }

    function setProfitToPay(uint32 _profitToPay) external onlyOwner {
        profitToPay = _profitToPay;
    }

    function setCanBuy(bool _canBuy) external onlyOwner {
        canBuy = _canBuy;
    }

    function setCanClaim(bool _canClaim) external onlyOwner {
        canClaim = _canClaim;
    }

    function setCanTrade(bool _canTrade) external onlyOwner {
        canTrade = _canTrade;
    }

    function setMaxValueToRaise(uint256 _maxValueToRaise) external onlyOwner {
        maxValueToRaise = _maxValueToRaise;
    }

    function addValidValues(uint256 value) external onlyOwner {
        validValues[value] = true;
    }

    function setMaxBatchCount(uint16 _maxBatchCount) external onlyOwner {
        maxBatchCount = _maxBatchCount;
    }

    function setBuyFee(uint16 _buyFee) external onlyOwner {
        buyFee = _buyFee;
    }

    function setTradeFee(uint16 _tradeFee) external onlyOwner {
        tradeFee = _tradeFee;
    }

    // ARRAYS

    function addToArray(uint256[] storage list, uint256 value) private {
        uint256 index = find(list, value);
        if (index == list.length) {
            list.push(value);
        }
    }

    function removeFromArray(uint256[] storage list, uint256 value) private {
        uint256 index = find(list, value);
        if (index < list.length) {
            list[index] = list[list.length - 1];
            list.pop();
        }
    }

    function find(uint256[] storage list, uint256 value) private view returns (uint256) {
        for (uint256 i = 0; i < list.length; i++) {
            if (list[i] == value) {
                return i;
            }
        }
        return list.length;
    }

    // NOT SUPPORTED FUNCTIONS

    function transferFrom(address, address, uint256) public pure override(ERC721, IERC721) {
        revert("Not Allowed");
    }

    function safeTransferFrom(address, address, uint256) public pure override(ERC721, IERC721) {
        revert("Not Allowed");
    }

    function safeTransferFrom(address, address, uint256, bytes memory) public pure override(ERC721, IERC721) {
        revert("Not Allowed");
    }

    // Compliance required by Solidity

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
