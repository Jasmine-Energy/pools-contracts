# CryticERC20ExternalHarness









## Methods

### bridge

```solidity
function bridge() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### eat

```solidity
function eat() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### feeBeneficiary

```solidity
function feeBeneficiary() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### feeManager

```solidity
function feeManager() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### frontHalfPool

```solidity
function frontHalfPool() external view returns (contract JasminePool)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasminePool | undefined |

### mintEAT

```solidity
function mintEAT(address recipient, uint256 amount, uint40 vintage, uint32 techType) external nonpayable returns (uint256 tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| recipient | address | undefined |
| amount | uint256 | undefined |
| vintage | uint40 | undefined |
| techType | uint32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

### minter

```solidity
function minter() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### oracle

```solidity
function oracle() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### owner

```solidity
function owner() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### poolFactory

```solidity
function poolFactory() external view returns (contract JasminePoolFactory)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasminePoolFactory | undefined |

### poolImplementation

```solidity
function poolImplementation() external view returns (contract JasminePool)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasminePool | undefined |

### poolManager

```solidity
function poolManager() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### retirementService

```solidity
function retirementService() external view returns (contract JasmineRetirementService)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasmineRetirementService | undefined |

### test_ERC20external_constantSupply

```solidity
function test_ERC20external_constantSupply() external nonpayable
```






### test_ERC20external_selfTransfer

```solidity
function test_ERC20external_selfTransfer(uint256 value) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| value | uint256 | undefined |

### test_ERC20external_selfTransferFrom

```solidity
function test_ERC20external_selfTransferFrom(uint256 value) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| value | uint256 | undefined |

### test_ERC20external_setAllowance

```solidity
function test_ERC20external_setAllowance(address target, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| target | address | undefined |
| amount | uint256 | undefined |

### test_ERC20external_setAllowanceTwice

```solidity
function test_ERC20external_setAllowanceTwice(address target, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| target | address | undefined |
| amount | uint256 | undefined |

### test_ERC20external_spendAllowanceAfterTransfer

```solidity
function test_ERC20external_spendAllowanceAfterTransfer(address target, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| target | address | undefined |
| amount | uint256 | undefined |

### test_ERC20external_transfer

```solidity
function test_ERC20external_transfer(address target, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| target | address | undefined |
| amount | uint256 | undefined |

### test_ERC20external_transferFrom

```solidity
function test_ERC20external_transferFrom(address target, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| target | address | undefined |
| amount | uint256 | undefined |

### test_ERC20external_transferFromMoreThanBalance

```solidity
function test_ERC20external_transferFromMoreThanBalance(address target) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| target | address | undefined |

### test_ERC20external_transferFromToZeroAddress

```solidity
function test_ERC20external_transferFromToZeroAddress(uint256 value) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| value | uint256 | undefined |

### test_ERC20external_transferFromZeroAmount

```solidity
function test_ERC20external_transferFromZeroAmount(address target) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| target | address | undefined |

### test_ERC20external_transferMoreThanBalance

```solidity
function test_ERC20external_transferMoreThanBalance(address target) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| target | address | undefined |

### test_ERC20external_transferToZeroAddress

```solidity
function test_ERC20external_transferToZeroAddress() external nonpayable
```






### test_ERC20external_transferZeroAmount

```solidity
function test_ERC20external_transferZeroAmount(address target) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| target | address | undefined |

### test_ERC20external_userBalanceNotHigherThanSupply

```solidity
function test_ERC20external_userBalanceNotHigherThanSupply() external nonpayable
```






### test_ERC20external_userBalancesLessThanTotalSupply

```solidity
function test_ERC20external_userBalancesLessThanTotalSupply() external nonpayable
```






### test_ERC20external_zeroAddressBalance

```solidity
function test_ERC20external_zeroAddressBalance() external nonpayable
```








## Events

### AssertEqFail

```solidity
event AssertEqFail(string)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0  | string | undefined |

### AssertFail

```solidity
event AssertFail(string)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0  | string | undefined |

### AssertGtFail

```solidity
event AssertGtFail(string)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0  | string | undefined |

### AssertGteFail

```solidity
event AssertGteFail(string)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0  | string | undefined |

### AssertLtFail

```solidity
event AssertLtFail(string)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0  | string | undefined |

### AssertLteFail

```solidity
event AssertLteFail(string)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0  | string | undefined |

### AssertNeqFail

```solidity
event AssertNeqFail(string)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0  | string | undefined |

### LogAddress

```solidity
event LogAddress(string, address)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0  | string | undefined |
| _1  | address | undefined |

### LogString

```solidity
event LogString(string)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0  | string | undefined |

### LogUint256

```solidity
event LogUint256(string, uint256)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0  | string | undefined |
| _1  | uint256 | undefined |



