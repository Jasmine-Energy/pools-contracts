# IFeePool

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Fee Pool Interface

Contains functionality and events for pools which have fees for         withdrawals and retirements.



## Methods

### deposit

```solidity
function deposit(uint256 tokenId, uint256 quantity) external nonpayable returns (uint256 jltQuantity)
```

Used to deposit EATs into the pool to receive JLTs. 

*Requirements:     - Pool must be an approved operator of from address *

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | EAT token ID to deposit |
| quantity | uint256 | Number of EATs for given tokenId to deposit  |

#### Returns

| Name | Type | Description |
|---|---|---|
| jltQuantity | uint256 | Number of JLTs issued for deposit  Emits a {Deposit} event. |

### depositBatch

```solidity
function depositBatch(address from, uint256[] tokenIds, uint256[] quantities) external nonpayable returns (uint256 jltQuantity)
```

Used to deposit numerous EATs of different IDs into the pool to receive JLTs. 

*Requirements:     - Pool must be an approved operator of from address     - Lenght of tokenIds and quantities must match *

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | Address from which to transfer EATs to pool |
| tokenIds | uint256[] | EAT token IDs to deposit |
| quantities | uint256[] | Number of EATs for tokenId at same index to deposit  |

#### Returns

| Name | Type | Description |
|---|---|---|
| jltQuantity | uint256 | Number of JLTs issued for deposit  Emits a {Deposit} event. |

### depositFrom

```solidity
function depositFrom(address from, uint256 tokenId, uint256 quantity) external nonpayable returns (uint256 jltQuantity)
```

Used to deposit EATs from another account into the pool to receive JLTs. 

*Requirements:     - Pool must be an approved operator of from address     - msg.sender must be approved for the user&#39;s tokens *

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | Address from which to transfer EATs to pool |
| tokenId | uint256 | EAT token ID to deposit |
| quantity | uint256 | Number of EATs for given tokenId to deposit  |

#### Returns

| Name | Type | Description |
|---|---|---|
| jltQuantity | uint256 | Number of JLTs issued for deposit  Emits a {Deposit} event. |

### retire

```solidity
function retire(address owner, address beneficiary, uint256 amount, bytes data) external nonpayable
```

Burns &#39;quantity&#39; of tokens from &#39;owner&#39; in the name of &#39;beneficiary&#39;. 

*Internally, calls are routed to Retirement Service to facilitate the retirement. Emits a {Retirement} event. Requirements:     - msg.sender must be approved for owner&#39;s JLTs     - Owner must have sufficient JLTs     - Owner cannot be zero address *

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | JLT owner from which to burn tokens |
| beneficiary | address | Address to receive retirement acknowledgment. If none, assume msg.sender |
| amount | uint256 | Number of JLTs to withdraw |
| data | bytes | Optional calldata to relay to retirement service via onERC1155Received  |

### retireExact

```solidity
function retireExact(address owner, address beneficiary, uint256 amount, bytes data) external nonpayable
```

Retires an exact amount of JLTs. If fees or other conversions are set,         cost of retirement will be greater than amount. 



#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | JLT holder to retire from |
| beneficiary | address | Address to receive retirement attestation |
| amount | uint256 | Exact number of JLTs to retire |
| data | bytes | Optional calldata to relay to retirement service via onERC1155Received |

### retirementCost

```solidity
function retirementCost(uint256 amount) external view returns (uint256 cost)
```

Cost of retiring JLTs from pool. 



#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | Amount of JLTs to retire.  |

#### Returns

| Name | Type | Description |
|---|---|---|
| cost | uint256 | Price of retiring in JLTs. |

### retirementRate

```solidity
function retirementRate() external view returns (uint96)
```

Retirement fee for a pool&#39;s JLT in basis points




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | undefined |

### withdraw

```solidity
function withdraw(address recipient, uint256 quantity, bytes data) external nonpayable returns (uint256[] tokenIds, uint256[] amounts)
```

Withdraw EATs from pool by burning &#39;quantity&#39; of JLTs from &#39;owner&#39;. 

*Pool will automatically select EATs to withdraw. Defer to {withdrawSpecific}      if selecting specific EATs to withdraw is important. Requirements:     - msg.sender must have sufficient JLTs     - If recipient is a contract, it must implement onERC1155Received &amp; onERC1155BatchReceived *

#### Parameters

| Name | Type | Description |
|---|---|---|
| recipient | address | Address to receive withdrawn EATs |
| quantity | uint256 | Number of JLTs to withdraw |
| data | bytes | Optional calldata to relay to recipient via onERC1155Received  |

#### Returns

| Name | Type | Description |
|---|---|---|
| tokenIds | uint256[] | Token IDs withdrawn from the pool |
| amounts | uint256[] | Number of tokens withdraw, per ID, from the pool  Emits a {Withdraw} event. |

### withdrawFrom

```solidity
function withdrawFrom(address owner, address recipient, uint256 quantity, bytes data) external nonpayable returns (uint256[] tokenIds, uint256[] amounts)
```

Withdraw EATs from pool by burning &#39;quantity&#39; of JLTs from &#39;owner&#39;. 

*Pool will automatically select EATs to withdraw. Defer to {withdrawSpecific}      if selecting specific EATs to withdraw is important. Requirements:     - msg.sender must be approved for owner&#39;s JLTs     - Owner must have sufficient JLTs     - If recipient is a contract, it must implement onERC1155Received &amp; onERC1155BatchReceived *

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | JLT owner from which to burn tokens |
| recipient | address | Address to receive withdrawn EATs |
| quantity | uint256 | Number of JLTs to withdraw |
| data | bytes | Optional calldata to relay to recipient via onERC1155Received  |

#### Returns

| Name | Type | Description |
|---|---|---|
| tokenIds | uint256[] | Token IDs withdrawn from the pool |
| amounts | uint256[] | Number of tokens withdraw, per ID, from the pool  Emits a {Withdraw} event. |

### withdrawSpecific

```solidity
function withdrawSpecific(address owner, address recipient, uint256[] tokenIds, uint256[] quantities, bytes data) external nonpayable
```

Withdraw specific EATs from pool by burning the sum of &#39;quantities&#39; in JLTs from &#39;owner&#39;. 

*Requirements:     - msg.sender must be approved for owner&#39;s JLTs     - Length of tokenIds and quantities must match     - Owner must have more JLTs than sum of quantities     - If recipient is a contract, it must implement onERC1155Received &amp; onERC1155BatchReceived     - Owner and Recipient cannot be zero address *

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | JLT owner from which to burn tokens |
| recipient | address | Address to receive withdrawn EATs |
| tokenIds | uint256[] | EAT token IDs to withdraw from pool |
| quantities | uint256[] | Number of EATs for tokenId at same index to deposit |
| data | bytes | Optional calldata to relay to recipient via onERC1155Received  Emits a {Withdraw} event. |

### withdrawalCost

```solidity
function withdrawalCost(uint256 amount) external view returns (uint256 cost)
```

Cost of withdrawing amount of tokens from pool where pool         selects the tokens to withdraw. 



#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | Number of EATs to withdraw.  |

#### Returns

| Name | Type | Description |
|---|---|---|
| cost | uint256 | Price of withdrawing EATs in JLTs |

### withdrawalCost

```solidity
function withdrawalCost(uint256[] tokenIds, uint256[] amounts) external view returns (uint256 cost)
```

Cost of withdrawing specified amounts of tokens from pool. 



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenIds | uint256[] | IDs of EATs to withdaw |
| amounts | uint256[] | Amounts of EATs to withdaw  |

#### Returns

| Name | Type | Description |
|---|---|---|
| cost | uint256 | Price of withdrawing EATs in JLTs |

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

### Deposit

```solidity
event Deposit(address indexed operator, address indexed owner, uint256 quantity)
```



*Emitted whenever EATs are deposited to the contract *

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | Initiator of the deposit |
| owner `indexed` | address | Token holder depositting to contract |
| quantity  | uint256 | Number of EATs deposited. Note: JLTs issued are 1-1 with EATs |

### Retirement

```solidity
event Retirement(address indexed operator, address indexed beneficiary, uint256 quantity)
```

emitted when tokens from a pool are retired 

*must be accompanied by a token burn event *

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | Initiator of retirement |
| beneficiary `indexed` | address | Designate beneficiary of retirement |
| quantity  | uint256 | Number of JLT being retired |

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

### Withdraw

```solidity
event Withdraw(address indexed sender, address indexed receiver, uint256 quantity)
```



*Emitted whenever EATs are withdrawn from the contract *

#### Parameters

| Name | Type | Description |
|---|---|---|
| sender `indexed` | address | Initiator of the deposit |
| receiver `indexed` | address | Token holder depositting to contract |
| quantity  | uint256 | Number of EATs withdrawn. |

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



