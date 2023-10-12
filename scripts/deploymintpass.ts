import { ethers } from "hardhat";

const systemAddress = "0x4BCC679c78E2C6D724E49B2F59f0F3B0565854D9"; 
const mintingFeeRecipient = "0x1f6A403347fd2d335d14Dc3f1AEb21D9192cF166";
const mintingFee = 100000000000000;
const loyaltyFee = 100;

async function main() {
  const ContractFactory = await ethers.getContractFactory("contracts/MintPass.sol:MintPassNFT");
  const instance = await ContractFactory.deploy(systemAddress, mintingFeeRecipient, mintingFee, loyaltyFee);
  await instance.deployed();

  console.log(`Contract deployed to ${instance.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
