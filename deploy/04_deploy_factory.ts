import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, Libraries, colouredLog } from '@/utils';
import { JasminePoolFactory } from '@/typechain';
import { AnyField } from '@/utils/constants';

const deployFactory: DeployFunction = async function (
    { ethers, deployments, network, run, hardhatArguments, getNamedAccounts }: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying Pool Factory to: ${network.name}`);

    const { deploy } = deployments;
    const { owner, deployer, feeBeneficiary, uniswapPoolFactory, USDC } = await getNamedAccounts();

    // 1. Get deployments
    const pool = await deployments.get(Contracts.pool);
    const policy = await deployments.get(Libraries.poolPolicy);

    // 2. Deploy Pool Factory Contract
    const factory = await deploy(Contracts.factory, {
        from: deployer,
        args: [owner, pool.address, feeBeneficiary, uniswapPoolFactory, USDC],
        libraries: {
            PoolPolicy: policy.address
        },
        log: hardhatArguments.verbose
    });

    colouredLog.blue(`Deployed factory to: ${factory.address}`);

    // 3. If on external network, verify contracts
    if (network.tags['public']) {
        console.log('Verifyiyng on Etherscan...');
        await run('verify:verify', {
            address: factory,
            constructorArguments: [owner, pool.address, feeBeneficiary, uniswapPoolFactory, USDC],
            // TODO: link libraries
        });
    }

    // 4. If not prod, create test pool
    if (!network.tags['public']) {
        const factoryContract = await ethers.getContractAt(Contracts.factory, factory.address) as JasminePoolFactory;
        await factoryContract.deployNewBasePool({
            vintagePeriod: [
                Math.ceil(new Date().valueOf() / 1_000) - 10_000_000,
                Math.ceil(new Date().valueOf() / 1_000) + 10_000_000
            ],
            techType: AnyField,
            registry: AnyField,
            certification: AnyField,
            endorsement: AnyField
        }, 'Any Tech \'23', 'a23JLT');
    }
};
deployFactory.tags = ['Factory', 'all'];
deployFactory.dependencies = ['Libraries', 'Pool', 'Core'];
export default deployFactory;
