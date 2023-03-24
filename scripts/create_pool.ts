import { ethers, deployments, getNamedAccounts } from 'hardhat';
import { JasminePoolFactory, PoolPolicy } from '@/typechain';
import { Contracts, Libraries, colouredLog, LogColours } from '@/utils';

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

    await poolFactory.deployNewPool({
        vintagePeriod: [
            new Date().valueOf() / 1_000,
            new Date().valueOf() + 100_000  / 1_000
        ],
        techTypes: [],
        registries: [],
        certificationTypes: [],
        endorsements: []
    }, 'Any Tech \'23', 'a23JLT');
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
