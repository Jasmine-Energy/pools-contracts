import { colouredLog } from "@/utils";
import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { TENDERLY_FORK_DASHBOARD } from "@/utils/constants";
import * as forksFile from "../../tenderly-forks.json";
import Table from "cli-table3";
import colors from "@colors/colors";
import fs from "fs/promises";
import path from "path";


task("fork:default", "Updates default tenderly fork")
  .addOptionalPositionalParam<number>("index", "Index of fork")
  .addFlag("silent", "Does not log except for fails")
  .addFlag("force", "Does not check index within forks")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, network, getChainId, ...hre }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      const forkIndex = taskArgs.index ?? forksFile.defaultFork;
      const defaultFork = forksFile.forks[forkIndex];

      if (taskArgs.index >= forksFile.total && !taskArgs.force) {
        colouredLog.red("Out of bounds");
        return;
      } else if (taskArgs.index) {
        await fs.writeFile(
            path.join(hre.config.paths.root, "tenderly-forks.json"),
            JSON.stringify({
              total: forksFile.forks.length,
              defaultFork: parseInt(taskArgs.index),
              forks: forksFile.forks,
            })
          );
      }

      const table = new Table({
        head: ["Index", "Name", "Forked", "Pool ID"],
        style: {
          head: ["yellow"],
          border: [],
        },
        wordWrap: true,
        wrapOnWordBoundary: false,
      });
      table.push([forkIndex, defaultFork.name, defaultFork.forked, { content: defaultFork.id, href: `${TENDERLY_FORK_DASHBOARD}/${defaultFork.id}` }])

      if (taskArgs.silent) {
        return;
      }
      console.log(colors.yellow("Default fork set to:"));
      console.log(table.toString());
    }
  );
