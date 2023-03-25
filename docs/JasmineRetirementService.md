# JasmineRetirementService









## Methods

### onERC1155BatchReceived

```solidity
function onERC1155BatchReceived(address operator, address from, uint256[] ids, uint256[] values, bytes data) external nonpayable returns (bytes4)
```



*Handles the receipt of a multiple ERC1155 token types. This function is called at the end of a `safeBatchTransferFrom` after the balances have been updated. NOTE: To accept the transfer(s), this must return `bytes4(keccak256(&quot;onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)&quot;))` (i.e. 0xbc197c81, or its own function selector).*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | The address which initiated the batch transfer (i.e. msg.sender) |
| from | address | The address which previously owned the token |
| ids | uint256[] | An array containing ids of each token being transferred (order and length must match values array) |
| values | uint256[] | An array containing amounts of each token being transferred (order and length must match ids array) |
| data | bytes | Additional data with no specified format |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | `bytes4(keccak256(&quot;onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)&quot;))` if transfer is allowed |

### onERC1155Received

```solidity
function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes data) external nonpayable returns (bytes4)
```



*Handles the receipt of a single ERC1155 token type. This function is called at the end of a `safeTransferFrom` after the balance has been updated. NOTE: To accept the transfer, this must return `bytes4(keccak256(&quot;onERC1155Received(address,address,uint256,uint256,bytes)&quot;))` (i.e. 0xf23a6e61, or its own function selector).*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | The address which initiated the transfer (i.e. msg.sender) |
| from | address | The address which previously owned the token |
| id | uint256 | The ID of the token being transferred |
| value | uint256 | The amount of tokens being transferred |
| data | bytes | Additional data with no specified format |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | `bytes4(keccak256(&quot;onERC1155Received(address,address,uint256,uint256,bytes)&quot;))` if transfer is allowed |

### registerRetirementRecipient

```solidity
function registerRetirementRecipient(address holder, address recipient) external nonpayable
```

Allows user to designate an address to receive retirement hooks.

*Contract must implement IRetirementRecipient&#39;s onRetirement function*

#### Parameters

| Name | Type | Description |
|---|---|---|
| holder | address | User address to notify recipient address of retirements |
| recipient | address | Smart contract to receive retirement hooks. Address must implement IRetirementRecipient interface. |

### requestResidualJLT

```solidity
function requestResidualJLT(address pool) external nonpayable returns (bool success)
```



*Called by pools for fractional retirements*

#### Parameters

| Name | Type | Description |
|---|---|---|
| pool | address | address of pool requesting residual JLTs |

#### Returns

| Name | Type | Description |
|---|---|---|
| success | bool | True if residual JLTs sent, false if ineligible |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*Returns true if this contract implements the interface defined by `interfaceId`. See the corresponding https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section] to learn more about how these ids are created. This function call must use less than 30 000 gas.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### tokensReceived

```solidity
function tokensReceived(address operator, address from, address to, uint256 amount, bytes userData, bytes operatorData) external nonpayable
```



*Called by an {IERC777} token contract whenever tokens are being moved or created into a registered account (`to`). The type of operation is conveyed by `from` being the zero address or not. This call occurs _after_ the token contract&#39;s state is updated, so {IERC777-balanceOf}, etc., can be used to query the post-operation state. This function may revert to prevent the operation from being executed.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| operator | address | undefined |
| from | address | undefined |
| to | address | undefined |
| amount | uint256 | undefined |
| userData | bytes | undefined |
| operatorData | bytes | undefined |




