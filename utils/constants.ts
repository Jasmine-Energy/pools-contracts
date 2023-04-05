
// NOTE This is uint32 max reserved value defined in PoolPolicy.sol
const AnyField = 4_294_967_295;

const Contracts = {
    // Pool Contracts
    pool: 'JasminePool',
    factory: 'JasminePoolFactory',

    // Core Contracts
    eat: 'JasmineEAT',
    oracle: 'JasmineOracle',
    minter: 'JasmineMinter',
};

const Libraries = {
    poolPolicy: 'PoolPolicy',
    calldata: 'Calldata',
    arrayUtils: 'ArrayUtils'
};

export {
    AnyField,
    Contracts, Libraries
};
