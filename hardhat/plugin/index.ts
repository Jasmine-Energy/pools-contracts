// @ts-nocheck

import { extendConfig, extendEnvironment } from "hardhat/config";
import { createProvider } from "hardhat/internal/core/providers/construction";
import {
  HARDHAT_NETWORK_NAME,
  lazyFunction,
  lazyObject,
} from "hardhat/plugins";
import { HardhatConfig, HardhatUserConfig } from "hardhat/types";
import {
  TASK_NODE,
  TASK_TEST,
  TASK_NODE_GET_PROVIDER,
  TASK_NODE_SERVER_READY,
  TASK_FLATTEN_GET_FLATTENED_SOURCE,
  TASK_COMPILE,
} from "hardhat/builtin-tasks/task-names";
import * as JasmineConstants from "../../utils/constants";
import { makeNamedAccounts } from "../accounts";
import deployCore from "../../deploy/plugin/00_deploy_core";
import deployRetirer from "../../deploy/plugin/01_deploy_retirer";
import deployPool from "../../deploy/plugin/02_deploy_pool";
import deployFactory from "../../deploy/plugin/03_deploy_factory";
import { deployTestPools } from "../../deploy/utils/deploy_test_pools";

import "../../tasks/transfer_token";
import "../../tasks/freeze_eat";
import "../../tasks/mint_eat";
import "../../tasks/pools";

// import { TASK_DEPLOY } from "hardhat-deploy";

// import "hardhat-deploy";

import "./type-extension";

export const TASK_DEPLOY_JASMINE_POOLS = "deploy:jasmine-pools";
const localhostNetworkName = "localhost";

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
    // executing hre function ensures that the `config` object is in a valid
    // state for its type, including its extensions. For example, you may
    // need to apply a default value, like in hre example.

    const forkUrl = userConfig.networks?.hardhat?.forking?.url;
    let forkNetwork: "polygon" | "mumbai" | undefined;
    if (!forkUrl) {
      return;
    } else if (forkUrl === userConfig.networks?.polygon?.url) {
      forkNetwork = "polygon";
    } else if (forkUrl === userConfig.networks?.mumbai?.url) {
      forkNetwork = "mumbai";
    } else {
      return;
    }

    const namedAccounts = makeNamedAccounts(forkNetwork);
    const accounts = userConfig.namedAccounts ?? {};

    const accountEntires = Object.entries(namedAccounts).map(
      ([name, value]) => [name, accounts[name] ?? value]
    );

    config.namedAccounts = {
      ...Object.fromEntries(accountEntires),
      ...config.namedAccounts,
    };
  }
);

extendEnvironment((hre) => {
  const existingJasmine = hre.jasmine ?? {};
  hre.jasmine = lazyObject(() => {
    existingJasmine.deployPools = async () => {
      await hre.run(TASK_DEPLOY_JASMINE_POOLS);
    };

    existingJasmine.Constants = lazyObject(() => JasmineConstants);

    return existingJasmine;
  });
});

task(TASK_NODE, "Starts a JSON-RPC server on top of Hardhat EVM")
  .addFlag("skipJasmine", "Skips deployment of Jasmine liquidity pools")
  .addFlag("noPools", "Skips deployment of testing JLT pools")
  .setAction(async (args, hre, runSuper) => {
    if (args.skipJasmine) {
      console.log("u say no deploy? ok, no pool 4 u!");
      await runSuper(args);
      return;
    } else if (args.noPools) {
      console.log("no jasmine pools 4 u!");
      await runSuper(args);
      return;
    }

    await hre.run(TASK_DEPLOY_JASMINE_POOLS, args);

    await runSuper(args);
  });

task(TASK_TEST, "Runs mocha tests")
  .addFlag("skipJasmine", "Skips deployment of Jasmine liquidity pools")
  .addFlag("noPools", "Skips deployment of testing JLT pools")
  .setAction(async (args, hre, runSuper) => {
    if (args.skipJasmine) {
      console.log("u say no deploy? ok, no pool 4 u!");
      await runSuper(args);
      return;
    } else if (args.noPools) {
      console.log("no jasmine pools 4 u!");
      await runSuper(args);
      return;
    }

    await hre.run(TASK_DEPLOY_JASMINE_POOLS, args);

    await runSuper(args);
  });

task(TASK_DEPLOY_JASMINE_POOLS, "Deploys Jasmine Pools")
  .addFlag("skipJasmine", "Skips deployment of Jasmine liquidity pools")
  .addFlag("noPools", "Skips deployment of testing JLT pools")
  .setAction(async (args, hre) => {
    if (args.skipJasmine) {
      console.log("u say no deploy? ok, no pool 4 u!");
      return;
    } else if (args.noPools) {
      console.log("no jasmine pools 4 u!");
      return;
    }

    if (hre.network.name === HARDHAT_NETWORK_NAME) {
      if (!args.verbose) {
        await hre.network.provider.send("hardhat_setLoggingEnabled", [false]);
      }

      if (hre.config.networks[localhostNetworkName]) {
        const localhost = hre.config.networks[localhostNetworkName];
        hre.network.name = localhostNetworkName;
        hre.network.config = localhost;
      }
    }

    await deployCore(hre);
    await deployRetirer(hre);
    await deployPool(hre);
    await deployFactory(hre);

    // if (!args.noPools) {
    //   await deployTestPools(hre);
    // }
    // console.log("Deployed Jasmine Pool Contracts!");

    if (hre.network.name === localhostNetworkName) {
      const hardhat = hre.config.networks[HARDHAT_NETWORK_NAME];
      hre.network.name = HARDHAT_NETWORK_NAME;
      hre.network.config = hardhat;
    }

    if (!args.noPools) {
      await deployTestPools(hre);
    }
    console.log("Deployed Jasmine Pool Contracts!");
  });

task("pool:list")
  //   .addOptionalParam<string>("factory", "Address of Jasmine pool factory")
  .setAction(async (args, hre, runSuper) => {
    if (args.factory) {
      await runSuper(args);
      return;
    }
    const { address: factory } = await hre.deployments.get(
      JasmineConstants.Contracts.factory
    );
    console.log(factory);

    if (
      hre.network.name === HARDHAT_NETWORK_NAME &&
      hre.config.networks[localhostNetworkName]
    ) {
      const localhost = hre.config.networks[localhostNetworkName];
      hre.network.name = localhostNetworkName;
      hre.network.config = localhost;
    }

    await runSuper(
      {
        ...args,
        factory,
      },
      hre
    );
  });
