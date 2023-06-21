# JasminePool

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Reference Pool

TODO: Write docs



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



*Returns the number of decimals used to get its user representation. For example, if `decimals` equals `2`, a balance of `505` tokens should be displayed to a user as `5.05` (`505 / 10 ** 2`). Tokens usually opt for a value of 18, imitating the relationship between Ether and Wei. This is the default value returned by this function, unless it&#39;s overridden. NOTE: This information is only used for _display_ purposes: it in no way affects any of the arithmetic of the contract, including {IERC20-balanceOf} and {IERC20-transfer}.*


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

Used to deposit EATs into the pool to receive JLTs. 

*Requirements:     - Pool must be an approved operator of from address *

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | EAT token ID to deposit |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| jltQuantity | uint256 | Number of JLTs issued for deposit  Emits a {Deposit} event. |

### depositBatch

```solidity
function depositBatch(address from, uint256[] tokenIds, uint256[] amounts) external nonpayable returns (uint256 jltQuantity)
```

Used to deposit numerous EATs of different IDs into the pool to receive JLTs. 

*Requirements:     - Pool must be an approved operator of from address     - Lenght of tokenIds and quantities must match *

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | Address from which to transfer EATs to pool |
| tokenIds | uint256[] | EAT token IDs to deposit |
| amounts | uint256[] | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| jltQuantity | uint256 | Number of JLTs issued for deposit  Emits a {Deposit} event. |

### depositFrom

```solidity
function depositFrom(address from, uint256 tokenId, uint256 amount) external nonpayable returns (uint256 jltQuantity)
```

Used to deposit EATs from another account into the pool to receive JLTs. 

*Requirements:     - Pool must be an approved operator of from address     - msg.sender must be approved for the user&#39;s tokens *

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | Address from which to transfer EATs to pool |
| tokenId | uint256 | EAT token ID to deposit |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| jltQuantity | uint256 | Number of JLTs issued for deposit  Emits a {Deposit} event. |

### eat

```solidity
function eat() external view returns (contract JasmineEAT)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasmineEAT | undefined |

### eip712Domain

```solidity
function eip712Domain() external view returns (bytes1 fields, string name, string version, uint256 chainId, address verifyingContract, bytes32 salt, uint256[] extensions)
```



*See {EIP-5267}. _Available since v4.9._*


#### Returns

| Name | Type | Description |
|---|---|---|
| fields | bytes1 | undefined |
| name | string | undefined |
| version | string | undefined |
| chainId | uint256 | undefined |
| verifyingContract | address | undefined |
| salt | bytes32 | undefined |
| extensions | uint256[] | undefined |

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

### initialize

```solidity
function initialize(bytes policy_, string name_, string symbol_) external nonpayable
```



*Initializer function for proxy deployments to call. Requirements:     - Caller must be factory*

#### Parameters

| Name | Type | Description |
|---|---|---|
| policy_ | bytes | Deposit Policy Conditions |
| name_ | string | JLT token name |
| symbol_ | string | JLT token symbol |

### meetsPolicy

```solidity
function meetsPolicy(uint256 tokenId) external view returns (bool isEligible)
```



*Checks if a token is eligible for deposit into the pool based on the      pool&#39;s Deposit Policy. *

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | EAT token ID to check eligibility |

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

### oracle

```solidity
function oracle() external view returns (contract JasmineOracle)
```



*Jasmine Oracle contract*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasmineOracle | undefined |

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

### rebalanceDeposits

```solidity
function rebalanceDeposits(uint256 amount) external nonpayable
```



*Used to rebalance a pool&#39;s deposit discrepancies between EAT deposits and JLTs issued*

#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | undefined |

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

### retirementService

```solidity
function retirementService() external view returns (address)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

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

*Appends token symbol to end of base URI*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### totalDeposits

```solidity
function totalDeposits() external view returns (uint256)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

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

Withdraw EATs from pool by burning &#39;quantity&#39; of JLTs from &#39;owner&#39;. 

*Pool will automatically select EATs to withdraw. Defer to {withdrawSpecific}      if selecting specific EATs to withdraw is important. Requirements:     - msg.sender must have sufficient JLTs     - If recipient is a contract, it must implement onERC1155Received &amp; onERC1155BatchReceived *

#### Parameters

| Name | Type | Description |
|---|---|---|
| recipient | address | Address to receive withdrawn EATs |
| amount | uint256 | undefined |
| data | bytes | Optional calldata to relay to recipient via onERC1155Received  |

#### Returns

| Name | Type | Description |
|---|---|---|
| tokenIds | uint256[] | Token IDs withdrawn from the pool |
| amounts | uint256[] | Number of tokens withdraw, per ID, from the pool  Emits a {Withdraw} event. |

### withdrawFrom

```solidity
function withdrawFrom(address sender, address recipient, uint256 amount, bytes data) external nonpayable returns (uint256[] tokenIds, uint256[] amounts)
```

Withdraw EATs from pool by burning &#39;quantity&#39; of JLTs from &#39;owner&#39;. 

*Pool will automatically select EATs to withdraw. Defer to {withdrawSpecific}      if selecting specific EATs to withdraw is important. Requirements:     - msg.sender must be approved for owner&#39;s JLTs     - Owner must have sufficient JLTs     - If recipient is a contract, it must implement onERC1155Received &amp; onERC1155BatchReceived *

#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | undefined |
| recipient | address | Address to receive withdrawn EATs |
| amount | uint256 | undefined |
| data | bytes | Optional calldata to relay to recipient via onERC1155Received  |

#### Returns

| Name | Type | Description |
|---|---|---|
| tokenIds | uint256[] | Token IDs withdrawn from the pool |
| amounts | uint256[] | Number of tokens withdraw, per ID, from the pool  Emits a {Withdraw} event. |

### withdrawSpecific

```solidity
function withdrawSpecific(address sender, address recipient, uint256[] tokenIds, uint256[] amounts, bytes data) external nonpayable
```

Withdraw specific EATs from pool by burning the sum of &#39;quantities&#39; in JLTs from &#39;owner&#39;. 

*Requirements:     - msg.sender must be approved for owner&#39;s JLTs     - Length of tokenIds and quantities must match     - Owner must have more JLTs than sum of quantities     - If recipient is a contract, it must implement onERC1155Received &amp; onERC1155BatchReceived     - Owner and Recipient cannot be zero address *

#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | undefined |
| recipient | address | Address to receive withdrawn EATs |
| tokenIds | uint256[] | EAT token IDs to withdraw from pool |
| amounts | uint256[] | undefined |
| data | bytes | Optional calldata to relay to recipient via onERC1155Received  Emits a {Withdraw} event. |

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

### EIP712DomainChanged

```solidity
event EIP712DomainChanged()
```






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





#### Parameters

| Name | Type | Description |
|---|---|---|
| retirementFeeBips  | uint96 | undefined |
| beneficiary `indexed` | address | undefined |

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





#### Parameters

| Name | Type | Description |
|---|---|---|
| withdrawFeeBips  | uint96 | undefined |
| beneficiary `indexed` | address | undefined |



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


### InvalidShortString

```solidity
error InvalidShortString()
```






### InvalidTokenAddress

```solidity
error InvalidTokenAddress(address received, address expected)
```



*Emitted if tokens (ERC-1155) are received from incorrect contract*

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

### StringTooLong

```solidity
error StringTooLong(string str)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| str | string | undefined |

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

### ValidationFailed

```solidity
error ValidationFailed()
```



*Emitted if internal validation failed*


### WithdrawsLocked

```solidity
error WithdrawsLocked()
```



*Emitted if withdraws are locked*



