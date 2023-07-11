# IJasminePoolFactory

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Pool Factory Interface

The Jasmine Pool Factory is responsible for creating and managing Jasmine         liquidity pool implementations and deployments.



## Methods

### eligiblePoolsForToken

```solidity
function eligiblePoolsForToken(uint256 tokenId) external view returns (address[] pools)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| pools | address[] | undefined |

### getPoolAtIndex

```solidity
function getPoolAtIndex(uint256 index) external view returns (address pool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| index | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| pool | address | undefined |

### totalPools

```solidity
function totalPools() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |



## Events

### PoolCreated

```solidity
event PoolCreated(bytes policy, address indexed pool, string indexed name, string indexed symbol)
```

Emitted when a new Jasmine pool is created 



#### Parameters

| Name | Type | Description |
|---|---|---|
| policy  | bytes | Pool&#39;s deposit policy in bytes |
| pool `indexed` | address | Address of newly created pool |
| name `indexed` | string | Name of the pool |
| symbol `indexed` | string | Token symbol of the pool |

### PoolImplementationAdded

```solidity
event PoolImplementationAdded(address indexed poolImplementation, address indexed beaconAddress, uint256 indexed poolIndex)
```

Emitted when new pool implementations are supported by factory 



#### Parameters

| Name | Type | Description |
|---|---|---|
| poolImplementation `indexed` | address | Address of newly supported pool implementation |
| beaconAddress `indexed` | address | Address of Beacon smart contract |
| poolIndex `indexed` | uint256 | Index of new pool in set of pool implementations |

### PoolImplementationRemoved

```solidity
event PoolImplementationRemoved(address indexed beaconAddress, uint256 indexed poolIndex)
```

Emitted when a pool implementations is removed 



#### Parameters

| Name | Type | Description |
|---|---|---|
| beaconAddress `indexed` | address | Address of Beacon smart contract |
| poolIndex `indexed` | uint256 | Index of deleted pool in set of pool implementations |

### PoolImplementationUpgraded

```solidity
event PoolImplementationUpgraded(address indexed newPoolImplementation, address indexed beaconAddress, uint256 indexed poolIndex)
```

Emitted when a pool&#39;s beacon implementation updates 



#### Parameters

| Name | Type | Description |
|---|---|---|
| newPoolImplementation `indexed` | address | Address of new pool implementation |
| beaconAddress `indexed` | address | Address of Beacon smart contract |
| poolIndex `indexed` | uint256 | Index of new pool in set of pool implementations |



