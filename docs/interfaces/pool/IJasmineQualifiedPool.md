# IJasmineQualifiedPool

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Qualified Pool Interface

Interface for any pool that has a deposit policy which constrains deposits.



## Methods

### meetsPolicy

```solidity
function meetsPolicy(uint256 tokenId) external view returns (bool isEligible)
```

Checks if a given Jasmine EAT token meets the pool&#39;s deposit policy 



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | Token to check pool eligibility for  |

#### Returns

| Name | Type | Description |
|---|---|---|
| isEligible | bool | True if token meets policy and may be deposited. False otherwise. |

### policyForVersion

```solidity
function policyForVersion(uint8 metadataVersion) external view returns (bytes policy)
```

Get a pool&#39;s deposit policy for a given metadata version 



#### Parameters

| Name | Type | Description |
|---|---|---|
| metadataVersion | uint8 | Version of metadata to return policy for  |

#### Returns

| Name | Type | Description |
|---|---|---|
| policy | bytes | Deposit policy for given metadata version |




## Errors

### Unqualified

```solidity
error Unqualified(uint256 tokenId)
```



*Emitted if a token does not meet pool&#39;s deposit policy*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |


