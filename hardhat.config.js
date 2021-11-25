require("dotenv").config();

require("@nomiclabs/hardhat-waffle");



/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.9",
  networks: {
    hardhat: {
      chainId: 1337
    },
    ropsten: {
      url: process.env.ROPSTEN_URL,
      accounts: [`0x${PRIVATE_KEY}`]
    },
  }
};
