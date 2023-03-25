# IJasminePoolFactory

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Pool Factory Interface





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



