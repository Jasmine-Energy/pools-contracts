import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, colouredLog } from '@/utils';
import { delay } from '@/utils/delay';

const deployRetirementService: DeployFunction = async function (
    { deployments, ethers, network, run, hardhatArguments, getNamedAccounts, upgrades }: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying Retirement Service to: ${network.name}`);

    const { deploy, save, get } = deployments;
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

    // 2. Preflight check
    if (!deployer || !owner || !eat || !minter || !oracle) throw new Error('Required addresses not found');

    // 3. Deploy Retirement Service Contract
    const Retirer = await ethers.getContractFactory(Contracts.retirementService);
    const retirer = await upgrades.deployProxy(Retirer, [owner], {
        deployer,
        kind: 'uups',
        constructorArgs: [minter, eat],
        unsafeAllow: ['state-variable-immutable', 'constructor']
    });

    await save(Contracts.retirementService, retirer);

    if (network.tags['public']) {
        colouredLog.yellow(`Deploying Retirement Service to: ${retirer.address} and waiting for 30 seconds for the contract to be deployed...`);
        await delay(180 * 1_000);
    }

    const implementationAddress = await upgrades.erc1967.getImplementationAddress(retirer.address);

    colouredLog.blue(`Deployed Retirement Service to: ${retirer.address} implementation: ${implementationAddress}`);

    // 4. If on external network, verify contracts
    if (network.tags['public']) {
        colouredLog.yellow('Verifyiyng on Etherscan...');
        try {
            await run('verify:verify', {
                address: retirer.address,
                constructorArguments: [
                    minter,
                    eat,
                ],
            });

            await run('verify:verify', {
                address: implementationAddress,
                constructorArguments: [
                    minter,
                    eat,
                ],
            });
            colouredLog.green(`Verification successful!`);
        } catch (err) {
            colouredLog.red(`Verification failed. Error: ${err}`);
        }
    }
};
deployRetirementService.tags = ['Retirer', 'all'];
deployRetirementService.dependencies = ['Core'];
export default deployRetirementService;
