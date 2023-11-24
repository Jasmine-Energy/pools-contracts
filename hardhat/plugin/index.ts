// @ts-nocheck

import { extendConfig, extendEnvironment } from "hardhat/config";
import { lazyFunction, lazyObject } from "hardhat/plugins";
import { HardhatConfig, HardhatUserConfig } from "hardhat/types";
import {
  TASK_NODE,
  TASK_TEST,
  TASK_NODE_GET_PROVIDER,
  TASK_NODE_SERVER_READY,
  TASK_FLATTEN_GET_FLATTENED_SOURCE,
  TASK_COMPILE,
} from "hardhat/builtin-tasks/task-names";
import fs from "fs";
import path from "path";
import deployCore from "../../deploy/plugin/00_deploy_core";
import deployRetirer from "../../deploy/plugin/01_deploy_retirer";
import deployPool from "../../deploy/plugin/02_deploy_pool";
import deployFactory from "../../deploy/plugin/03_deploy_factory";

// import { TASK_DEPLOY } from "hardhat-deploy";

// import "hardhat-deploy";

import "./type-extension";

extendConfig(
  (config: HardhatConfig, userConfig: Readonly<HardhatUserConfig>) => {
    // We apply our default config here. Any other kind of config resolution
    // or normalization should be placed here.
    //
    // `config` is the resolved config, which will be used during runtime and
    // you should modify.
    // `userConfig` is the config as provided by the user. You should not modify
    // it.
    //
    // If you extended the `HardhatConfig` type, you need to make sure that
    // executing this function ensures that the `config` object is in a valid
    // state for its type, including its extensions. For example, you may
    // need to apply a default value, like in this example.
    // const userPath = userConfig.paths?.newPath;
    // let newPath: string;
    // if (userPath === undefined) {
    //   newPath = path.join(config.paths.root, "newPath");
    // } else {
    //   if (path.isAbsolute(userPath)) {
    //     newPath = userPath;
    //   } else {
    //     // We resolve relative paths starting from the project's root.
    //     // Please keep this convention to avoid confusion.
    //     newPath = path.normalize(path.join(config.paths.root, userPath));
    //   }
    // }
    // config.paths.newPath = newPath;
  }
);

extendEnvironment((hre) => {
  // We add a field to the Hardhat Runtime Environment here.
  // We use lazyObject to avoid initializing things until they are actually
  // needed.
  //   hre.deployPools = lazyFunction(() => {
  //     return async () => {
  //       console.log("deploying!");
  //       await hre.run("deploy", { tags: "JasminePools" });
  //       console.log("Done!");
  //     };
  //   });

  const existingJasmine = hre.jasmine ?? {};
  hre.jasmine = lazyObject(() => {
    existingJasmine.deployPools = async () => {
      console.log("lol, no deploy 4 u!");
      //   await hre.run("deploy:runDeploy", {
      //     // TODO: Pass existing node args
      //     tags: "JasminePools",
      //   });
      //   console.log("Done!");
    };

    return existingJasmine;
  });
});

task(TASK_NODE, "Starts a JSON-RPC server on top of Hardhat EVM")
  .addFlag("noPools", "deploy Jasmien liquidity pools locally")
  .setAction(async (args, hre, runSuper) => {
    if (args.noDeploy) {
      console.log("u say no deploy? ok, no pool 4 u!");
      await runSuper(args);
      return;
    } else if (args.noPools) {
      console.log("no jasmine pools 4 u!");
      await runSuper(args);
      return;
    }
    // let running = true;

    // await hre.run("deploy", {
    //   // TODO: Pass existing node args
    //   ...args,
    //   tags: "JasminePools",
    // });

    // const directory = hre.config.paths.sources;
    // const buildFile = path.resolve(directory, ".JasmineContracts.sol");

    // console.log(`Build file is: ${buildFile}`);
    // const poolCode = await hre.run(TASK_FLATTEN_GET_FLATTENED_SOURCE, {
    //   file: [
    //     "node_modules/@jasmine-energy/pools-contracts/contracts/JasminePool.sol",
    //   ],
    // });

    // console.log(typeof poolCode);

    // Check file existance
    // fs.writeFileSync(buildFile, poolCode);
    //     fs.writeFileSync(
    //       buildFile,
    //       `// SPDX-License-Identifier: MIT
    // pragma solidity ^0.8.0;

    // import "@jasmine-energy/pools-contracts/contracts/JasminePool.sol";
    // import "@jasmine-energy/pools-contracts/contracts/JasminePoolFactory.sol";
    // import "@jasmine-energy/pools-contracts/contracts/JasmineRetirementService.sol";`
    //     );

    // await hre.run(TASK_COMPILE, {
    //   force: true,
    //   ...args,
    // });

    // fs.rmFileSync(buildFile);

    await deployCore(hre);
    await deployRetirer(hre);
    await deployPool(hre);
    await deployFactory(hre);

    console.log("Done!");

    await runSuper(args);
  });
