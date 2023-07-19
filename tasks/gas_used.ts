import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { colouredLog } from "@/utils";

task("gas-used", "Compute the total gas used for deployment")
    .addFlag("all", "Prints all gas used for each contract")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { deployments, network, hardhatArguments }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      const contracts = await deployments.all();
      if (Object.values(contracts).length === 0) {
        colouredLog.red("Error: No contracts found");
        return;
      }

      let gas = 0;
      for (const contract of Object.values(contracts)) {
        if (taskArgs.all || hardhatArguments.verbose) {
          colouredLog.yellow(
            `Gas used for ${contract.devdoc.title ?? contract.address}: ${contract.receipt?.gasUsed}`
          );
        }

        gas += parseInt(contract.receipt?.gasUsed as string);
      }
      colouredLog.blue(`Total gas used: ${gas} on network: ${network.name}`);
    }
  );
