import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, Libraries, colouredLog } from '@/utils';

const deployRetirementService: DeployFunction = async function (
    { deployments, network, run, hardhatArguments, getNamedAccounts }: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying Retirement Service to: ${network.name}`);

    const { deploy, get } = deployments;
    const namedAccounts = await getNamedAccounts();
    const { owner } = namedAccounts;

    // 1. Get deployements
    const calldata = await get(Libraries.calldata);
    const arrayUtils = await get(Libraries.arrayUtils);
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
        from: owner,
        args: [
            minter,
            eat,
        ],
        libraries: {
            Calldata: calldata.address,
            ArrayUtils: arrayUtils.address,
        },
        log: hardhatArguments.verbose
    });

    colouredLog.blue(`Deployed Pool impl to: ${retirer.address}`);

    // 3. If on external network, verify contracts
    if (network.tags['public']) {
        // TODO: Verify on sourcify as well. Run "sourcify" command
        console.log('Verifyiyng on Etherscan...');
        await run('verify:verify', {
            address: retirer,
            constructorArguments: [
                minter,
                eat,
            ],
        });
    }
};
deployRetirementService.tags = ['Retirer', 'all'];
deployRetirementService.dependencies = ['Libraries', 'Core'];
export default deployRetirementService;
