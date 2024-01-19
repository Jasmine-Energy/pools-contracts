/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  ERC712,
  ERC712Interface,
} from "../../../../contracts/test/CrypticInterface.sol/ERC712";

const _abi = [
  {
    inputs: [],
    name: "DOMAIN_SEPARATOR",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

export class ERC712__factory {
  static readonly abi = _abi;
  static createInterface(): ERC712Interface {
    return new utils.Interface(_abi) as ERC712Interface;
  }
  static connect(address: string, signerOrProvider: Signer | Provider): ERC712 {
    return new Contract(address, _abi, signerOrProvider) as ERC712;
  }
}
