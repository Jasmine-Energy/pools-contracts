import { colouredLog } from '@/utils';
import { task } from 'hardhat/config';
import type { TaskArguments, HardhatRuntimeEnvironment } from 'hardhat/types';
import Table from "cli-table3";


task("fund", "Funds an account on Tenderly network")
  .addVariadicPositionalParam<string>("accounts", "Account addresses to fund")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, network }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      if (network.name != 'tenderly') {
        colouredLog.red('Error: Command only supported on tenderly network');
        return;
      }

      const head = ["Address", "Balance"];
      var results = new Table({
        head,
        style: {
          head: ["yellow"],
        }
      });
      const result = await network.provider.send("tenderly_addBalance", [
        taskArgs.accounts,
        ethers.utils.hexValue(
          ethers.utils.parseUnits("10", "ether").toHexString()
        ),
      ]);
      
      // console.log(result, network.provider)
      for (const account of taskArgs.accounts) {
        const balance = await ethers.getDefaultProvider().getBalance(account);
        results.push([account, balance.toString()]);
      }

      console.log(results.toString());
    }
  );
  // Account #0: 0x77f774c6632B1CA6BD248068fBaA952355eAE2b5 (10000 ETH)

  // Account #1:   (10000 ETH)
  
  // Account #2: 0x6F518B13C26368F17287f4FfB5faE6EA6544Fff1 (10000 ETH)
  
  // Account #3: 0x2dcAd29De8a67d70b7B5bf32B19f1480f333D8dD (10000 ETH)
  
  // Account #4: 0x3930B63a7F6009767c0C6066f7Ce066cc9c5731a (10000 ETH)
  // Account #5: 0x24Db4e7Ec088A9e81830d8BAa01950dc88bdCA93 (10000 ETH)
  // Account #6: 0x694d38e74b52fBb2C2DDfA54D229097eeAb304dD (10000 ETH)
  // Account #7: 0xd2F49a52c07Be026804FcE08ca46eDa6631fca6e (10000 ETH)
  // Account #8: 0xE6BEDe1b393864AA03e0eE30e1603d646F976d44 (10000 ETH)
  // Account #9: 0x16C638286AC9777ddb57Db734C34919E80346474 (10000 ETH)
// ["0x16C638286AC9777ddb57Db734C34919E80346474", "0xE6BEDe1b393864AA03e0eE30e1603d646F976d44"]