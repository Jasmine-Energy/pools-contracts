# IJasmineQualifiedPool

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Qualified Pool Interface

Interface for any pool that has a deposit policy which constrains deposits.



## Methods

### meetsPolicy

```solidity
function meetsPolicy(uint256 tokenId) external view returns (bool isEligible)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| isEligible | bool | undefined |

### policyForVersion

```solidity
function policyForVersion(uint8 metadataVersion) external view returns (bytes policy)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| metadataVersion | uint8 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| policy | bytes | undefined |




