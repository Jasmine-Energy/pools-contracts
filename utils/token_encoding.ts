
import { ethers } from 'ethers';
import { 
    CertificateRegistry,
    CertificateRegistryArr
} from '@/types/energy-certificate.types';

interface ParsedEnergyAttributeTokenID {
  uuid: string;
  registry: CertificateRegistry;
  vintage: Date; // NOTE: Vintage experiences data loss compared to DB. Fetch EAC from UUID to get exact vintage
}


/**
 * @description decode an energy attribute token id into its
 * associated certificateId, vintage, and registry
 */
const decodeEnergyAttributeTokenId = (tokenId: bigint | string): ParsedEnergyAttributeTokenID => {

  const eatId = BigInt(tokenId);

  // @ts-ignore
  const uuidNumber = eatId >> 128n; // eslint-disable-line no-bitwise
  // zero padding ensures that we don't accidentally chop off the leading zeros
  const uuidPacked = ethers.utils.hexZeroPad(ethers.utils.hexValue(uuidNumber), 16).slice(2);
  const uuid = [
    uuidPacked.slice(0, 8),
    uuidPacked.slice(8, 12),
    uuidPacked.slice(12, 16),
    uuidPacked.slice(16, 20),
    uuidPacked.slice(20)
  ].join('-');

  // @ts-ignore
  const registryNumber = Number(eatId >> 96n & BigInt(2 ** 32 - 1)); // eslint-disable-line no-bitwise
  const registry = Object.values(CertificateRegistry)[registryNumber] as CertificateRegistry;

  // @ts-ignore
  const vintageNumber = Number(eatId >> 56n & BigInt(2 ** 40 - 1)); // eslint-disable-line no-bitwise
  const vintage = new Date(vintageNumber * 1_000);

  return {
    uuid,
    registry,
    vintage,
  };
}


/**
 * @description encode a energy attribute token id from the
 * associated certificateId, vintage, and registry
 */
const encodeEnergyAttributeTokenId = (certificateId: string, registry: CertificateRegistry, vintage: Date) => {

  const uuid = BigInt(`0x${certificateId.replaceAll('-', '')}`);
  const registryNumber = BigInt(CertificateRegistryArr.indexOf(registry)) & BigInt(2 ** 32 - 1);
  const vintageNumber = BigInt(Math.ceil(vintage.getTime() / 1_000)) & BigInt(2 ** 40 - 1);
  return (uuid << 128n) + (registryNumber << 96n) + (vintageNumber << 56n);
}


export {
  encodeEnergyAttributeTokenId,
  ParsedEnergyAttributeTokenID,
  decodeEnergyAttributeTokenId,
};
