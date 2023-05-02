import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, Libraries, colouredLog } from '@/utils';

const deployPoolImplementation: DeployFunction = async function (
    hre: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying dependencies to: ${hre.network.name}`);

    const { ethers, tenderly, deployments, network, getNamedAccounts } = hre;
    const { deploy, get } = deployments;
    const namedAccounts = await getNamedAccounts();
    const { owner } = namedAccounts;
    const ownerSigner = await ethers.getSigner(owner);
    const ownerNonce = await ownerSigner.getTransactionCount();
    const poolFactoryFutureAddress = ethers.utils.getContractAddress({
        from: owner,
        nonce: ownerNonce + 1,
    });

    // 1. Get deployements
    const policy = await get(Libraries.poolPolicy);
    const arrayUtils = await get(Libraries.arrayUtils);
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
        from: owner,
        args: [
            eat,
            oracle,
            poolFactoryFutureAddress
        ],
        libraries: {
            PoolPolicy: policy.address,
            ArrayUtils: arrayUtils.address
        },
        log: hre.hardhatArguments.verbose
    });

    await tenderly.persistArtifacts({
        name: Contracts.pool,
        address: pool.address,
        network: network.name,
        libraries: {
            PoolPolicy: policy.address,
            ArrayUtils: arrayUtils.address
        }
    });

    colouredLog.blue(`Deployed Pool impl to: ${pool.address}`);

    // 3. If on external network, verify contracts
    if (network.tags['public']) {
        // TODO: Verify on sourcify as well. Run "sourcify" command
        console.log('Verifyiyng on Etherscan...');
        await hre.run('verify:verify', {
            address: pool,
            constructorArguments: [
                eat,
                oracle,
                poolFactoryFutureAddress
            ],
        });

        await tenderly.verify({
            name: Contracts.pool,
            address: pool.address,
            network: network.name,
            libraries: {
                PoolPolicy: policy.address,
                ArrayUtils: arrayUtils.address
            }
        });
    } else if (network.tags['tenderly']) {
        await tenderly.verify({
            name: Contracts.pool,
            address: pool.address,
            network: network.name,
            libraries: {
                PoolPolicy: policy.address,
                ArrayUtils: arrayUtils.address
            }
        });
    }
};
deployPoolImplementation.tags = ['Pool', 'all'];
deployPoolImplementation.dependencies = ['Libraries', 'Core'];
export default deployPoolImplementation;
