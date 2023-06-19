//import { ethers } from "hardhat";

const API_KEY = "3iqNgDWSBHMkWq9vVT5GwGNuIJ_4vlbQ";
//PRIVATE_KEY = "78501fb8da333ed1c8312a2a4138bde909e280519157d5cac7e627222f2886b9";
PRIVATE_KEY = "35322f3d9f56cf2f84592411ffacb71cf8d39ef3c7918a0358d4aebfec562989";
const MINTPASS_CONTRACT_ADDRESS = "0xBAB5c7041b51a202373f522d2A0Cb9516bcbEED8";
const MINDFUL_CONTRACT_ADDRESS = "0xb5932aCe7504a7158807781e5500FE1A81078880";
const fromAddress = "0x9b39710bd511bc14fcb0f64a9d8f8e6f630751ab";
const tokenId = 1;

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

async function main() {

    const name = await MintPassNFTContract.name();    
    console.log("The name is: " + name); 
    console.log("Minting MindfulNFT...");
	await MintPassNFTContract['safeTransferFrom(address,address,uint256)'](fromAddress, MINDFUL_CONTRACT_ADDRESS, tokenId);
	
}

main();