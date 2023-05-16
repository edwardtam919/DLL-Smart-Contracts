require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require("@nomicfoundation/hardhat-chai-matchers")

const polytestnet_PRIVATE_KEY = "78501fb8da333ed1c8312a2a4138bde909e280519157d5cac7e627222f2886b9";

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.17",
  networks: {
    polytestnet: {
      url: `https://rpc-mumbai.maticvigil.com`,
      accounts: [polytestnet_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: "IYMSWKVVCMDEKEXUBV4NRXEBN8BZ7GZB4E",
  }
};
