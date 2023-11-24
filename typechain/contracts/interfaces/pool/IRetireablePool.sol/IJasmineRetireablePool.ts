/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumberish,
  BytesLike,
  FunctionFragment,
  Result,
  Interface,
  EventFragment,
  AddressLike,
  ContractRunner,
  ContractMethod,
  Listener,
} from "ethers";
import type {
  TypedContractEvent,
  TypedDeferredTopicFilter,
  TypedEventLog,
  TypedLogDescription,
  TypedListener,
  TypedContractMethod,
} from "../../../../common";

export interface IJasmineRetireablePoolInterface extends Interface {
  getFunction(
    nameOrSignature:
      | "deposit"
      | "depositBatch"
      | "depositFrom"
      | "retire"
      | "retirementCost"
      | "withdraw"
      | "withdrawFrom"
      | "withdrawSpecific"
      | "withdrawalCost(uint256)"
      | "withdrawalCost(uint256[],uint256[])"
  ): FunctionFragment;

  getEvent(
    nameOrSignatureOrTopic: "Deposit" | "Retirement" | "Withdraw"
  ): EventFragment;

  encodeFunctionData(
    functionFragment: "deposit",
    values: [BigNumberish, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "depositBatch",
    values: [AddressLike, BigNumberish[], BigNumberish[]]
  ): string;
  encodeFunctionData(
    functionFragment: "depositFrom",
    values: [AddressLike, BigNumberish, BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "retire",
    values: [AddressLike, AddressLike, BigNumberish, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "retirementCost",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "withdraw",
    values: [AddressLike, BigNumberish, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "withdrawFrom",
    values: [AddressLike, AddressLike, BigNumberish, BytesLike]
  ): string;
  encodeFunctionData(
    functionFragment: "withdrawSpecific",
    values: [
      AddressLike,
      AddressLike,
      BigNumberish[],
      BigNumberish[],
      BytesLike
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "withdrawalCost(uint256)",
    values: [BigNumberish]
  ): string;
  encodeFunctionData(
    functionFragment: "withdrawalCost(uint256[],uint256[])",
    values: [BigNumberish[], BigNumberish[]]
  ): string;

  decodeFunctionResult(functionFragment: "deposit", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "depositBatch",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "depositFrom",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "retire", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "retirementCost",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "withdraw", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "withdrawFrom",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "withdrawSpecific",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "withdrawalCost(uint256)",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "withdrawalCost(uint256[],uint256[])",
    data: BytesLike
  ): Result;
}

export namespace DepositEvent {
  export type InputTuple = [
    operator: AddressLike,
    owner: AddressLike,
    quantity: BigNumberish
  ];
  export type OutputTuple = [operator: string, owner: string, quantity: bigint];
  export interface OutputObject {
    operator: string;
    owner: string;
    quantity: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace RetirementEvent {
  export type InputTuple = [
    operator: AddressLike,
    beneficiary: AddressLike,
    quantity: BigNumberish
  ];
  export type OutputTuple = [
    operator: string,
    beneficiary: string,
    quantity: bigint
  ];
  export interface OutputObject {
    operator: string;
    beneficiary: string;
    quantity: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export namespace WithdrawEvent {
  export type InputTuple = [
    sender: AddressLike,
    receiver: AddressLike,
    quantity: BigNumberish
  ];
  export type OutputTuple = [
    sender: string,
    receiver: string,
    quantity: bigint
  ];
  export interface OutputObject {
    sender: string;
    receiver: string;
    quantity: bigint;
  }
  export type Event = TypedContractEvent<InputTuple, OutputTuple, OutputObject>;
  export type Filter = TypedDeferredTopicFilter<Event>;
  export type Log = TypedEventLog<Event>;
  export type LogDescription = TypedLogDescription<Event>;
}

export interface IJasmineRetireablePool extends BaseContract {
  connect(runner?: ContractRunner | null): IJasmineRetireablePool;
  waitForDeployment(): Promise<this>;

  interface: IJasmineRetireablePoolInterface;

  queryFilter<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;
  queryFilter<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TypedEventLog<TCEvent>>>;

  on<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  on<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  once<TCEvent extends TypedContractEvent>(
    event: TCEvent,
    listener: TypedListener<TCEvent>
  ): Promise<this>;
  once<TCEvent extends TypedContractEvent>(
    filter: TypedDeferredTopicFilter<TCEvent>,
    listener: TypedListener<TCEvent>
  ): Promise<this>;

  listeners<TCEvent extends TypedContractEvent>(
    event: TCEvent
  ): Promise<Array<TypedListener<TCEvent>>>;
  listeners(eventName?: string): Promise<Array<Listener>>;
  removeAllListeners<TCEvent extends TypedContractEvent>(
    event?: TCEvent
  ): Promise<this>;

  deposit: TypedContractMethod<
    [tokenId: BigNumberish, quantity: BigNumberish],
    [bigint],
    "nonpayable"
  >;

  depositBatch: TypedContractMethod<
    [from: AddressLike, tokenIds: BigNumberish[], quantities: BigNumberish[]],
    [bigint],
    "nonpayable"
  >;

  depositFrom: TypedContractMethod<
    [from: AddressLike, tokenId: BigNumberish, quantity: BigNumberish],
    [bigint],
    "nonpayable"
  >;

  retire: TypedContractMethod<
    [
      from: AddressLike,
      beneficiary: AddressLike,
      amount: BigNumberish,
      data: BytesLike
    ],
    [void],
    "nonpayable"
  >;

  retirementCost: TypedContractMethod<[amount: BigNumberish], [bigint], "view">;

  withdraw: TypedContractMethod<
    [recipient: AddressLike, quantity: BigNumberish, data: BytesLike],
    [[bigint[], bigint[]] & { tokenIds: bigint[]; amounts: bigint[] }],
    "nonpayable"
  >;

  withdrawFrom: TypedContractMethod<
    [
      spender: AddressLike,
      recipient: AddressLike,
      quantity: BigNumberish,
      data: BytesLike
    ],
    [[bigint[], bigint[]] & { tokenIds: bigint[]; amounts: bigint[] }],
    "nonpayable"
  >;

  withdrawSpecific: TypedContractMethod<
    [
      spender: AddressLike,
      recipient: AddressLike,
      tokenIds: BigNumberish[],
      quantities: BigNumberish[],
      data: BytesLike
    ],
    [void],
    "nonpayable"
  >;

  "withdrawalCost(uint256)": TypedContractMethod<
    [amount: BigNumberish],
    [bigint],
    "view"
  >;

  "withdrawalCost(uint256[],uint256[])": TypedContractMethod<
    [tokenIds: BigNumberish[], amounts: BigNumberish[]],
    [bigint],
    "view"
  >;

  getFunction<T extends ContractMethod = ContractMethod>(
    key: string | FunctionFragment
  ): T;

  getFunction(
    nameOrSignature: "deposit"
  ): TypedContractMethod<
    [tokenId: BigNumberish, quantity: BigNumberish],
    [bigint],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "depositBatch"
  ): TypedContractMethod<
    [from: AddressLike, tokenIds: BigNumberish[], quantities: BigNumberish[]],
    [bigint],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "depositFrom"
  ): TypedContractMethod<
    [from: AddressLike, tokenId: BigNumberish, quantity: BigNumberish],
    [bigint],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "retire"
  ): TypedContractMethod<
    [
      from: AddressLike,
      beneficiary: AddressLike,
      amount: BigNumberish,
      data: BytesLike
    ],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "retirementCost"
  ): TypedContractMethod<[amount: BigNumberish], [bigint], "view">;
  getFunction(
    nameOrSignature: "withdraw"
  ): TypedContractMethod<
    [recipient: AddressLike, quantity: BigNumberish, data: BytesLike],
    [[bigint[], bigint[]] & { tokenIds: bigint[]; amounts: bigint[] }],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "withdrawFrom"
  ): TypedContractMethod<
    [
      spender: AddressLike,
      recipient: AddressLike,
      quantity: BigNumberish,
      data: BytesLike
    ],
    [[bigint[], bigint[]] & { tokenIds: bigint[]; amounts: bigint[] }],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "withdrawSpecific"
  ): TypedContractMethod<
    [
      spender: AddressLike,
      recipient: AddressLike,
      tokenIds: BigNumberish[],
      quantities: BigNumberish[],
      data: BytesLike
    ],
    [void],
    "nonpayable"
  >;
  getFunction(
    nameOrSignature: "withdrawalCost(uint256)"
  ): TypedContractMethod<[amount: BigNumberish], [bigint], "view">;
  getFunction(
    nameOrSignature: "withdrawalCost(uint256[],uint256[])"
  ): TypedContractMethod<
    [tokenIds: BigNumberish[], amounts: BigNumberish[]],
    [bigint],
    "view"
  >;

  getEvent(
    key: "Deposit"
  ): TypedContractEvent<
    DepositEvent.InputTuple,
    DepositEvent.OutputTuple,
    DepositEvent.OutputObject
  >;
  getEvent(
    key: "Retirement"
  ): TypedContractEvent<
    RetirementEvent.InputTuple,
    RetirementEvent.OutputTuple,
    RetirementEvent.OutputObject
  >;
  getEvent(
    key: "Withdraw"
  ): TypedContractEvent<
    WithdrawEvent.InputTuple,
    WithdrawEvent.OutputTuple,
    WithdrawEvent.OutputObject
  >;

  filters: {
    "Deposit(address,address,uint256)": TypedContractEvent<
      DepositEvent.InputTuple,
      DepositEvent.OutputTuple,
      DepositEvent.OutputObject
    >;
    Deposit: TypedContractEvent<
      DepositEvent.InputTuple,
      DepositEvent.OutputTuple,
      DepositEvent.OutputObject
    >;

    "Retirement(address,address,uint256)": TypedContractEvent<
      RetirementEvent.InputTuple,
      RetirementEvent.OutputTuple,
      RetirementEvent.OutputObject
    >;
    Retirement: TypedContractEvent<
      RetirementEvent.InputTuple,
      RetirementEvent.OutputTuple,
      RetirementEvent.OutputObject
    >;

    "Withdraw(address,address,uint256)": TypedContractEvent<
      WithdrawEvent.InputTuple,
      WithdrawEvent.OutputTuple,
      WithdrawEvent.OutputObject
    >;
    Withdraw: TypedContractEvent<
      WithdrawEvent.InputTuple,
      WithdrawEvent.OutputTuple,
      WithdrawEvent.OutputObject
    >;
  };
}
