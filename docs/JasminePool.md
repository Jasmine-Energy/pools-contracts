# JasminePool

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Reference Pool

TODO: Write docs



## Methods

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
function allowance(address holder, address spender) external view returns (uint256)
```



*See {IERC20-allowance}. Note that operator and allowance concepts are orthogonal: operators may not have allowance, and accounts with allowance may not be operators themselves.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| holder | address | undefined |
| spender | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### approve

```solidity
function approve(address spender, uint256 value) external nonpayable returns (bool)
```



*See {IERC20-approve}. NOTE: If `value` is the maximum `uint256`, the allowance is not updated on `transferFrom`. This is semantically equivalent to an infinite approval. Note that accounts cannot have allowance issued by their operators.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| spender | address | undefined |
| value | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### authorizeOperator

```solidity
function authorizeOperator(address operator) external nonpayable
```



*See {IERC777-authorizeOperator}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |

### balanceOf

```solidity
function balanceOf(address tokenHolder) external view returns (uint256)
```



*Returns the amount of tokens owned by an account (`tokenHolder`).*

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenHolder | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### burn

```solidity
function burn(uint256 amount, bytes data) external nonpayable
```



*See {IERC777-burn}. Also emits a {IERC20-Transfer} event for ERC20 compatibility.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| amount | uint256 | undefined |
| data | bytes | undefined |

### decimals

```solidity
function decimals() external pure returns (uint8)
```



*See {ERC20-decimals}. Always returns 18, as per the [ERC777 EIP](https://eips.ethereum.org/EIPS/eip-777#backward-compatibility).*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint8 | undefined |

### defaultOperators

```solidity
function defaultOperators() external view returns (address[])
```



*See {IERC777-defaultOperators}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address[] | undefined |

### deposit

```solidity
function deposit(uint256 tokenId, uint256 amount) external nonpayable returns (bool success, uint256 jltQuantity)
```

Used to deposit EATs into the pool. 

*Requirements:     - Pool must be an approved operator of caller&#39;s EATs     - Caller must hold tokenId and have balance greater than or equal to amount *

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | ID of EAT to deposit into pool |
| amount | uint256 | Number of EATs to deposit |

#### Returns

| Name | Type | Description |
|---|---|---|
| success | bool | Whether deposit was successful |
| jltQuantity | uint256 | Number of JLTs issued |

### depositBatch

```solidity
function depositBatch(address from, uint256[] tokenIds, uint256[] amounts) external nonpayable returns (bool success, uint256 jltQuantity)
```

 

*Requirements: *

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | Address from which EATs will be transfered |
| tokenIds | uint256[] | IDs of EAT to deposit into pool |
| amounts | uint256[] | Number of EATs to deposit |

#### Returns

| Name | Type | Description |
|---|---|---|
| success | bool | Whether deposit was successful |
| jltQuantity | uint256 | Number of JLTs issued |

### granularity

```solidity
function granularity() external view returns (uint256)
```



*See {IERC777-granularity}. This implementation always returns `1`.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

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

### isOperatorFor

```solidity
function isOperatorFor(address operator, address tokenHolder) external view returns (bool)
```



*See {IERC777-isOperatorFor}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |
| tokenHolder | address | undefined |

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



*See {IERC777-name}*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address, address from, uint256[] tokenIds, uint256[] values, bytes data) external nonpayable returns (bytes4)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| from | address | undefined |
| tokenIds | uint256[] | undefined |
| values | uint256[] | undefined |
| data | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

### onERC1155Received

```solidity
function onERC1155Received(address, address from, uint256 tokenId, uint256 value, bytes data) external nonpayable returns (bytes4)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| from | address | undefined |
| tokenId | uint256 | undefined |
| value | uint256 | undefined |
| data | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | undefined |

### operatorBurn

```solidity
function operatorBurn(address account, uint256 amount, bytes data, bytes operatorData) external nonpayable
```



*See {IERC777-operatorBurn}. Emits {Burned} and {IERC20-Transfer} events.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| amount | uint256 | undefined |
| data | bytes | undefined |
| operatorData | bytes | undefined |

### operatorDeposit

```solidity
function operatorDeposit(address from, uint256 tokenId, uint256 amount) external nonpayable returns (bool success, uint256 jltQuantity)
```

Used to deposit EATs on behalf of another address into the pool. 

*Requirements:     - Pool must be an approved operator of from&#39;s EATs     - Caller must be an approved operator of from&#39;s EATs     - From account must hold tokenId and have balance greater than or equal to amount *

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | Address from which EATs will be transfered |
| tokenId | uint256 | ID of EAT to deposit into pool |
| amount | uint256 | Number of EATs to deposit |

#### Returns

| Name | Type | Description |
|---|---|---|
| success | bool | Whether deposit was successful |
| jltQuantity | uint256 | Number of JLTs issued |

### operatorSend

```solidity
function operatorSend(address sender, address recipient, uint256 amount, bytes data, bytes operatorData) external nonpayable
```



*See {IERC777-operatorSend}. Emits {Sent} and {IERC20-Transfer} events.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | undefined |
| recipient | address | undefined |
| amount | uint256 | undefined |
| data | bytes | undefined |
| operatorData | bytes | undefined |

### operatorWithdraw

```solidity
function operatorWithdraw(address sender, address recipient, uint256 amount, bytes data) external nonpayable returns (bool success)
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
| success | bool | undefined |

### oracle

```solidity
function oracle() external view returns (contract JasmineOracle)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract JasmineOracle | undefined |

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
function retire(address sender, address beneficiary, uint256 quantity, bytes data) external nonpayable returns (bool success)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| sender | address | undefined |
| beneficiary | address | undefined |
| quantity | uint256 | undefined |
| data | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| success | bool | undefined |

### revokeOperator

```solidity
function revokeOperator(address operator) external nonpayable
```



*See {IERC777-revokeOperator}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |

### send

```solidity
function send(address recipient, uint256 amount, bytes data) external nonpayable
```



*See {IERC777-send}. Also emits a {IERC20-Transfer} event for ERC20 compatibility.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| recipient | address | undefined |
| amount | uint256 | undefined |
| data | bytes | undefined |

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



*See {IERC777-symbol}*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### tokenURI

```solidity
function tokenURI() external view returns (string)
```



*See {IERC1046-tokenURI}*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | string | undefined |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```



*See {IERC777-totalSupply}.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### transfer

```solidity
function transfer(address recipient, uint256 amount) external nonpayable returns (bool)
```



*See {IERC20-transfer}. Unlike `send`, `recipient` is _not_ required to implement the {IERC777Recipient} interface if it is a contract. Also emits a {Sent} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| recipient | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### transferFrom

```solidity
function transferFrom(address holder, address recipient, uint256 amount) external nonpayable returns (bool)
```



*See {IERC20-transferFrom}. NOTE: Does not update the allowance if the current allowance is the maximum `uint256`. Note that operator and allowance concepts are orthogonal: operators cannot call `transferFrom` (unless they have allowance), and accounts with allowance cannot call `operatorSend` (unless they are operators). Emits {Sent}, {IERC20-Transfer} and {IERC20-Approval} events.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| holder | address | undefined |
| recipient | address | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### withdraw

```solidity
function withdraw(address recipient, uint256 amount, bytes data) external nonpayable returns (bool success)
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
| success | bool | undefined |

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

### AuthorizedOperator

```solidity
event AuthorizedOperator(address indexed operator, address indexed tokenHolder)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| tokenHolder `indexed` | address | undefined |

### Burned

```solidity
event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| amount  | uint256 | undefined |
| data  | bytes | undefined |
| operatorData  | bytes | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### Minted

```solidity
event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| to `indexed` | address | undefined |
| amount  | uint256 | undefined |
| data  | bytes | undefined |
| operatorData  | bytes | undefined |

### RevokedOperator

```solidity
event RevokedOperator(address indexed operator, address indexed tokenHolder)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| tokenHolder `indexed` | address | undefined |

### Sent

```solidity
event Sent(address indexed operator, address indexed from, address indexed to, uint256 amount, bytes data, bytes operatorData)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| operator `indexed` | address | undefined |
| from `indexed` | address | undefined |
| to `indexed` | address | undefined |
| amount  | uint256 | undefined |
| data  | bytes | undefined |
| operatorData  | bytes | undefined |

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



## Errors

### Unqualified

```solidity
error Unqualified(uint256 tokenId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | undefined |


