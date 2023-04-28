
// NOTE: This is uint32 max reserved value defined in PoolPolicy.sol
const AnyField = 4_294_967_295;

// NOTE: Access control bytes32 values
const DEFAULT_ADMIN_ROLE = "0x0000000000000000000000000000000000000000000000000000000000000000";
const FEE_MANAGER_ROLE = "0x6c0757dc3e6b28b2580c03fd9e96c274acf4f99d91fbec9b418fa1d70604ff1c";

const DEFAULT_DECIMAL_MULTIPLE = 10n ** 18n;

// TODO: Swap to using env vars. Fine for now
const TENDERLY_FORK_API = `http://api.tenderly.co/api/v1/account/Jasmine/project/reference-pools/fork`;
const TENDERLY_FORK_DASHBOARD = "https://dashboard.tenderly.co/Jasmine/reference-pools/fork"

const TENDERLY_API_BASE_URL = "https://api.tenderly.co/api/v1";

enum TenderlyEndpoints {
    fork = "fork",
}

const Tenderly = {
    apiBaseUrl: "https://api.tenderly.co/api/v1",
    projectUrl: "account/Jasmine/project/reference-pools",

    endpoints: (endpoint: TenderlyEndpoints) => {
        return `${Tenderly.projectUrl}/${endpoint}`;
    },

    forksDashboard: "https://dashboard.tenderly.co/Jasmine/reference-pools/fork"
}

const Contracts = {
    // Pool Contracts
    pool: 'JasminePool',
    factory: 'JasminePoolFactory',

    // Core Contracts
    eat: 'JasmineEAT',
    oracle: 'JasmineOracle',
    minter: 'JasmineMinter',

    uniswap: {
        factory: 'IUniswapV3Factory',
        pool: 'IUniswapV3Pool',
    },
};

const Libraries = {
    poolPolicy: 'PoolPolicy',
    calldata: 'Calldata',
    arrayUtils: 'ArrayUtils'
};

export {
    AnyField,
    DEFAULT_ADMIN_ROLE, FEE_MANAGER_ROLE,
    DEFAULT_DECIMAL_MULTIPLE,
    Tenderly, TenderlyEndpoints, TENDERLY_API_BASE_URL, TENDERLY_FORK_API, TENDERLY_FORK_DASHBOARD,
    Contracts, Libraries
};
