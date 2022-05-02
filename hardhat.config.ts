import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat"
import "@nomiclabs/hardhat-truffle5";
import { task, HardhatUserConfig } from "hardhat/config";
import { resolve } from "path";

import { config as dotenvConfig } from "dotenv";
dotenvConfig({ path: resolve(__dirname, "./.env") });

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  solidity: '0.8.3',
  typechain: {
    outDir: 'typechain',
    target: 'ethers-v5',
    alwaysGenerateOverloads: false // should overloads with full signatures like deposit(uint256) be generated always, even if there are no overloads?
  },
  mocha: {
    timeout: 10000000,
  },
  etherscan: {
    // Your API key for Etherscan
    // Obtain one at https://etherscan.io/
    apiKey: {
      ropsten: '8HHE3RBH3MZ29E9I9XYP8VP6D9SQIINUIU'
    }
  },
  gasReporter: {
    currency: 'USD',
    gasPrice: 20,
    token: 'ETH',
    gasPriceApi: 'https://api.etherscan.io/api?module=proxy&action=eth_gasPrice',
    coinmarketcap: 'f6673cc5-a673-4e07-8461-f7281a5de7d7',
    onlyCalledMethods: false
  }
}