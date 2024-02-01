/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import type { Provider, TransactionRequest } from "@ethersproject/providers";
import type { PromiseOrValue } from "../../../../../common";
import type {
  ERC1155Upgradeable,
  ERC1155UpgradeableInterface,
} from "../../../../../@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable";

const _abi = [
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "operator",
        type: "address",
      },
      {
        indexed: false,
        internalType: "bool",
        name: "approved",
        type: "bool",
      },
    ],
    name: "ApprovalForAll",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "uint8",
        name: "version",
        type: "uint8",
      },
    ],
    name: "Initialized",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "operator",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256[]",
        name: "ids",
        type: "uint256[]",
      },
      {
        indexed: false,
        internalType: "uint256[]",
        name: "values",
        type: "uint256[]",
      },
    ],
    name: "TransferBatch",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: true,
        internalType: "address",
        name: "operator",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        indexed: true,
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "id",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "value",
        type: "uint256",
      },
    ],
    name: "TransferSingle",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "string",
        name: "value",
        type: "string",
      },
      {
        indexed: true,
        internalType: "uint256",
        name: "id",
        type: "uint256",
      },
    ],
    name: "URI",
    type: "event",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "id",
        type: "uint256",
      },
    ],
    name: "balanceOf",
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
  {
    inputs: [
      {
        internalType: "address[]",
        name: "accounts",
        type: "address[]",
      },
      {
        internalType: "uint256[]",
        name: "ids",
        type: "uint256[]",
      },
    ],
    name: "balanceOfBatch",
    outputs: [
      {
        internalType: "uint256[]",
        name: "",
        type: "uint256[]",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "account",
        type: "address",
      },
      {
        internalType: "address",
        name: "operator",
        type: "address",
      },
    ],
    name: "isApprovedForAll",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256[]",
        name: "ids",
        type: "uint256[]",
      },
      {
        internalType: "uint256[]",
        name: "amounts",
        type: "uint256[]",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "safeBatchTransferFrom",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "from",
        type: "address",
      },
      {
        internalType: "address",
        name: "to",
        type: "address",
      },
      {
        internalType: "uint256",
        name: "id",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "amount",
        type: "uint256",
      },
      {
        internalType: "bytes",
        name: "data",
        type: "bytes",
      },
    ],
    name: "safeTransferFrom",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "operator",
        type: "address",
      },
      {
        internalType: "bool",
        name: "approved",
        type: "bool",
      },
    ],
    name: "setApprovalForAll",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes4",
        name: "interfaceId",
        type: "bytes4",
      },
    ],
    name: "supportsInterface",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    name: "uri",
    outputs: [
      {
        internalType: "string",
        name: "",
        type: "string",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
] as const;

const _bytecode =
  "0x608060405234801561001057600080fd5b50611450806100206000396000f3fe608060405234801561001057600080fd5b50600436106100875760003560e01c80634e1273f41161005b5780634e1273f41461010a578063a22cb4651461012a578063e985e9c51461013d578063f242432a1461017957600080fd5b8062fdd58e1461008c57806301ffc9a7146100b25780630e89341c146100d55780632eb2c2d6146100f5575b600080fd5b61009f61009a366004610d55565b61018c565b6040519081526020015b60405180910390f35b6100c56100c0366004610d98565b610227565b60405190151581526020016100a9565b6100e86100e3366004610dbc565b610277565b6040516100a99190610e1b565b610108610103366004610f7f565b61030b565b005b61011d610118366004611029565b61039e565b6040516100a99190611130565b610108610138366004611143565b6104c0565b6100c561014b36600461117f565b6001600160a01b03918216600090815260666020908152604080832093909416825291909152205460ff1690565b6101086101873660046111b2565b6104cf565b60006001600160a01b0383166101fc5760405162461bcd60e51b815260206004820152602a60248201527f455243313135353a2061646472657373207a65726f206973206e6f742061207660448201526930b634b21037bbb732b960b11b60648201526084015b60405180910390fd5b5060008181526065602090815260408083206001600160a01b03861684529091529020545b92915050565b60006001600160e01b03198216636cdb3d1360e11b148061025857506001600160e01b031982166303a24d0760e21b145b8061022157506301ffc9a760e01b6001600160e01b0319831614610221565b60606067805461028690611217565b80601f01602080910402602001604051908101604052809291908181526020018280546102b290611217565b80156102ff5780601f106102d4576101008083540402835291602001916102ff565b820191906000526020600020905b8154815290600101906020018083116102e257829003601f168201915b50505050509050919050565b6001600160a01b0385163314806103275750610327853361014b565b61038a5760405162461bcd60e51b815260206004820152602e60248201527f455243313135353a2063616c6c6572206973206e6f7420746f6b656e206f776e60448201526d195c881bdc88185c1c1c9bdd995960921b60648201526084016101f3565b610397858585858561055b565b5050505050565b606081518351146104035760405162461bcd60e51b815260206004820152602960248201527f455243313135353a206163636f756e747320616e6420696473206c656e677468604482015268040dad2e6dac2e8c6d60bb1b60648201526084016101f3565b6000835167ffffffffffffffff81111561041f5761041f610e2e565b604051908082528060200260200182016040528015610448578160200160208202803683370190505b50905060005b84518110156104b85761049385828151811061046c5761046c611251565b602002602001015185838151811061048657610486611251565b602002602001015161018c565b8282815181106104a5576104a5611251565b602090810291909101015260010161044e565b509392505050565b6104cb3383836107b5565b5050565b6001600160a01b0385163314806104eb57506104eb853361014b565b61054e5760405162461bcd60e51b815260206004820152602e60248201527f455243313135353a2063616c6c6572206973206e6f7420746f6b656e206f776e60448201526d195c881bdc88185c1c1c9bdd995960921b60648201526084016101f3565b6103978585858585610895565b81518351146105bd5760405162461bcd60e51b815260206004820152602860248201527f455243313135353a2069647320616e6420616d6f756e7473206c656e677468206044820152670dad2e6dac2e8c6d60c31b60648201526084016101f3565b6001600160a01b0384166106215760405162461bcd60e51b815260206004820152602560248201527f455243313135353a207472616e7366657220746f20746865207a65726f206164604482015264647265737360d81b60648201526084016101f3565b3360005b845181101561074757600085828151811061064257610642611251565b60200260200101519050600085838151811061066057610660611251565b60209081029190910181015160008481526065835260408082206001600160a01b038e1683529093529190912054909150818110156106f45760405162461bcd60e51b815260206004820152602a60248201527f455243313135353a20696e73756666696369656e742062616c616e636520666f60448201526939103a3930b739b332b960b11b60648201526084016101f3565b60008381526065602090815260408083206001600160a01b038e8116855292528083208585039055908b16825281208054849290610733908490611267565b909155505060019093019250610625915050565b50846001600160a01b0316866001600160a01b0316826001600160a01b03167f4a39dc06d4c0dbc64b70af90fd698a233a518aa5d07e595d983b8c0526c8f7fb8787604051610797929190611288565b60405180910390a46107ad818787878787610a44565b505050505050565b816001600160a01b0316836001600160a01b0316036108285760405162461bcd60e51b815260206004820152602960248201527f455243313135353a2073657474696e6720617070726f76616c20737461747573604482015268103337b91039b2b63360b91b60648201526084016101f3565b6001600160a01b03838116600081815260666020908152604080832094871680845294825291829020805460ff191686151590811790915591519182527f17307eab39ab6107e8899845ad3d59bd9653f200f220920489ca2b5937696c31910160405180910390a3505050565b6001600160a01b0384166108f95760405162461bcd60e51b815260206004820152602560248201527f455243313135353a207472616e7366657220746f20746865207a65726f206164604482015264647265737360d81b60648201526084016101f3565b33600061090585610bf2565b9050600061091285610bf2565b905060008681526065602090815260408083206001600160a01b038c1684529091529020548581101561099a5760405162461bcd60e51b815260206004820152602a60248201527f455243313135353a20696e73756666696369656e742062616c616e636520666f60448201526939103a3930b739b332b960b11b60648201526084016101f3565b60008781526065602090815260408083206001600160a01b038d8116855292528083208985039055908a168252812080548892906109d9908490611267565b909155505060408051888152602081018890526001600160a01b03808b16928c821692918816917fc3d58168c5ae7397731d063d5bbf3d657854427343f4c083240f7aacaa2d0f62910160405180910390a4610a39848a8a8a8a8a610c3d565b505050505050505050565b6001600160a01b0384163b156107ad5760405163bc197c8160e01b81526001600160a01b0385169063bc197c8190610a8890899089908890889088906004016112b6565b6020604051808303816000875af1925050508015610ac3575060408051601f3d908101601f19168201909252610ac091810190611314565b60015b610b7857610acf611331565b806308c379a003610b085750610ae361134d565b80610aee5750610b0a565b8060405162461bcd60e51b81526004016101f39190610e1b565b505b60405162461bcd60e51b815260206004820152603460248201527f455243313135353a207472616e7366657220746f206e6f6e2d4552433131353560448201527f526563656976657220696d706c656d656e74657200000000000000000000000060648201526084016101f3565b6001600160e01b0319811663bc197c8160e01b14610be95760405162461bcd60e51b815260206004820152602860248201527f455243313135353a204552433131353552656365697665722072656a656374656044820152676420746f6b656e7360c01b60648201526084016101f3565b50505050505050565b60408051600180825281830190925260609160009190602080830190803683370190505090508281600081518110610c2c57610c2c611251565b602090810291909101015292915050565b6001600160a01b0384163b156107ad5760405163f23a6e6160e01b81526001600160a01b0385169063f23a6e6190610c8190899089908890889088906004016113d7565b6020604051808303816000875af1925050508015610cbc575060408051601f3d908101601f19168201909252610cb991810190611314565b60015b610cc857610acf611331565b6001600160e01b0319811663f23a6e6160e01b14610be95760405162461bcd60e51b815260206004820152602860248201527f455243313135353a204552433131353552656365697665722072656a656374656044820152676420746f6b656e7360c01b60648201526084016101f3565b80356001600160a01b0381168114610d5057600080fd5b919050565b60008060408385031215610d6857600080fd5b610d7183610d39565b946020939093013593505050565b6001600160e01b031981168114610d9557600080fd5b50565b600060208284031215610daa57600080fd5b8135610db581610d7f565b9392505050565b600060208284031215610dce57600080fd5b5035919050565b6000815180845260005b81811015610dfb57602081850181015186830182015201610ddf565b506000602082860101526020601f19601f83011685010191505092915050565b602081526000610db56020830184610dd5565b634e487b7160e01b600052604160045260246000fd5b601f8201601f1916810167ffffffffffffffff81118282101715610e6a57610e6a610e2e565b6040525050565b600067ffffffffffffffff821115610e8b57610e8b610e2e565b5060051b60200190565b600082601f830112610ea657600080fd5b81356020610eb382610e71565b604051610ec08282610e44565b80915083815260208101915060208460051b870101935086841115610ee457600080fd5b602086015b84811015610f005780358352918301918301610ee9565b509695505050505050565b600082601f830112610f1c57600080fd5b813567ffffffffffffffff811115610f3657610f36610e2e565b604051610f4d601f8301601f191660200182610e44565b818152846020838601011115610f6257600080fd5b816020850160208301376000918101602001919091529392505050565b600080600080600060a08688031215610f9757600080fd5b610fa086610d39565b9450610fae60208701610d39565b9350604086013567ffffffffffffffff80821115610fcb57600080fd5b610fd789838a01610e95565b94506060880135915080821115610fed57600080fd5b610ff989838a01610e95565b9350608088013591508082111561100f57600080fd5b5061101c88828901610f0b565b9150509295509295909350565b6000806040838503121561103c57600080fd5b823567ffffffffffffffff8082111561105457600080fd5b818501915085601f83011261106857600080fd5b8135602061107582610e71565b6040516110828282610e44565b83815260059390931b85018201928281019150898411156110a257600080fd5b948201945b838610156110c7576110b886610d39565b825294820194908201906110a7565b965050860135925050808211156110dd57600080fd5b506110ea85828601610e95565b9150509250929050565b60008151808452602080850194506020840160005b8381101561112557815187529582019590820190600101611109565b509495945050505050565b602081526000610db560208301846110f4565b6000806040838503121561115657600080fd5b61115f83610d39565b91506020830135801515811461117457600080fd5b809150509250929050565b6000806040838503121561119257600080fd5b61119b83610d39565b91506111a960208401610d39565b90509250929050565b600080600080600060a086880312156111ca57600080fd5b6111d386610d39565b94506111e160208701610d39565b93506040860135925060608601359150608086013567ffffffffffffffff81111561120b57600080fd5b61101c88828901610f0b565b600181811c9082168061122b57607f821691505b60208210810361124b57634e487b7160e01b600052602260045260246000fd5b50919050565b634e487b7160e01b600052603260045260246000fd5b8082018082111561022157634e487b7160e01b600052601160045260246000fd5b60408152600061129b60408301856110f4565b82810360208401526112ad81856110f4565b95945050505050565b60006001600160a01b03808816835280871660208401525060a060408301526112e260a08301866110f4565b82810360608401526112f481866110f4565b905082810360808401526113088185610dd5565b98975050505050505050565b60006020828403121561132657600080fd5b8151610db581610d7f565b600060033d111561134a5760046000803e5060005160e01c5b90565b600060443d101561135b5790565b6040516003193d81016004833e81513d67ffffffffffffffff816024840111818411171561138b57505050505090565b82850191508151818111156113a35750505050505090565b843d87010160208285010111156113bd5750505050505090565b6113cc60208286010187610e44565b509095945050505050565b60006001600160a01b03808816835280871660208401525084604083015283606083015260a0608083015261140f60a0830184610dd5565b97965050505050505056fea264697066735822122081359c05d6842acc92a50101f4d7912820d45540df199402c1cf32cd0ae7749c64736f6c63430008170033";

type ERC1155UpgradeableConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: ERC1155UpgradeableConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class ERC1155Upgradeable__factory extends ContractFactory {
  constructor(...args: ERC1155UpgradeableConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
  }

  override deploy(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ERC1155Upgradeable> {
    return super.deploy(overrides || {}) as Promise<ERC1155Upgradeable>;
  }
  override getDeployTransaction(
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  override attach(address: string): ERC1155Upgradeable {
    return super.attach(address) as ERC1155Upgradeable;
  }
  override connect(signer: Signer): ERC1155Upgradeable__factory {
    return super.connect(signer) as ERC1155Upgradeable__factory;
  }

  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): ERC1155UpgradeableInterface {
    return new utils.Interface(_abi) as ERC1155UpgradeableInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): ERC1155Upgradeable {
    return new Contract(address, _abi, signerOrProvider) as ERC1155Upgradeable;
  }
}
