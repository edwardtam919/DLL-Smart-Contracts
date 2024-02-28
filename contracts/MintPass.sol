// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract MintPassNFT is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable, ERC2981, ReentrancyGuard {

    using ECDSA for bytes32;
    using Address for address payable;

    address private immutable systemAddress;
    address private immutable mintingFeeRecipient;
    uint256 private mintingFee;
    uint96 private immutable loyaltyFee;
    address immutable contractOwner;
    uint private lastMintingFeeChangeTime;

    // Mapping of addresses who has been used
    mapping(bytes32 => bool) public hashUsed;

    // timelock
    uint public constant lockDuration = 48 hours;

    // events
    event tokenIdMinted(uint256 indexed tokenId);
    event mintingFeeSet(uint256 indexed mintingFee);

    // constructor takes the systemAddress (for signature verification), minting fee recipients, minting fee & loyalty fee
    constructor(address _systemAddress, address _mintingFeeRecipient, uint256 _mintingFee,  uint96 _loyaltyFee) ERC721("Mindful Ocean Mint Pass", "MPASS") {
        contractOwner = msg.sender;
        systemAddress = _systemAddress;
        mintingFeeRecipient = _mintingFeeRecipient;
        mintingFee = _mintingFee;
        loyaltyFee = _loyaltyFee;
        lastMintingFeeChangeTime = block.timestamp; 
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

    // set minting fee, only contract creator can call
    function setMintingFee(uint256 _mintingFee) public  {

        // check if contract Owner
        require(contractOwner == msg.sender, "Must be Contract Owner to call the function");

        // check if pass lock duration
        uint endLocking = lastMintingFeeChangeTime + lockDuration;
        require(block.timestamp >= endLocking, "Need to wait 2 minutes before change minting fee again");

        mintingFee = _mintingFee;
        lastMintingFeeChangeTime = block.timestamp;
        emit mintingFeeSet(mintingFee);
    }

    // get minting fee
    function getMintingFee() public view returns (uint256) {
        return mintingFee;
    }

    // get lastMintingFeeChangeTime
    function getLastMintingFeeChangeTime() public view returns (uint) {
        return lastMintingFeeChangeTime;
    }

    // mint Metaverse NFT
    function mintMintPass(bytes32 hash, bytes calldata signature, uint256 tokenId, string calldata uri) public payable whenNotPaused nonReentrant returns(uint256){

        // check if hash has been used
        require(!hashUsed[hash], "Hash has been used");

        // set the hash as used
        hashUsed[hash] = true;

        // check signature
        require(recoverSigner(hash, signature) == systemAddress, "Signature Failed");

        // transfer minting fee to the defined wallet
        require(msg.value >= mintingFee, "Not enough MATIC sent; check price!");
        payable(address(mintingFeeRecipient)).sendValue(mintingFee);

        //refund any excess native tokens sent by the user
        if (msg.value > mintingFee){
            payable(address(msg.sender)).sendValue(msg.value-mintingFee);
        }

        // set tokeID & recipient
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
