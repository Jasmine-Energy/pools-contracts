import * as dotenv from "dotenv";

import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-chai-matchers";
import "@nomicfoundation/hardhat-network-helpers";
import "@nomiclabs/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";
import "@primitivefi/hardhat-dodoc";
import "hardhat-abi-exporter";
import "hardhat-contract-sizer";
import "hardhat-dependency-compiler";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import "hardhat-storage-layout";
import "hardhat-tracer";
import "hardhat-interact";
import "solidity-coverage"
import "@typechain/hardhat";

dotenv.config();

import "tsconfig-paths/register";

import { 
  networks, defaultNetwork,
  namedAccounts,
  solidity,
  extensions
} from "./hardhat";

import "./tasks";


const config: HardhatUserConfig = {
  defaultNetwork,
  networks,
  namedAccounts,
  solidity,
  ...extensions
};

export default config;
