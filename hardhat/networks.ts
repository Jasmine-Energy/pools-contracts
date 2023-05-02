import {
  NetworksUserConfig,
  HttpNetworkUserConfig,
  HardhatNetworkUserConfig,
} from "hardhat/types";
import * as tenderlyForks from "@/tenderly-forks.json";
import { accounts, accountsForNetwork } from "./accounts";

// Network definitions

const localhost: HttpNetworkUserConfig = {
  accounts, //: accountsForNetwork("localhost"),
  url: "http://127.0.0.1:8545",
  tags: ["local"],
};

const tenderly: HttpNetworkUserConfig = {
  accounts, //: accountsForNetwork("tenderly"),
  url: `https://rpc.tenderly.co/fork/${
    tenderlyForks.forks[tenderlyForks.defaultFork].id ??
    "20e808f7-4569-4778-933b-87706fac8e39"
  }`,
  tags: ["tenderly"],
};

const mumbai: HttpNetworkUserConfig = {
  accounts, //: accountsForNetwork("mumbai"),
  url: process.env.INFURA_API_KEY
    ? `https://polygon-mumbai.infura.io/v3/${process.env.INFURA_API_KEY}`
    : process.env.MUMBAI_RPC_URL ?? "",
  chainId: 80001,
  saveDeployments: true,
  tags: ["testnet", "public"],
};

const polygon: HttpNetworkUserConfig = {
  live: true,
  accounts: accountsForNetwork("polygon", false),
  url: process.env.INFURA_API_KEY
    ? `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`
    : process.env.POLYGON_RPC_URL ?? "",
  chainId: 137,
  saveDeployments: true,
  tags: ["production", "public"],
};

// Define external networks & Hardhat network

export const externalNetworks: {
  [networkName: string]: HttpNetworkUserConfig;
} = {
  localhost,
  tenderly,
  mumbai,
  polygon,
};

export const forkNetworkName = process.env.FORK_NETWORK ?? "polygon";
export const forkNetwork: HttpNetworkUserConfig = externalNetworks[forkNetworkName];

const hardhat: HardhatNetworkUserConfig = {
  chainId: 31337,
  loggingEnabled: true,
  accounts,
  forking: {
    url: forkNetwork.url!,
  },
  saveDeployments: true,
  autoImpersonate: true,
  tags: ["local"],
};

// Exports

export const externalNetworkNames = Object.keys(externalNetworks);
type ExternalNetworkType = (typeof externalNetworkNames)[number];

export const defaultNetwork: ExternalNetworkType =
  process.env.DEFAULT_NETWORK ?? "localhost";

export const networks: NetworksUserConfig = {
  hardhat,
  ...externalNetworks,
};
