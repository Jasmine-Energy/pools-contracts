import { colouredLog } from '@/utils';
import { task } from 'hardhat/config';
import type { TaskArguments, HardhatRuntimeEnvironment } from 'hardhat/types';

task("fund", "Funds an account on Tenderly network")
  .addPositionalParam("account", "The account's address to fund")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, network }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      if (network.name != 'tenderly') {
        colouredLog.red('Error: Command only supported on tenderly network');
        return;
      }
      const result = await network.provider.send("tenderly_addBalance", [
        [taskArgs.account],
        ethers.utils.hexValue(
          ethers.utils.parseUnits("10", "ether").toHexString()
        ),
      ]);

      console.log(result);
    }
  );
