# ArrayUtils

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Array Utilities

Utility library for interacting with arrays



## Methods

### fill

```solidity
function fill(address repeatedAddress, uint256 amount) external pure returns (address[] filledArray)
```



*Creates an array of `repeatedAddress` with `amount` occurences. NOTE: Useful for ERC1155.balanceOfBatch *

#### Parameters

| Name | Type | Description |
|---|---|---|
| repeatedAddress | address | Input address to duplicate |
| amount | uint256 | Number of times to duplicate |

#### Returns

| Name | Type | Description |
|---|---|---|
| filledArray | address[] | Array of length `amount` containing `repeatedAddress` |

### sum

```solidity
function sum(uint256[] inputs) external pure returns (uint256 total)
```



*Sums all elements in an array *

#### Parameters

| Name | Type | Description |
|---|---|---|
| inputs | uint256[] | Array of numbers to sum |

#### Returns

| Name | Type | Description |
|---|---|---|
| total | uint256 | The sum of all elements |




