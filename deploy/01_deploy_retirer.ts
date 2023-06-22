import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, colouredLog } from '@/utils';

const deployRetirementService: DeployFunction = async function (
    { deployments, network, run, hardhatArguments, getNamedAccounts }: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying Retirement Service to: ${network.name}`);

    const { deploy, get } = deployments;
    const namedAccounts = await getNamedAccounts();
    const { deployer, owner } = namedAccounts;

    // 1. Get deployements
    let eat: string;
    let minter: string;
    let oracle: string;
    try {
        eat = (await get(Contracts.eat)).address;
        minter = (await get(Contracts.minter)).address;
        oracle = (await get(Contracts.oracle)).address;
    } catch {
        eat = namedAccounts.eat;
        minter = namedAccounts.minter;
        oracle = namedAccounts.oracle;
    }

    // 2. Deploy Retirement Service Contract
    const retirer = await deploy(Contracts.retirementService, {
        from: deployer,
        args: [
            minter,
            eat,
        ],
        proxy: {
            proxyContract: 'UUPS',
            execute: {
              init: {
                    methodName: 'initialize',
                    args: [owner],
                },
            },
        },
        log: hardhatArguments.verbose
    });

    colouredLog.blue(`Deployed Retirement Service to: ${retirer.address}`);

    // 3. If on external network, verify contracts
    if (network.tags['public']) {
        console.log('Verifyiyng on Etherscan...');
        try {
            await run('verify:verify', {
                address: retirer.address,
                constructorArguments: [
                    minter,
                    eat,
                ],
            });
        } catch (err) {
            colouredLog.red(`Verification failed. Error: ${err}`);
        }
    }
};
deployRetirementService.tags = ['Retirer', 'all'];
deployRetirementService.dependencies = ['Libraries', 'Core'];
export default deployRetirementService;
