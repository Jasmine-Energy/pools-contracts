# IJasmineFeeManager

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Fee Manager Interface

Standard interface for fee manager contract in          Jasmine reference pools



## Methods

### baseRetirementRate

```solidity
function baseRetirementRate() external nonpayable returns (uint96)
```



*Default fee for retirements across pools. May be overridden per pool*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | undefined |

### baseWithdrawalRate

```solidity
function baseWithdrawalRate() external nonpayable returns (uint96)
```



*Default fee for withdrawals across pools. May be overridden per pool*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | undefined |

### baseWithdrawalSpecificRate

```solidity
function baseWithdrawalSpecificRate() external nonpayable returns (uint96)
```



*Default fee for withdrawing specific EATs from pools. May be overridden per pool*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | undefined |

### feeBeneficiary

```solidity
function feeBeneficiary() external nonpayable returns (address)
```



*Address to receive fees*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |



## Events

### BaseRetirementFeeUpdate

```solidity
event BaseRetirementFeeUpdate(uint96 retirementRateBips, address indexed beneficiary)
```



*Emitted whenever fee manager updates retirement rate *

#### Parameters

| Name | Type | Description |
|---|---|---|
| retirementRateBips  | uint96 | new retirement rate in basis points |
| beneficiary `indexed` | address | Address to receive fees |

### BaseWithdrawalFeeUpdate

```solidity
event BaseWithdrawalFeeUpdate(uint96 withdrawRateBips, address indexed beneficiary, bool indexed specific)
```



*Emitted whenever fee manager updates withdrawal rate *

#### Parameters

| Name | Type | Description |
|---|---|---|
| withdrawRateBips  | uint96 | New withdrawal rate in basis points |
| beneficiary `indexed` | address | Address to receive fees |
| specific `indexed` | bool | Specifies whether new rate applies to specific or any withdrawals |



