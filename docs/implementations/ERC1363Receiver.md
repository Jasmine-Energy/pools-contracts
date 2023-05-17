# ERC1363Receiver

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> ERC-1363 Receiver

Implementation of ERC-1363 Receiver



## Methods

### onTransferReceived

```solidity
function onTransferReceived(address, address, uint256, bytes) external nonpayable returns (bytes4)
```

Handle the receipt of ERC1363 tokens

*Any ERC1363 smart contract calls this function on the recipient after a `transfer` or a `transferFrom`. This function MAY throw to revert and reject the transfer. Return of other than the magic value MUST result in the transaction being reverted. Note: the token contract address is always the message sender.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |
| _1 | address | undefined |
| _2 | uint256 | undefined |
| _3 | bytes | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes4 | `bytes4(keccak256(&quot;onTransferReceived(address,address,uint256,bytes)&quot;))`  unless throwing |




