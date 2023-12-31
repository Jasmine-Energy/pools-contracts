/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Signer, utils } from "ethers";
import type { Provider } from "@ethersproject/providers";
import type {
  IHevm,
  IHevmInterface,
} from "../../../../../../@crytic/properties/contracts/util/Hevm.sol/IHevm";

const _abi = [
  {
    inputs: [
      {
        internalType: "uint256",
        name: "privateKey",
        type: "uint256",
      },
    ],
    name: "addr",
    outputs: [
      {
        internalType: "address",
        name: "addr",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "string[]",
        name: "inputs",
        type: "string[]",
      },
    ],
    name: "ffi",
    outputs: [
      {
        internalType: "bytes",
        name: "result",
        type: "bytes",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "where",
        type: "address",
      },
      {
        internalType: "bytes32",
        name: "slot",
        type: "bytes32",
      },
    ],
    name: "load",
    outputs: [
      {
        internalType: "bytes32",
        name: "",
        type: "bytes32",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "newSender",
        type: "address",
      },
    ],
    name: "prank",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "newNumber",
        type: "uint256",
      },
    ],
    name: "roll",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "privateKey",
        type: "uint256",
      },
      {
        internalType: "bytes32",
        name: "digest",
        type: "bytes32",
      },
    ],
    name: "sign",
    outputs: [
      {
        internalType: "uint8",
        name: "r",
        type: "uint8",
      },
      {
        internalType: "bytes32",
        name: "v",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "s",
        type: "bytes32",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "where",
        type: "address",
      },
      {
        internalType: "bytes32",
        name: "slot",
        type: "bytes32",
      },
      {
        internalType: "bytes32",
        name: "value",
        type: "bytes32",
      },
    ],
    name: "store",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "newTimestamp",
        type: "uint256",
      },
    ],
    name: "warp",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
] as const;

export class IHevm__factory {
  static readonly abi = _abi;
  static createInterface(): IHevmInterface {
    return new utils.Interface(_abi) as IHevmInterface;
  }
  static connect(address: string, signerOrProvider: Signer | Provider): IHevm {
    return new Contract(address, _abi, signerOrProvider) as IHevm;
  }
}
