import { ethers } from "hardhat";

const systemAddress = "0x4BCC679c78E2C6D724E49B2F59f0F3B0565854D9";
const mintPass = "0xaa250f5d3a78518cd1A077391682388DA650963A";
const loyaltyFee = 800;

async function main() {
  const ContractFactory = await ethers.getContractFactory("contracts/MindfulNFT.sol:MindfulNFT");
  const instance = await ContractFactory.deploy(systemAddress, mintPass, loyaltyFee);
  await instance.deployed();

  console.log(`Contract deployed to ${instance.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
