// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // IERC20 interface

contract MintPassNFT is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable, ERC2981, DefaultOperatorFilterer {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    using ECDSA for bytes32;
    address private systemAddress;
    using SafeMath for uint256;

    // constructor takes the systemAddress for signature verification
    constructor(address _systemAddress) ERC721("MintPass", "MPASS") {
        systemAddress = _systemAddress;
    }

    // pause minting action
    function pause() public onlyOwner {
        _pause();
    }

    // unpause minting action
    function unpause() public onlyOwner {
        _unpause();
    }

    // recover Signer from hash & signature
    function recoverSigner(bytes32 hash, bytes memory signature) public pure returns (address) {
        bytes32 messageDigest = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
        return ECDSA.recover(messageDigest, signature);
    }

    // mint Metaverse NFT
    function mintMintPass(address recipient, string memory uri, address royaltFeeReceiver, uint96 fee, bytes32 hash, bytes memory signature) public payable returns(uint256){

        // check signature
        require(recoverSigner(hash, signature) == systemAddress, "Signature Failed");

        //define mint price
        require(msg.value >= 100000000000000, "Not enough MATIC sent; check price!"); 
        payable(address(0x1f6A403347fd2d335d14Dc3f1AEb21D9192cF166)).transfer(100000000000000);


        // set tokeID & recipient        
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(recipient, tokenId);

        // set metadata
        _setTokenURI(tokenId, uri);

        // set loyalty fee
        _setTokenRoyalty(tokenId, royaltFeeReceiver, fee);

        return tokenId;
    }


    // The following functions are overrides required by Solidity.
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    //function _burn(uint256 tokenId) external override(ERC721, ERC721URIStorage) {
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

    function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
        super.setApprovalForAll(operator, approved);
    }

    function approve(address operator, uint256 tokenId) public override onlyAllowedOperatorApproval(operator) {
        super.approve(operator, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override onlyAllowedOperator(from) {
        super.safeTransferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        override
        onlyAllowedOperator(from)
    {
        super.safeTransferFrom(from, to, tokenId, data);
    }

}