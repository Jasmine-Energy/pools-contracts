import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, colouredLog } from '@/utils';
import { FormatTypes } from '@ethersproject/abi';
import { impersonateAccount } from '@nomicfoundation/hardhat-network-helpers';
import { JasmineMinter } from '@/typechain';
import { disableForking } from '@/utils/environment';

const deployCore: DeployFunction = async function (
    { ethers, upgrades, deployments, network, run, getNamedAccounts }: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying core contracts to: ${network.name}`);

    // 1. Setup
    const { save } = deployments;
    const { owner, bridge } = await getNamedAccounts();
    const ownerSigner = await ethers.getSigner(owner);

    const tokenURI = 'https://api.jasmine.energy/v1/eat/{id}.json';
    const ownerNonce = await ownerSigner.getTransactionCount();
    const futureMinterAddress = ethers.utils.getContractAddress({
        from: owner,
        nonce: ownerNonce + 5,
    });

    // 2. Deploy EAT Contract
    const EAT = await ethers.getContractFactory(Contracts.eat);
    const eatArgs = [
        tokenURI,               // initialURI
        futureMinterAddress,    // initialMinter
        owner,                  // initialOwner
    ];
    const eat = await upgrades.deployProxy(EAT, eatArgs, {
        kind: 'uups',
    });
    await eat.deployed();

    // 3. Deploy Oracle Contract
    const Oracle = await ethers.getContractFactory(Contracts.oracle);
    const oracleArgs = [
        futureMinterAddress,    // initialMinter
        owner,                  // initialOwner
    ];
    const oracle = await upgrades.deployProxy(Oracle, oracleArgs, {
        kind: 'uups',
    });
    await oracle.deployed();

    // 4. Deploy Minter Contract
    const Minter = await ethers.getContractFactory(Contracts.minter);
    const minterArgs = [
        Contracts.minter, 
        '1', 
        bridge,
        owner
    ];
    const minter = await upgrades.deployProxy(Minter, minterArgs,
    {
        unsafeAllow: ['constructor', 'state-variable-immutable'],
        constructorArgs: [eat.address, oracle.address],
        kind: 'uups',
    });
    await minter.deployed();

    colouredLog.blue(`Deployed EAT to: ${eat.address} Oracle to: ${oracle.address} Minter to: ${minter.address}`);

    // 5. Save deployments
    const eatImplementationAddress = await upgrades.erc1967.getImplementationAddress(eat.address);
    const oracleImplementationAddress = await upgrades.erc1967.getImplementationAddress(oracle.address);
    const minterImplementationAddress = await upgrades.erc1967.getImplementationAddress(minter.address);
    await save(Contracts.eat, {
        abi: <string[]>EAT.interface.format(FormatTypes.full),
        address: eat.address,
        transactionHash: eat.deployTransaction.hash,
        args: eatArgs,
        implementation: eatImplementationAddress
    });
    await save(Contracts.oracle, {
        abi: <string[]>Oracle.interface.format(FormatTypes.full),
        address: oracle.address,
        transactionHash: oracle.deployTransaction.hash,
        args: oracleArgs,
        implementation: oracleImplementationAddress
    });
    await save(Contracts.minter, {
        abi: <string[]>Minter.interface.format(FormatTypes.full),
        address: minter.address,
        transactionHash: minter.deployTransaction.hash,
        args: minterArgs,
        implementation: minterImplementationAddress
    });
  
    // 6. If on external network, verify contracts
    if (network.tags['public']) {
        console.log('Verifyiyng on Etherscan...');
        try {
            await run('verify:verify', {
                address: eatImplementationAddress,
            });

            await run('verify:verify', {
                address: oracleImplementationAddress,
            });

            await run('verify:verify', {
                address: minterImplementationAddress,
                constructorArguments: [
                    Contracts.minter, 
                    '1', 
                    bridge,
                    owner
                ],
            });
        } catch (err) {
            colouredLog.red(`Verification failed. Error: ${err}`);
        }
    }
};
deployCore.skip = async function (
    hre: HardhatRuntimeEnvironment
) {
    const { eat, minter, oracle, bridge } = await hre.getNamedAccounts();
    let skip: boolean;
    if (eat && minter && oracle) {
        if (hre.network.name === "hardhat" && disableForking) {
            skip = false
        } else if (hre.network.name === "hardhat" && hre.network.autoImpersonate) {
            // NOTE: This screws up following deployment steps...
            // await hre.run("run", { script: "./scripts/set_bridge.ts", network: "hardhat" });
            var minterContract = await hre.ethers.getContractAt(Contracts.minter, minter) as JasmineMinter;
            const ownerAddress = await minterContract.owner();
            await impersonateAccount(ownerAddress);
            const ownerSigner = await hre.ethers.getSigner(ownerAddress);
            minterContract = await hre.ethers.getContractAt(Contracts.minter, minter, ownerSigner) as JasmineMinter;
            await minterContract.setBridge(bridge);

            colouredLog.blue(`BRIDGE CHANGED TO: ${bridge}`);
            skip = true;
        } else {
            skip = true;
        }
    } else if (hre.network.live || hre.network.tags['public']) {
        skip = true;
    } else {
        skip = false;
    }

    if (skip) {
        colouredLog.yellow(`Skipping core contracts deployment on: ${hre.network.name}`);
    }

    return skip;
}
deployCore.tags = ['Core', 'all'];
export default deployCore;
