import { ethers } from "hardhat";

async function main() {
  const ContractFactory = await ethers.getContractFactory("contracts/MindfulNFT.sol:MindfulNFT");

  const instance = await ContractFactory.deploy("0xd512aBB7CCC8072b7b98C8EaA4778AdCBD8993F8", "https://123.com/", 100);
  await instance.deployed();

  console.log(`Contract deployed to ${instance.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
