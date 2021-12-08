/* test/sample-test.js */
describe("NFT marketplace self made", function() {
  it("Should create and make market sales", async function() {
    /* deploy the marketplace */
    const Market = await ethers.getContractFactory("NFTMarketPlaceabc")
    const market = await Market.deploy()
    await market.deployed()
    const marketAddress = market.address
    const listingFee = await market.getDefaultListingFee();

    /* deploy the NFT contract */
    const NFT = await ethers.getContractFactory("NFTtoken")
    const nft = await NFT.deploy(marketAddress)
    await nft.deployed()
    const nftContractAddress = nft.address

    const auctionPrice = ethers.utils.parseUnits('1', 'ether');

    /* create two tokens */
    await nft.mintToken("https://gateway.pinata.cloud/ipfs/QmRq4QYd1BReTjRQDnMBqdKLRa2CWWcAp1WN4dWFqdmryb")
    await nft.mintToken("https://gateway.pinata.cloud/ipfs/QmRUt1FCy7t9vxzgCvu7iUaiQA2wJfsED2zcZUdDKetXzh")

    /* put both tokens for sale */
    await market.createMarketItem(nftContractAddress, 1, auctionPrice, {value: listingFee});
    await market.createMarketItem(nftContractAddress, 2, auctionPrice, {value: listingFee});

    const [_, buyerAddress] = await ethers.getSigners()
    
    /* execute sale of token to another user */
    await market.connect(buyerAddress).createMarketSale(nftContractAddress, 1, { value: auctionPrice})

    /* query for and return the unsold items */
    
    items = await market.fetchMarketItems();
    console.log(items);
    /*
    items = await Promise.all(items.map(async i => {
      const tokenUri = await nft.tokenURI(i.tokenId)
      let item = {
        price: i.price.toString(),
        tokenId: i.tokenId.toString(),
        seller: i.seller,
        owner: i.owner,
        tokenUri
      }
      return item
    }))
    console.log('items: ', items)
    */
  })
})