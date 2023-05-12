# JasmineFeePool

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Fee Pool

Extends JasmineBasePool with withdrawal and retirement fees managed by         a universal admin entity.



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
function decimals() external view returns (uint8)
```



*Returns the number of decimals used to get its user representation. For example, if `decimals` equals `2`, a balance of `505` tokens should be displayed to a user as `5.05` (`505 / 10 ** 2`). Tokens usually opt for a value of 18, imitating the relationship between Ether and Wei. This is the value {ERC20} uses, unless this function is overridden; NOTE: This information is only used for _display_ purposes: it in no way affects any of the arithmetic of the contract, including {IERC20-balanceOf} and {IERC20-transfer}.*


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

### minter

```solidity
function minter() external view returns (contract JasmineMinter)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasmineMinter | undefined |

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
function onERC1155BatchReceived(address, address from, uint256[] tokenIds, uint256[] values, bytes) external nonpayable returns (bytes4)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| from | address | undefined |
| tokenIds | uint256[] | undefined |
| values | uint256[] | undefined |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

### onERC1155Received

```solidity
function onERC1155Received(address, address from, uint256 tokenId, uint256 value, bytes) external nonpayable returns (bytes4)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| from | address | undefined |
| tokenId | uint256 | undefined |
| value | uint256 | undefined |
| _4 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

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

Cost of retiring JLTs from pool including retirement fees. 



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

Returns the pool&#39;s JLT retirement rate in basis points 

*If pool&#39;s retirement rate is not set, defer to pool factory&#39;s base rate *


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | Retirement rate in basis points |

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

### updateRetirementRate

```solidity
function updateRetirementRate(uint96 newRetirementRate) external nonpayable
```

Allows pool fee managers to update the retirement rate 

*Requirements:     - Caller must have fee manager role - in pool factory emits RetirementRateUpdate *

#### Parameters

| Name | Type | Description |
|---|---|---|
| newRetirementRate | uint96 | New rate on retirements in basis points |

### updateWithdrawalRate

```solidity
function updateWithdrawalRate(uint96 newWithdrawalRate) external nonpayable
```

Allows pool fee managers to update the withdrawal rate 

*Requirements:     - Caller must have fee manager role - in pool factory emits WithdrawalRateUpdate *

#### Parameters

| Name | Type | Description |
|---|---|---|
| newWithdrawalRate | uint96 | New rate on withdrawals in basis points |

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

Cost of withdrawing amount of tokens from pool where pool         selects the tokens to withdraw, including withdrawal fee. 



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

Cost of withdrawing specified amounts of tokens from pool including         withdrawal fee. 



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

Returns the pool&#39;s JLT withdrawal rate in basis points 

*If pool&#39;s withdrawal rate is not set, defer to pool factory&#39;s base rate *


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | Withdrawal fee in basis points |

### withdrawalSpecificRate

```solidity
function withdrawalSpecificRate() external view returns (uint96)
```

Returns the pool&#39;s JLT withdrawal rate for withdrawing specific tokens,         in basis points 

*If pool&#39;s specific withdrawal rate is not set, defer to pool factory&#39;s base rate *


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | Withdrawal fee in basis points |



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





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| owner `indexed` | address | undefined |
| quantity  | uint256 | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### Retirement

```solidity
event Retirement(address indexed operator, address indexed beneficiary, uint256 quantity)
```

emitted when tokens from a pool are retired 



#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| beneficiary `indexed` | address | undefined |
| quantity  | uint256 | undefined |

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





#### Parameters

| Name | Type | Description |
|---|---|---|
| sender `indexed` | address | undefined |
| receiver `indexed` | address | undefined |
| quantity  | uint256 | undefined |

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



## Errors

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


### InsufficientDeposits

```solidity
error InsufficientDeposits()
```






### InvalidInput

```solidity
error InvalidInput()
```



*Emitted if input is invalid*


### InvalidTokenAddress

```solidity
error InvalidTokenAddress(address received, address expected)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| received | address | undefined |
| expected | address | undefined |

### Prohibited

```solidity
error Prohibited()
```



*Emitted for unauthorized actions*


### RequiresRole

```solidity
error RequiresRole(bytes32 role)
```



*Emitted if access control check fails*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |

### Unqualified

```solidity
error Unqualified(uint256 tokenId)
```



*Emitted if a token does not meet pool&#39;s deposit policy*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |

### UnsupportedMetadataVersion

```solidity
error UnsupportedMetadataVersion(uint8 metadataVersion)
```



*Emitted if contract does not support metadata version*

#### Parameters

| Name | Type | Description |
|---|---|---|
| metadataVersion | uint8 | undefined |

### WithdrawsLocked

```solidity
error WithdrawsLocked()
```







