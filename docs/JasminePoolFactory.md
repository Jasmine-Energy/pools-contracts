# JasminePoolFactory

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Pool Factory





## Methods

### acceptOwnership

```solidity
function acceptOwnership() external nonpayable
```



*The new owner accepts the ownership transfer.*


### deployNewPool

```solidity
function deployNewPool(PoolPolicy.DepositPolicy policy, string name, string symbol) external nonpayable returns (address newPool)
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

### poolImplementation

```solidity
function poolImplementation() external view returns (address)
```



*Implementation address for pools*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### totalPools

```solidity
function totalPools() external view returns (uint256)
```






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
function updateImplementationAddress(address newPoolImplementation) external nonpayable
```



*Allows owner to update the address pool proxies point to. *

#### Parameters

| Name | Type | Description |
|---|---|---|
| newPoolImplementation | address | Address new pool proxies will point to |



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



## Errors

### PoolExists

```solidity
error PoolExists()
```







