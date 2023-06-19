import { ethers } from "hardhat";

async function main() {
  const ContractFactory = await ethers.getContractFactory("contracts/MindfulNFT.sol:MindfulNFT");
  const instance = await ContractFactory.deploy("0xBAB5c7041b51a202373f522d2A0Cb9516bcbEED8", 100);
  await instance.deployed();

  console.log(`Contract deployed to ${instance.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
