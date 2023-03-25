# PoolPolicy

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> PoolPolicy

Utility library for Pool Policy types



## Methods

### backHalfOfYear

```solidity
function backHalfOfYear(uint16 year) external pure returns (uint256[2] period)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| year | uint16 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| period | uint256[2] | undefined |

### frontHalfOfYear

```solidity
function frontHalfOfYear(uint16 year) external pure returns (uint256[2] period)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| year | uint16 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| period | uint256[2] | undefined |

### toBytes

```solidity
function toBytes(PoolPolicy.DepositPolicy policy) external pure returns (bytes)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| policy | PoolPolicy.DepositPolicy | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes | undefined |

### toDepositPolicy

```solidity
function toDepositPolicy(bytes _encodedPolicy) external pure returns (struct PoolPolicy.DepositPolicy)
```



*Converts bytes to Deposit Policy *

#### Parameters

| Name | Type | Description |
|---|---|---|
| _encodedPolicy | bytes | Byte encode policy to decode |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | PoolPolicy.DepositPolicy | undefined |




