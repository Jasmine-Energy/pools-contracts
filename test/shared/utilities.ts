
import { ethers, getNamedAccounts } from 'hardhat';
import { Contracts } from '@/utils';
import {
    FuelType,
    CertificateRegistry,
    EnergyCertificateType,
    CertificateEndorsement,
} from '@/types/energy-certificate.types';
import {
    encodeEnergyAttributeTokenId,
    encodeOracleData,
} from '@/utils/token_encoding';
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { deployCoreFixture } from './fixtures';



export async function mintEat(
    recipient: string,
    amount: number = 10,
    fuel: FuelType = FuelType.SOLAR,
    registry: CertificateRegistry = CertificateRegistry.NAR,
    vintage: number = new Date().valueOf(),
    endorsement: CertificateEndorsement = CertificateEndorsement.GREEN_E,
    certification: EnergyCertificateType = EnergyCertificateType.REC
) {
    // 1. Load required accounts, contracts and info
    const { bridge } = await getNamedAccounts();
    const { minter } = await loadFixture(deployCoreFixture);
    const minterAddress = minter.address;
    const signer = await ethers.getSigner(recipient);
    const recipientAddress: string = signer.address;
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
        registry,
        new Date(vintage)
    );

    const oracleData = encodeOracleData(
        uuid,
        registry,
        new Date(vintage),
        fuel,
        certification,
        endorsement
    );

    const deadline = Math.ceil(new Date().getTime() / 1_000) + 86_400; // 1 day
    const nonce = ethers.utils.randomBytes(32);
    const value = {
        minter: recipientAddress,
        id,
        amount,
        oracleData,
        deadline,
        nonce,
    };
    const signature = await bridgeSigner._signTypedData(domain, types, value);

    const tx = await minterContract.mint(
      recipientAddress,
        id,
        amount,
        [],
        oracleData,
        deadline,
        nonce,
        signature
    );
    await tx.wait();
}
