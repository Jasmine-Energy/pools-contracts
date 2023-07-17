import { colouredLog, tryRequire } from '@/utils';
import { DEFAULT_DECIMAL_MULTIPLE } from '@/utils/constants';
import { BigNumber, utils } from 'ethers';
import { task } from 'hardhat/config';
import type { TaskArguments, HardhatRuntimeEnvironment } from 'hardhat/types';

task('balance', 'Prints an account\'s balance')
    .addPositionalParam('account', 'The account\'s address')
    .addOptionalParam('token', 'The token\'s address')
    .setAction(async (taskArgs: TaskArguments, { ethers, run }: HardhatRuntimeEnvironment): Promise<void> => {
        if (taskArgs.token) {
            if (!tryRequire("@/typechain")) {
                await run("compile");
                await run("typechain");
              }
              // @ts-ignore
              const { JasminePool__factory } = await import("@/typechain");
              
            try {
                const pool = JasminePool__factory.connect(taskArgs.token, await ethers.getDefaultProvider());
                const balance = await pool.balanceOf(taskArgs.account);
                const poolName = await pool.name();
                const symbol = await pool.symbol();
                colouredLog.blue(
                    `\nBalance in "${poolName}" is now: ${balance.div(DEFAULT_DECIMAL_MULTIPLE)} ${symbol}`
                );
              } catch {}
        } else {
            const account: string = utils.getAddress(taskArgs.account);
            const balance: BigNumber = await ethers.getDefaultProvider().getBalance(account);
            console.log(`${utils.formatEther(balance)}${ethers.constants.EtherSymbol}`);
        }
    });
