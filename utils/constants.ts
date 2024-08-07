// NOTE: This is uint32 max reserved value defined in PoolPolicy.sol
const AnyField = 4_294_967_295;

// NOTE: Access control bytes32 values
const DEFAULT_ADMIN_ROLE =
  "0x0000000000000000000000000000000000000000000000000000000000000000";
const POOL_MANAGER_ROLE =
  "0x6077685936c8169d09204a1d97db12e41713588c38e1d29a61867d3dcee98aff";
const FEE_MANAGER_ROLE =
  "0x6c0757dc3e6b28b2580c03fd9e96c274acf4f99d91fbec9b418fa1d70604ff1c";

const DEFAULT_DECIMAL_V1 = 18n;
const DEFAULT_DECIMAL = 6n;
const DEFAULT_DECIMAL_MULTIPLE = 10n ** DEFAULT_DECIMAL;

const DepositPolicy = {
  types: ["uint256[2]", "uint256", "uint256", "uint256", "uint256"],
};

const Contracts = {
  // Pool Contracts
  pool: "JasminePool",
  factory: "JasminePoolFactory",
  retirementService: "JasmineRetirementService",

  // Core Contracts
  eat: "JasmineEAT",
  oracle: "JasmineOracle",
  minter: "JasmineMinter",

  uniswap: {
    factory: "IUniswapV3Factory",
    pool: "IUniswapV3Pool",
  },
};

export {
  AnyField,
  DEFAULT_ADMIN_ROLE,
  POOL_MANAGER_ROLE,
  FEE_MANAGER_ROLE,
  DEFAULT_DECIMAL,
  DEFAULT_DECIMAL_MULTIPLE,
  DEFAULT_DECIMAL_V1,
  DepositPolicy,
  Contracts,
};
