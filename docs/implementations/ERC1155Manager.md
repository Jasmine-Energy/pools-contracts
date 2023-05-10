# ERC1155Manager









## Methods

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




## Errors

### InvalidTokenAddress

```solidity
error InvalidTokenAddress(address received, address expected)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| received | address | undefined |
| expected | address | undefined |


