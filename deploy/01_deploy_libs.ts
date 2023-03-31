import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Libraries, colouredLog } from '@/utils';

const deployDependencies: DeployFunction = async function (
    hre: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying libraries to: ${hre.network.name}`);

    const { deployments, tenderly, network, getNamedAccounts } = hre;
    const { deploy } = deployments;
    const { owner } = await getNamedAccounts();

    // 1. Deploy Pool Policy Library
    const policyLib = await deploy(Libraries.poolPolicy, {
        from: owner,
        log: hre.hardhatArguments.verbose
    });
  
    // 2. Deploy Calldata Library
    const calldataLib = await deploy(Libraries.calldata, {
        from: owner,
        log: hre.hardhatArguments.verbose,
    });

    // 3. Deploy Calldata Library
    const arrayUtilsLib = await deploy(Libraries.arrayUtils, {
        from: owner,
        log: hre.hardhatArguments.verbose,
    });

    const contracts = [
        {
            name: Libraries.poolPolicy,
            address: policyLib.address,
            network: network.name
        },
        {
            name: Libraries.calldata,
            address: calldataLib.address,
            network: network.name
        },
        {
            name: Libraries.arrayUtils,
            address: arrayUtilsLib.address,
            network: network.name
        }
    ];

    await tenderly.persistArtifacts(...contracts);

    colouredLog.blue(`Deployed Policy Lib to: ${policyLib.address} Calldata Lib to: ${calldataLib.address} ArrayUtils Lib to: ${arrayUtilsLib.address}`);
  
    // 4. If on external network, verify contracts
    if (network.tags['public']) {
        console.log('Verifyiyng on Etherscan...');
        await hre.run('verify:verify', {
            address: calldataLib,
        });

        await hre.run('verify:verify', {
            address: policyLib,
        });

        await hre.run('verify:verify', {
            address: arrayUtilsLib,
        });

        await tenderly.verify(...contracts);
    } else if (network.tags['tenderly']) {
        await tenderly.verify(...contracts);
    }
};
deployDependencies.tags = ['Libraries', 'all'];
export default deployDependencies;
