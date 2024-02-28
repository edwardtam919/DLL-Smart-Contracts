// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// declare burn & tokenURI interface
interface burnMintPass{
  function burn(uint256 tokenId) external;
  function tokenURI(uint256 tokenId) external view returns(string memory);
}

contract MindfulNFT is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable, ERC2981, ReentrancyGuard {

    using ECDSA for bytes32;
    
    address private immutable mintPass;
    uint96 private immutable loyaltyFee;

    address private immutable systemAddress;
    address immutable contractOwner;

    // Mapping of addresses who has been used
    mapping(bytes32 => bool) public hashUsed;

    // events
    event tokenIdMinted(uint256 indexed tokenId);

    // constructor takes the systemAddress (for signature verification), mintPass contract address & loyalty fee
    constructor(address _systemAddress, address _mintPass, uint96 _loyaltyFee) ERC721("Mindful Ocean NFT", "MINDFUL") {
        systemAddress = _systemAddress;
        mintPass = _mintPass;
        loyaltyFee = _loyaltyFee;
        contractOwner = msg.sender;
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

    // mint MindfulOcean NFT
    function mintMindfulNFT(bytes32 hash, bytes calldata signature, uint256 tokenId, string calldata uri, address to) public whenNotPaused nonReentrant returns(uint256){

        // only contract owner can mintMintfulNFT in this way
        require(msg.sender == contractOwner, "Must be owner of the contract");

        // check if hash has been used
        require(!hashUsed[hash], "Hash has been used");

        // set the hash as used
        hashUsed[hash] = true;

        // check signature
        require(recoverSigner(hash, signature) == systemAddress, "Signature Failed");

        _safeMint(to, tokenId);

        // set loyalty fee
        _setTokenRoyalty(tokenId, msg.sender, loyaltyFee);

        // set token URI
        _setTokenURI(tokenId, uri);

        emit tokenIdMinted(tokenId);

        return tokenId;
    }

    function onERC721Received(address, address _from, uint256 _tokenId, bytes calldata _data) external whenNotPaused returns(bytes4) {

        bool isBurned = false;
        string memory url = string(_data);

        // can only accept call from mintpass smart contract
        require(msg.sender == mintPass, "Can receive only from MintPass");
    
        // create the interface
        burnMintPass mintPassContract = burnMintPass(mintPass);    

         // burn the NFT received   
        try mintPassContract.burn(_tokenId){
            isBurned = true;
        } catch Error(string memory) {
            isBurned = false;
        } catch (bytes memory) {
            isBurned = false;
        }
        require(isBurned, "MintPass not burned");

        // mint the new one
        _safeMint(_from, _tokenId);

        // set loyalty fee
        _setTokenRoyalty(_tokenId, _from, loyaltyFee);

        // set token URI
        _setTokenURI(_tokenId, url);

        return IERC721Receiver.onERC721Received.selector;
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
        //override(ERC721, ERC721Enumerable, ERC2981)
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}
