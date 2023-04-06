import { colouredLog } from '@/utils';
import { task } from 'hardhat/config';
import type { TaskArguments, HardhatRuntimeEnvironment } from 'hardhat/types';
import * as forksFile from '../../tenderly-forks.json';
import Table from "cli-table3";
import colors from '@colors/colors'

task("fork:list", "Creates a tenderly fork of network")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, network, getChainId }: HardhatRuntimeEnvironment
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
        const row = [i, fork.name, fork.forked, fork.id];
        table.push(
            i == forksFile.defaultFork ?
            row.map(i => colors.green(i.toString())) :
            row
        );
      }

      console.log(table.toString());
    }
  );
