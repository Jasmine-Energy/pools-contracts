/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */

import { Contract, Interface, type ContractRunner } from "ethers";
import type {
  IJasminePoolFactory,
  IJasminePoolFactoryInterface,
} from "../../../contracts/interfaces/IJasminePoolFactory";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "bytes",
        name: "policy",
        type: "bytes",
      },
      {
        indexed: true,
        internalType: "address",
        name: "pool",
        type: "address",
      },
      {
        indexed: true,
        internalType: "string",
        name: "name",
        type: "string",
      },
      {
        indexed: true,
        internalType: "string",
        name: "symbol",
        type: "string",
      },
    ],
    name: "PoolCreated",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "poolImplementation",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "beaconAddress",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "poolIndex",
        type: "uint256",
      },
    ],
    name: "PoolImplementationAdded",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "beaconAddress",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "poolIndex",
        type: "uint256",
      },
    ],
    name: "PoolImplementationRemoved",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "newPoolImplementation",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "beaconAddress",
        type: "address",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "poolIndex",
        type: "uint256",
      },
    ],
    name: "PoolImplementationUpgraded",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "tokenId",
        type: "uint256",
      },
    ],
    name: "eligiblePoolsForToken",
    outputs: [
      {
        internalType: "address[]",
        name: "pools",
        type: "address[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "index",
        type: "uint256",
      },
    ],
    name: "getPoolAtIndex",
    outputs: [
      {
        internalType: "address",
        name: "pool",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "totalPools",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

export class IJasminePoolFactory__factory {
  static readonly abi = _abi;
  static createInterface(): IJasminePoolFactoryInterface {
    return new Interface(_abi) as IJasminePoolFactoryInterface;
  }
  static connect(
    address: string,
    runner?: ContractRunner | null
  ): IJasminePoolFactory {
    return new Contract(
      address,
      _abi,
      runner
    ) as unknown as IJasminePoolFactory;
  }
}
