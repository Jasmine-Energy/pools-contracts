# Nonces







*Provides tracking nonces for addresses. Nonces will only increment.*

## Methods

### nonces

```solidity
function nonces(address owner) external view returns (uint256)
```



*Returns an the next unused nonce for an address.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |




## Errors

### InvalidAccountNonce

```solidity
error InvalidAccountNonce(address account, uint256 currentNonce)
```



*The nonce used for an `account` is not the expected current nonce.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| currentNonce | uint256 | undefined |


