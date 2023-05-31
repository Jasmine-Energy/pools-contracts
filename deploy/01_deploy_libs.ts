import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Libraries, colouredLog } from '@/utils';

const deployDependencies: DeployFunction = async function (
    { deployments, network, hardhatArguments, run, getNamedAccounts }: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying libraries to: ${network.name}`);

    const { deploy } = deployments;
    const { deployer } = await getNamedAccounts();

    // 1. Deploy Pool Policy Library
    const policyLib = await deploy(Libraries.poolPolicy, {
        from: deployer,
        log: hardhatArguments.verbose
    });
  
    // 2. Deploy Calldata Library
    const calldataLib = await deploy(Libraries.calldata, {
        from: deployer,
        log: hardhatArguments.verbose,
    });

    // 3. Deploy Calldata Library
    const arrayUtilsLib = await deploy(Libraries.arrayUtils, {
        from: deployer,
        log: hardhatArguments.verbose,
    });

    // 4. Deploy RedBlackTree Library
    const redBlackTree  = await deploy(Libraries.redBlackTree, {
        from: deployer,
        log: hardhatArguments.verbose,
    });

    colouredLog.blue(`Deployed Policy Lib to: ${policyLib.address} Calldata Lib to: ${calldataLib.address} ArrayUtils Lib to: ${arrayUtilsLib.address} RedBlackTree Lib to: ${redBlackTree.address}`);
  
    // 5. If on external network, verify contracts
    if (network.tags['public']) {
        console.log('Verifyiyng on Etherscan...');
        try {
            await run('verify:verify', {
                address: calldataLib,
            });

            await run('verify:verify', {
                address: policyLib,
            });

            await run('verify:verify', {
                address: arrayUtilsLib,
            });
        } catch (err) {
            colouredLog.red(`Verification failed. Error: ${err}`);
        }
    }
};
deployDependencies.tags = ['Libraries', 'all'];
export default deployDependencies;
