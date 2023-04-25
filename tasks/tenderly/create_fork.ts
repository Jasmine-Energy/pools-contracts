import { colouredLog } from "@/utils";
import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { Tenderly, TenderlyEndpoints } from "@/utils/constants";
import { anAxiosOnTenderly, TenderlyFork } from "@/utils/tenderly";
import * as forksFile from "../../tenderly-forks.json";
import Table from "cli-table3";
import fs from "fs/promises";
import path from "path";


task("fork", "Creates a tenderly fork of network")
  .addOptionalParam<string>("name", "Optional name to save fork as")
  .addOptionalParam<string>("block", "Block to fork from")
  .addFlag("default", "Sets new fork to default")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, network, getChainId, run, ...hre }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      const chainId = await getChainId();
      var fork: TenderlyFork = {
        network_id: chainId,
      };

      if (taskArgs.block) {
        fork.block_number = parseInt(taskArgs.block);
      }

      const axiosOnTenderly = anAxiosOnTenderly();
      const forkResponse = await axiosOnTenderly.post(
        Tenderly.endpoints(TenderlyEndpoints.fork),
        fork
      );

      if (forkResponse.status != 201) {
        if (hre.hardhatArguments.verbose) {
          console.log(forkResponse);
          colouredLog.red("Failed. See above response");
        } else {
          colouredLog.red("Failed");
        }
        return;
      }

      const { simulation_fork } = forkResponse.data;

      const name =
        taskArgs.name ??
        `${network.name} Fork from ${new Date(
          simulation_fork.created_at
        ).toLocaleString()}`;

      var updatesForks = forksFile;
      updatesForks.forks.push({
        name,
        forked: network.name,
        ...simulation_fork,
      });

      await fs.writeFile(
        path.join(hre.config.paths.root, "tenderly-forks.json"),
        JSON.stringify({
          total: updatesForks.forks.length,
          defaultFork: updatesForks.defaultFork,
          forks: updatesForks.forks,
        })
      );

      colouredLog.blue(
        "Fork created".concat(taskArgs.default ? " and set to default!" : "!")
      );
      const head = ["Index", "Name", "Forked", "Pool ID"];
      var table = new Table({
        head,
        style: {
          head: ["yellow"],
          border: [],
        },
        wordWrap: true,
        wrapOnWordBoundary: false,
      });
      table.push([
        updatesForks.forks.length - 1,
        name,
        network.name,
        {
          content: simulation_fork.id,
          href: `${Tenderly.forksDashboard}/${simulation_fork.id}`,
        },
      ]);

      console.log(table.toString());

      await run("fork:default", {
        index: (updatesForks.forks.length - 1).toString(),
        silent: true,
        force: true,
      });
    }
  );
