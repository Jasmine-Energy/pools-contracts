import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, colouredLog } from '@/utils';

const deployPoolImplementation: DeployFunction = async function (
    { ethers, deployments, network, run, hardhatArguments, getNamedAccounts }: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying Pool implementation to: ${network.name}`);

    // 1. Get deployments, accounts and constructor args
    const { deploy, get } = deployments;
    const namedAccounts = await getNamedAccounts();
    const { deployer } = namedAccounts;
    const deployerSigner = await ethers.getSigner(deployer);
    const deployerNonce = await deployerSigner.getTransactionCount();
    const poolFactoryFutureAddress = ethers.utils.getContractAddress({
        from: deployer,
        nonce: deployerNonce + 2,
    });

    const retirer = await get(Contracts.retirementService);
    let eat: string;
    let oracle: string;
    try {
        eat = (await get(Contracts.eat)).address;
        oracle = (await get(Contracts.oracle)).address;
    } catch {
        eat = namedAccounts.eat;
        oracle = namedAccounts.oracle;
    }

    const constructorArgs = [
        eat,
        oracle,
        poolFactoryFutureAddress,
        retirer.address
    ];

    // 2. Deploy Pool Contract
    const pool = await deploy(Contracts.pool, {
        from: deployer,
        args: constructorArgs,
        log: hardhatArguments.verbose,
    });

    colouredLog.blue(`Deployed Pool impl to: ${pool.address}`);

    // 3. If on external network, verify contracts
    if (network.tags['public']) {
        console.log('Verifyiyng on Etherscan...');
        try {
            await run('verify:verify', {
                address: pool.address,
                constructorArguments: constructorArgs,
            });
        } catch (err) {
            colouredLog.red(`Verification failed. Error: ${err}`);
        }
    }
};
deployPoolImplementation.tags = ['Pool', 'all'];
deployPoolImplementation.dependencies = ['Libraries', 'Core'];
export default deployPoolImplementation;
