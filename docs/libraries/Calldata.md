# Calldata

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Calldata

Utility library encoding and decoding calldata between contracts



## Methods

### BRIDGE_OFF_OP

```solidity
function BRIDGE_OFF_OP() external view returns (bytes32)
```



*Calldata prefix for bridge-off operations*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### RETIREMENT_OP

```solidity
function RETIREMENT_OP() external view returns (bytes32)
```



*Calldata prefix for retirement operations*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### encodeRetirementCalldata

```solidity
function encodeRetirementCalldata(address, bytes32) external pure returns (bytes)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | bytes32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes | undefined |




