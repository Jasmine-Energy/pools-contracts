# JasmineRetirementService

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Retirement Service

Facilitates retirements of EATs and JLTs in the Jasmine protocol



## Methods

### EAT

```solidity
function EAT() external view returns (contract JasmineEAT)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasmineEAT | undefined |

### ERC1820_REGISTRY

```solidity
function ERC1820_REGISTRY() external view returns (contract IERC1820Registry)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IERC1820Registry | undefined |

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

### onTransferReceived

```solidity
function onTransferReceived(address operator, address from, uint256 value, bytes data) external nonpayable returns (bytes4)
```

Handle the receipt of ERC1363 tokens

*Any ERC1363 smart contract calls this function on the recipient after a `transfer` or a `transferFrom`. This function MAY throw to revert and reject the transfer. Return of other than the magic value MUST result in the transaction being reverted. Note: the token contract address is always the message sender.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | address The address which called `transferAndCall` or `transferFromAndCall` function |
| from | address | address The address which are token transferred from |
| value | uint256 | uint256 The amount of tokens transferred |
| data | bytes | bytes Additional data with no specified format |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | `bytes4(keccak256(&quot;onTransferReceived(address,address,uint256,bytes)&quot;))`  unless throwing |

### registerRetirementRecipient

```solidity
function registerRetirementRecipient(address holder, address recipient) external nonpayable
```

Allows user to designate an address to receive retirement hooks.

*Contract must implement IRetirementRecipient&#39;s onRetirement function*

#### Parameters

| Name | Type | Description |
|---|---|---|
| holder | address | User address to notify recipient address of retirements |
| recipient | address | Smart contract to receive retirement hooks. Address must implement IRetirementRecipient interface. |

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

### Prohibited

```solidity
error Prohibited()
```



*Emitted for unauthorized actions*



