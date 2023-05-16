//import { ethers } from "hardhat";

const API_KEY = "3iqNgDWSBHMkWq9vVT5GwGNuIJ_4vlbQ";
const PRIVATE_KEY = "78501fb8da333ed1c8312a2a4138bde909e280519157d5cac7e627222f2886b9";
//const PRIVATE_KEY = "35322f3d9f56cf2f84592411ffacb71cf8d39ef3c7918a0358d4aebfec562989";
const CONTRACT_ADDRESS = "0x60C53752a081a15A9944e574781061980c2B64bf";

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
	
	// read the contract name
    const name = await MintPassNFTContract.name();    
    console.log("The contract name is: " + name); 

	// mint the mintPass
    console.log("Minting MintPass...");
    const tx = await MintPassNFTContract.mintMintPass("0x9B39710bD511bc14Fcb0f64a9D8f8e6F630751Ab", "https://www.google.com", "0x9B39710bD511bc14Fcb0f64a9D8f8e6F630751Ab", "10", messageHash, signature, {value: 100000000000000});
    await tx.wait();

}

main();