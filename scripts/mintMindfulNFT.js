//import { ethers } from "hardhat";

const API_KEY = "3iqNgDWSBHMkWq9vVT5GwGNuIJ_4vlbQ";
const PRIVATE_KEY = "78501fb8da333ed1c8312a2a4138bde909e280519157d5cac7e627222f2886b9";
//const PRIVATE_KEY = "35322f3d9f56cf2f84592411ffacb71cf8d39ef3c7918a0358d4aebfec562989";
const CONTRACT_ADDRESS = "0xcCB6008Ff575402cbd32416540b27AAfDA2e0500";

const contract = require("../artifacts/contracts/MindfulNFT.sol/MindfulNFT.json");

// provider - Alchemy
const netObj = {
    name: 'maticmum',
    chainId: 80001  // hardwired bullshit
}
const alchemyProvider = new ethers.providers.AlchemyProvider(netObj, API_KEY);

// signer
const signer = new ethers.Wallet(PRIVATE_KEY, alchemyProvider);

// contract instance
const MintPassNFTContract = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, signer);

async function main() {

	// construct the message to sign
	let message = "Hello World " + Date.now();
	console.log("Message: ", message);
	
	// Compute hash of the message
	let messageHash = ethers.utils.id(message);
	console.log("Message Hash: ", messageHash);
	
	// Sign the hashed message
	let messageBytes = ethers.utils.arrayify(messageHash);
	let signature = await signer.signMessage(messageBytes);
	console.log("Signature: ", signature);
	
    const name = await MintPassNFTContract.name();    
    console.log("The name is: " + name); 

    console.log("Minting MindfulNFT...");
	const tx = await MintPassNFTContract.mintMindfulNFT("0x9B39710bD511bc14Fcb0f64a9D8f8e6F630751Ab", "https://www.google.com", "0x9B39710bD511bc14Fcb0f64a9D8f8e6F630751Ab", "10", 0, messageHash, signature);
    await tx.wait();


}

main();