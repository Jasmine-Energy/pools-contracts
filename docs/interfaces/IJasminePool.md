# IJasminePool

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> IJasminePool





## Methods

### allowance

```solidity
function allowance(address owner, address spender) external view returns (uint256)
```



*Returns the remaining number of tokens that `spender` will be allowed to spend on behalf of `owner` through {transferFrom}. This is zero by default. This value changes when {approve} or {transferFrom} are called.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |
| spender | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### approve

```solidity
function approve(address spender, uint256 amount) external nonpayable returns (bool)
```



*Sets `amount` as the allowance of `spender` over the caller&#39;s tokens. Returns a boolean value indicating whether the operation succeeded. IMPORTANT: Beware that changing an allowance with this method brings the risk that someone may use both the old and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729 Emits an {Approval} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### balanceOf

```solidity
function balanceOf(address account) external view returns (uint256)
```



*Returns the amount of tokens owned by `account`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### decimals

```solidity
function decimals() external view returns (uint8)
```



*Returns the decimals places of the token.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint8 | undefined |

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

### initialize

```solidity
function initialize(bytes policy, string name, string symbol) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| policy | bytes | undefined |
| name | string | undefined |
| symbol | string | undefined |

### meetsPolicy

```solidity
function meetsPolicy(uint256 tokenId) external view returns (bool isEligible)
```

Checks if a given Jasmine EAT token meets the pool&#39;s deposit policy 



#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | Token to check pool eligibility for  |

#### Returns

| Name | Type | Description |
|---|---|---|
| isEligible | bool | True if token meets policy and may be deposited. False otherwise. |

### name

```solidity
function name() external view returns (string)
```



*Returns the name of the token.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### policyForVersion

```solidity
function policyForVersion(uint8 metadataVersion) external view returns (bytes policy)
```

Get a pool&#39;s deposit policy for a given metadata version 



#### Parameters

| Name | Type | Description |
|---|---|---|
| metadataVersion | uint8 | Version of metadata to return policy for  |

#### Returns

| Name | Type | Description |
|---|---|---|
| policy | bytes | Deposit policy for given metadata version |

### retire

```solidity
function retire(address from, address beneficiary, uint256 amount, bytes data) external nonpayable
```

Burns &#39;quantity&#39; of tokens from &#39;owner&#39; in the name of &#39;beneficiary&#39;. 

*Internally, calls are routed to Retirement Service to facilitate the retirement. Emits a {Retirement} event. Requirements:     - msg.sender must be approved for owner&#39;s JLTs     - Owner must have sufficient JLTs     - Owner cannot be zero address *

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | JLT owner from which to burn tokens |
| beneficiary | address | Address to receive retirement acknowledgment. If none, assume msg.sender |
| amount | uint256 | Number of JLTs to withdraw |
| data | bytes | Optional calldata to relay to retirement service via onERC1155Received  |

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

### symbol

```solidity
function symbol() external view returns (string)
```



*Returns the symbol of the token.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```



*Returns the amount of tokens in existence.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### transfer

```solidity
function transfer(address to, uint256 amount) external nonpayable returns (bool)
```



*Moves `amount` tokens from the caller&#39;s account to `to`. Returns a boolean value indicating whether the operation succeeded. Emits a {Transfer} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| to | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 amount) external nonpayable returns (bool)
```



*Moves `amount` tokens from `from` to `to` using the allowance mechanism. `amount` is then deducted from the caller&#39;s allowance. Returns a boolean value indicating whether the operation succeeded. Emits a {Transfer} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | undefined |
| to | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

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
function withdrawFrom(address spender, address recipient, uint256 quantity, bytes data) external nonpayable returns (uint256[] tokenIds, uint256[] amounts)
```

Withdraw EATs from pool by burning &#39;quantity&#39; of JLTs from &#39;owner&#39;. 

*Pool will automatically select EATs to withdraw. Defer to {withdrawSpecific}      if selecting specific EATs to withdraw is important. Requirements:     - msg.sender must be approved for owner&#39;s JLTs     - Owner must have sufficient JLTs     - If recipient is a contract, it must implement onERC1155Received &amp; onERC1155BatchReceived *

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | JLT owner from which to burn tokens |
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
function withdrawSpecific(address spender, address recipient, uint256[] tokenIds, uint256[] quantities, bytes data) external nonpayable
```

Withdraw specific EATs from pool by burning the sum of &#39;quantities&#39; in JLTs from &#39;owner&#39;. 

*Requirements:     - msg.sender must be approved for owner&#39;s JLTs     - Length of tokenIds and quantities must match     - Owner must have more JLTs than sum of quantities     - If recipient is a contract, it must implement onERC1155Received &amp; onERC1155BatchReceived     - Owner and Recipient cannot be zero address *

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | JLT owner from which to burn tokens |
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



## Events

### Approval

```solidity
event Approval(address indexed owner, address indexed spender, uint256 value)
```



*Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}. `value` is the new allowance.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner `indexed` | address | undefined |
| spender `indexed` | address | undefined |
| value  | uint256 | undefined |

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

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 value)
```



*Emitted when `value` tokens are moved from one account (`from`) to another (`to`). Note that `value` may be zero.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| value  | uint256 | undefined |

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



## Errors

### Unqualified

```solidity
error Unqualified(uint256 tokenId)
```



*Emitted if a token does not meet pool&#39;s deposit policy*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |


