import { utils } from 'ethers';
import { task } from 'hardhat/config';
import type { TaskArguments, HardhatRuntimeEnvironment } from 'hardhat/types';
import { colouredLog, Contracts, LogColours } from '@/utils';
import {
    FuelType,
    CertificateRegistry,
    EnergyCertificateType,
    CertificateEndorsement,
    FuelTypesArray,
    CertificateRegistryArr,
    CertificateArr,
    CertificateEndorsementArr,
} from '@/types/energy-certificate.types';
import {
    encodeEnergyAttributeTokenId,
    encodeOracleData,
} from '@/utils/token_encoding';

task('mint', 'Mints an EAT')
    .addPositionalParam<string>('account', 'The account\'s address')
    .addParam<string>(
        'vintage',
        'EAT\'s vintage in form YYYY-MM-DD.',
        new Date().toISOString().split('T')[0]
    )
    .addParam<FuelType>(
        'fuel',
        `EAT's fuel type. Either ${FuelTypesArray.join(', ')}.`,
        FuelType.SOLAR
    )
    .addParam<CertificateRegistry>(
        'registry',
        `EAT's registry. Either ${CertificateRegistryArr.join(', ')}.`,
        CertificateRegistry.NAR
    )
    .addParam<EnergyCertificateType>(
        'certification',
        `EAT certifications. Either ${CertificateArr.join(', ')}`,
        EnergyCertificateType.REC
    )
    .addParam<CertificateEndorsement>(
        'endorsement',
        `EAT endorsements. Either ${CertificateEndorsementArr.join(', ')}`,
        CertificateEndorsement.GREEN_E
    )
    .addParam<string>('quantity', 'Number of EATs to mint.', '5')
    .addOptionalParam('minter', 'Address of minter contract')
    .setAction(
        async (
            taskArgs: TaskArguments,
            {
                ethers,
                deployments,
                network,
                getNamedAccounts,
            }: HardhatRuntimeEnvironment
        ): Promise<void> => {
            if (network.tags['production']) {
                colouredLog(
                    LogColours.red,
                    'Error: Unable to use mint on production network.'
                );
                return;
            }
            // 1. Load required accounts, contracts and info
            const account: string = utils.getAddress(taskArgs.account);
            const { bridge, minter } = await getNamedAccounts();
            const minterAddress = taskArgs.minter ?? minter;
            const signer = await ethers.getSigner(account);
            const bridgeSigner = await ethers.getSigner(bridge);
            const chainId = await bridgeSigner.getChainId();
            const minterContract = await ethers.getContractAt(
                Contracts.minter,
                minterAddress,
                signer
            );

            // 2. Create typed data struct
            const domain = {
                name: Contracts.minter,
                version: '1',
                chainId: chainId,
                verifyingContract: minterAddress.toLowerCase(),
            };
            const types = {
                MintAuthorization: [
                    { name: 'minter', type: 'address' },
                    { name: 'id', type: 'uint256' },
                    { name: 'amount', type: 'uint256' },
                    { name: 'oracleData', type: 'bytes' },
                    { name: 'deadline', type: 'uint256' },
                    { name: 'nonce', type: 'bytes32' },
                ],
            };
            const uuidPacked = ethers.utils
                .hexZeroPad(ethers.utils.hexValue(ethers.utils.randomBytes(16)), 16)
                .slice(2);
            const uuid = [
                uuidPacked.slice(0, 8),
                uuidPacked.slice(8, 12),
                uuidPacked.slice(12, 16),
                uuidPacked.slice(16, 20),
                uuidPacked.slice(20),
            ].join('-');

            const id = encodeEnergyAttributeTokenId(
                uuid,
                taskArgs.registry,
                new Date(taskArgs.vintage)
            );
            const amount = parseInt(taskArgs.quantity);

            const oracleData = encodeOracleData(
                uuid,
                taskArgs.registry,
                new Date(taskArgs.vintage),
                taskArgs.fuel,
                taskArgs.certification,
                taskArgs.endorsement
            );
            console.log('Oracle data is: ', oracleData);

            const deadline = Math.ceil(new Date().getTime() / 1_000) + 86_400; // 1 day
            const nonce = ethers.utils.randomBytes(32);
            const value = {
                minter: account,
                id,
                amount,
                oracleData,
                deadline,
                nonce,
            };

            const signature = await bridgeSigner._signTypedData(domain, types, value);
            console.log(`Signature is: ${signature}`);

            const tx = await minterContract.mint(
                minterAddress,
                id,
                amount,
                [],
                oracleData,
                deadline,
                nonce,
                signature
            );

            const result = await tx.wait();
            console.log(tx, result);
        }
    );
