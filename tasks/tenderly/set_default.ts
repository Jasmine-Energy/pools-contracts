import { colouredLog } from "@/utils";
import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import * as forksFile from "../../tenderly-forks.json";
import Table from "cli-table3";
import colors from "@colors/colors";
import fs from "fs/promises";
import path from "path";


task("fork:default", "Updates default tenderly fork")
  .addPositionalParam<number>("index", "Index of fork")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, network, getChainId, ...hre }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      if (taskArgs.index >= forksFile.total) {
        colouredLog.red("Out of bounds");
        return;
      }
      await fs.writeFile(
        path.join(hre.config.paths.root, "tenderly-forks.json"),
        JSON.stringify({
          total: forksFile.forks.length,
          defaultFork: parseInt(taskArgs.index),
          forks: forksFile.forks,
        })
      );

      const defaultFork = forksFile.forks[taskArgs.index];
      const table = new Table({
        head: ["Index", "Name", "Forked", "Pool ID"],
        style: {
          head: ["yellow"],
          border: [],
        },
        wordWrap: true,
        wrapOnWordBoundary: false,
      });
      table.push([taskArgs.index, defaultFork.name, defaultFork.forked, defaultFork.id])

      console.log(colors.yellow("Default fork set to:"));
      console.log(table.toString());
    }
  );
