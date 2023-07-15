# IJasmineMinter









## Methods

### burn

```solidity
function burn(uint256 id, uint256 amount, bytes metadata) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| id | uint256 | undefined |
| amount | uint256 | undefined |
| metadata | bytes | undefined |

### burnBatch

```solidity
function burnBatch(uint256[] ids, uint256[] amounts, bytes metadata) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| ids | uint256[] | undefined |
| amounts | uint256[] | undefined |
| metadata | bytes | undefined |

### mint

```solidity
function mint(address receiver, uint256 id, uint256 amount, bytes transferData, bytes oracleData, uint256 deadline, bytes32 nonce, bytes sig) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| receiver | address | undefined |
| id | uint256 | undefined |
| amount | uint256 | undefined |
| transferData | bytes | undefined |
| oracleData | bytes | undefined |
| deadline | uint256 | undefined |
| nonce | bytes32 | undefined |
| sig | bytes | undefined |

### mintBatch

```solidity
function mintBatch(address receiver, uint256[] ids, uint256[] amounts, bytes transferData, bytes[] oracleDatas, uint256 deadline, bytes32 nonce, bytes sig) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| receiver | address | undefined |
| ids | uint256[] | undefined |
| amounts | uint256[] | undefined |
| transferData | bytes | undefined |
| oracleDatas | bytes[] | undefined |
| deadline | uint256 | undefined |
| nonce | bytes32 | undefined |
| sig | bytes | undefined |



## Events

### BurnedBatch

```solidity
event BurnedBatch(address indexed owner, uint256[] ids, uint256[] amounts, bytes metadata)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| ids  | uint256[] | undefined |
| amounts  | uint256[] | undefined |
| metadata  | bytes | undefined |

### BurnedSingle

```solidity
event BurnedSingle(address indexed owner, uint256 id, uint256 amount, bytes metadata)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| id  | uint256 | undefined |
| amount  | uint256 | undefined |
| metadata  | bytes | undefined |



