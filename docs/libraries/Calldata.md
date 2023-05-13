# Calldata

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Calldata

Utility library encoding and decoding calldata between contracts



## Methods

### BRIDGE_OFF_OP

```solidity
function BRIDGE_OFF_OP() external view returns (bytes1)
```



*Calldata prefix for bridge-off operations*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes1 | undefined |

### RETIREMENT_FRACTIONAL_OP

```solidity
function RETIREMENT_FRACTIONAL_OP() external view returns (bytes1)
```



*Calldata prefix for fractional retirement operations*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes1 | undefined |

### RETIREMENT_OP

```solidity
function RETIREMENT_OP() external view returns (bytes1)
```



*Calldata prefix for retirement operations associated with a single user*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes1 | undefined |

### encodeBridgeOffData

```solidity
function encodeBridgeOffData(address recipient) external pure returns (bytes bridgeOffData)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| recipient | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| bridgeOffData | bytes | undefined |

### encodeFractionalRetirementData

```solidity
function encodeFractionalRetirementData() external pure returns (bytes retirementData)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| retirementData | bytes | undefined |

### encodeRetirementData

```solidity
function encodeRetirementData(address beneficiary, bool hasFractional) external pure returns (bytes retirementData)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| beneficiary | address | undefined |
| hasFractional | bool | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| retirementData | bytes | undefined |

### isBridgeOffOperation

```solidity
function isBridgeOffOperation(bytes data) external pure returns (bool isBridgeOff)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| data | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| isBridgeOff | bool | undefined |

### isRetirementOperation

```solidity
function isRetirementOperation(bytes data) external pure returns (bool isRetirement, bool hasFractional)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| data | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| isRetirement | bool | undefined |
| hasFractional | bool | undefined |




## Errors

### InvalidInput

```solidity
error InvalidInput()
```



*Emitted if input is invalid*



