import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import { Contracts, colouredLog } from '@/utils';
import { FormatTypes } from '@ethersproject/abi';

// TODO: Migrate this over to using Jasmine contract's deploy function - included via plugin
const deployCore: DeployFunction = async function (
    hre: HardhatRuntimeEnvironment
) {
    colouredLog.yellow(`deploying core contracts to: ${hre.network.name}`);

    // 1. Setup
    const { ethers, upgrades, deployments, network, getNamedAccounts } = hre;
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
    const eat = await upgrades.deployProxy(EAT, [
        tokenURI,               // initialURI
        futureMinterAddress,    // initialMinter
        owner,                  // initialOwner
    ], {
        kind: 'uups',
    });
    await eat.deployed();

    // 3. Deploy Oracle Contract
    const Oracle = await ethers.getContractFactory(Contracts.oracle);
    const oracle = await upgrades.deployProxy(Oracle, [
        futureMinterAddress,    // initialMinter
        owner,                  // initialOwner
    ], {
        kind: 'uups',
    });
    await oracle.deployed();

    // 4. Deploy Minter Contract
    const Minter = await ethers.getContractFactory(Contracts.minter);
    const minter = await upgrades.deployProxy(Minter, [
        Contracts.minter, 
        '1', 
        bridge,
        owner
    ],
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
        implementation: eatImplementationAddress
    });
    await save(Contracts.oracle, {
        abi: <string[]>Oracle.interface.format(FormatTypes.full),
        address: oracle.address,
        transactionHash: oracle.deployTransaction.hash,
        implementation: oracleImplementationAddress
    });
    await save(Contracts.minter, {
        abi: <string[]>Minter.interface.format(FormatTypes.full),
        address: minter.address,
        transactionHash: minter.deployTransaction.hash,
        implementation: minterImplementationAddress
    });
  
    // 6. If on external network, verify contracts
    if (network.tags['public']) {
        console.log('Verifyiyng on Etherscan...');
        await hre.run('verify:verify', {
            address: eatImplementationAddress,
            constructorArguments: [],
        });

        await hre.run('verify:verify', {
            address: oracleImplementationAddress,
            constructorArguments: [],
        });

        await hre.run('verify:verify', {
            address: minterImplementationAddress,
            constructorArguments: [
                Contracts.minter, 
                '1', 
                bridge,
                owner
            ],
        });
    }
};
deployCore.tags = ['Core', 'all'];
export default deployCore;
