import { task } from 'hardhat/config';
import type { TaskArguments } from 'hardhat/types';
import { TENDERLY_FORK_DASHBOARD } from "@/utils/constants";
import * as forksFile from '../../tenderly-forks.json';
import Table from "cli-table3";
import colors from '@colors/colors'

task("fork:list", "Creates a tenderly fork of network")
  .addOptionalParam<string>("fork", "Only list forks from network")
  .setAction(
    async (
      taskArgs: TaskArguments
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

      var forks = forksFile.forks;

      if (taskArgs.fork) {
        forks = forks.filter((fork) => fork.forked === taskArgs.fork);
      }

      for (var i = 0; i < forks.length; i++) {
        const fork = forks[i];
        const indexOfFork = forksFile.forks.indexOf(fork);
        const row = [indexOfFork.toString(), fork.name, fork.forked, { content: fork.id, href: `${TENDERLY_FORK_DASHBOARD}/${fork.id}` }];
        table.push(
            indexOfFork == forksFile.defaultFork ?
            row.map(cell => typeof cell == 'string' ? colors.green(cell) : { content: colors.green(cell.content), href: cell.href }) :
            row
        );
      }

      console.log(table.toString());
    }
  );
