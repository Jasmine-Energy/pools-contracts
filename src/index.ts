// ABI Exports
// export { default as JasminePoolABI } from "../abi/contracts/JasminePool.sol/JasminePool.json";
// export { default as JasminePoolFactoryABI } from "../abi/contracts/JasminePoolFactory.sol/JasminePoolFactory.json";
// export { default as JasmineRetirementServiceABI } from "../abi/contracts/JasmineRetirementService.sol/JasmineRetirementService.json";
// Typechain Exports
const typechainContracts = require("../typechain/contracts");
const typechainFactories = require("../typechain/factories/contracts");

// export { JasminePool__factory as JasminePoolContractFactory } from "../typechain/factories/contracts/JasminePool__factory";
// export { JasminePoolFactory__factory as JasminePoolFactoryContractFactory } from "../typechain/factories/contracts/JasminePoolFactory__factory";
// export { JasmineRetirementService__factory as JasmineRetirementServiceContractFactory } from "../typechain/factories/contracts/JasmineRetirementService__factory";
// Utils Exports
// export * as utils from "../utils";
const utils = require("../utils");
// export * from "../utils";
// Types
// export * as types from "../types";
// export * from "../types";
const types = require("../types");

// import "../hardhat/plugin";
const plugin = require("../hardhat/plugin");
// Deploy Scripts

module.exports = {
  typechain: {
    contracts: typechainContracts,
    factories: typechainFactories,
  },
  utils,
  types,
  plugin,
};
