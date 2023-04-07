import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import * as forksFile from "../../tenderly-forks.json";
import { colouredLog } from "@/utils";
import colors from "@colors/colors";
import fs from "fs/promises";
import axios from "axios";
import path from "path";

task("fork:remove", "Deletes a tenderly fork")
  .addOptionalPositionalParam<number>("index", "Index of fork to delete")
  .addFlag("last", "Removes last fork")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, network, getChainId, ...hre }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      // 1. Require index to be set, or --last flag to be provided
      if (!taskArgs.index && !taskArgs.last) {
        colouredLog.red("Must specify fork to remove");
        return;
      }
      // 2. Assign index from task args or set to last item (presuming last flag set)
      const index = taskArgs.index ?? forksFile.total - 1;
      if (index >= forksFile.total) {
        colouredLog.red("Out of bounds");
        return;
      }

      const anAxiosOnTenderly = () =>
        axios.create({
          baseURL: "https://api.tenderly.co/api/v1",
          headers: {
            "X-Access-Key": process.env.TENDERLY_API_KEY || "",
            "Content-Type": "application/json",
          },
        });

      const projectUrl = "account/Jasmine/project/reference-pools";
      const axiosOnTenderly = anAxiosOnTenderly();
      const resp = await axiosOnTenderly.delete(
        `${projectUrl}/fork/${forksFile.forks[index].id}`
      );

      if (resp.status != 204) {
        if (hre.hardhatArguments.verbose) {
          console.log(resp);
          colouredLog.red("Failed. See above response");
        } else {
          colouredLog.red("Failed");
        }
        return;
      }

      const removed = forksFile.forks[index];
      var updatesForks = forksFile;
      updatesForks.forks.splice(index, 1);

      await fs.writeFile(
        path.join(hre.config.paths.root, "tenderly-forks.json"),
        JSON.stringify({
          total: updatesForks.forks.length,
          defaultFork:
            index >= updatesForks.forks.length - 1
              ? 0
              : updatesForks.defaultFork,
          forks: updatesForks.forks,
        })
      );

      console.log(colors.blue(`Fork at index: ${colors.yellow(index)} named: ${colors.yellow(removed.name)} removed`));
    }
  );
