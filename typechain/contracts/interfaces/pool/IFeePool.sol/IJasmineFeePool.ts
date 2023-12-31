/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  ContractTransaction,
  Overrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type {
  FunctionFragment,
  Result,
  EventFragment,
} from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
  PromiseOrValue,
} from "../../../../common";

export interface IJasmineFeePoolInterface extends utils.Interface {
  functions: {
    "deposit(uint256,uint256)": FunctionFragment;
    "depositBatch(address,uint256[],uint256[])": FunctionFragment;
    "depositFrom(address,uint256,uint256)": FunctionFragment;
    "retire(address,address,uint256,bytes)": FunctionFragment;
    "retireExact(address,address,uint256,bytes)": FunctionFragment;
    "retirementCost(uint256)": FunctionFragment;
    "retirementRate()": FunctionFragment;
    "withdraw(address,uint256,bytes)": FunctionFragment;
    "withdrawFrom(address,address,uint256,bytes)": FunctionFragment;
    "withdrawSpecific(address,address,uint256[],uint256[],bytes)": FunctionFragment;
    "withdrawalCost(uint256)": FunctionFragment;
    "withdrawalCost(uint256[],uint256[])": FunctionFragment;
    "withdrawalRate()": FunctionFragment;
    "withdrawalSpecificRate()": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "deposit"
      | "depositBatch"
      | "depositFrom"
      | "retire"
      | "retireExact"
      | "retirementCost"
      | "retirementRate"
      | "withdraw"
      | "withdrawFrom"
      | "withdrawSpecific"
      | "withdrawalCost(uint256)"
      | "withdrawalCost(uint256[],uint256[])"
      | "withdrawalRate"
      | "withdrawalSpecificRate"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "deposit",
    values: [PromiseOrValue<BigNumberish>, PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "depositBatch",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>[],
      PromiseOrValue<BigNumberish>[]
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "depositFrom",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "retire",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "retireExact",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "retirementCost",
    values: [PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "retirementRate",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "withdraw",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "withdrawFrom",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "withdrawSpecific",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>[],
      PromiseOrValue<BigNumberish>[],
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "withdrawalCost(uint256)",
    values: [PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "withdrawalCost(uint256[],uint256[])",
    values: [PromiseOrValue<BigNumberish>[], PromiseOrValue<BigNumberish>[]]
  ): string;
  encodeFunctionData(
    functionFragment: "withdrawalRate",
    values?: undefined
  ): string;
  encodeFunctionData(
    functionFragment: "withdrawalSpecificRate",
    values?: undefined
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
    functionFragment: "retireExact",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "retirementCost",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "retirementRate",
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
  decodeFunctionResult(
    functionFragment: "withdrawalRate",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "withdrawalSpecificRate",
    data: BytesLike
  ): Result;

  events: {
    "Deposit(address,address,uint256)": EventFragment;
    "Retirement(address,address,uint256)": EventFragment;
    "RetirementRateUpdate(uint96,address)": EventFragment;
    "Withdraw(address,address,uint256)": EventFragment;
    "WithdrawalRateUpdate(uint96,address,bool)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "Deposit"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "Retirement"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "RetirementRateUpdate"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "Withdraw"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "WithdrawalRateUpdate"): EventFragment;
}

export interface DepositEventObject {
  operator: string;
  owner: string;
  quantity: BigNumber;
}
export type DepositEvent = TypedEvent<
  [string, string, BigNumber],
  DepositEventObject
>;

export type DepositEventFilter = TypedEventFilter<DepositEvent>;

export interface RetirementEventObject {
  operator: string;
  beneficiary: string;
  quantity: BigNumber;
}
export type RetirementEvent = TypedEvent<
  [string, string, BigNumber],
  RetirementEventObject
>;

export type RetirementEventFilter = TypedEventFilter<RetirementEvent>;

export interface RetirementRateUpdateEventObject {
  retirementFeeBips: BigNumber;
  beneficiary: string;
}
export type RetirementRateUpdateEvent = TypedEvent<
  [BigNumber, string],
  RetirementRateUpdateEventObject
>;

export type RetirementRateUpdateEventFilter =
  TypedEventFilter<RetirementRateUpdateEvent>;

export interface WithdrawEventObject {
  sender: string;
  receiver: string;
  quantity: BigNumber;
}
export type WithdrawEvent = TypedEvent<
  [string, string, BigNumber],
  WithdrawEventObject
>;

export type WithdrawEventFilter = TypedEventFilter<WithdrawEvent>;

export interface WithdrawalRateUpdateEventObject {
  withdrawFeeBips: BigNumber;
  beneficiary: string;
  isSpecificRate: boolean;
}
export type WithdrawalRateUpdateEvent = TypedEvent<
  [BigNumber, string, boolean],
  WithdrawalRateUpdateEventObject
>;

export type WithdrawalRateUpdateEventFilter =
  TypedEventFilter<WithdrawalRateUpdateEvent>;

export interface IJasmineFeePool extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IJasmineFeePoolInterface;

  queryFilter<TEvent extends TypedEvent>(
    event: TypedEventFilter<TEvent>,
    fromBlockOrBlockhash?: string | number | undefined,
    toBlock?: string | number | undefined
  ): Promise<Array<TEvent>>;

  listeners<TEvent extends TypedEvent>(
    eventFilter?: TypedEventFilter<TEvent>
  ): Array<TypedListener<TEvent>>;
  listeners(eventName?: string): Array<Listener>;
  removeAllListeners<TEvent extends TypedEvent>(
    eventFilter: TypedEventFilter<TEvent>
  ): this;
  removeAllListeners(eventName?: string): this;
  off: OnEvent<this>;
  on: OnEvent<this>;
  once: OnEvent<this>;
  removeListener: OnEvent<this>;

  functions: {
    deposit(
      tokenId: PromiseOrValue<BigNumberish>,
      quantity: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    depositBatch(
      from: PromiseOrValue<string>,
      tokenIds: PromiseOrValue<BigNumberish>[],
      quantities: PromiseOrValue<BigNumberish>[],
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    depositFrom(
      from: PromiseOrValue<string>,
      tokenId: PromiseOrValue<BigNumberish>,
      quantity: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    retire(
      from: PromiseOrValue<string>,
      beneficiary: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    retireExact(
      from: PromiseOrValue<string>,
      beneficiary: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    retirementCost(
      amount: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<[BigNumber] & { cost: BigNumber }>;

    retirementRate(overrides?: CallOverrides): Promise<[BigNumber]>;

    withdraw(
      recipient: PromiseOrValue<string>,
      quantity: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    withdrawFrom(
      spender: PromiseOrValue<string>,
      recipient: PromiseOrValue<string>,
      quantity: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    withdrawSpecific(
      spender: PromiseOrValue<string>,
      recipient: PromiseOrValue<string>,
      tokenIds: PromiseOrValue<BigNumberish>[],
      quantities: PromiseOrValue<BigNumberish>[],
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    "withdrawalCost(uint256)"(
      amount: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<[BigNumber] & { cost: BigNumber }>;

    "withdrawalCost(uint256[],uint256[])"(
      tokenIds: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      overrides?: CallOverrides
    ): Promise<[BigNumber] & { cost: BigNumber }>;

    withdrawalRate(overrides?: CallOverrides): Promise<[BigNumber]>;

    withdrawalSpecificRate(overrides?: CallOverrides): Promise<[BigNumber]>;
  };

  deposit(
    tokenId: PromiseOrValue<BigNumberish>,
    quantity: PromiseOrValue<BigNumberish>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  depositBatch(
    from: PromiseOrValue<string>,
    tokenIds: PromiseOrValue<BigNumberish>[],
    quantities: PromiseOrValue<BigNumberish>[],
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  depositFrom(
    from: PromiseOrValue<string>,
    tokenId: PromiseOrValue<BigNumberish>,
    quantity: PromiseOrValue<BigNumberish>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  retire(
    from: PromiseOrValue<string>,
    beneficiary: PromiseOrValue<string>,
    amount: PromiseOrValue<BigNumberish>,
    data: PromiseOrValue<BytesLike>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  retireExact(
    from: PromiseOrValue<string>,
    beneficiary: PromiseOrValue<string>,
    amount: PromiseOrValue<BigNumberish>,
    data: PromiseOrValue<BytesLike>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  retirementCost(
    amount: PromiseOrValue<BigNumberish>,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  retirementRate(overrides?: CallOverrides): Promise<BigNumber>;

  withdraw(
    recipient: PromiseOrValue<string>,
    quantity: PromiseOrValue<BigNumberish>,
    data: PromiseOrValue<BytesLike>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  withdrawFrom(
    spender: PromiseOrValue<string>,
    recipient: PromiseOrValue<string>,
    quantity: PromiseOrValue<BigNumberish>,
    data: PromiseOrValue<BytesLike>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  withdrawSpecific(
    spender: PromiseOrValue<string>,
    recipient: PromiseOrValue<string>,
    tokenIds: PromiseOrValue<BigNumberish>[],
    quantities: PromiseOrValue<BigNumberish>[],
    data: PromiseOrValue<BytesLike>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  "withdrawalCost(uint256)"(
    amount: PromiseOrValue<BigNumberish>,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  "withdrawalCost(uint256[],uint256[])"(
    tokenIds: PromiseOrValue<BigNumberish>[],
    amounts: PromiseOrValue<BigNumberish>[],
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  withdrawalRate(overrides?: CallOverrides): Promise<BigNumber>;

  withdrawalSpecificRate(overrides?: CallOverrides): Promise<BigNumber>;

  callStatic: {
    deposit(
      tokenId: PromiseOrValue<BigNumberish>,
      quantity: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    depositBatch(
      from: PromiseOrValue<string>,
      tokenIds: PromiseOrValue<BigNumberish>[],
      quantities: PromiseOrValue<BigNumberish>[],
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    depositFrom(
      from: PromiseOrValue<string>,
      tokenId: PromiseOrValue<BigNumberish>,
      quantity: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    retire(
      from: PromiseOrValue<string>,
      beneficiary: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<void>;

    retireExact(
      from: PromiseOrValue<string>,
      beneficiary: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<void>;

    retirementCost(
      amount: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    retirementRate(overrides?: CallOverrides): Promise<BigNumber>;

    withdraw(
      recipient: PromiseOrValue<string>,
      quantity: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<
      [BigNumber[], BigNumber[]] & {
        tokenIds: BigNumber[];
        amounts: BigNumber[];
      }
    >;

    withdrawFrom(
      spender: PromiseOrValue<string>,
      recipient: PromiseOrValue<string>,
      quantity: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<
      [BigNumber[], BigNumber[]] & {
        tokenIds: BigNumber[];
        amounts: BigNumber[];
      }
    >;

    withdrawSpecific(
      spender: PromiseOrValue<string>,
      recipient: PromiseOrValue<string>,
      tokenIds: PromiseOrValue<BigNumberish>[],
      quantities: PromiseOrValue<BigNumberish>[],
      data: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<void>;

    "withdrawalCost(uint256)"(
      amount: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    "withdrawalCost(uint256[],uint256[])"(
      tokenIds: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    withdrawalRate(overrides?: CallOverrides): Promise<BigNumber>;

    withdrawalSpecificRate(overrides?: CallOverrides): Promise<BigNumber>;
  };

  filters: {
    "Deposit(address,address,uint256)"(
      operator?: PromiseOrValue<string> | null,
      owner?: PromiseOrValue<string> | null,
      quantity?: null
    ): DepositEventFilter;
    Deposit(
      operator?: PromiseOrValue<string> | null,
      owner?: PromiseOrValue<string> | null,
      quantity?: null
    ): DepositEventFilter;

    "Retirement(address,address,uint256)"(
      operator?: PromiseOrValue<string> | null,
      beneficiary?: PromiseOrValue<string> | null,
      quantity?: null
    ): RetirementEventFilter;
    Retirement(
      operator?: PromiseOrValue<string> | null,
      beneficiary?: PromiseOrValue<string> | null,
      quantity?: null
    ): RetirementEventFilter;

    "RetirementRateUpdate(uint96,address)"(
      retirementFeeBips?: null,
      beneficiary?: PromiseOrValue<string> | null
    ): RetirementRateUpdateEventFilter;
    RetirementRateUpdate(
      retirementFeeBips?: null,
      beneficiary?: PromiseOrValue<string> | null
    ): RetirementRateUpdateEventFilter;

    "Withdraw(address,address,uint256)"(
      sender?: PromiseOrValue<string> | null,
      receiver?: PromiseOrValue<string> | null,
      quantity?: null
    ): WithdrawEventFilter;
    Withdraw(
      sender?: PromiseOrValue<string> | null,
      receiver?: PromiseOrValue<string> | null,
      quantity?: null
    ): WithdrawEventFilter;

    "WithdrawalRateUpdate(uint96,address,bool)"(
      withdrawFeeBips?: null,
      beneficiary?: PromiseOrValue<string> | null,
      isSpecificRate?: null
    ): WithdrawalRateUpdateEventFilter;
    WithdrawalRateUpdate(
      withdrawFeeBips?: null,
      beneficiary?: PromiseOrValue<string> | null,
      isSpecificRate?: null
    ): WithdrawalRateUpdateEventFilter;
  };

  estimateGas: {
    deposit(
      tokenId: PromiseOrValue<BigNumberish>,
      quantity: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    depositBatch(
      from: PromiseOrValue<string>,
      tokenIds: PromiseOrValue<BigNumberish>[],
      quantities: PromiseOrValue<BigNumberish>[],
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    depositFrom(
      from: PromiseOrValue<string>,
      tokenId: PromiseOrValue<BigNumberish>,
      quantity: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    retire(
      from: PromiseOrValue<string>,
      beneficiary: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    retireExact(
      from: PromiseOrValue<string>,
      beneficiary: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    retirementCost(
      amount: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    retirementRate(overrides?: CallOverrides): Promise<BigNumber>;

    withdraw(
      recipient: PromiseOrValue<string>,
      quantity: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    withdrawFrom(
      spender: PromiseOrValue<string>,
      recipient: PromiseOrValue<string>,
      quantity: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    withdrawSpecific(
      spender: PromiseOrValue<string>,
      recipient: PromiseOrValue<string>,
      tokenIds: PromiseOrValue<BigNumberish>[],
      quantities: PromiseOrValue<BigNumberish>[],
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    "withdrawalCost(uint256)"(
      amount: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    "withdrawalCost(uint256[],uint256[])"(
      tokenIds: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    withdrawalRate(overrides?: CallOverrides): Promise<BigNumber>;

    withdrawalSpecificRate(overrides?: CallOverrides): Promise<BigNumber>;
  };

  populateTransaction: {
    deposit(
      tokenId: PromiseOrValue<BigNumberish>,
      quantity: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    depositBatch(
      from: PromiseOrValue<string>,
      tokenIds: PromiseOrValue<BigNumberish>[],
      quantities: PromiseOrValue<BigNumberish>[],
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    depositFrom(
      from: PromiseOrValue<string>,
      tokenId: PromiseOrValue<BigNumberish>,
      quantity: PromiseOrValue<BigNumberish>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    retire(
      from: PromiseOrValue<string>,
      beneficiary: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    retireExact(
      from: PromiseOrValue<string>,
      beneficiary: PromiseOrValue<string>,
      amount: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    retirementCost(
      amount: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    retirementRate(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    withdraw(
      recipient: PromiseOrValue<string>,
      quantity: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    withdrawFrom(
      spender: PromiseOrValue<string>,
      recipient: PromiseOrValue<string>,
      quantity: PromiseOrValue<BigNumberish>,
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    withdrawSpecific(
      spender: PromiseOrValue<string>,
      recipient: PromiseOrValue<string>,
      tokenIds: PromiseOrValue<BigNumberish>[],
      quantities: PromiseOrValue<BigNumberish>[],
      data: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    "withdrawalCost(uint256)"(
      amount: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    "withdrawalCost(uint256[],uint256[])"(
      tokenIds: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    withdrawalRate(overrides?: CallOverrides): Promise<PopulatedTransaction>;

    withdrawalSpecificRate(
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}
