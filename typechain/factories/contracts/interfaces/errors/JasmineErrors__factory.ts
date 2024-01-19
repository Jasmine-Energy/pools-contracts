/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  JasmineErrors,
  JasmineErrorsInterface,
} from "../../../../contracts/interfaces/errors/JasmineErrors";

const _abi = [
  {
    inputs: [],
    name: "Disabled",
    type: "error",
  },
  {
    inputs: [],
    name: "InvalidInput",
    type: "error",
  },
  {
    inputs: [],
    name: "Prohibited",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "bytes32",
        name: "role",
        type: "bytes32",
      },
    ],
    name: "RequiresRole",
    type: "error",
  },
  {
    inputs: [
      {
        internalType: "uint8",
        name: "metadataVersion",
        type: "uint8",
      },
    ],
    name: "UnsupportedMetadataVersion",
    type: "error",
  },
  {
    inputs: [],
    name: "ValidationFailed",
    type: "error",
  },
] as const;

export class JasmineErrors__factory {
  static readonly abi = _abi;
  static createInterface(): JasmineErrorsInterface {
    return new utils.Interface(_abi) as JasmineErrorsInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): JasmineErrors {
    return new Contract(address, _abi, signerOrProvider) as JasmineErrors;
  }
}
