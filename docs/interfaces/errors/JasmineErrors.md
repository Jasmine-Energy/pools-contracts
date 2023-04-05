# JasmineErrors

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Errors

Convenience interface for errors omitted by Jasmine&#39;s smart contracts





## Errors

### InvalidConformance

```solidity
error InvalidConformance(bytes4 interfaceId)
```



*Emitted for failed supportsInterface check - per ERC-165*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

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


### Unqualified

```solidity
error Unqualified(uint256 tokenId)
```



*Emitted if a token does not meet pool&#39;s deposit policy*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |


