# ERC1155Manager

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> ERC-1155 Manager

Manages deposits of ERC-1155 tokens (from a single contract) and enables         interactions with the underlying deposits through explicit conventions.



## Methods

### _selectWithdrawTokens

```solidity
function _selectWithdrawTokens(uint256 amount) external view returns (uint256[] tokenIds, uint256[] amounts)
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

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address, address from, uint256[] tokenIds, uint256[] values, bytes) external nonpayable returns (bytes4)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| from | address | undefined |
| tokenIds | uint256[] | undefined |
| values | uint256[] | undefined |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

### onERC1155Received

```solidity
function onERC1155Received(address, address from, uint256 tokenId, uint256 value, bytes) external nonpayable returns (bytes4)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| from | address | undefined |
| tokenId | uint256 | undefined |
| value | uint256 | undefined |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

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

### totalDeposits

```solidity
function totalDeposits() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |




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

### WithdrawsLocked

```solidity
error WithdrawsLocked()
```



*Emitted if withdraws are locked*



