# JasminePoolFactory

*Kai Aldag&lt;kai.aldag@jasmine.energy&gt;*

> Jasmine Pool Factory

Deploys new Jasmine Reference Pools, manages pool implementations and         controls fees across the Jasmine protocol



## Methods

### DEFAULT_ADMIN_ROLE

```solidity
function DEFAULT_ADMIN_ROLE() external view returns (bytes32)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### FEE_MANAGER_ROLE

```solidity
function FEE_MANAGER_ROLE() external view returns (bytes32)
```



*Access control roll for pool fee management*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### POOL_MANAGER_ROLE

```solidity
function POOL_MANAGER_ROLE() external view returns (bytes32)
```



*Access control roll for managers of pool implementations and deployments*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### USDC

```solidity
function USDC() external view returns (address)
```



*Address of USDC contract used to create UniSwap V3 pools for new JLTs*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### UniswapFactory

```solidity
function UniswapFactory() external view returns (address)
```



*Address of Uniswap V3 Factory to automatically deploy JLT liquidity pools*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### acceptOwnership

```solidity
function acceptOwnership() external nonpayable
```



*The new owner accepts the ownership transfer.*


### addPoolImplementation

```solidity
function addPoolImplementation(address newPoolImplementation) external nonpayable returns (uint256 indexInPools)
```

Used to add a new pool implementation 

*emits PoolImplementationAdded *

#### Parameters

| Name | Type | Description |
|---|---|---|
| newPoolImplementation | address | New pool implementation address to support |

#### Returns

| Name | Type | Description |
|---|---|---|
| indexInPools | uint256 | undefined |

### baseRetirementRate

```solidity
function baseRetirementRate() external view returns (uint96)
```



*Default fee for retirements across pools. May be overridden per pool*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | undefined |

### baseWithdrawalRate

```solidity
function baseWithdrawalRate() external view returns (uint96)
```



*Default fee for withdrawals across pools. May be overridden per pool*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | undefined |

### baseWithdrawalSpecificRate

```solidity
function baseWithdrawalSpecificRate() external view returns (uint96)
```



*Default fee for withdrawing specific EATs from pools. May be overridden per pool*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint96 | undefined |

### computePoolAddress

```solidity
function computePoolAddress(bytes32 policyHash) external view returns (address poolAddress)
```

Utility function to calculate deployed address of a pool from its         policy hash 

*Requirements:     - Policy hash must exist in existing pools *

#### Parameters

| Name | Type | Description |
|---|---|---|
| policyHash | bytes32 | Policy hash of pool to compute address of |

#### Returns

| Name | Type | Description |
|---|---|---|
| poolAddress | address | Address of deployed pool |

### defaultUniswapFee

```solidity
function defaultUniswapFee() external view returns (uint24)
```



*Default fee tier for Uniswap V3 pools. Default is 0.3%*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint24 | undefined |

### deployNewBasePool

```solidity
function deployNewBasePool(PoolPolicy.DepositPolicy policy, string name, string symbol) external nonpayable returns (address newPool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| policy | PoolPolicy.DepositPolicy | undefined |
| name | string | undefined |
| symbol | string | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| newPool | address | undefined |

### deployNewPool

```solidity
function deployNewPool(uint256 version, bytes4 initSelector, bytes initData, string name, string symbol) external nonpayable returns (address newPool)
```

Deploys a new pool from list of pool implementations 

*initData must omit method selector, name and symbol. These arguments      are encoded automatically as:    ┌──────────┬──────────┬─────────┬─────────┐   │ selector │ initData │ name    │ symbol  │   │ (bytes4) │ (bytes)  │ (bytes) │ (bytes) │   └──────────┴──────────┴─────────┴─────────┘ Requirements:     - Caller must be owner     - Policy must not exist     - Version must be valid pool implementation index Throws PoolExists(address pool) on failure *

#### Parameters

| Name | Type | Description |
|---|---|---|
| version | uint256 | Index of pool implementation to deploy |
| initSelector | bytes4 | Method selector of initializer |
| initData | bytes | Initializer data (excluding method selector, name and symbol) |
| name | string | New pool&#39;s token name |
| symbol | string | New pool&#39;s token symbol  |

#### Returns

| Name | Type | Description |
|---|---|---|
| newPool | address | address of newly created pool |

### eligiblePoolsForToken

```solidity
function eligiblePoolsForToken(uint256 tokenId) external view returns (address[] pools)
```

Gets a list of Jasmine pool addresses that an EAT is eligible         to be deposited into. 

*Runs in O(n) with respect to number of pools and does not support      a max count. This should only be used by off-chain services and      should not be called by other smart contracts due to the potentially      unlimited gas that may be spent. *

#### Parameters

| Name | Type | Description |
|---|---|---|
| tokenId | uint256 | EAT token ID to check for eligible pools  |

#### Returns

| Name | Type | Description |
|---|---|---|
| pools | address[] | List of pool addresses token meets eligibility criteria |

### feeBeneficiary

```solidity
function feeBeneficiary() external view returns (address)
```



*Address to receive fees*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### getPoolAtIndex

```solidity
function getPoolAtIndex(uint256 index) external view returns (address pool)
```

Used to obtain the address of a pool in the set of pools - if it exists 

*Throw NoPool() on failure *

#### Parameters

| Name | Type | Description |
|---|---|---|
| index | uint256 | Index of the deployed pool in set of pools |

#### Returns

| Name | Type | Description |
|---|---|---|
| pool | address | Address of pool in set |

### getRoleAdmin

```solidity
function getRoleAdmin(bytes32 role) external view returns (bytes32)
```



*Returns the admin role that controls `role`. See {grantRole} and {revokeRole}. To change a role&#39;s admin, use {_setRoleAdmin}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

### grantRole

```solidity
function grantRole(bytes32 role, address account) external nonpayable
```



*Grants `role` to `account`. If `account` had not been already granted `role`, emits a {RoleGranted} event. Requirements: - the caller must have ``role``&#39;s admin role. May emit a {RoleGranted} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

### hasFeeManagerRole

```solidity
function hasFeeManagerRole(address account) external view returns (bool)
```



*Checks if account has pool fee manager roll *

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | Account to check fee manager roll against |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### hasRole

```solidity
function hasRole(bytes32 role, address account) external view returns (bool)
```



*Returns `true` if `account` has been granted `role`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### owner

```solidity
function owner() external view returns (address)
```



*Returns the address of the current owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### pendingOwner

```solidity
function pendingOwner() external view returns (address)
```



*Returns the address of the pending owner.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

### readdPoolImplementation

```solidity
function readdPoolImplementation(uint256 implementationsIndex) external nonpayable
```

Used to undo a pool implementation removal 

*emits PoolImplementationAdded *

#### Parameters

| Name | Type | Description |
|---|---|---|
| implementationsIndex | uint256 | Index of pool to undo removal |

### removePoolImplementation

```solidity
function removePoolImplementation(uint256 implementationsIndex) external nonpayable
```

Used to remove a pool implementation 

*Marks a pool implementation as deprecated. This is a soft delete      preventing new pool deployments from using the implementation while      allowing upgrades to occur. emits PoolImplementationRemoved *

#### Parameters

| Name | Type | Description |
|---|---|---|
| implementationsIndex | uint256 | Index of pool to remove  |

### renounceOwnership

```solidity
function renounceOwnership() external view
```

Renouncing ownership is deliberately disabled




### renounceRole

```solidity
function renounceRole(bytes32 role, address account) external nonpayable
```



*Revokes `role` from the calling account. Roles are often managed via {grantRole} and {revokeRole}: this function&#39;s purpose is to provide a mechanism for accounts to lose their privileges if they are compromised (such as when a trusted device is misplaced). If the calling account had been revoked `role`, emits a {RoleRevoked} event. Requirements: - the caller must be `account`. May emit a {RoleRevoked} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

### revokeRole

```solidity
function revokeRole(bytes32 role, address account) external nonpayable
```



*Revokes `role` from `account`. If `account` had been granted `role`, emits a {RoleRevoked} event. Requirements: - the caller must have ``role``&#39;s admin role. May emit a {RoleRevoked} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |
| account | address | undefined |

### setBaseRetirementRate

```solidity
function setBaseRetirementRate(uint96 newRetirementRate) external nonpayable
```

Allows pool fee managers to update the base retirement rate across pools 

*Requirements:     - Caller must have fee manager role emits BaseRetirementFeeUpdate *

#### Parameters

| Name | Type | Description |
|---|---|---|
| newRetirementRate | uint96 | New base rate for retirements in basis points |

### setBaseWithdrawalRate

```solidity
function setBaseWithdrawalRate(uint96 newWithdrawalRate) external nonpayable
```

Allows pool fee managers to update the base withdrawal rate across pools 

*Requirements:     - Caller must have fee manager role emits BaseWithdrawalFeeUpdate *

#### Parameters

| Name | Type | Description |
|---|---|---|
| newWithdrawalRate | uint96 | New base rate for withdrawals in basis points |

### setBaseWithdrawalSpecificRate

```solidity
function setBaseWithdrawalSpecificRate(uint96 newWithdrawalRate) external nonpayable
```

Allows pool fee managers to update the base withdrawal rate across pools 

*Requirements:     - Caller must have fee manager role     - Specific rate must be greater than base rate emits BaseWithdrawalFeeUpdate *

#### Parameters

| Name | Type | Description |
|---|---|---|
| newWithdrawalRate | uint96 | New base rate for withdrawals in basis points |

### setFeeBeneficiary

```solidity
function setFeeBeneficiary(address newFeeBeneficiary) external nonpayable
```

Allows pool fee managers to update the beneficiary to receive pool fees         across all Jasmine pools 

*Requirements:     - Caller must have fee manager role     - New beneficiary cannot be zero address emits BaseWithdrawalFeeUpdate &amp; BaseRetirementFeeUpdate *

#### Parameters

| Name | Type | Description |
|---|---|---|
| newFeeBeneficiary | address | Address to receive all pool JLT fees |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```



*See {IERC165-supportsInterface}.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bool | undefined |

### totalPools

```solidity
function totalPools() external view returns (uint256)
```

Returns the total number of pools deployed




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint256 | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one. Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### updateImplementationAddress

```solidity
function updateImplementationAddress(address newPoolImplementation, uint256 poolIndex) external nonpayable
```

Allows owner to update a pool implementation 

*emits PoolImplementationUpgraded *

#### Parameters

| Name | Type | Description |
|---|---|---|
| newPoolImplementation | address | New address to replace |
| poolIndex | uint256 | Index of pool to replace |



## Events

### BaseRetirementFeeUpdate

```solidity
event BaseRetirementFeeUpdate(uint96 retirementRateBips, address indexed beneficiary)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| retirementRateBips  | uint96 | undefined |
| beneficiary `indexed` | address | undefined |

### BaseWithdrawalFeeUpdate

```solidity
event BaseWithdrawalFeeUpdate(uint96 withdrawRateBips, address indexed beneficiary, bool indexed specific)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| withdrawRateBips  | uint96 | undefined |
| beneficiary `indexed` | address | undefined |
| specific `indexed` | bool | undefined |

### OwnershipTransferStarted

```solidity
event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### OwnershipTransferred

```solidity
event OwnershipTransferred(address indexed previousOwner, address indexed newOwner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| previousOwner `indexed` | address | undefined |
| newOwner `indexed` | address | undefined |

### PoolCreated

```solidity
event PoolCreated(bytes policy, address indexed pool, string indexed name, string indexed symbol)
```

Emitted when a new Jasmine pool is created 



#### Parameters

| Name | Type | Description |
|---|---|---|
| policy  | bytes | undefined |
| pool `indexed` | address | undefined |
| name `indexed` | string | undefined |
| symbol `indexed` | string | undefined |

### PoolImplementationAdded

```solidity
event PoolImplementationAdded(address indexed poolImplementation, address indexed beaconAddress, uint256 indexed poolIndex)
```

Emitted when new pool implementations are supported by factory 



#### Parameters

| Name | Type | Description |
|---|---|---|
| poolImplementation `indexed` | address | undefined |
| beaconAddress `indexed` | address | undefined |
| poolIndex `indexed` | uint256 | undefined |

### PoolImplementationRemoved

```solidity
event PoolImplementationRemoved(address indexed beaconAddress, uint256 indexed poolIndex)
```

Emitted when a pool implementations is removed 



#### Parameters

| Name | Type | Description |
|---|---|---|
| beaconAddress `indexed` | address | undefined |
| poolIndex `indexed` | uint256 | undefined |

### PoolImplementationUpgraded

```solidity
event PoolImplementationUpgraded(address indexed newPoolImplementation, address indexed beaconAddress, uint256 indexed poolIndex)
```

Emitted when a pool&#39;s beacon implementation updates 



#### Parameters

| Name | Type | Description |
|---|---|---|
| newPoolImplementation `indexed` | address | undefined |
| beaconAddress `indexed` | address | undefined |
| poolIndex `indexed` | uint256 | undefined |

### RoleAdminChanged

```solidity
event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| role `indexed` | bytes32 | undefined |
| previousAdminRole `indexed` | bytes32 | undefined |
| newAdminRole `indexed` | bytes32 | undefined |

### RoleGranted

```solidity
event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| role `indexed` | bytes32 | undefined |
| account `indexed` | address | undefined |
| sender `indexed` | address | undefined |

### RoleRevoked

```solidity
event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| role `indexed` | bytes32 | undefined |
| account `indexed` | address | undefined |
| sender `indexed` | address | undefined |



## Errors

### Disabled

```solidity
error Disabled()
```



*Emitted if function is disabled*


### InvalidConformance

```solidity
error InvalidConformance(bytes4 interfaceId)
```



*Emitted for failed supportsInterface check - per ERC-165*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

### InvalidInput

```solidity
error InvalidInput()
```



*Emitted if input is invalid*


### NoPool

```solidity
error NoPool()
```



*Emitted if no pool(s) meet query*


### PoolExists

```solidity
error PoolExists(address pool)
```



*Emitted if a pool exists with given policy*

#### Parameters

| Name | Type | Description |
|---|---|---|
| pool | address | undefined |

### RequiresRole

```solidity
error RequiresRole(bytes32 role)
```



*Emitted if access control check fails*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role | bytes32 | undefined |

### ValidationFailed

```solidity
error ValidationFailed()
```



*Emitted if internal validation failed*



