import { SolidityUserConfig } from "hardhat/types";

const defaultOptimizerRuns = process.env.OPTIMIZER_RUNS
  ? parseInt(process.env.OPTIMIZER_RUNS)
  : 400;
// NOTE: When compiling with solc 0.8.20, need to specify evmVersion below shanghai due to the PUSH0 opcode (only on mainnet)
const evmVersion = process.env.EVM_VERSION || "paris";

export const solidity: SolidityUserConfig = {
  compilers: [
    {
      version: "0.8.23",
      settings: {
        optimizer: {
          enabled: true,
          runs: defaultOptimizerRuns,
        },
      },
    },
    {
      version: "0.8.20",
      settings: {
        optimizer: {
          enabled: true,
          runs: defaultOptimizerRuns,
        },
        evmVersion,
      },
    },
    {
      version: "0.8.17",
      settings: {
        viaIR: true,
        optimizer: {
          enabled: true,
          runs: defaultOptimizerRuns,
        },
      },
    },
  ],
};
