# JasmineErrors

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Errors

Convenience interface for errors omitted by Jasmine&#39;s smart contracts





## Errors

### Disabled

```solidity
error Disabled()
```



*Emitted if function is disabled*


### InbalancedDeposits

```solidity
error InbalancedDeposits()
```



*Emitted if operation would cause inbalance in pool&#39;s EAT deposits*


### InvalidConformance

```solidity
error InvalidConformance(bytes4 interfaceId)
```



*Emitted for failed supportsInterface check - per ERC-165*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

### InvalidInput

```solidity
error InvalidInput()
```



*Emitted if input is invalid*


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

### NoPool

```solidity
error NoPool()
```



*Emitted if no pool(s) meet query*


### PoolExists

```solidity
error PoolExists(address pool)
```



*Emitted if a pool exists with given policy*

#### Parameters

| Name | Type | Description |
|---|---|---|
| pool | address | undefined |

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

### Unqualified

```solidity
error Unqualified(uint256 tokenId)
```



*Emitted if a token does not meet pool&#39;s deposit policy*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

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


### WithdrawsLocked

```solidity
error WithdrawsLocked()
```



*Emitted if withdraws are locked*



