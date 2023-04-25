import { HDAccountsUserConfig, HttpNetworkAccountsUserConfig } from "hardhat/types";
import { forkNetwork, networks } from "./networks";

const mnemonic =
  process.env.MNEMONIC ?? "tattoo clip ankle prefer cruise car motion borrow bread future legal system";
export const accounts = {
  mnemonic: mnemonic,
  path: "m/44'/60'/0'/0",
  initialIndex: 0,
  count: 10,
  passphrase: "",
};

export function accountsForNetwork(
    networkName: string,
    allowDefault: boolean = true
): HttpNetworkAccountsUserConfig | undefined {
    if (process.env[`${networkName.toLocaleUpperCase()}_MNEMONIC`]) {
        return {
            mnemonic: process.env[`${networkName.toLocaleUpperCase()}_MNEMONIC`],
            path: "m/44'/60'/0'/0",
            initialIndex: 0,
            count: 10,
            passphrase: "",
          } as HDAccountsUserConfig;
    } else if (process.env[`${networkName.toLocaleUpperCase()}_PRIV_KEY`]) {
        return [ process.env[`${networkName.toLocaleUpperCase()}_PRIV_KEY`] ] as HttpNetworkAccountsUserConfig;
    } else {
        return allowDefault ? accounts : undefined;
    }
}

export const namedAccounts = {
  // Deployer accounts
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
  // Core contracts
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
  // Tokens
  usdc: {
    polygon: "0x2791bca1f2de4661ed88a30c99a7a9449aa84174",
    mumbai: "0x0FA8781a83E46826621b3BC094Ea2A0212e71B23",
    // TODO: Determine based on fork network
    localhost: "0x2791bca1f2de4661ed88a30c99a7a9449aa84174",
    hardhat: "0x2791bca1f2de4661ed88a30c99a7a9449aa84174",
  },
  // UniSwap contracts
  uniswapRouter: {
    polygon: "0x4C60051384bd2d3C01bfc845Cf5F4b44bcbE9de5",
    mumbai: "0x4648a43B2C14Da09FdF82B161150d3F634f40491",
    // TODO: Determine based on fork network
    localhost: "0x4C60051384bd2d3C01bfc845Cf5F4b44bcbE9de5",
    hardhat: "0x4C60051384bd2d3C01bfc845Cf5F4b44bcbE9de5",
  },
  uniswapPoolFactory: {
    default: "0x1F98431c8aD98523631AE4a59f267346ea31F984",
  },
  permit2: {
    default: "0x000000000022D473030F116dDEE9F6B43aC78BA3",
  },
};
