import { ethers } from "hardhat";

async function main() {
  const ContractFactory = await ethers.getContractFactory("contracts/MintPass.sol:MintPassNFT");

  const instance = await ContractFactory.deploy("0x4BCC679c78E2C6D724E49B2F59f0F3B0565854D9", "0x1f6A403347fd2d335d14Dc3f1AEb21D9192cF166", "https://xyz.com/", 100000000000000, 100);
  await instance.deployed();

  console.log(`Contract deployed to ${instance.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
