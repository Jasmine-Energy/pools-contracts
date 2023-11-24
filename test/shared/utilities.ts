
import { ethers, getNamedAccounts } from 'hardhat';
import { 
    Contracts,
    AnyField,
    encodeEnergyAttributeTokenId,
    encodeOracleData
} from '@/utils';
import {
    FuelType,
    CertificateRegistry,
    EnergyCertificateType,
    CertificateEndorsement,
    FuelTypesArray,
} from '@/types';
import { JasmineMinter } from '@/typechain';

export type mintFunctionType = ((recipient: string, amount?: number, fuel?: FuelType, registry?: CertificateRegistry, vintage?: number, endorsement?: CertificateEndorsement, certificateType?: EnergyCertificateType) => Promise<{ id: bigint; amount: bigint; }>) | ((arg0: string, arg1: number, arg2: FuelType) => { id: bigint; amount: bigint; } | PromiseLike<{ id: bigint; amount: bigint; }>);

export function makeMintFunction(minter: JasmineMinter): mintFunctionType {
    return async function mintEat(
        recipient: string,
        amount: number = 10,
        fuel: FuelType = FuelType.SOLAR,
        registry: CertificateRegistry = CertificateRegistry.NAR,
        vintage: number = new Date().valueOf(),
        endorsement: CertificateEndorsement = CertificateEndorsement.GREEN_E,
        certificateType: EnergyCertificateType = EnergyCertificateType.REC
    ) {
        // 1. Load required accounts, contracts and info
        const { bridge } = await getNamedAccounts();
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
            certificateType,
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
    
        return { id, amount: BigInt(amount) };
    }
}

export function createSolarPolicy() {
    return {
        vintagePeriod: [AnyField, AnyField] as [number, number],
        techType: BigInt(FuelTypesArray.indexOf(FuelType.SOLAR)) & BigInt(2 ** 32 - 1),
        registry: AnyField,
        certificateType: AnyField,
        endorsement: AnyField
    };
}

export function createWindPolicy() {
    return {
        vintagePeriod: [AnyField, AnyField] as [number, number],
        techType: BigInt(FuelTypesArray.indexOf(FuelType.WIND)) & BigInt(2 ** 32 - 1),
        registry: AnyField,
        certificateType: AnyField,
        endorsement: AnyField
    };
}

export function createAnyTechAnnualPolicy() {
    const currentYear = new Date().getFullYear(); // TODO: This does not account for timezones
    return {
        vintagePeriod: [
            Math.floor(new Date(currentYear, 0, 0).valueOf() / 1_000),
            Math.ceil(new Date(currentYear + 1, 0, 0).valueOf() / 1_000) - 1,
        ] as [number, number],
        techType: AnyField,
        registry: AnyField,
        certificateType: AnyField,
        endorsement: AnyField
    };
}
