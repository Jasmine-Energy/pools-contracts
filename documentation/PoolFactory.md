# Jasmine Pool Factory
**Responsibilities:**
1. Manage pool implementations
2. Deploy new reference pools
3. Controls protocol wide fees and fee manager role

**Conformances:**
1. Ownable 2 step (ownership transfers require acceptance)
2. Access control (not enumerable)

## 1. Pool Implementation Management

**Overview:** The pool factory allows the `owner` to add, update and remove new pool implementations from which individual pools are deployed via beacon proxies.

### Relevant Fields:
```solidity
EnumerableSet.AddressSet internal _poolBeacons;
```

### Methods:
#### 1. `addPoolImplementation(address newPoolImplementation)`

**It:**
1. Enforces caller is `owner` and checks the given address is eligible (via `_validatePoolImplementation` which checks the address is not `0x0`, supports `IJasminePool` and `IERC1155Receiver` interface [via ERC-165], and that it does not yet exist in list of implementations)
2. Deploys an `UpgradeableBeacon` - deterministically via CREATE2, salted with the index of the new implementation in `_poolBeacons`
3. Checks deployment of new beacon was successful, adds to list of implementation beacons and emits a `PoolImplementationAdded` event


#### 2. `updateImplementationAddress(address newPoolImplementation, uint256 poolIndex)`

**It:**
1. Enforces caller is `owner` and validates new pool implementation - via `_validatePoolImplementation`
2. Gets beacon at given index and calls `upgradeTo` with new address
3. Emits a `PoolImplementationUpgraded` event

#### 3. `removePoolImplementation(uint256 poolIndex)`

**It:** is unimplemented. Why? Questions around intended functionality.

It *could* prevent new pool deployments from the removed implementation but allow upgrade to the implementation. 

## 2. Deploy New Reference Pools

### Relevant Fields:
```solidity
EnumerableSet.Bytes32Set internal _pools;
```
Stores deposit policy hashes (which can be derived into a pool's address via `computePoolAddress`)

```solidity
mapping(bytes32 => uint256) internal _poolVersions;
```
Maps deposit policy hashes to the Beacon Implementation index it was deployed from

### Methods:
#### 1. `deployNewBasePool(PoolPolicy.DepositPolicy calldata policy, string calldata name, string calldata symbol)`

**It:**
1. Enforces caller is `owner`
2. Encodes data and calls general purpose `deployNewPool` function

#### 2. `deployNewPool(uint256 version, bytes4  initSelector, bytes memory initData, string calldata name, string calldata symbol)`

**It:**
1. Enforces caller is `owner`
2. Checks no pool has been deployed with its given `initData` (aka its policy hash)
3. Deploys a new `BeaconProxy` via CREATE2 which is salted from its policy hash
4. Initializes new pool, adds to list of deployed pools, and emits a `PoolCreated` event
5. Deploys a UniSwapV3 pool between the new JLT and USDC at the **0.3% fee tier** (with initial price of 5USDC/JLT)

#### 3. Getter Functions

1. `totalPools()`
2. `getPoolAtIndex(uint256 index)`
3. `eligiblePoolsForToken(uint256 tokenId)`

## 3. Manage Fees

**Overview:** Pool fees are managed by the `FEE_MANAGER_ROLE` which can set fees for withdraws (both any and specific), retirements and designate a `feeBeneficiary`. The pool factory may set a protocol wide default value for each of the three tiers which may be overriden per pool. Access control is shared between the Pool Factory and all deployed pools. 
