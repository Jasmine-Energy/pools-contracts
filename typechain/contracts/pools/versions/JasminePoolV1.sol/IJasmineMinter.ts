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

export interface IJasmineMinterInterface extends utils.Interface {
  functions: {
    "burn(uint256,uint256,bytes)": FunctionFragment;
    "burnBatch(uint256[],uint256[],bytes)": FunctionFragment;
    "mint(address,uint256,uint256,bytes,bytes,uint256,bytes32,bytes)": FunctionFragment;
    "mintBatch(address,uint256[],uint256[],bytes,bytes[],uint256,bytes32,bytes)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic: "burn" | "burnBatch" | "mint" | "mintBatch"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "burn",
    values: [
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "burnBatch",
    values: [
      PromiseOrValue<BigNumberish>[],
      PromiseOrValue<BigNumberish>[],
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "mint",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BytesLike>,
      PromiseOrValue<BytesLike>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BytesLike>,
      PromiseOrValue<BytesLike>
    ]
  ): string;
  encodeFunctionData(
    functionFragment: "mintBatch",
    values: [
      PromiseOrValue<string>,
      PromiseOrValue<BigNumberish>[],
      PromiseOrValue<BigNumberish>[],
      PromiseOrValue<BytesLike>,
      PromiseOrValue<BytesLike>[],
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BytesLike>,
      PromiseOrValue<BytesLike>
    ]
  ): string;

  decodeFunctionResult(functionFragment: "burn", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "burnBatch", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "mint", data: BytesLike): Result;
  decodeFunctionResult(functionFragment: "mintBatch", data: BytesLike): Result;

  events: {
    "BurnedBatch(address,uint256[],uint256[],bytes)": EventFragment;
    "BurnedSingle(address,uint256,uint256,bytes)": EventFragment;
  };

  getEvent(nameOrSignatureOrTopic: "BurnedBatch"): EventFragment;
  getEvent(nameOrSignatureOrTopic: "BurnedSingle"): EventFragment;
}

export interface BurnedBatchEventObject {
  owner: string;
  ids: BigNumber[];
  amounts: BigNumber[];
  metadata: string;
}
export type BurnedBatchEvent = TypedEvent<
  [string, BigNumber[], BigNumber[], string],
  BurnedBatchEventObject
>;

export type BurnedBatchEventFilter = TypedEventFilter<BurnedBatchEvent>;

export interface BurnedSingleEventObject {
  owner: string;
  id: BigNumber;
  amount: BigNumber;
  metadata: string;
}
export type BurnedSingleEvent = TypedEvent<
  [string, BigNumber, BigNumber, string],
  BurnedSingleEventObject
>;

export type BurnedSingleEventFilter = TypedEventFilter<BurnedSingleEvent>;

export interface IJasmineMinter extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IJasmineMinterInterface;

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
    burn(
      id: PromiseOrValue<BigNumberish>,
      amount: PromiseOrValue<BigNumberish>,
      metadata: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    burnBatch(
      ids: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      metadata: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    mint(
      receiver: PromiseOrValue<string>,
      id: PromiseOrValue<BigNumberish>,
      amount: PromiseOrValue<BigNumberish>,
      transferData: PromiseOrValue<BytesLike>,
      oracleData: PromiseOrValue<BytesLike>,
      deadline: PromiseOrValue<BigNumberish>,
      nonce: PromiseOrValue<BytesLike>,
      sig: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;

    mintBatch(
      receiver: PromiseOrValue<string>,
      ids: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      transferData: PromiseOrValue<BytesLike>,
      oracleDatas: PromiseOrValue<BytesLike>[],
      deadline: PromiseOrValue<BigNumberish>,
      nonce: PromiseOrValue<BytesLike>,
      sig: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<ContractTransaction>;
  };

  burn(
    id: PromiseOrValue<BigNumberish>,
    amount: PromiseOrValue<BigNumberish>,
    metadata: PromiseOrValue<BytesLike>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  burnBatch(
    ids: PromiseOrValue<BigNumberish>[],
    amounts: PromiseOrValue<BigNumberish>[],
    metadata: PromiseOrValue<BytesLike>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  mint(
    receiver: PromiseOrValue<string>,
    id: PromiseOrValue<BigNumberish>,
    amount: PromiseOrValue<BigNumberish>,
    transferData: PromiseOrValue<BytesLike>,
    oracleData: PromiseOrValue<BytesLike>,
    deadline: PromiseOrValue<BigNumberish>,
    nonce: PromiseOrValue<BytesLike>,
    sig: PromiseOrValue<BytesLike>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  mintBatch(
    receiver: PromiseOrValue<string>,
    ids: PromiseOrValue<BigNumberish>[],
    amounts: PromiseOrValue<BigNumberish>[],
    transferData: PromiseOrValue<BytesLike>,
    oracleDatas: PromiseOrValue<BytesLike>[],
    deadline: PromiseOrValue<BigNumberish>,
    nonce: PromiseOrValue<BytesLike>,
    sig: PromiseOrValue<BytesLike>,
    overrides?: Overrides & { from?: PromiseOrValue<string> }
  ): Promise<ContractTransaction>;

  callStatic: {
    burn(
      id: PromiseOrValue<BigNumberish>,
      amount: PromiseOrValue<BigNumberish>,
      metadata: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<void>;

    burnBatch(
      ids: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      metadata: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<void>;

    mint(
      receiver: PromiseOrValue<string>,
      id: PromiseOrValue<BigNumberish>,
      amount: PromiseOrValue<BigNumberish>,
      transferData: PromiseOrValue<BytesLike>,
      oracleData: PromiseOrValue<BytesLike>,
      deadline: PromiseOrValue<BigNumberish>,
      nonce: PromiseOrValue<BytesLike>,
      sig: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<void>;

    mintBatch(
      receiver: PromiseOrValue<string>,
      ids: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      transferData: PromiseOrValue<BytesLike>,
      oracleDatas: PromiseOrValue<BytesLike>[],
      deadline: PromiseOrValue<BigNumberish>,
      nonce: PromiseOrValue<BytesLike>,
      sig: PromiseOrValue<BytesLike>,
      overrides?: CallOverrides
    ): Promise<void>;
  };

  filters: {
    "BurnedBatch(address,uint256[],uint256[],bytes)"(
      owner?: PromiseOrValue<string> | null,
      ids?: null,
      amounts?: null,
      metadata?: null
    ): BurnedBatchEventFilter;
    BurnedBatch(
      owner?: PromiseOrValue<string> | null,
      ids?: null,
      amounts?: null,
      metadata?: null
    ): BurnedBatchEventFilter;

    "BurnedSingle(address,uint256,uint256,bytes)"(
      owner?: PromiseOrValue<string> | null,
      id?: null,
      amount?: null,
      metadata?: null
    ): BurnedSingleEventFilter;
    BurnedSingle(
      owner?: PromiseOrValue<string> | null,
      id?: null,
      amount?: null,
      metadata?: null
    ): BurnedSingleEventFilter;
  };

  estimateGas: {
    burn(
      id: PromiseOrValue<BigNumberish>,
      amount: PromiseOrValue<BigNumberish>,
      metadata: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    burnBatch(
      ids: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      metadata: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    mint(
      receiver: PromiseOrValue<string>,
      id: PromiseOrValue<BigNumberish>,
      amount: PromiseOrValue<BigNumberish>,
      transferData: PromiseOrValue<BytesLike>,
      oracleData: PromiseOrValue<BytesLike>,
      deadline: PromiseOrValue<BigNumberish>,
      nonce: PromiseOrValue<BytesLike>,
      sig: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;

    mintBatch(
      receiver: PromiseOrValue<string>,
      ids: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      transferData: PromiseOrValue<BytesLike>,
      oracleDatas: PromiseOrValue<BytesLike>[],
      deadline: PromiseOrValue<BigNumberish>,
      nonce: PromiseOrValue<BytesLike>,
      sig: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    burn(
      id: PromiseOrValue<BigNumberish>,
      amount: PromiseOrValue<BigNumberish>,
      metadata: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    burnBatch(
      ids: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      metadata: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    mint(
      receiver: PromiseOrValue<string>,
      id: PromiseOrValue<BigNumberish>,
      amount: PromiseOrValue<BigNumberish>,
      transferData: PromiseOrValue<BytesLike>,
      oracleData: PromiseOrValue<BytesLike>,
      deadline: PromiseOrValue<BigNumberish>,
      nonce: PromiseOrValue<BytesLike>,
      sig: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;

    mintBatch(
      receiver: PromiseOrValue<string>,
      ids: PromiseOrValue<BigNumberish>[],
      amounts: PromiseOrValue<BigNumberish>[],
      transferData: PromiseOrValue<BytesLike>,
      oracleDatas: PromiseOrValue<BytesLike>[],
      deadline: PromiseOrValue<BigNumberish>,
      nonce: PromiseOrValue<BytesLike>,
      sig: PromiseOrValue<BytesLike>,
      overrides?: Overrides & { from?: PromiseOrValue<string> }
    ): Promise<PopulatedTransaction>;
  };
}
