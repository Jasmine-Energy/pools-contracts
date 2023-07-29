# IHevm









## Methods

### addr

```solidity
function addr(uint256 privateKey) external nonpayable returns (address addr)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| privateKey | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| addr | address | undefined |

### ffi

```solidity
function ffi(string[] inputs) external nonpayable returns (bytes result)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| inputs | string[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| result | bytes | undefined |

### load

```solidity
function load(address where, bytes32 slot) external nonpayable returns (bytes32)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| where | address | undefined |
| slot | bytes32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### prank

```solidity
function prank(address newSender) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newSender | address | undefined |

### roll

```solidity
function roll(uint256 newNumber) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newNumber | uint256 | undefined |

### sign

```solidity
function sign(uint256 privateKey, bytes32 digest) external nonpayable returns (uint8 r, bytes32 v, bytes32 s)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| privateKey | uint256 | undefined |
| digest | bytes32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| r | uint8 | undefined |
| v | bytes32 | undefined |
| s | bytes32 | undefined |

### store

```solidity
function store(address where, bytes32 slot, bytes32 value) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| where | address | undefined |
| slot | bytes32 | undefined |
| value | bytes32 | undefined |

### warp

```solidity
function warp(uint256 newTimestamp) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| newTimestamp | uint256 | undefined |




