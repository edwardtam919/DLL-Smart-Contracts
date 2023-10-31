import { ethers } from "hardhat";

const mintPass = "0xc1cefC8C23906C3d9662dd40161EB31E7EA13FbE";
const loyaltyFee = 100;

async function main() {
  const ContractFactory = await ethers.getContractFactory("contracts/MindfulNFT.sol:MindfulNFT");
  const instance = await ContractFactory.deploy(mintPass, loyaltyFee);
  await instance.deployed();

  console.log(`Contract deployed to ${instance.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
