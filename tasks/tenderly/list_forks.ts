import { colouredLog } from '@/utils';
import { task } from 'hardhat/config';
import type { TaskArguments, HardhatRuntimeEnvironment } from 'hardhat/types';
import * as forksFile from '../../tenderly-forks.json';
import Table from "cli-table3";

task("fork:list", "Creates a tenderly fork of network")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, network, getChainId, ...hre }: HardhatRuntimeEnvironment
    ): Promise<void> => {
       
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

      for (var i = 0; i < forksFile.total; i++) {
        const fork = forksFile.forks[i];
        table.push([i, fork.name, fork.Forked, fork.id]);
      }

      console.log(table.toString());
    }
  );
