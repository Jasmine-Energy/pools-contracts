# JasmineOracle





This contract stores the machine-readable metadata about each EAT series. This is used to determine whether a particular EAT is eligible for certain on-chain uses (e.g. membership in a solar-only EAT pool).

*This contract is upgradeable. You can only append new contracts to the list of bases. You cannot delete bases or reorder them.*

## Methods

### acceptOwnership

```solidity
function acceptOwnership() external nonpayable
```



*The new owner accepts the ownership transfer.*


### getUUID

```solidity
function getUUID(uint256 id) external pure returns (uint128)
```

Each EAT series has a UUID associated with it. This has no structure, but serves to identify the series to an off-chain database.



#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint128 | undefined |

### hasCertificateType

```solidity
function hasCertificateType(uint256 id, uint256 query) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |
| query | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### hasEndorsement

```solidity
function hasEndorsement(uint256 id, uint256 query) external view returns (bool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |
| query | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### hasFuel

```solidity
function hasFuel(uint256 id, uint256 query) external view returns (bool)
```

The fuel type of an EAT identifies the source of the energy used to generate the corresponding electrical power. This is an opaque value that can only be checked for an exact match. Future EATs may have more than 1 fuel type.



#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |
| query | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### hasRegistry

```solidity
function hasRegistry(uint256 id, uint256 query) external pure returns (bool)
```

Each EAT is traded on an EAT registry. EATs cannot generally be moved between registries. The registry id is opaque, but can be checked for an exact match.



#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |
| query | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### hasVintage

```solidity
function hasVintage(uint256 id, uint256 min, uint256 max) external pure returns (bool)
```

The vintage of an EAT identifies the time at which it was generated. The vintage is represented as a UNIX timestamp. The granularity of an EAT&#39;s vintage depends on the conventions of its registry and generator.



#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |
| min | uint256 | undefined |
| max | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### initialize

```solidity
function initialize(address initialMinter, address initialOwner) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| initialMinter | address | undefined |
| initialOwner | address | undefined |

### minter

```solidity
function minter() external view returns (address)
```

This address is the mint authorization checker. The minter is controlled by the bridge.




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

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

### proxiableUUID

```solidity
function proxiableUUID() external view returns (bytes32)
```



*Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation&#39;s compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions anymore. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby removing any functionality that is only available to the owner.*


### setMinter

```solidity
function setMinter(address newMinter) external nonpayable
```

In the event of a minter migration (not just an upgrade), the owner has the ability to set the minter address.



#### Parameters

| Name | Type | Description |
|---|---|---|
| newMinter | address | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one. Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### updateSeries

```solidity
function updateSeries(uint256 id, bytes encodedMetadata) external nonpayable
```

The encodedMetadata is structured as the ABI encoding the metadata fields



#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |
| encodedMetadata | bytes | undefined |

### upgradeTo

```solidity
function upgradeTo(address newImplementation) external nonpayable
```



*Upgrade the implementation of the proxy to `newImplementation`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newImplementation | address | undefined |

### upgradeToAndCall

```solidity
function upgradeToAndCall(address newImplementation, bytes data) external payable
```



*Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newImplementation | address | undefined |
| data | bytes | undefined |



## Events

### AdminChanged

```solidity
event AdminChanged(address previousAdmin, address newAdmin)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousAdmin  | address | undefined |
| newAdmin  | address | undefined |

### BeaconUpgraded

```solidity
event BeaconUpgraded(address indexed beacon)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| beacon `indexed` | address | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### MinterChanged

```solidity
event MinterChanged(address indexed newMinter)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newMinter `indexed` | address | undefined |

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

### Upgraded

```solidity
event Upgraded(address indexed implementation)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| implementation `indexed` | address | undefined |



