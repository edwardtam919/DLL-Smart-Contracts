//import { ethers } from "hardhat";

const API_KEY = "3iqNgDWSBHMkWq9vVT5GwGNuIJ_4vlbQ";
//PRIVATE_KEY = "78501fb8da333ed1c8312a2a4138bde909e280519157d5cac7e627222f2886b9";
PRIVATE_KEY = "35322f3d9f56cf2f84592411ffacb71cf8d39ef3c7918a0358d4aebfec562989";
const MINTPASS_CONTRACT_ADDRESS = "0x627721833E29dAcD5ec000Fe17F2d46dADA19f28";
const MINDFUL_CONTRACT_ADDRESS = "0xF30aaF36A9637CFf42933d38B34E39EBEb770261";
const fromAddress = "0x9b39710bd511bc14fcb0f64a9d8f8e6f630751ab";
const tokenId = 9;
const url = "ipfs://bafyreie3vlwy7pqagjpyqxbtzgiyky5twkqptkaqmys4fuy4rqt742uow4/metadata.json"; 

const contract = require("../artifacts/contracts/MintPass.sol/MintPassNFT.json");

// provider - Alchemy
const netObj = {
    name: 'maticmum',
    chainId: 80001  // hardwired bullshit
}
const alchemyProvider = new ethers.providers.AlchemyProvider(netObj, API_KEY);

// signer
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

// contract instance
const MintPassNFTContract = new ethers.Contract(MINTPASS_CONTRACT_ADDRESS, contract.abi, signer);

// change url to hex format
urlHex = 'Hello'.toString(16);

async function main() {

    const name = await MintPassNFTContract.name();    
    console.log("The name is: " + name); 
    console.log("Minting MindfulNFT...");

    // convert url to hex format
    let urlHex = '0x';
    let tASCII, Hex;
    url.split('').map( i => {
        tASCII = i.charCodeAt(0)
        Hex = tASCII.toString(16);
        urlHex = urlHex + Hex;
    });

    urlHex = urlHex.trim();
    console.log("URL in hex: " + urlHex);


    //console.log("A".charCodeAt(0).toString(16));
	//await MintPassNFTContract['safeTransferFrom(address,address,uint256)'](fromAddress, MINDFUL_CONTRACT_ADDRESS, tokenId);
    await MintPassNFTContract['safeTransferFrom(address,address,uint256,bytes)'](fromAddress, MINDFUL_CONTRACT_ADDRESS, tokenId, urlHex);
	
}

main();