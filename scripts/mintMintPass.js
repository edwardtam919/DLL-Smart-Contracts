//import { ethers } from "hardhat";

const API_KEY = "3iqNgDWSBHMkWq9vVT5GwGNuIJ_4vlbQ";
const PRIVATE_KEY = "78501fb8da333ed1c8312a2a4138bde909e280519157d5cac7e627222f2886b9";
const CONTRACT_ADDRESS = "0x042af24293a14A616AD942b72687d55CcD210904";

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
	const tx = await MintPassNFTContract.mintMintPass(messageHash, signature, {value: 100000000000000});
    //await tx.wait();

}

main();