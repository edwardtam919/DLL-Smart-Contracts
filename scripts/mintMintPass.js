//import { ethers } from "hardhat";

const API_KEY = "3iqNgDWSBHMkWq9vVT5GwGNuIJ_4vlbQ";
const SYSTEM_PRIVATE_KEY = "78501fb8da333ed1c8312a2a4138bde909e280519157d5cac7e627222f2886b9";
const CALLER_PRIVATE_KEY = "35322f3d9f56cf2f84592411ffacb71cf8d39ef3c7918a0358d4aebfec562989";
const CONTRACT_ADDRESS = "0x54d7Eb7A94ED4A87542B4ABAb8Bb5e22dF299325";
const url = "ipfs://bafyreifm457a6j647vd4b7g6oqwkyxvgzegpfwsg3hvd6wf6rk2ukhk7gq/metadata.json"; 

const contract = require("../artifacts/contracts/MintPass.sol/MintPassNFT.json");

// provider - Alchemy
const netObj = {
    name: 'maticmum',
    chainId: 80001  // hardwired bullshit
}
const alchemyProvider = new ethers.providers.AlchemyProvider(netObj, API_KEY);

// signer
const systemSigner = new ethers.Wallet(SYSTEM_PRIVATE_KEY, alchemyProvider);
const callerSigner = new ethers.Wallet(CALLER_PRIVATE_KEY, alchemyProvider);

// contract instance
const MintPassNFTContract = new ethers.Contract(CONTRACT_ADDRESS, contract.abi, callerSigner);

async function main() {

	// construct the message to sign
	//let message = "Hello World " + Date.now();
	//let message = "Hello World ";
	const ethAddress = await callerSigner.getAddress();
	console.log("ethAddress: ", ethAddress);
	const timestamp = Date.now();
	console.log("timestamp: ", timestamp);
	let message = ethAddress + timestamp;
	//let message = "0x9B39710bD511bc14Fcb0f64a9D8f8e6F630751Ab1698397046585";
	console.log("Message: ", message);
	
	// Compute hash of the message
	let messageHash = ethers.utils.id(message);
	console.log("Message Hash: ", messageHash);
	
	// Sign the hashed message
	let messageBytes = ethers.utils.arrayify(messageHash);
	let signature = await systemSigner.signMessage(messageBytes);
	console.log("Signature: ", signature);
	
	// read the contract name
    const name = await MintPassNFTContract.name();    
    console.log("The contract name is: " + name); 

	// mint the mintPass
    console.log("Minting MintPass...");
    const tx = await MintPassNFTContract.mintMintPass(messageHash, signature, url, {value: 100000000000000});
	//const tx = await MintPassNFTContract.mintMintPass(messageHash, signature, url, {value: 200000000000000});
    console.log("tx: ", tx);

}

main();