//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import "hardhat/console.sol";

contract NFTMarketPlace is ReentrancyGuard {

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

    /**
        inventory item style
     */
    struct MarketItem {
        uint256 itemId; // item id
        address nftContract; // nft contract address
        uint256 tokenId; // NFT token ID
        address payable seller; // contract emitter
        address payable owner; // Onwer address
        uint256 price; // listing price
        bool sold; // is transfered
    }

    // mapping function to map uint to MarketItem
    mapping(uint256 => MarketItem) private id2MarketItem;

    // build event
    event ItemCreateEvent(
        uint256 indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address payable seller,
        address payable owner,
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
        // setting itemID
        uint256 itemId = _itemIds.current();

        // append item state
        id2MarketItem[itemId] = MarketItem(
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),
            payable(address(0)),
            price,
            false
        );

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
    }

    /**
        listing marketplace item
        transfer ownership from one to another, and transfer money from seller to buyer
    */
    function marketplaceListing(address nftContract, uint itemId) public payable nonReentrant{
        //getListing price
        uint price = id2MarketItem[itemId].price;
        //send money from buyer to contract
        require(msg.value == price);
        uint tokenId = id2MarketItem[itemId].tokenId;
        
        // send cargo
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);
        // send money to the seller
        id2MarketItem[itemId].seller.transfer(msg.value);

        // register item to new address
        id2MarketItem[itemId].owner = payable(msg.sender);
        id2MarketItem[itemId].sold = true;
        _itemsSold.increment();

        // send listing fee to the owner of the contract in the end
        payable(owner).transfer(listingFee);
    }

    // return all unsold listing items on listing
    function fetchMarketItems() public view returns(MarketItem[] memory) {
        uint itemsLength = _itemIds.current() - _itemsSold.current();
        MarketItem[] memory unsoldItems = new MarketItem[](itemsLength);

        uint unsoldIdx = 0;
        for (uint i = 0; i<_itemsSold.current(); i++){
            if (id2MarketItem[i+1].sold == false){
                MarketItem memory item = id2MarketItem[i+1];
                unsoldIdx += 1;
                unsoldItems[unsoldIdx] = item;
            }
        }
        return unsoldItems;
    }

    // retrieve users NFT
    function fetchMyNFT(address account) public view returns(MarketItem[] memory) {
        uint myNftLength = 0;
        for (uint i=0; i<_itemIds.current(); i++){
            if (id2MarketItem[i+1].owner == payable(account)) {
                myNftLength+=1;
            }
        }
        MarketItem[] memory myNfts = new MarketItem[](myNftLength);
        
        uint myNftIdx = 0;
        for (uint i=0; i<_itemIds.current(); i++){
            if(id2MarketItem[i+1].owner == payable(account)) {
                myNftIdx += 1;
                myNfts[myNftIdx] = id2MarketItem[i+1];
            }
        }
        return myNfts;
    }
}