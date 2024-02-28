import { ethers } from "hardhat";

const systemAddress = "0x4BCC679c78E2C6D724E49B2F59f0F3B0565854D9";
const mintingFeeRecipient = "0xEb9aac7B6219a8aBAa4eb86cD1955c956442C201";
//const mintingFeeRecipient1 = "0xEb9aac7B6219a8aBAa4eb86cD1955c956442C201";
//const mintingFeeRecipient2 = "0xe0602B33B6321d78D72EB899ac3906130c35f0D8";
//const mintingFeeRecipient3 = "0x1D2c37fACD8f1237D580722696821C05bAF8F82F";
const mintingFee = 100000000000000;
const loyaltyFee = 800;

async function main() {
  const ContractFactory = await ethers.getContractFactory("contracts/MintPass.sol:MintPassNFT");
  //const instance = await ContractFactory.deploy(systemAddress, mintingFeeRecipient1, mintingFeeRecipient2, mintingFeeRecipient3, mintingFee, loyaltyFee);
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
