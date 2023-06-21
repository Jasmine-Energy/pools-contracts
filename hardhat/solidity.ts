import { SolidityUserConfig } from "hardhat/types";

export const optimizerRuns = 75;

export const solidity: SolidityUserConfig = {
  compilers: [
    {
      version: "0.8.19",
      settings: {
        optimizer: {
          enabled: true,
          runs: optimizerRuns,
        },
      },
    },
    {
      version: "0.8.17",
      settings: {
        optimizer: {
          enabled: true,
          runs: optimizerRuns,
        },
      },
    },
  ],
};
