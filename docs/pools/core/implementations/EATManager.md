# EATManager

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine EAT Manager

Manages deposits and withdraws of Jasmine EATs (ERC-1155).



## Methods

### eat

```solidity
function eat() external view returns (address)
```



*Address of the Jasmine EAT (ERC-1155) contract*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address operator, address from, uint256[] tokenIds, uint256[] values, bytes) external nonpayable returns (bytes4)
```



*Handles the receipt of a multiple ERC1155 token types. This function is called at the end of a `safeBatchTransferFrom` after the balances have been updated. NOTE: To accept the transfer(s), this must return `bytes4(keccak256(&quot;onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)&quot;))` (i.e. 0xbc197c81, or its own function selector).*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | The address which initiated the batch transfer (i.e. msg.sender) |
| from | address | The address which previously owned the token |
| tokenIds | uint256[] | undefined |
| values | uint256[] | An array containing amounts of each token being transferred (order and length must match ids array) |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | `bytes4(keccak256(&quot;onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)&quot;))` if transfer is allowed |

### onERC1155Received

```solidity
function onERC1155Received(address operator, address from, uint256 tokenId, uint256 value, bytes) external nonpayable returns (bytes4)
```



*Handles the receipt of a single ERC1155 token type. This function is called at the end of a `safeTransferFrom` after the balance has been updated. NOTE: To accept the transfer, this must return `bytes4(keccak256(&quot;onERC1155Received(address,address,uint256,uint256,bytes)&quot;))` (i.e. 0xf23a6e61, or its own function selector).*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | The address which initiated the transfer (i.e. msg.sender) |
| from | address | The address which previously owned the token |
| tokenId | uint256 | undefined |
| value | uint256 | The amount of tokens being transferred |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | `bytes4(keccak256(&quot;onERC1155Received(address,address,uint256,uint256,bytes)&quot;))` if transfer is allowed |

### selectWithdrawTokens

```solidity
function selectWithdrawTokens(uint256 amount) external view returns (uint256[] tokenIds, uint256[] amounts)
```



*Internal function to select tokens to withdraw from the contract *

#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | Number of tokens to withdraw from contract  |

#### Returns

| Name | Type | Description |
|---|---|---|
| tokenIds | uint256[] | Token IDs to withdraw |
| amounts | uint256[] | Number of tokens to withdraw for each token ID |

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

### InvalidTokenAddress

```solidity
error InvalidTokenAddress(address received, address expected)
```



*Emitted if tokens (ERC-1155) are received from incorrect contract*

#### Parameters

| Name | Type | Description |
|---|---|---|
| received | address | undefined |
| expected | address | undefined |

### ValidationFailed

```solidity
error ValidationFailed()
```



*Emitted if internal validation failed*


### WithdrawBlocked

```solidity
error WithdrawBlocked(uint256 tokenId)
```



*Emitted if a token is unable to be withdrawn from pool*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

### WithdrawsLocked

```solidity
error WithdrawsLocked()
```



*Emitted if withdraws are locked*



