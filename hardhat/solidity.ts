import { SolidityUserConfig } from "hardhat/types";

const defaultOptimizerRuns = process.env.OPTIMIZER_RUNS ? parseInt(process.env.OPTIMIZER_RUNS) : 200;

export const solidity: SolidityUserConfig = {
  compilers: [
    {
      version: "0.8.19", // TODO: Bump to 0.8.20
      settings: {
        optimizer: {
          enabled: true,
          runs: defaultOptimizerRuns,
        },
      },
    },
    {
      version: "0.8.17",
      settings: {
        optimizer: {
          enabled: true,
          runs: defaultOptimizerRuns,
        },
      },
    },
  ],
};
