import {
  NetworksUserConfig,
  HttpNetworkUserConfig,
  HardhatNetworkUserConfig,
} from "hardhat/types";
import { accounts, accountsForNetwork } from "./accounts";
import { disableForking } from "@/utils/environment";

// Network definitions

const localhost: HttpNetworkUserConfig = {
  accounts, //: accountsForNetwork("localhost"),
  url: "http://127.0.0.1:8545",
  tags: ["local"],
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
    enabled: !disableForking,
    blockNumber: process.env.FORK_NUMBER ? parseInt(process.env.FORK_NUMBER) : (forkNetworkName === "polygon" ? 43382100 : 36285100),
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
