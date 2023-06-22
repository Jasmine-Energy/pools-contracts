import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, colouredLog } from '@/utils';
import { JasminePoolFactory } from '@/typechain';
import { AnyField } from '@/utils/constants';

const deployFactory: DeployFunction = async function (
    { ethers, deployments, network, run, hardhatArguments, getNamedAccounts }: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying Pool Factory to: ${network.name}`);

    // 1. Get deployments, accounts and constructor args
    const { deploy } = deployments;
    const { owner, deployer, feeBeneficiary, uniswapPoolFactory, USDC } = await getNamedAccounts();

    let tokenBaseURI: string;
    if (network.live) {
        tokenBaseURI = "https://api.jasmine.energy/v1/pools/";
    } else {
        tokenBaseURI = "https://localhost:8080/v1/pools/";
    }

    const pool = await deployments.get(Contracts.pool);

    const constructorArgs = [
        uniswapPoolFactory,
        USDC,
    ];

    const initializerArgs = [
        owner,
        pool.address,
        feeBeneficiary,
        tokenBaseURI
    ];

    // 2. Deploy Pool Factory Contract
    const factory = await deploy(Contracts.factory, {
        from: deployer,
        args: constructorArgs,
        proxy: {
            proxyContract: 'UUPS',
            execute: {
              init: {
                    methodName: 'initialize',
                    args: initializerArgs,
                },
            },
        },
        log: hardhatArguments.verbose
    });

    colouredLog.blue(`Deployed factory to: ${factory.address}`);

    // 3. If on external network, verify contracts
    if (network.tags['public']) {
        console.log('Verifyiyng on Etherscan...');
        try {
            await run('verify:verify', {
                address: factory.address,
                constructorArguments: constructorArgs,
            });
        } catch (err) {
            colouredLog.red(`Verification failed. Error: ${err}`);
        }
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
            certificateType: AnyField,
            endorsement: AnyField
        }, 'Any Tech \'23', 'a23JLT', 177159557114295710296101716160n);
    }
};
deployFactory.tags = ['Factory', 'all'];
deployFactory.dependencies = ['Libraries', 'Pool', 'Core'];
export default deployFactory;
