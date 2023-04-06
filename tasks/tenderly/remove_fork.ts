import { colouredLog } from "@/utils";
import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import * as forksFile from "../../tenderly-forks.json";
import fs from "fs/promises";
import axios from "axios";
import path from "path";

const TENDERLY_FORK_API = `http://api.tenderly.co/api/v1/account/Jasmine/project/reference-pools/fork`;

task("fork:remove", "Deletes a tenderly fork")
  .addPositionalParam<number>("index", "Index of fork to delete")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, network, getChainId, ...hre }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      if (taskArgs.index >= forksFile.total) {
        colouredLog.red("Out of bounds");
        return;
      }
      
      const opts = {
        headers: {
          "X-Access-Key": process.env.TENDERLY_API_KEY,
        },
      };

      const resp = await axios.delete(path.join(TENDERLY_FORK_API, forksFile.forks[taskArgs.index].id), opts);

    //   if (resp.status != 201) {
    //     colouredLog.red("Failed");
    //     return;
    //   }
    console.log(resp);


      var updatesForks = forksFile;
      delete updatesForks.forks[taskArgs.index];

      await fs.writeFile(
        path.join(hre.config.paths.root, "tenderly-forks.json"),
        JSON.stringify({
          total: updatesForks.forks.length,
          defaultFork: taskArgs.index >= updatesForks.forks.length ? 0 : updatesForks.defaultFork,
          forks: updatesForks.forks,
        })
      );

      colouredLog.blue("Fork remove");
    }
  );
