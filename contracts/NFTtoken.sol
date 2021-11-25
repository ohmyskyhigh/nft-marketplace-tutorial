//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import "hardhat/console.sol";

contract NFTtoken is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    address _contractAddress;

    constructor(address marketContractAddress) ERC721("Metaverse Tokens", "METT"){
        _contractAddress = marketContractAddress;
    }

    function mintToken(string memory tokenURI) public returns (uint) {
        // Approve or operator(_contractAddress) as an operator for the caller.
        setApprovalForAll(_contractAddress, true);
        
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        // Mints tokenId and transfers it to msg.sender
        _mint(msg.sender, newItemId);
        // Sets _tokenURI as the tokenURI of tokenId.
        _setTokenURI(newItemId, tokenURI);
        return newItemId;
    }
}