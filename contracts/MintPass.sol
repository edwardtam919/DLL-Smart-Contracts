// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // IERC20 interface

contract MintPassNFT is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable, ERC2981 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    using ECDSA for bytes32;
    using SafeMath for uint256;

    address private systemAddress;
    address private mintingFeeRecipient;
    //string private baseURILink;
    uint256 private mintingFee;
    uint96 private loyaltyFee;
    address contractOwner;

    event tokenIdMinted(uint256 indexed tokenId);

    // constructor takes the systemAddress (for signature verification), minting recipient, base URI, minting fee & loyalty fee
    constructor(address _systemAddress, address _mintingFeeRecipient, uint256 _mintingFee,  uint96 _loyaltyFee) ERC721("MintPass", "MPASS") {
        contractOwner = msg.sender;
        systemAddress = _systemAddress;
        mintingFeeRecipient = _mintingFeeRecipient;
        //baseURILink = _baseURILink;
        mintingFee = _mintingFee;
        loyaltyFee = _loyaltyFee;
    }

    // recover Signer from hash & signature
    function recoverSigner(bytes32 hash, bytes memory signature) private pure returns (address) {
        bytes32 messageDigest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        return ECDSA.recover(messageDigest, signature);
    }

    // pause minting action
    function pause() public onlyOwner {
        _pause();
    }

    // unpause minting action
    function unpause() public onlyOwner {
        _unpause();
    }

    // set minting fee
    function setMintingFee(uint256 _mintingFee) public  {
        require(contractOwner == msg.sender);
        mintingFee = _mintingFee;
    }

    // get minting fee
    function getMintingFee() public view returns (uint256) {
        return mintingFee;
    }

    // mint Metaverse NFT
    function mintMintPass(bytes32 hash, bytes memory signature, string memory uri) public payable returns(uint256){

        // check signature
        require(recoverSigner(hash, signature) == systemAddress, "Signature Failed");

        // transfer minting fee to the defined wallet
        require(msg.value >= mintingFee, "Not enough MATIC sent; check price!"); 
        payable(address(mintingFeeRecipient)).transfer(mintingFee);

        // set tokeID & recipient        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);

        // set loyalty fee
        _setTokenRoyalty(tokenId, msg.sender, loyaltyFee);

        // set token URI
        _setTokenURI(tokenId, uri);

        emit tokenIdMinted(tokenId);

        return tokenId;
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}
