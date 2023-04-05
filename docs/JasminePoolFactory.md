# JasminePoolFactory

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Pool Factory





## Methods

### acceptOwnership

```solidity
function acceptOwnership() external nonpayable
```



*The new owner accepts the ownership transfer.*


### addPoolImplementation

```solidity
function addPoolImplementation(address newPoolImplementation) external nonpayable returns (uint256 indexInPools)
```



*Used to add a new pool implementation *

#### Parameters

| Name | Type | Description |
|---|---|---|
| newPoolImplementation | address | New pool implementation address to support |

#### Returns

| Name | Type | Description |
|---|---|---|
| indexInPools | uint256 | undefined |

### computePoolAddress

```solidity
function computePoolAddress(bytes32 policyHash) external view returns (address poolAddress)
```

Utility function to calculate deployed address of a pool from its         policy hash 

*Requirements:     - Policy hash must exist in existing pools *

#### Parameters

| Name | Type | Description |
|---|---|---|
| policyHash | bytes32 | Policy hash of pool to compute address of |

#### Returns

| Name | Type | Description |
|---|---|---|
| poolAddress | address | Address of deployed pool |

### deployNewBasePool

```solidity
function deployNewBasePool(PoolPolicy.DepositPolicy policy, string name, string symbol) external nonpayable returns (address newPool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| policy | PoolPolicy.DepositPolicy | undefined |
| name | string | undefined |
| symbol | string | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| newPool | address | undefined |

### deployNewPool

```solidity
function deployNewPool(uint256 version, bytes4 initSelector, bytes initData, string name, string symbol) external nonpayable returns (address newPool)
```

Deploys a new pool from list of pool implementations 

*initData must omit method selector, name and symbol. These arguments      are encoded automatically as:    ┌──────────┬──────────┬─────────┬─────────┐   │ selector │ initData │ name    │ symbol  │   │ (bytes4) │ (bytes)  │ (bytes) │ (bytes) │   └──────────┴──────────┴─────────┴─────────┘ Requirements:     - Caller must be owner     - Policy must not exist     - Version must be valid pool implementation index Throws PoolExists(address pool) on failure *

#### Parameters

| Name | Type | Description |
|---|---|---|
| version | uint256 | Index of pool implementation to deploy |
| initSelector | bytes4 | Method selector of initializer |
| initData | bytes | Initializer data (excluding method selector, name and symbol) |
| name | string | New pool&#39;s token name |
| symbol | string | New pool&#39;s token symbol  |

#### Returns

| Name | Type | Description |
|---|---|---|
| newPool | address | address of newly created pool |

### eligiblePoolsForToken

```solidity
function eligiblePoolsForToken(uint256) external pure returns (address[])
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address[] | undefined |

### getPoolAtIndex

```solidity
function getPoolAtIndex(uint256 index) external view returns (address pool)
```

Used to obtain the address of a pool in the set of pools - if it exists 

*Throw NoPool() on failure *

#### Parameters

| Name | Type | Description |
|---|---|---|
| index | uint256 | Index of the deployed pool in set of pools |

#### Returns

| Name | Type | Description |
|---|---|---|
| pool | address | Address of pool in set |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### pendingOwner

```solidity
function pendingOwner() external view returns (address)
```



*Returns the address of the pending owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### removePoolImplementation

```solidity
function removePoolImplementation(uint256) external view
```



*Used to remove a pool implementation  param poolIndex Index of pool to remove TODO: Would be nice to have an overloaded version that takes address of pool to remove NOTE: This will break CREATE2 address predictions. Think of means around this*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### totalPools

```solidity
function totalPools() external view returns (uint256)
```

Returns the total number of pools deployed




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one. Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### updateImplementationAddress

```solidity
function updateImplementationAddress(address, uint256 poolIndex) external view
```



*Allows owner to update a pool implementation  param newPoolImplementation New address to replace*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| poolIndex | uint256 | Index of pool to replace TODO: Would be nice to have an overloaded version that takes address of pool to update |



## Events

### OwnershipTransferStarted

```solidity
event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### PoolCreated

```solidity
event PoolCreated(bytes policy, address indexed pool, string indexed name, string indexed symbol)
```

Emitted when a new Jasmine pool is created 



#### Parameters

| Name | Type | Description |
|---|---|---|
| policy  | bytes | undefined |
| pool `indexed` | address | undefined |
| name `indexed` | string | undefined |
| symbol `indexed` | string | undefined |

### PoolImplementationAdded

```solidity
event PoolImplementationAdded(address indexed poolImplementation, uint256 indexed poolIndex)
```

Emitted when new pool implementations are supported by factory 



#### Parameters

| Name | Type | Description |
|---|---|---|
| poolImplementation `indexed` | address | undefined |
| poolIndex `indexed` | uint256 | undefined |

### PoolImplementationRemoved

```solidity
event PoolImplementationRemoved(address indexed poolImplementation, uint256 indexed poolIndex)
```

Emitted when a pool implementations is removed 



#### Parameters

| Name | Type | Description |
|---|---|---|
| poolImplementation `indexed` | address | undefined |
| poolIndex `indexed` | uint256 | undefined |



## Errors

### InvalidConformance

```solidity
error InvalidConformance(bytes4 interfaceId)
```



*Emitted for failed supportsInterface check - per ERC-165*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

### NoPool

```solidity
error NoPool()
```



*Emitted if no pool(s) meet query*


### PoolExists

```solidity
error PoolExists(address pool)
```



*Emitted if a pool exists with given policy*

#### Parameters

| Name | Type | Description |
|---|---|---|
| pool | address | undefined |


