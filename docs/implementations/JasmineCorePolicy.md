# JasmineCorePolicy









## Methods

### eat

```solidity
function eat() external view returns (contract IJasmineEAT)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IJasmineEAT | undefined |

### makeCertificationsCondition

```solidity
function makeCertificationsCondition(uint256[] certificationTypes) external view returns (struct PoolPolicy.Condition certificationsCondition)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| certificationTypes | uint256[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| certificationsCondition | PoolPolicy.Condition | undefined |

### makeEndorsementCondition

```solidity
function makeEndorsementCondition(uint256[] endorsements) external view returns (struct PoolPolicy.Condition endorsementsCondition)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| endorsements | uint256[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| endorsementsCondition | PoolPolicy.Condition | undefined |

### makeRegistriesCondition

```solidity
function makeRegistriesCondition(uint256[] registries) external view returns (struct PoolPolicy.Condition registriesCondition)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| registries | uint256[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| registriesCondition | PoolPolicy.Condition | undefined |

### makeTechTypesCondition

```solidity
function makeTechTypesCondition(uint256[] techTypes) external view returns (struct PoolPolicy.Condition techTypeCondition)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| techTypes | uint256[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| techTypeCondition | PoolPolicy.Condition | undefined |

### makeVintageCondition

```solidity
function makeVintageCondition(uint256[2] vintagePeriod) external view returns (struct PoolPolicy.Condition vintagePeriodCondition)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| vintagePeriod | uint256[2] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| vintagePeriodCondition | PoolPolicy.Condition | undefined |

### oracle

```solidity
function oracle() external view returns (contract IJasmineOracle)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IJasmineOracle | undefined |

### totalPolicies

```solidity
function totalPolicies() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |




