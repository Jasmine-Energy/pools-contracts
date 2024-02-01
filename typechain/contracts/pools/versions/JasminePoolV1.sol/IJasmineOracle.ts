/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import type {
  BaseContract,
  BigNumber,
  BigNumberish,
  BytesLike,
  CallOverrides,
  PopulatedTransaction,
  Signer,
  utils,
} from "ethers";
import type { FunctionFragment, Result } from "@ethersproject/abi";
import type { Listener, Provider } from "@ethersproject/providers";
import type {
  TypedEventFilter,
  TypedEvent,
  TypedListener,
  OnEvent,
  PromiseOrValue,
} from "../../../../common";

export interface IJasmineOracleInterface extends utils.Interface {
  functions: {
    "getUUID(uint256)": FunctionFragment;
    "hasCertificateType(uint256,uint256)": FunctionFragment;
    "hasEndorsement(uint256,uint256)": FunctionFragment;
    "hasFuel(uint256,uint256)": FunctionFragment;
    "hasRegistry(uint256,uint256)": FunctionFragment;
    "hasVintage(uint256,uint256,uint256)": FunctionFragment;
  };

  getFunction(
    nameOrSignatureOrTopic:
      | "getUUID"
      | "hasCertificateType"
      | "hasEndorsement"
      | "hasFuel"
      | "hasRegistry"
      | "hasVintage"
  ): FunctionFragment;

  encodeFunctionData(
    functionFragment: "getUUID",
    values: [PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "hasCertificateType",
    values: [PromiseOrValue<BigNumberish>, PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "hasEndorsement",
    values: [PromiseOrValue<BigNumberish>, PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "hasFuel",
    values: [PromiseOrValue<BigNumberish>, PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "hasRegistry",
    values: [PromiseOrValue<BigNumberish>, PromiseOrValue<BigNumberish>]
  ): string;
  encodeFunctionData(
    functionFragment: "hasVintage",
    values: [
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>,
      PromiseOrValue<BigNumberish>
    ]
  ): string;

  decodeFunctionResult(functionFragment: "getUUID", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "hasCertificateType",
    data: BytesLike
  ): Result;
  decodeFunctionResult(
    functionFragment: "hasEndorsement",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "hasFuel", data: BytesLike): Result;
  decodeFunctionResult(
    functionFragment: "hasRegistry",
    data: BytesLike
  ): Result;
  decodeFunctionResult(functionFragment: "hasVintage", data: BytesLike): Result;

  events: {};
}

export interface IJasmineOracle extends BaseContract {
  connect(signerOrProvider: Signer | Provider | string): this;
  attach(addressOrName: string): this;
  deployed(): Promise<this>;

  interface: IJasmineOracleInterface;

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
    getUUID(
      id: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<[BigNumber]>;

    hasCertificateType(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    hasEndorsement(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    hasFuel(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    hasRegistry(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<[boolean]>;

    hasVintage(
      id: PromiseOrValue<BigNumberish>,
      min: PromiseOrValue<BigNumberish>,
      max: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<[boolean]>;
  };

  getUUID(
    id: PromiseOrValue<BigNumberish>,
    overrides?: CallOverrides
  ): Promise<BigNumber>;

  hasCertificateType(
    id: PromiseOrValue<BigNumberish>,
    query: PromiseOrValue<BigNumberish>,
    overrides?: CallOverrides
  ): Promise<boolean>;

  hasEndorsement(
    id: PromiseOrValue<BigNumberish>,
    query: PromiseOrValue<BigNumberish>,
    overrides?: CallOverrides
  ): Promise<boolean>;

  hasFuel(
    id: PromiseOrValue<BigNumberish>,
    query: PromiseOrValue<BigNumberish>,
    overrides?: CallOverrides
  ): Promise<boolean>;

  hasRegistry(
    id: PromiseOrValue<BigNumberish>,
    query: PromiseOrValue<BigNumberish>,
    overrides?: CallOverrides
  ): Promise<boolean>;

  hasVintage(
    id: PromiseOrValue<BigNumberish>,
    min: PromiseOrValue<BigNumberish>,
    max: PromiseOrValue<BigNumberish>,
    overrides?: CallOverrides
  ): Promise<boolean>;

  callStatic: {
    getUUID(
      id: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    hasCertificateType(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<boolean>;

    hasEndorsement(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<boolean>;

    hasFuel(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<boolean>;

    hasRegistry(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<boolean>;

    hasVintage(
      id: PromiseOrValue<BigNumberish>,
      min: PromiseOrValue<BigNumberish>,
      max: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<boolean>;
  };

  filters: {};

  estimateGas: {
    getUUID(
      id: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    hasCertificateType(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    hasEndorsement(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    hasFuel(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    hasRegistry(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;

    hasVintage(
      id: PromiseOrValue<BigNumberish>,
      min: PromiseOrValue<BigNumberish>,
      max: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<BigNumber>;
  };

  populateTransaction: {
    getUUID(
      id: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    hasCertificateType(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    hasEndorsement(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    hasFuel(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    hasRegistry(
      id: PromiseOrValue<BigNumberish>,
      query: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;

    hasVintage(
      id: PromiseOrValue<BigNumberish>,
      min: PromiseOrValue<BigNumberish>,
      max: PromiseOrValue<BigNumberish>,
      overrides?: CallOverrides
    ): Promise<PopulatedTransaction>;
  };
}
