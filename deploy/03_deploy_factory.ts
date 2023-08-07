import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, colouredLog } from '@/utils';
import { JasminePoolFactory } from '@/typechain';
import { AnyField } from '@/utils/constants';
import { CertificateEndorsement, CertificateEndorsementArr, CertificateArr, EnergyCertificateType } from "@/types/energy-certificate.types";
import { delay } from '@/utils/delay';

const deployFactory: DeployFunction = async function (
    { ethers, deployments, network, run, getNamedAccounts, upgrades }: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying Pool Factory to: ${network.name}`);

    // 1. Get deployments, accounts and constructor args
    const { save } = deployments;
    const { owner, deployer, poolManager, feeManager, feeBeneficiary, uniswapPoolFactory, USDC } = await getNamedAccounts();

    let tokenBaseURI: string;
    if (network.name === "polygon") {
        tokenBaseURI = "https://api.jasmine.energy/v1/pool/";
    } else if (network.name === "mumbai") {
        tokenBaseURI = "https://api.jazzmine.xyz/v1/pool/";
    } else {
        tokenBaseURI = "https://localhost:8964/v1/pool/";
    }

    const pool = await deployments.get(Contracts.pool);

    const constructorArgs = [
        uniswapPoolFactory,
        USDC,
    ];

    const initializerArgs = [
        owner,
        pool.address,
        poolManager,
        feeManager,
        feeBeneficiary,
        tokenBaseURI
    ];

    // 2. Deploy Pool Factory Contract
    const Factory = await ethers.getContractFactory(Contracts.factory);
    const factory = await upgrades.deployProxy(Factory, initializerArgs, {
        deployer,
        kind: 'uups',
        constructorArgs,
        unsafeAllow: ['state-variable-immutable', 'constructor']
    });

    await save(Contracts.factory, factory);

    if (network.tags['public']) {
        if (network.name === "polygon") {
            colouredLog.yellow(`Deploying Pool factory to: ${factory.address} and waiting for 3 minutes for the contract to be deployed...`);
            await delay(180 * 1_000);
        } else if (network.name === "mumbai") {
            colouredLog.yellow(`Deploying Pool factory to: ${factory.address} and waiting for 30 seconds for the contract to be deployed...`);
            await delay(30 * 1_000);
        } else {
            colouredLog.yellow(`Deploying Pool factory to: ${factory.address} and waiting for 30 seconds for the contract to be deployed...`);
            await delay(30 * 1_000);
        }
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

            await run('verify:verify', {
                address: implementationAddress,
                constructorArguments: constructorArgs,
            });
            colouredLog.green(`Verification successful!`);
        } catch (err) {
            colouredLog.red(`Verification failed. Error: ${err}`);
        }
    }

    // 4. If not prod, create test pool
    if (network.name === 'hardhat' && process.env.SKIP_DEPLOY_TEST_POOL !== 'true') {
        const managerSigner = await ethers.getSigner(poolManager);
        const factoryContract = await ethers.getContractAt(Contracts.factory, factory.address, managerSigner) as JasminePoolFactory;
        const frontHalfPool = await factoryContract.deployNewBasePool({
            vintagePeriod: [
                1672531200, // Jan 1st, 2023 @ midnight
                1688083200, // June 30th, 2023 @ midnight
              ] as [number, number],
              techType: AnyField,
              registry: AnyField,
              certificateType: BigInt(CertificateArr.indexOf(EnergyCertificateType.REC)) & BigInt(2 ** 32 - 1),
              endorsement: BigInt(CertificateEndorsementArr.indexOf(CertificateEndorsement.GREEN_E)) & BigInt(2 ** 32 - 1),
        }, 'Any Tech \'23', 'a23JLT', 177159557114295710296101716160n);
        const frontHalfDeployedPool = await frontHalfPool.wait();
        const frontHalfPoolAddress = frontHalfDeployedPool.events
            ?.find((e) => e.event === "PoolCreated")
            ?.args?.at(1);
        colouredLog.blue(`Deployed front half pool to: ${frontHalfPoolAddress}`);
    } else if (network.name === 'hardhat' && process.env.SKIP_DEPLOY_TEST_POOL === 'true') {
        colouredLog.yellow('Skipping test pool deployment');
    }

    // 5. Run gas used task
    await run('gas-used', { all: false });
};
deployFactory.tags = ['Factory', 'all'];
deployFactory.dependencies = ['Libraries', 'Pool', 'Core'];
deployFactory.runAtTheEnd = true;
export default deployFactory;
