# ExternalJasminePoolTest









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

### echidna_check_deposit

```solidity
function echidna_check_deposit() external nonpayable returns (bool)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

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

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address, address, uint256[], uint256[], bytes) external nonpayable returns (bytes4)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | address | undefined |
| _2 | uint256[] | undefined |
| _3 | uint256[] | undefined |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

### onERC1155Received

```solidity
function onERC1155Received(address, address, uint256, uint256, bytes) external nonpayable returns (bytes4)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | address | undefined |
| _2 | uint256 | undefined |
| _3 | uint256 | undefined |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

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

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*See {IERC165-supportsInterface}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |



## Events

### AssertionFailed

```solidity
event AssertionFailed(string reason)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| reason  | string | undefined |



