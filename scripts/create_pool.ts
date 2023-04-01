import { ethers, deployments, getNamedAccounts } from 'hardhat';
import { JasminePoolFactory, PoolPolicy } from '@/typechain';
import { Contracts, Libraries, colouredLog } from '@/utils';

// TODO: Would be amazing if (1) deploy new pool on public network auto verified newly deployed
// TODO: proxy on etherscan and (2) created a new ERC-1967 proxy file containing the new pool's
// TODO name, symbol, policy, and other metadata in docstring

async function main() {
    // 1. Connect to contract
    const { owner } = await getNamedAccounts();
    console.log(await deployments.all(), await deployments.getDeploymentsFromAddress(owner));
    const factory = await ethers.getContract(Contracts.factory);
    console.log(factory);
    const deployedFactory = await deployments.get(Contracts.factory);
    const poolFactory = (await ethers.getContractAt(
        Contracts.factory,
        deployedFactory.address
    )) as JasminePoolFactory;

    //   ethers.getContract(Libraries.poolPolicy);

    //   const deployedPolicyLib = await deployments.get(Libraries.poolPolicy);
    //   const poolPolicyLib = (await ethers.getContractAt(
    //     Libraries.poolPolicy,
    //     deployedPolicyLib.address
    //   )) as PoolPolicy;

    await poolFactory.deployNewBasePool({
        vintagePeriod: [
            new Date().valueOf() / 1_000,
            new Date().valueOf() + 100_000  / 1_000
        ],
        techType: 0,
        registry: 0,
        certification: 0,
        endorsement: 0
    }, 'Any Tech \'23', 'a23JLT');
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
