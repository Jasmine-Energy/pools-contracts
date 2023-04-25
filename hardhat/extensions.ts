export const extensions = {
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
