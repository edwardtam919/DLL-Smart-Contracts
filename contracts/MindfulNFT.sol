// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

// declare burn & tokenURI interface
interface burnMintPass{
  function burn(uint256 tokenId) external;
  function tokenURI(uint256 tokenId) external view returns(string memory);
}

contract MindfulNFT is ERC721, ERC721URIStorage, Pausable, Ownable, ERC721Burnable, ERC2981 {
    
    address private immutable mintPass;
    uint96 private immutable loyaltyFee;

    constructor(address _mintPass, uint96 _loyaltyFee) ERC721("Mindful Ocean NFT", "MINDFUL") {
        mintPass = _mintPass;
        loyaltyFee = _loyaltyFee;
    }

    // pause minting action
    function pause() public onlyOwner {
        _pause();
    }

    // unpause minting action
    function unpause() public onlyOwner {
        _unpause();
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
