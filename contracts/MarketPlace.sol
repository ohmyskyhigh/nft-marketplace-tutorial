//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "hardhat/console.sol";

contract NFTMarketPlaceabc is ReentrancyGuard {
    /**
        NFTMarketPlace合约 功能：
            1. 用户登陆注册
            2. 用户上架NFT
            3. 用户购买NFT
            4. 用户卖出NFT
            5. 用户收取eth
            6. 用户发送eth
            7. 库存
     */
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    // define a payable user
    address payable owner;
    // base price
    uint256 listingFee = 0.025 ether;

    // the messenger is the senders
    constructor() {
        // creator address
        owner = payable(msg.sender);
    }

     struct MarketItem {
        uint256 itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    mapping(uint256 => MarketItem) private idToMarketItem;

    event MarketItemCreated(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner,
        uint256 price,
        bool sold
    );

    // return the listing fee
    function getDefaultListingFee() public view returns (uint256) {
        return listingFee;
    }

    /**
        NFT listing feature; mint NFT to the current contract
    */
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        require(price > 0, "Price must be at least 1 wei");


        _itemIds.increment();
        uint256 itemId = _itemIds.current();
        console.log("itemId", itemId);
        console.log("nftcontract", nftContract);
        console.log("seller", msg.sender);
        idToMarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            true
        );
        /*
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);

        emit ItemCreateEvent(
            itemId, 
            nftContract, 
            tokenId, 
            payable(msg.sender), 
            payable(address(0)), 
            price, 
            false
        );
        */
    }

    /**
        listing marketplace item
        transfer ownership from one to another, and transfer money from seller to buyer
    */
    function createMarketSale(address nftContract, uint256 itemId)
        public
        payable
        nonReentrant
    {
        uint256 price = idToMarketItem[itemId].price;
        uint256 tokenId = idToMarketItem[itemId].tokenId;
        require(
            msg.value == price,
            "Please submit the asking price in order to complete the purchase"
        );

        idToMarketItem[itemId].seller.transfer(msg.value);
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;
        _itemsSold.increment();
        payable(owner).transfer(listingFee);
    }

    // return all unsold listing items on listing
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        uint256 itemsLength = _itemIds.current() - _itemsSold.current();
        MarketItem[] memory unsoldItems = new MarketItem[](itemsLength);

        uint256 unsoldIdx = 0;
        for (uint256 i = 0; i < _itemIds.current(); i++) {
            uint256 currentId = i + 1;
            if (idToMarketItem[currentId].owner == address(0)) {
                MarketItem memory item = idToMarketItem[currentId];
                unsoldItems[unsoldIdx] = item;
                unsoldIdx += 1;
            }
        }
        return unsoldItems;
    }

    // retrieve users NFT
    function fetchMyNFT(address account)
        public
        view
        returns (MarketItem[] memory)
    {
        uint256 myNftLength = 0;
        for (uint256 i = 0; i < _itemIds.current(); i++) {
            if (idToMarketItem[i + 1].owner == payable(account)) {
                myNftLength += 1;
            }
        }
        MarketItem[] memory myNfts = new MarketItem[](myNftLength);

        uint256 myNftIdx = 0;
        for (uint256 i = 0; i < _itemIds.current(); i++) {
            if (idToMarketItem[i + 1].owner == payable(account)) {
                myNftIdx += 1;
                myNfts[myNftIdx] = idToMarketItem[i + 1];
            }
        }
        return myNfts;
    }
}
