import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { colouredLog, Contracts, tryRequire } from "../../utils";

task("pool:at", "Transfers an EAT")
  .addPositionalParam<number>("index", "Pool index to get from factory")
  .addOptionalParam<string>("factory", "Address of Jasmine pool factory")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, deployments, run }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      // 1. Check if typechain exists. If not, compile and explicitly generate typings
      if (!tryRequire("@/typechain")) {
        await run("compile");
        await run("typechain");
      }
      // @ts-ignore
      const { JasminePoolFactory__factory } = await import("@/typechain");

      // 2. Load contract
      const factoryDeployment = await deployments.get(Contracts.factory);
      const factory = JasminePoolFactory__factory.connect(
        taskArgs.factory ?? factoryDeployment.address,
        (await ethers.getSigners())[0]
      );

      const totalPools = await factory.totalPools();

      if (totalPools < taskArgs.index) {
        colouredLog.red("Out of bound");
        return;
      }

      const pool = await factory.getPoolAtIndex(taskArgs.index);
      colouredLog.blue(`Pool at ${taskArgs.index} is ${pool}`);
    }
  );
