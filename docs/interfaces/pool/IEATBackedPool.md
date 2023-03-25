# IEATBackedPool

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> EAT Backed Pool Interface

Contains functionality and events for pools which issue JLTs for EATs         deposits and permit withdrawals of EATs.

*Due to linearization issues, ERC-20 and ERC-1155 Receiver are not enforced      conformances - but likely should be.*

## Methods

### deposit

```solidity
function deposit(address from, uint256 tokenId, uint256 quantity) external nonpayable returns (bool success, uint256 jltQuantity)
```

Used to deposit EATs into the pool to receive JLTs.

*Requirements:     - Pool must be an approved operator of from address *

#### Parameters

| Name | Type | Description |
|---|---|---|
| from | address | Address from which to transfer EATs to pool |
| tokenId | uint256 | EAT token ID to deposit |
| quantity | uint256 | Number of EATs for given tokenId to deposit  |

#### Returns

| Name | Type | Description |
|---|---|---|
| success | bool | If deposit operation was successful, true will be returned |
| jltQuantity | uint256 | Number of JLTs issued for deposit  Emits a {Deposit} event. |

### depositBatch

```solidity
function depositBatch(address from, uint256[] tokenIds, uint256[] quantities) external nonpayable returns (bool success, uint256 jltQuantity)
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
| success | bool | If deposit operation was successful, true will be returned |
| jltQuantity | uint256 | Number of JLTs issued for deposit  Emits a {Deposit} event. |

### withdraw

```solidity
function withdraw(address owner, address recipient, uint256 quantity, bytes data) external nonpayable returns (bool success)
```

Withdraw EATs from pool by burning &#39;quantity&#39; of JLTs from &#39;owner&#39;. 

*Pool will automatically select EATs to withdraw. Defer to {withdrawSpecific}      if selecting specific EATs to withdraw is important. Requirements:     - msg.sender must be approved for owner&#39;s JLTs     - Owner must have sufficient JLTs     - If recipient is a contract, it must implement onERC1155Received &amp; onERC1155BatchReceived     - Owner and Recipient cannot be zero address *

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
| success | bool | If withdraw operation was successful, true will be returned  Emits a {Withdraw} event. |

### withdrawSpecific

```solidity
function withdrawSpecific(address owner, address recipient, uint256[] tokenIds, uint256[] quantities, bytes data) external nonpayable returns (bool success)
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
| data | bytes | Optional calldata to relay to recipient via onERC1155Received  |

#### Returns

| Name | Type | Description |
|---|---|---|
| success | bool | If withdraw operation was successful, true will be returned  Emits a {Withdraw} event. |



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



