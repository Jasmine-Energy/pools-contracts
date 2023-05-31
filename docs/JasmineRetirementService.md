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

### eat

```solidity
function eat() external view returns (contract JasmineEAT)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasmineEAT | undefined |

### minter

```solidity
function minter() external view returns (contract JasmineMinter)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasmineMinter | undefined |

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address, address from, uint256[] tokenIds, uint256[] amounts, bytes data) external nonpayable returns (bytes4)
```





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

### registerRetirementRecipient

```solidity
function registerRetirementRecipient(address account, address implementer) external nonpayable
```

Registers a smart contract to receive notifications on retirement events 

*Requirements:      - Retirement service must be an approved ERC-1820 manager of account      - Implementer must support IRetirementRecipient interface via ERC-165 *

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | Address to register retirement recipient for |
| implementer | address | Smart contract address to register as retirement implementer |

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




## Errors

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



