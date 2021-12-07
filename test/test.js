const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("NFTMarketPlace Unit Tests", function () {
	var NFT;
	var market;
	var marketAddress;
	var nftAddress;
	var listingPrice;

	it("should listed in the marketplace", async function () {
		try {
			// setup contract
			NFT = await ethers.getContractFactory("NFTtoken");
			market = await ethers.getContractFactory("NFTMarketPlace");
			// deploy contract
			market = await market.deploy();
			// get market contract address
			marketAddress = await market.address;
			console.log(marketAddress);
			// deploy NFT contract and set marketAddress as admin
			NFT = await NFT.deploy(marketAddress);
			nftAddress = await NFT.address;
		} catch (e) {
			console.log(e);
		}
		await NFT.mintToken("https://gateway.pinata.cloud/ipfs/QmRq4QYd1BReTjRQDnMBqdKLRa2CWWcAp1WN4dWFqdmryb");
		await NFT.mintToken("https://gateway.pinata.cloud/ipfs/QmRUt1FCy7t9vxzgCvu7iUaiQA2wJfsED2zcZUdDKetXzh")
		//set auction price
		const auctionPrice = ethers.utils.parseUnits('0.1', 'ether');
		// list friend
		console.log(nftAddress);
		await market.createMarketItem(nftAddress, 1, auctionPrice);
		// list qiqi
		await market.createMarketItem(nftAddress, 1, auctionPrice);

		const [_, buyerAddress] = await ethers.getSigners();
		// create sale
		await market.connect(buyerAddress).marketplaceListing(nftContractAddress, 1, { value: auctionPrice });

		// get unsold item in market place
		items = await market.fetchMarketItems();
		console.log(items);
	})
});
