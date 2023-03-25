# JasmineMinter





This contract is responsible for validating that the bridge has authorized an EAT mint.This contract also updates the oracle with EAT metadata during each mint.

*This contract is upgradeable. You can only append new contracts to the list of bases. You cannot delete bases or reorder them.*

## Methods

### CONSUMENONCE_TYPEHASH

```solidity
function CONSUMENONCE_TYPEHASH() external view returns (bytes32)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### DOMAIN_SEPARATOR

```solidity
function DOMAIN_SEPARATOR() external view returns (bytes32)
```

This is the EIP712 domain separator. It is exposed here for ease of introspection.




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### MINTBATCH_TYPEHASH

```solidity
function MINTBATCH_TYPEHASH() external view returns (bytes32)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### MINT_TYPEHASH

```solidity
function MINT_TYPEHASH() external view returns (bytes32)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### acceptOwnership

```solidity
function acceptOwnership() external nonpayable
```



*The new owner accepts the ownership transfer.*


### bridge

```solidity
function bridge() external view returns (address)
```



*This is the wallet/EOA address that authorizes minting new EATs. This is a separate authority from the right to upgrade protocol contracts.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### burn

```solidity
function burn(uint256 id, uint256 amount, bytes metadata) external nonpayable
```

Used in both redemption and bridge-off flows.

*JasmineMinter must be approved to spend the caller&#39;s EATs for the operation to succeed. JasmineMinter indirectly authenticates that the caller owns the specified amount of the specified EATs.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | The series of EAT to be redeemed/bridged-off. |
| amount | uint256 | The amount of EAT of the specified series to be redeemed/bridged-off. |
| metadata | bytes | Message to the bridge specifying whether to redeem or bridge-off. If the operation is a bridge-off, also specifies the destination of the EAC. JasmineMinter imposes no authentication or structure on the metadata. Malformed or otherwise invalid metadata is an unrecoverable error. |

### burnBatch

```solidity
function burnBatch(uint256[] ids, uint256[] amounts, bytes metadata) external nonpayable
```

Used in both redemption and bridge-off flows.

*JasmineMinter must be approved to spend the caller&#39;s EATs for the operation to succeed. JasmineMinter indirectly authenticates that the caller owns the specified amount of the specified EATs.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| ids | uint256[] | The series of EATs to be redeemed/bridged-off. |
| amounts | uint256[] | The amounts of EATs of the specified series to be redeemed/bridged-off. |
| metadata | bytes | Message to the bridge specifying whether to redeem or bridge-off. If the operation is a bridge-off, also specifies the destination of the EAC. JasmineMinter imposes no authentication or structure on the metadata. Malformed or otherwise invalid metadata is an unrecoverable error. |

### consumeNonce

```solidity
function consumeNonce(bytes32 nonce, bytes sig) external nonpayable
```

Used to invalidate a nonce embedded in another EIP712 minting authorization.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nonce | bytes32 | undefined |
| sig | bytes | undefined |

### consumedNonces

```solidity
function consumedNonces(bytes32) external view returns (bool)
```

Whether a particular nonce has been used to prevent replay.

*This contract uses non-sequential nonces so that multiple mint authorizations can be issued concurrently. The downside to this approach is that it is slightly more involved to invalidate a nonce that has not yet been consumed.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### initialize

```solidity
function initialize(string initialName, string initialVersion, address initialBridge, address initialOwner) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| initialName | string | undefined |
| initialVersion | string | undefined |
| initialBridge | address | undefined |
| initialOwner | address | undefined |

### mint

```solidity
function mint(address receiver, uint256 id, uint256 amount, bytes transferData, bytes oracleData, uint256 deadline, bytes32 nonce, bytes sig) external nonpayable
```

Mint a new EAT.Only callable by the address specified in the EIP712 mint authoriztaion.



#### Parameters

| Name | Type | Description |
|---|---|---|
| receiver | address | The initial owner of the newly-minted EATs. If this is a contract, it must support IERC1155Receiver.onERC1155Received. Failure of the receiver callback does not invalidate the nonce. The receiver is NOT part of the EIP712 minting authorization. |
| id | uint256 | The identifier of the EAT series to mint. See JasmineOracle for the constraints on this value. The id is part of the EIP712 minting authorization. |
| amount | uint256 | The quantity of EATs to mint. The amount is part of the EIP712 minting authorization. |
| transferData | bytes | Additional argument to be passed to `receiver`&#39;s callback. Ignored if `receiver` is not a contract. The transferData is NOT part of the EIP712 minting authorization. |
| oracleData | bytes | Authenticated EAT metadata passed to the oracle. Oracle updates are idempotent. The oracleData is part of the EIP712 minting authorization. |
| deadline | uint256 | The latest timestamp at which the mint authorization remains valid. After this time, attempts to mint will revert. The deadline is part of the EIP712 minting authorization. |
| nonce | bytes32 | Used to prevent signature replay. The nonce is part of the EIP712 minting authorization. If consumedNonces(nonce), the minting authorization is invalid. |
| sig | bytes | Encoded ECDSA signature by `bridge` over the EIP712 minting authorization. Formed as the 65-byte concatenation of r, s, and v in that order. s must be in the lower half of the curve. v must be 27 or 28. |

### mintBatch

```solidity
function mintBatch(address receiver, uint256[] ids, uint256[] amounts, bytes transferData, bytes[] oracleDatas, uint256 deadline, bytes32 nonce, bytes sig) external nonpayable
```

Mint a new EAT.Only callable by the address specified in the EIP712 mint authoriztaion.



#### Parameters

| Name | Type | Description |
|---|---|---|
| receiver | address | The initial owner of the newly-minted EATs. If this is a contract, it must support IERC1155Receiver.onERC1155Received. Failure of the receiver callback does not invalidate the nonce. The receiver is NOT part of the EIP712 minting authorization. |
| ids | uint256[] | The identifiers of the EAT series to mint. See JasmineOracle for the constraints on this value. The ids are part of the EIP712 minting authorization. |
| amounts | uint256[] | The quantities of EATs to mint. The amounts are part of the EIP712 minting authorization. |
| transferData | bytes | Additional argument to be passed to `receiver`&#39;s callback. Ignored if `receiver` is not a contract. The transferData is NOT part of the EIP712 minting authorization. |
| oracleDatas | bytes[] | Authenticated EAT metadatas passed to the oracle. Oracle updates are idempotent. The oracleData is part of the EIP712 minting authorization. |
| deadline | uint256 | The latest timestamp at which the mint authorization remains valid. After this time, attempts to mint will revert. The deadline is part of the EIP712 minting authorization. |
| nonce | bytes32 | Used to prevent signature replay. The nonce is part of the EIP712 minting authorization. If consumedNonces(nonce), the minting authorization is invalid. |
| sig | bytes | Encoded ECDSA signature by `bridge` over the EIP712 minting authorization. Formed as the 65-byte concatenation of r, s, and v in that order. s must be in the lower half of the curve. v must be 27 or 28. |

### name

```solidity
function name() external view returns (string)
```



*This is the EIP712 domain name. It is exposed here for ease of introspection.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### oracle

```solidity
function oracle() external view returns (address)
```






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


### setBridge

```solidity
function setBridge(address newBridge) external nonpayable
```

When the bridge wallet/EOA is migrated, the owner updates the bridge address.



#### Parameters

| Name | Type | Description |
|---|---|---|
| newBridge | address | undefined |

### token

```solidity
function token() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

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

### version

```solidity
function version() external view returns (string)
```



*This is the EIP712 domain version. It is exposed here for ease of introspection.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |



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

### BridgeChanged

```solidity
event BridgeChanged(address indexed newBridge)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newBridge `indexed` | address | undefined |

### BurnedBatch

```solidity
event BurnedBatch(address indexed owner, uint256[] ids, uint256[] amounts, bytes metadata)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| ids  | uint256[] | undefined |
| amounts  | uint256[] | undefined |
| metadata  | bytes | undefined |

### BurnedSingle

```solidity
event BurnedSingle(address indexed owner, uint256 id, uint256 amount, bytes metadata)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| id  | uint256 | undefined |
| amount  | uint256 | undefined |
| metadata  | bytes | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### NonceConsumed

```solidity
event NonceConsumed(bytes32 indexed nonce)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nonce `indexed` | bytes32 | undefined |

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



