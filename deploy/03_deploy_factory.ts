import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, Libraries, colouredLog } from '@/utils';
import { JasminePoolFactory } from '@/typechain';
import { AnyField } from '@/utils/constants';

const deployFactory: DeployFunction = async function (
    hre: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying Pool Factory to: ${hre.network.name}`);

    const { ethers, tenderly, deployments, network, getNamedAccounts } = hre;
    const { deploy } = deployments;
    const { owner, feeBeneficiary, uniswapPoolFactory, USDC } = await getNamedAccounts();

    // 1. Get deployments
    const pool = await deployments.get(Contracts.pool);
    const policy = await deployments.get(Libraries.poolPolicy);

    // 2. Deploy Pool Factory Contract
    const factory = await deploy(Contracts.factory, {
        from: owner,
        args: [pool.address, feeBeneficiary, uniswapPoolFactory, USDC],
        libraries: {
            PoolPolicy: policy.address
        },
        log: hre.hardhatArguments.verbose
    });

    await tenderly.persistArtifacts({
        name: Contracts.factory,
        address: factory.address,
        network: network.name,
        libraries: {
            PoolPolicy: policy.address
        }
    });

    colouredLog.blue(`Deployed factory to: ${factory.address}`);

    // 3. If on external network, verify contracts
    if (network.tags['public']) {
        console.log('Verifyiyng on Etherscan...');
        await hre.run('verify:verify', {
            address: factory,
            constructorArguments: [pool.address],
        });
        await tenderly.verify({
            name: Contracts.factory,
            address: factory.address,
            network: network.name,
            libraries: {
                PoolPolicy: policy.address
            }
        });
    } else if (network.tags['tenderly']) {
        await tenderly.verify({
            name: Contracts.factory,
            address: factory.address,
            network: network.name,
            libraries: {
                PoolPolicy: policy.address
            }
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
