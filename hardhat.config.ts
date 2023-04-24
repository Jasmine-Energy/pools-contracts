import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";
import * as tenderlyForks from "./tenderly-forks.json";
import * as tenderly from "@tenderly/hardhat-tenderly";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-network-helpers";
import "@nomiclabs/hardhat-ethers";
import "@nomiclabs/hardhat-etherscan";
import "@openzeppelin/hardhat-upgrades";
import "@primitivefi/hardhat-dodoc";
import "@uniswap/hardhat-v3-deploy";
import "hardhat-abi-exporter";
import "hardhat-contract-sizer";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import "hardhat-deploy-tenderly";
import "hardhat-tracer";
import "hardhat-interact";
import "@typechain/hardhat";

import "tsconfig-paths/register";

import "./tasks";

dotenv.config();
tenderly.setup();

// TODO Move this
const mnemonic =
  "tattoo clip ankle prefer cruise car motion borrow bread future legal system";
const accounts = {
  mnemonic: mnemonic,
  path: "m/44'/60'/0'/0",
  initialIndex: 0,
  count: 10,
  passphrase: "",
};

const config: HardhatUserConfig = {
  defaultNetwork: "localhost",
  networks: {
    hardhat: {
      chainId: 31337,
      loggingEnabled: true,
      accounts,
      forking: {
        url: process.env.INFURA_API_KEY
          ? `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`
          : process.env.HARDHAT_FORK_RPC_URL ?? "",
      },
      saveDeployments: true,
      tags: ["local"],
    },
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    tenderly: {
      accounts,
      url: `https://rpc.tenderly.co/fork/${
        tenderlyForks.forks[tenderlyForks.defaultFork].id ??
        "20e808f7-4569-4778-933b-87706fac8e39"
      }`,
      tags: ["tenderly"],
    },
    mumbai: {
      url: process.env.INFURA_API_KEY
        ? `https://polygon-mumbai.infura.io/v3/${process.env.INFURA_API_KEY}`
        : process.env.MUMBAI_RPC_URL ?? "",
      chainId: 80001,
      saveDeployments: true,
      tags: ["testnet", "public"],
    },
    polygon: {
      live: true,
      url: process.env.INFURA_API_KEY
        ? `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`
        : process.env.POLYGON_RPC_URL ?? "",
      chainId: 137,
      saveDeployments: true,
      tags: ["production", "public"],
    },
  },
  namedAccounts: {
    owner: {
      default: 0,
    },
    bridge: {
      default: 1,
      // TODO: Set to correct address on Polygon and mumbai
    },
    feeBeneficiary: {
      default: 5,
    },
    eat: {
      polygon: "0xba3aa8083f8978257aaafb19ed698a623197a7c1",
      mumbai: "0xae205e00c7dcb5292388bd8962e79582a5ae14d0",
    },
    minter: {
      polygon: "0x5e71fa178f3b8ca0fc4736b8a85a1b669c042dde",
      mumbai: "0xe9c135b9fb2942982e3df5b89a03e51d8ee6cb74",
    },
    oracle: {
      polygon: "0x954f12ab1e40fbd7c28f2ab5285d3c74ba6faf6f",
      mumbai: "0x3f3f61a613504166302c5ee3546b0e85c0a61934",
    },
  },
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
  paths: {
    deployments: "deployments",
  },
  abiExporter: {
    path: "./abi",
    runOnCompile: true,
    pretty: true,
  },
  typechain: {
    outDir: "./typechain",
  },
  dodoc: {
    exclude: ["elin", "energy"],
    // freshOutput: false // NOTE: Found this fixes annoying iCloud overrides
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  tenderly: {
    project: "reference-pools",
    username: "Jasmine",
  },
};

export default config;
