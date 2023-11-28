# JasmineRetirementService

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Retirement Service

Facilitates retirements of EATs and JLTs in the Jasmine protocol



## Methods

### ERC1820_REGISTRY

```solidity
function ERC1820_REGISTRY() external view returns (contract IERC1820Registry)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IERC1820Registry | undefined |

### acceptOwnership

```solidity
function acceptOwnership() external nonpayable
```



*The new owner accepts the ownership transfer.*


### eat

```solidity
function eat() external view returns (contract IJasmineEAT)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IJasmineEAT | undefined |

### initialize

```solidity
function initialize(address _owner) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _owner | address | undefined |

### minter

```solidity
function minter() external view returns (contract IJasmineMinter)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IJasmineMinter | undefined |

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address, address from, uint256[] tokenIds, uint256[] amounts, bytes data) external nonpayable returns (bytes4)
```



*inheritdoc ERC1155Receiver*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| from | address | undefined |
| tokenIds | uint256[] | undefined |
| amounts | uint256[] | undefined |
| data | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

### onERC1155Received

```solidity
function onERC1155Received(address, address from, uint256 tokenId, uint256 amount, bytes data) external nonpayable returns (bytes4)
```



*inheritdoc ERC1155Receiver*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| from | address | undefined |
| tokenId | uint256 | undefined |
| amount | uint256 | undefined |
| data | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

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

### registerRetirementRecipient

```solidity
function registerRetirementRecipient(address account, address implementer) external nonpayable
```

Registers a smart contract to receive notifications on retirement events

*Requirements:      - Retirement service must be an approved ERC-1820 manager of account      - Implementer must support IRetirementRecipient interface via ERC-165*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | Address to register retirement recipient for |
| implementer | address | Smart contract address to register as retirement implementer |

### renounceOwnership

```solidity
function renounceOwnership() external nonpayable
```



*Leaves the contract without owner. It will not be possible to call `onlyOwner` functions. Can only be called by the current owner. NOTE: Renouncing ownership will leave the contract without an owner, thereby disabling any functionality that is only available to the owner.*


### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*See {IERC165-supportsInterface}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one. Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

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



*Emitted when the admin account has changed.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| previousAdmin  | address | undefined |
| newAdmin  | address | undefined |

### BeaconUpgraded

```solidity
event BeaconUpgraded(address indexed beacon)
```



*Emitted when the beacon is changed.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| beacon `indexed` | address | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```



*Triggered when the contract has been initialized or reinitialized.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

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



*Emitted when the implementation is upgraded.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| implementation `indexed` | address | undefined |



## Errors

### Disabled

```solidity
error Disabled()
```



*Emitted if function is disabled*


### InvalidInput

```solidity
error InvalidInput()
```



*Emitted if input is invalid*


### Prohibited

```solidity
error Prohibited()
```



*Emitted for unauthorized actions*


### RequiresRole

```solidity
error RequiresRole(bytes32 role)
```



*Emitted if access control check fails*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |

### UnsupportedMetadataVersion

```solidity
error UnsupportedMetadataVersion(uint8 metadataVersion)
```



*Emitted if contract does not support metadata version*

#### Parameters

| Name | Type | Description |
|---|---|---|
| metadataVersion | uint8 | undefined |

### ValidationFailed

```solidity
error ValidationFailed()
```



*Emitted if internal validation failed*



