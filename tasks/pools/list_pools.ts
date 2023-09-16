
import { task } from 'hardhat/config';
import type { TaskArguments, HardhatRuntimeEnvironment } from 'hardhat/types';
import { Contracts, tryRequire, makeLinkedTableCell } from '@/utils';
import Table from 'cli-table3';
import { BigNumber } from 'ethers';


task('pool:list', 'Transfers an EAT')
    .addOptionalParam<string>('factory', 'Address of Jasmine pool factory')
    .setAction(
        async (
            taskArgs: TaskArguments,
            { ethers, deployments, run }: HardhatRuntimeEnvironment
        ): Promise<void> => {

            // 1. Check if typechain exists. If not, compile and explicitly generate typings
            if (!tryRequire('@/typechain')) {
                await run('compile');
                await run('typechain');
            }
            // @ts-ignore
            const { JasminePoolFactory__factory, JasminePool__factory } = await import('@/typechain');

            // 2. Load contract
            const factoryDeployment = await deployments.get(Contracts.factory);
            const defaultSigner = (await ethers.getSigners())[0];
            const factory = JasminePoolFactory__factory.connect(taskArgs.factory ?? factoryDeployment.address, defaultSigner);

            const totalPools = await factory.totalPools();
            var table = new Table({
                head: ['Index', 'Address', 'Name', 'Symbol'],
                style: {
                    head: ['yellow'],
                   border: [] 
                }
            });
        
            for (var i = 0; i < totalPools.toNumber(); i++) {
                const poolAddress = await factory.getPoolAtIndex(i);
                const pool = JasminePool__factory.connect(poolAddress, defaultSigner);
                const name = await pool.name();
                const symbol = await pool.symbol();
                table.push([i.toString(), await makeLinkedTableCell(poolAddress, { run }), name, symbol]);
            }

            console.log(table.toString());
        }
    );

