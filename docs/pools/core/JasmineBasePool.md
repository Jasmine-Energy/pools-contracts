# JasmineBasePool

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Base Pool

Jasmine&#39;s Base Pool contract which other pools extend as needed



## Methods

### DOMAIN_SEPARATOR

```solidity
function DOMAIN_SEPARATOR() external view returns (bytes32)
```



*See {IERC20Permit-DOMAIN_SEPARATOR}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### EAT

```solidity
function EAT() external view returns (contract JasmineEAT)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasmineEAT | undefined |

### allowance

```solidity
function allowance(address owner, address spender) external view returns (uint256)
```



*See {IERC20-allowance}.*

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



*See {IERC20-approve}. NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on `transferFrom`. This is semantically equivalent to an infinite approval. Requirements: - `spender` cannot be the zero address.*

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



*See {ERC20-balanceOf}*

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
function decimals() external pure returns (uint8)
```



*See {IERC20Metadata-decimals}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint8 | undefined |

### decreaseAllowance

```solidity
function decreaseAllowance(address spender, uint256 subtractedValue) external nonpayable returns (bool)
```



*Atomically decreases the allowance granted to `spender` by the caller. This is an alternative to {approve} that can be used as a mitigation for problems described in {IERC20-approve}. Emits an {Approval} event indicating the updated allowance. Requirements: - `spender` cannot be the zero address. - `spender` must have allowance for the caller of at least `subtractedValue`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| subtractedValue | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### deposit

```solidity
function deposit(uint256 tokenId, uint256 amount) external nonpayable returns (uint256 jltQuantity)
```

Used to deposit EATs into the pool. 

*Requirements:     - Pool must be an approved operator of caller&#39;s EATs     - Caller must hold tokenId and have balance greater than or equal to amount *

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | ID of EAT to deposit into pool |
| amount | uint256 | Number of EATs to deposit  |

#### Returns

| Name | Type | Description |
|---|---|---|
| jltQuantity | uint256 | Number of JLTs issued |

### depositBatch

```solidity
function depositBatch(address from, uint256[] tokenIds, uint256[] amounts) external nonpayable returns (uint256 jltQuantity)
```

 

*Requirements: *

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | Address from which EATs will be transfered |
| tokenIds | uint256[] | IDs of EAT to deposit into pool |
| amounts | uint256[] | Number of EATs to deposit  |

#### Returns

| Name | Type | Description |
|---|---|---|
| jltQuantity | uint256 | Number of JLTs issued |

### increaseAllowance

```solidity
function increaseAllowance(address spender, uint256 addedValue) external nonpayable returns (bool)
```



*Atomically increases the allowance granted to `spender` by the caller. This is an alternative to {approve} that can be used as a mitigation for problems described in {IERC20-approve}. Emits an {Approval} event indicating the updated allowance. Requirements: - `spender` cannot be the zero address.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| addedValue | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### meetsPolicy

```solidity
function meetsPolicy(uint256 tokenId) external view returns (bool isEligible)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| isEligible | bool | undefined |

### name

```solidity
function name() external view returns (string)
```



*See {IERC20Metadata-name}*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### nonces

```solidity
function nonces(address owner) external view returns (uint256)
```



*See {IERC20Permit-nonces}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address operator, address from, uint256[] tokenIds, uint256[] values, bytes) external nonpayable returns (bytes4)
```



*Handles the receipt of a multiple ERC1155 token types. This function is called at the end of a `safeBatchTransferFrom` after the balances have been updated. NOTE: To accept the transfer(s), this must return `bytes4(keccak256(&quot;onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)&quot;))` (i.e. 0xbc197c81, or its own function selector).*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | The address which initiated the batch transfer (i.e. msg.sender) |
| from | address | The address which previously owned the token |
| tokenIds | uint256[] | undefined |
| values | uint256[] | An array containing amounts of each token being transferred (order and length must match ids array) |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | `bytes4(keccak256(&quot;onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)&quot;))` if transfer is allowed |

### onERC1155Received

```solidity
function onERC1155Received(address operator, address from, uint256 tokenId, uint256 value, bytes) external nonpayable returns (bytes4)
```



*Handles the receipt of a single ERC1155 token type. This function is called at the end of a `safeTransferFrom` after the balance has been updated. NOTE: To accept the transfer, this must return `bytes4(keccak256(&quot;onERC1155Received(address,address,uint256,uint256,bytes)&quot;))` (i.e. 0xf23a6e61, or its own function selector).*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | The address which initiated the transfer (i.e. msg.sender) |
| from | address | The address which previously owned the token |
| tokenId | uint256 | undefined |
| value | uint256 | The amount of tokens being transferred |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | `bytes4(keccak256(&quot;onERC1155Received(address,address,uint256,uint256,bytes)&quot;))` if transfer is allowed |

### operatorDeposit

```solidity
function operatorDeposit(address from, uint256 tokenId, uint256 amount) external nonpayable returns (uint256 jltQuantity)
```

Used to deposit EATs on behalf of another address into the pool. 

*Requirements:     - Pool must be an approved operator of from&#39;s EATs     - Caller must be an approved operator of from&#39;s EATs     - From account must hold tokenId and have balance greater than or equal to amount *

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | Address from which EATs will be transfered |
| tokenId | uint256 | ID of EAT to deposit into pool |
| amount | uint256 | Number of EATs to deposit  |

#### Returns

| Name | Type | Description |
|---|---|---|
| jltQuantity | uint256 | Number of JLTs issued TODO: Rename from operator deposit |

### operatorWithdraw

```solidity
function operatorWithdraw(address sender, address recipient, uint256 amount, bytes data) external nonpayable returns (uint256[] tokenIds, uint256[] amounts)
```

Used to convert JLTs from sender into EATs which are sent         to recipient. 

*Requirements:     - Caller must be approved operator for sender     - Sender must have sufficient JLTs     - If recipient is a contract, must implements ERC1155Receiver *

#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | Account to which will have JLTs burned |
| recipient | address | Address to receive EATs |
| amount | uint256 | Number of JLTs to burn and EATs to withdraw |
| data | bytes | Optional calldata to forward to recipient |

#### Returns

| Name | Type | Description |
|---|---|---|
| tokenIds | uint256[] | undefined |
| amounts | uint256[] | undefined |

### permit

```solidity
function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external nonpayable
```



*See {IERC20Permit-permit}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |
| spender | address | undefined |
| value | uint256 | undefined |
| deadline | uint256 | undefined |
| v | uint8 | undefined |
| r | bytes32 | undefined |
| s | bytes32 | undefined |

### policyForVersion

```solidity
function policyForVersion(uint8 metadataVersion) external view returns (bytes policy)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| metadataVersion | uint8 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| policy | bytes | undefined |

### poolFactory

```solidity
function poolFactory() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### retire

```solidity
function retire(address owner, address beneficiary, uint256 amount, bytes data) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |
| beneficiary | address | undefined |
| amount | uint256 | undefined |
| data | bytes | undefined |

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

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*See {IERC165-supportsInterface}*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### symbol

```solidity
function symbol() external view returns (string)
```



*See {IERC20Metadata-symbol}*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### tokenURI

```solidity
function tokenURI() external view returns (string)
```

Gets an ERC-721-like token URI

*The resolved data MUST be in JSON format and           support ERC-1046&#39;s ERC-20 Token Metadata Schema*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```



*See {ERC20-totalSupply}*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### transfer

```solidity
function transfer(address to, uint256 amount) external nonpayable returns (bool)
```



*See {IERC20-transfer}. Requirements: - `to` cannot be the zero address. - the caller must have a balance of at least `amount`.*

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



*See {IERC20-transferFrom}. Emits an {Approval} event indicating the updated allowance. This is not required by the EIP. See the note at the beginning of {ERC20}. NOTE: Does not update the allowance if the current allowance is the maximum `uint256`. Requirements: - `from` and `to` cannot be the zero address. - `from` must have a balance of at least `amount`. - the caller must have allowance for ``from``&#39;s tokens of at least `amount`.*

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
function withdraw(address recipient, uint256 amount, bytes data) external nonpayable returns (uint256[] tokenIds, uint256[] amounts)
```

Used to convert JLTs into EATs. Withdraws JLTs from caller. To withdraw         from an alternate address - that the caller&#39;s approved for -          defer to operatorWithdraw. 

*Requirements:     - Caller must have sufficient JLTs     - If recipient is a contract, must implements ERC1155Receiver *

#### Parameters

| Name | Type | Description |
|---|---|---|
| recipient | address | Address to receive EATs |
| amount | uint256 | Number of JLTs to burn and EATs to withdraw |
| data | bytes | Optional calldata to forward to recipient |

#### Returns

| Name | Type | Description |
|---|---|---|
| tokenIds | uint256[] | undefined |
| amounts | uint256[] | undefined |

### withdrawSpecific

```solidity
function withdrawSpecific(address sender, address recipient, uint256[] tokenIds, uint256[] amounts, bytes data) external nonpayable
```

Used to withdraw specific EATs held by pool by burning         JLTs from sender. 

*Requirements:     - Caller must be approved operator for sender     - Sender must have sufficient JLTs     - If recipient is a contract, must implements ERC1155Receiver     - Length of token IDs and amounts must match     - Pool must hold all token IDs specified *

#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | Account to which will have JLTs burned |
| recipient | address | Address to receive EATs |
| tokenIds | uint256[] | EAT token IDs to withdraw |
| amounts | uint256[] | Amount of EATs to withdraw per token ID |
| data | bytes | Optional calldata to forward to recipient |

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

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 value)
```





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

### ERC1155InsufficientApproval

```solidity
error ERC1155InsufficientApproval(address operator, uint256 tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |
| tokenId | uint256 | undefined |

### ERC1155InsufficientBalance

```solidity
error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | undefined |
| balance | uint256 | undefined |
| needed | uint256 | undefined |
| tokenId | uint256 | undefined |

### ERC1155InvalidArrayLength

```solidity
error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| idsLength | uint256 | undefined |
| valuesLength | uint256 | undefined |

### ERC20InsufficientBalance

```solidity
error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | undefined |
| balance | uint256 | undefined |
| needed | uint256 | undefined |

### InbalancedDeposits

```solidity
error InbalancedDeposits()
```



*Emitted if operation would cause inbalance in pool&#39;s EAT deposits*


### InvalidInput

```solidity
error InvalidInput()
```



*Emitted if input is invalid*


### Prohibited

```solidity
error Prohibited()
```



*Emitted for unauthorized actions*


### Unqualified

```solidity
error Unqualified(uint256 tokenId)
```



*Emitted if a token does not meet pool&#39;s deposit policy*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

### ValidationFailed

```solidity
error ValidationFailed()
```



*Emitted if internal validation failed*



