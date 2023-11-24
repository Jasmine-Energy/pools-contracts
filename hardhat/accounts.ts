import {
  HDAccountsUserConfig,
  HttpNetworkAccountsUserConfig,
} from "hardhat/types";
import { PERMIT2_ADDRESS } from "@uniswap/permit2-sdk";

const mnemonic =
  process.env.MNEMONIC ??
  "tattoo clip ankle prefer cruise car motion borrow bread future legal system";
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
    return [
      process.env[`${networkName.toLocaleUpperCase()}_PRIV_KEY`],
    ] as HttpNetworkAccountsUserConfig;
  } else {
    return allowDefault ? accounts : undefined;
  }
}

export const makeNamedAccounts = (forkNetwork?: "mumbai" | "polygon") => {
  return {
    owner: {
      default: 0,
      mumbai: "0xe3a305455c71944EC7C5b85b845c617FA6F6CCD7",
      polygon: "0xe3a305455c71944EC7C5b85b845c617FA6F6CCD7",
    },
    bridge: {
      polygon: "0xf752f0300333d53982dd8c128ca077f17cb8c405",
      mumbai: "0x2dcad29de8a67d70b7b5bf32b19f1480f333d8dd",
      default: 3,
    },
    deployer: {
      default: 2,
      mumbai: 0,
      polygon: 0,
    },
    feeBeneficiary: {
      default: 5,
      mumbai: "0xc6e9B1a30E604cE6c2d32e33B290286b6c1cE555",
      polygon: "0xc6e9B1a30E604cE6c2d32e33B290286b6c1cE555",
    },
    poolManager: {
      default: 6,
      mumbai: 1,
      polygon: 1,
    },
    feeManager: {
      default: 7,
      mumbai: "0xe3a305455c71944EC7C5b85b845c617FA6F6CCD7",
      polygon: "0xe3a305455c71944EC7C5b85b845c617FA6F6CCD7",
    },
    fuzzingContract: {
      // Account # 9
      hardhat: "0x16C638286AC9777ddb57Db734C34919E80346474",
      localhost: "0x16C638286AC9777ddb57Db734C34919E80346474",
    },
    // Core contracts
    eat: {
      polygon: "0xba3aa8083F8978257aAAFB19Ed698a623197A7C1",
      mumbai: "0xae205e00c7dcb5292388bd8962e79582a5ae14d0",
      get localhost() {
        return this[forkNetwork];
      },
      get hardhat() {
        return this[forkNetwork];
      },
    },
    minter: {
      polygon: "0x5E71fa178F3b8cA0FC4736B8A85a1B669c042DdE",
      mumbai: "0xe9c135b9fb2942982e3df5b89a03e51d8ee6cb74",
      get localhost() {
        return this[forkNetwork];
      },
      get hardhat() {
        return this[forkNetwork];
      },
    },
    oracle: {
      polygon: "0x954F12aB1e40fbD7C28f2ab5285d3C74bA6faf6f",
      mumbai: "0x3f3f61a613504166302c5ee3546b0e85c0a61934",
      get localhost() {
        return this[forkNetwork];
      },
      get hardhat() {
        return this[forkNetwork];
      },
    },
    // Tokens
    USDC: {
      polygon: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
      mumbai: "0x0FA8781a83E46826621b3BC094Ea2A0212e71B23",
      get localhost() {
        return this[forkNetwork];
      },
      get hardhat() {
        return this[forkNetwork];
      },
    },
    WMATIC: {
      polygon: "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270",
      mumbai: "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889",
      get localhost() {
        return this[forkNetwork];
      },
      get hardhat() {
        return this[forkNetwork];
      },
    },
    // UniSwap contracts
    uniswapRouter: {
      polygon: "0x4C60051384bd2d3C01bfc845Cf5F4b44bcbE9de5",
      mumbai: "0x4648a43B2C14Da09FdF82B161150d3F634f40491",
      get localhost() {
        return this[forkNetwork];
      },
      get hardhat() {
        return this[forkNetwork];
      },
    },
    uniswapPoolFactory: {
      default: "0x1F98431c8aD98523631AE4a59f267346ea31F984",
    },
    permit2: {
      default: PERMIT2_ADDRESS,
    },
  };
};

// export const namedAccounts = {
//   // Deployer accounts
//   owner: {
//     default: 0,
//     mumbai: "0xe3a305455c71944EC7C5b85b845c617FA6F6CCD7",
//     polygon: "0xe3a305455c71944EC7C5b85b845c617FA6F6CCD7",
//   },
//   bridge: {
//     polygon: "0xf752f0300333d53982dd8c128ca077f17cb8c405",
//     mumbai: "0x2dcad29de8a67d70b7b5bf32b19f1480f333d8dd",
//     default: 3,
//   },
//   deployer: {
//     default: 2,
//     mumbai: 0,
//     polygon: 0,
//   },
//   feeBeneficiary: {
//     default: 5,
//     mumbai: "0xc6e9B1a30E604cE6c2d32e33B290286b6c1cE555",
//     polygon: "0xc6e9B1a30E604cE6c2d32e33B290286b6c1cE555",
//   },
//   poolManager: {
//     default: 6,
//     mumbai: 1,
//     polygon: 1,
//   },
//   feeManager: {
//     default: 7,
//     mumbai: "0xe3a305455c71944EC7C5b85b845c617FA6F6CCD7",
//     polygon: "0xe3a305455c71944EC7C5b85b845c617FA6F6CCD7",
//   },
//   fuzzingContract: {
//     // Account # 9
//     hardhat: "0x16C638286AC9777ddb57Db734C34919E80346474",
//     localhost: "0x16C638286AC9777ddb57Db734C34919E80346474",
//   },
//   // Core contracts
//   eat: {
//     polygon: "0xba3aa8083F8978257aAAFB19Ed698a623197A7C1",
//     mumbai: "0xae205e00c7dcb5292388bd8962e79582a5ae14d0",
//     get localhost() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//     get hardhat() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//   },
//   minter: {
//     polygon: "0x5E71fa178F3b8cA0FC4736B8A85a1B669c042DdE",
//     mumbai: "0xe9c135b9fb2942982e3df5b89a03e51d8ee6cb74",
//     get localhost() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//     get hardhat() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//   },
//   oracle: {
//     polygon: "0x954F12aB1e40fbD7C28f2ab5285d3C74bA6faf6f",
//     mumbai: "0x3f3f61a613504166302c5ee3546b0e85c0a61934",
//     get localhost() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//     get hardhat() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//   },
//   // Tokens
//   USDC: {
//     polygon: "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174",
//     mumbai: "0x0FA8781a83E46826621b3BC094Ea2A0212e71B23",
//     get localhost() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//     get hardhat() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//   },
//   WMATIC: {
//     polygon: "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270",
//     mumbai: "0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889",
//     get localhost() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//     get hardhat() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//   },
//   // UniSwap contracts
//   uniswapRouter: {
//     polygon: "0x4C60051384bd2d3C01bfc845Cf5F4b44bcbE9de5",
//     mumbai: "0x4648a43B2C14Da09FdF82B161150d3F634f40491",
//     get localhost() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//     get hardhat() {
//       return this[forkNetworkName as "polygon" | "mumbai"];
//     },
//   },
//   uniswapPoolFactory: {
//     default: "0x1F98431c8aD98523631AE4a59f267346ea31F984",
//   },
//   permit2: {
//     default: PERMIT2_ADDRESS,
//   },
// };
