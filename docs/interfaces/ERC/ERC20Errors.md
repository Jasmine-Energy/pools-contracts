# ERC20Errors



> Standard ERC20 Errors



*See https://eips.ethereum.org/EIPS/eip-20  https://eips.ethereum.org/EIPS/eip-6093*



## Errors

### ERC20InsufficientAllowance

```solidity
error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| allowance | uint256 | undefined |
| needed | uint256 | undefined |

### ERC20InsufficientBalance

```solidity
error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | undefined |
| balance | uint256 | undefined |
| needed | uint256 | undefined |

### ERC20InvalidApprover

```solidity
error ERC20InvalidApprover(address approver)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| approver | address | undefined |

### ERC20InvalidReceiver

```solidity
error ERC20InvalidReceiver(address receiver)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| receiver | address | undefined |

### ERC20InvalidSender

```solidity
error ERC20InvalidSender(address sender)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | undefined |

### ERC20InvalidSpender

```solidity
error ERC20InvalidSpender(address spender)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |


