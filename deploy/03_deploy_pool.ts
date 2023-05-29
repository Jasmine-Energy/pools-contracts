import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, Libraries, colouredLog } from '@/utils';

const deployPoolImplementation: DeployFunction = async function (
    { ethers, deployments, network, run, hardhatArguments, getNamedAccounts }: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying Pool implementation to: ${network.name}`);

    const { deploy, get } = deployments;
    const namedAccounts = await getNamedAccounts();
    const { deployer } = namedAccounts;
    const deployerSigner = await ethers.getSigner(deployer);
    const deployerNonce = await deployerSigner.getTransactionCount();
    const poolFactoryFutureAddress = ethers.utils.getContractAddress({
        from: deployer,
        nonce: deployerNonce + 1,
    });

    // 1. Get deployements
    const retirer = await get(Contracts.retirementService);
    const policy = await get(Libraries.poolPolicy);
    const arrayUtils = await get(Libraries.arrayUtils);
    const calldata = await get(Libraries.calldata);
    let eat: string;
    let oracle: string;
    try {
        eat = (await get(Contracts.eat)).address;
        oracle = (await get(Contracts.oracle)).address;
    } catch {
        eat = namedAccounts.eat;
        oracle = namedAccounts.oracle;
    }

    // 2. Deploy Pool Contract
    const pool = await deploy(Contracts.pool, {
        from: deployer,
        args: [
            eat,
            oracle,
            poolFactoryFutureAddress,
            retirer.address
        ],
        libraries: {
            PoolPolicy: policy.address,
            ArrayUtils: arrayUtils.address,
            Calldata: calldata.address
        },
        log: hardhatArguments.verbose
    });

    colouredLog.blue(`Deployed Pool impl to: ${pool.address}`);

    // 3. If on external network, verify contracts
    if (network.tags['public']) {
        // TODO: Verify on sourcify as well. Run "sourcify" command
        console.log('Verifyiyng on Etherscan...');
        await run('verify:verify', {
            address: pool,
            constructorArguments: [
                eat,
                oracle,
                poolFactoryFutureAddress,
                retirer.address
            ],
        });
    }
};
deployPoolImplementation.tags = ['Pool', 'all'];
deployPoolImplementation.dependencies = ['Libraries', 'Core'];
export default deployPoolImplementation;
