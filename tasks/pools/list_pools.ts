import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { Contracts, tryRequire, makeLinkedTableCell } from "../../utils";
import {
  JasminePoolFactory__factory,
  JasminePool__factory,
} from "../../typechain";
import Table from "cli-table3";

task("pool:list", "Lists all Jasmine pools")
  .addOptionalParam<string>("factory", "Address of Jasmine pool factory")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, deployments, run, network }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      // 1. Check if typechain exists. If not, compile and explicitly generate typings
      if (!tryRequire("@/typechain")) {
        await run("compile");
        await run("typechain");
      }

      // 2. Load contract
      let factoryAddress =
        taskArgs.factory ??
        (await deployments.getOrNull(Contracts.factory)).address;

      if (!factoryAddress) {
        console.log(
          "Error: Cannot find deployment for factory. Please provide address"
        );
        return;
      }

      const defaultSigner = (await ethers.getSigners())[0];
      const factory = JasminePoolFactory__factory.connect(
        factoryAddress,
        defaultSigner
      );

      const totalPools = await factory.totalPools();
      var table = new Table({
        head: ["Index", "Address", "Name", "Symbol"],
        style: {
          head: ["yellow"],
          border: [],
        },
      });

      for (var i = 0; i < totalPools.toNumber(); i++) {
        const poolAddress = await factory.getPoolAtIndex(i);
        const pool = JasminePool__factory.connect(poolAddress, defaultSigner);
        const name = await pool.name();
        const symbol = await pool.symbol();
        table.push([
          i.toString(),
          await makeLinkedTableCell(poolAddress, { run }),
          name,
          symbol,
        ]);
      }

      console.log(table.toString());
    }
  );
