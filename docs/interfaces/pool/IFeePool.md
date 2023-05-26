# IFeePool

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Fee Pool Interface

Contains functionality and events for pools which have fees for         withdrawals and retirements.



## Methods

### retirementRate

```solidity
function retirementRate() external view returns (uint96)
```

Retirement fee for a pool&#39;s JLT in basis points




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | undefined |

### withdrawalRate

```solidity
function withdrawalRate() external view returns (uint96)
```

Withdrawal fee for any EATs from a pool in basis points




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | undefined |

### withdrawalSpecificRate

```solidity
function withdrawalSpecificRate() external view returns (uint96)
```

Withdrawal fee for specific EATs from a pool in basis points




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | undefined |



## Events

### RetirementRateUpdate

```solidity
event RetirementRateUpdate(uint96 retirementFeeBips, address indexed beneficiary)
```



*Emitted whenever fee manager updates retirement fee *

#### Parameters

| Name | Type | Description |
|---|---|---|
| retirementFeeBips  | uint96 | new retirement fee in basis points |
| beneficiary `indexed` | address | Address to receive fees |

### WithdrawalRateUpdate

```solidity
event WithdrawalRateUpdate(uint96 withdrawFeeBips, address indexed beneficiary)
```



*Emitted whenever fee manager updates withdrawal fee *

#### Parameters

| Name | Type | Description |
|---|---|---|
| withdrawFeeBips  | uint96 | New withdrawal fee in basis points |
| beneficiary `indexed` | address | Address to receive fees |



