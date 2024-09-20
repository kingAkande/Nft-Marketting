// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarket is ERC721, Ownable {

    uint256 private _currentTokenId;

    struct Listing {
        uint256 price;
        address seller;
        bool isActive;
    }

    mapping(uint256 => Listing) private _listings;
    

    event NFTMinted(uint256 tokenId, address owner, string tokenURI);
    event NFTListed(uint256 tokenId, uint256 price, address seller);
    event NFTPurchased(uint256 tokenId, address buyer, address seller);

    // Corrected constructor
    constructor() ERC721("NFTMarket", "NFTM") {}

    function mintNFT(address to, string memory tokenURI) public onlyOwner returns (uint256) {
        _currentTokenId += 1; 
        uint256 newItemId = _currentTokenId;

        _mint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);

        emit NFTMinted(newItemId, to, tokenURI);
        return newItemId;
    }

    function _setTokenURI(uint256 tokenId, string memory tokenURI) internal {
        _tokenURIs[tokenId] = tokenURI;
    }

    function listForSale(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "Only owner");
        _listings[tokenId] = Listing(price, msg.sender, true);
        emit NFTListed(tokenId, price, msg.sender);
    }

    function buy(uint256 tokenId) public payable {
        Listing memory listing = _listings[tokenId];
        require(listing.isActive, "NFT is not listed for sale");
        require(msg.value >= listing.price, "Insufficient payment");

        address seller = listing.seller;
        _transfer(seller, msg.sender, tokenId);
        payable(seller).transfer(msg.value);
        _listings[tokenId].isActive = false;

        emit NFTPurchased(tokenId, msg.sender, seller);
    }
}
