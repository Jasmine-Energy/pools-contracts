import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-chai-matchers"
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@openzeppelin/hardhat-upgrades";
import "hardhat-abi-exporter";
import "hardhat-contract-sizer"
import "hardhat-deploy";
import "hardhat-interact";
import "@typechain/hardhat";

import "tsconfig-paths/register";

import "./tasks";

dotenv.config();

// TODO Move this
const mnemonic = "tattoo clip ankle prefer cruise car motion borrow bread future legal system";
const accounts = {
  mnemonic: mnemonic,
  path: "m/44'/60'/0'/0",
  initialIndex: 0,
  count: 10,
  passphrase: "",
};

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 250,
          },
        },
      },
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 250,
          },
        },
      },
    ],
  },
  networks: {
    hardhat: {
      chainId: 31337,
      loggingEnabled: true,
      accounts,
      forking: {
        url: `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      },
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    mumbai: {
      url: "https://matic-testnet-archive-rpc.bwarelabs.com",
      chainId: 80001,
    },
    polygon: {
      url: `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
      chainId: 137
    }
  },
  abiExporter: {
    path: "./abi",
    runOnCompile: true,
    pretty: true,
  },
  typechain: {
    outDir: "./typechain",
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  }
};

export default config;
