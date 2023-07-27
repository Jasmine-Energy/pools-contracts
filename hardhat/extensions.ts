export const extensions = {
  paths: {
    deployments: "deployments",
  },
  abiExporter: {
    path: "./abi",
    format: "json",
    except: [
      "@jasmine-energy",
      "@openzeppelin",
      "@uniswap",
    ],
    runOnCompile: true,
    clear: true,
  },
  typechain: {
    outDir: "./typechain",
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    token: "MATIC",
    gasPriceApi: "https://api.polygonscan.com/api?module=proxy&action=eth_gasPrice",
    currency: "USD",
    outputFile: "./gasReport/gasReport-*.json",
    showTimeSpent: true,
    showMethodSig: true,
  },
  mocha: {
    timeout: 60_000,
  },
  dodoc: {
    exclude: ["elin", "energy", "v3-core", "console"],
    // freshOutput: false // NOTE: Found this fixes annoying iCloud overrides
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  },
  dependencyCompiler: {
    paths: [
      '@jasmine-energy/core-contracts/src/JasmineEAT.sol',
      '@jasmine-energy/core-contracts/src/JasmineMinter.sol',
      '@jasmine-energy/core-contracts/src/JasmineOracle.sol',
    ],
  }
};
