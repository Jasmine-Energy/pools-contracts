import { ethers, deployments } from 'hardhat';
import { JasminePoolFactory } from '@/typechain';
import { Contracts, colouredLog } from '@/utils';
import { AnyField } from '@/utils/constants';

// TODO: Would be amazing if (1) deploy new pool on public network auto verified newly deployed
// TODO: proxy on etherscan and (2) created a new ERC-1967 proxy file containing the new pool's
// TODO name, symbol, policy, and other metadata in docstring

async function main() {
    // 1. Connect to contract
    const deployedFactory = await deployments.get(Contracts.factory);
    const poolFactory = (await ethers.getContractAt(
        Contracts.factory,
        deployedFactory.address
    )) as JasminePoolFactory;

    const deployPoolTx = await poolFactory.deployNewBasePool({
        vintagePeriod: [
            Math.ceil(new Date().valueOf() / 1_000) - 10_000_000,
            Math.ceil(new Date().valueOf() / 1_000) + 10_000_000
        ] as [number, number],
        techType: AnyField,
        registry: AnyField,
        certification: AnyField,
        endorsement: AnyField
    }, 'Any Tech \'23', 'a23JLT');

    await deployPoolTx.wait();
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
