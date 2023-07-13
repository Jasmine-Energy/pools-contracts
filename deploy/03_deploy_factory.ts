import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, colouredLog } from '@/utils';
import { JasminePoolFactory } from '@/typechain';
import { AnyField } from '@/utils/constants';
import { delay } from '@/utils/delay';

const deployFactory: DeployFunction = async function (
    { ethers, deployments, network, run, hardhatArguments, getNamedAccounts, upgrades }: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying Pool Factory to: ${network.name}`);

    // 1. Get deployments, accounts and constructor args
    const { deploy } = deployments;
    const { owner, deployer, feeBeneficiary, uniswapPoolFactory, USDC } = await getNamedAccounts();

    let tokenBaseURI: string;
    if (network.live) {
        tokenBaseURI = "https://api.jasmine.energy/v1/pool/";
    } else {
        tokenBaseURI = "https://localhost:8080/v1/pool/";
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

    if (network.tags['public']) {
        colouredLog.yellow(`Deploying Pool factory to: ${factory.address} and waiting for 30 seconds for the contract to be deployed...`);
        await delay(30 * 1_000);
    }

    const implementationAddress = await upgrades.erc1967.getImplementationAddress(factory.address);

    colouredLog.blue(`Deployed factory to: ${factory.address} implementation: ${implementationAddress}`);

    // 3. If on external network, verify contracts
    if (network.tags['public']) {
        colouredLog.yellow('Verifyiyng on Etherscan...');
        try {
            await run('verify:verify', {
                address: factory.address,
                constructorArguments: constructorArgs,
            });
            colouredLog.green(`Verification successful!`);
        } catch (err) {
            colouredLog.red(`Verification failed. Error: ${err}`);
        }
    }

    // 4. If not prod, create test pool
    if (network.name === 'hardhat') {
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
deployFactory.runAtTheEnd = true;
export default deployFactory;
