# ERC1155Errors



> Standard ERC1155 Errors



*See https://eips.ethereum.org/EIPS/eip-1155  https://eips.ethereum.org/EIPS/eip-6093*



## Errors

### ERC1155InsufficientApproval

```solidity
error ERC1155InsufficientApproval(address operator, uint256 tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |
| tokenId | uint256 | undefined |

### ERC1155InsufficientBalance

```solidity
error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | undefined |
| balance | uint256 | undefined |
| needed | uint256 | undefined |
| tokenId | uint256 | undefined |

### ERC1155InvalidApprover

```solidity
error ERC1155InvalidApprover(address approver)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| approver | address | undefined |

### ERC1155InvalidArrayLength

```solidity
error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| idsLength | uint256 | undefined |
| valuesLength | uint256 | undefined |

### ERC1155InvalidOperator

```solidity
error ERC1155InvalidOperator(address operator)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |

### ERC1155InvalidReceiver

```solidity
error ERC1155InvalidReceiver(address receiver)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| receiver | address | undefined |

### ERC1155InvalidSender

```solidity
error ERC1155InvalidSender(address sender)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | undefined |


