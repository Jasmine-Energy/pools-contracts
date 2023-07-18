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
      '@jasmine-energy/contracts/src/JasmineEAT.sol',
      '@jasmine-energy/contracts/src/JasmineMinter.sol',
      '@jasmine-energy/contracts/src/JasmineOracle.sol',
    ],
  }
};
