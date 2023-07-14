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

### UNISWAP_FEE_TIER

```solidity
function UNISWAP_FEE_TIER() external view returns (uint24)
```



*Default fee tier for Uniswap V3 pools. Default is 0.3%*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | uint24 | undefined |

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

### deployNewBasePool

```solidity
function deployNewBasePool(PoolPolicy.DepositPolicy policy, string name, string symbol, uint160 initialSqrtPriceX96) external nonpayable returns (address newPool)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| policy | PoolPolicy.DepositPolicy | undefined |
| name | string | undefined |
| symbol | string | undefined |
| initialSqrtPriceX96 | uint160 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| newPool | address | undefined |

### deployNewPool

```solidity
function deployNewPool(uint256 version, bytes4 initSelector, bytes initData, string name, string symbol, uint160 initialSqrtPriceX96) external nonpayable returns (address newPool)
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
| symbol | string | New pool&#39;s token symbol |
| initialSqrtPriceX96 | uint160 | Initial Uniswap price of pool. If 0, no Uniswap pool will be deployed  |

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
function hasFeeManagerRole(address account) external view returns (bool isFeeManager)
```



*Checks if account has pool fee manager roll *

#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | Account to check fee manager roll against |

#### Returns

| Name | Type | Description |
|---|---|---|
| isFeeManager | bool | undefined |

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

### initialize

```solidity
function initialize(address _owner, address _poolImplementation, address _feeBeneficiary, string _tokensBaseURI) external nonpayable
```



*UUPS initializer to set feilds, setup access control roles,     transfer ownership to initial owner, and add an initial pool *

#### Parameters

| Name | Type | Description |
|---|---|---|
| _owner | address | Address to receive initial ownership of contract |
| _poolImplementation | address | Address containing Jasmine Pool implementation |
| _feeBeneficiary | address | Address to receive all pool fees |
| _tokensBaseURI | string | Base URI of used for ERC-1046 token URI function |

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

### poolsBaseURI

```solidity
function poolsBaseURI() external view returns (string baseURI)
```

Base API endpoint from which a pool&#39;s information may be obtained         by appending token symbol to end 

*Used by pools to return their respect tokenURI functions*


#### Returns

| Name | Type | Description |
|---|---|---|
| baseURI | string | undefined |

### proxiableUUID

```solidity
function proxiableUUID() external view returns (bytes32)
```



*Implementation of the ERC1822 {proxiableUUID} function. This returns the storage slot used by the implementation. It is used to validate the implementation&#39;s compatibility when performing an upgrade. IMPORTANT: A proxy pointing at a proxiable contract should not be considered proxiable itself, because this risks bricking a proxy that upgrades to it, by delegating to itself until out of gas. Thus it is critical that this function revert if invoked through a proxy. This is guaranteed by the `notDelegated` modifier.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | undefined |

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
function totalPools() external view returns (uint256 numberOfPools)
```

Returns the total number of pools deployed




#### Returns

| Name | Type | Description |
|---|---|---|
| numberOfPools | uint256 | undefined |

### transferOwnership

```solidity
function transferOwnership(address newOwner) external nonpayable
```



*Starts the ownership transfer of the contract to a new account. Replaces the pending transfer if there is one. Can only be called by the current owner.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newOwner | address | undefined |

### uniswapFactory

```solidity
function uniswapFactory() external view returns (address)
```



*Address of Uniswap V3 Factory to automatically deploy JLT liquidity pools*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |

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

### updatePoolsBaseURI

```solidity
function updatePoolsBaseURI(string newPoolsURI) external nonpayable
```

Allows pool managers to update the base URI of pools 

*No validation is done on the new URI. Onus is on caller to ensure the new      URI is valid emits PoolsBaseURIChanged *

#### Parameters

| Name | Type | Description |
|---|---|---|
| newPoolsURI | string | New base endpoint for pools to point to |

### upgradeTo

```solidity
function upgradeTo(address newImplementation) external nonpayable
```



*Upgrade the implementation of the proxy to `newImplementation`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newImplementation | address | undefined |

### upgradeToAndCall

```solidity
function upgradeToAndCall(address newImplementation, bytes data) external payable
```



*Upgrade the implementation of the proxy to `newImplementation`, and subsequently execute the function call encoded in `data`. Calls {_authorizeUpgrade}. Emits an {Upgraded} event.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| newImplementation | address | undefined |
| data | bytes | undefined |

### usdc

```solidity
function usdc() external view returns (address)
```



*Address of USDC contract used to create UniSwap V3 pools for new JLTs*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | address | undefined |



## Events

### AdminChanged

```solidity
event AdminChanged(address previousAdmin, address newAdmin)
```



*Emitted when the admin account has changed.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| previousAdmin  | address | undefined |
| newAdmin  | address | undefined |

### BaseRetirementFeeUpdate

```solidity
event BaseRetirementFeeUpdate(uint96 retirementRateBips, address indexed beneficiary)
```



*Emitted whenever fee manager updates retirement rate *

#### Parameters

| Name | Type | Description |
|---|---|---|
| retirementRateBips  | uint96 | new retirement rate in basis points |
| beneficiary `indexed` | address | Address to receive fees |

### BaseWithdrawalFeeUpdate

```solidity
event BaseWithdrawalFeeUpdate(uint96 withdrawRateBips, address indexed beneficiary, bool indexed specific)
```



*Emitted whenever fee manager updates withdrawal rate *

#### Parameters

| Name | Type | Description |
|---|---|---|
| withdrawRateBips  | uint96 | New withdrawal rate in basis points |
| beneficiary `indexed` | address | Address to receive fees |
| specific `indexed` | bool | Specifies whether new rate applies to specific or any withdrawals |

### BeaconUpgraded

```solidity
event BeaconUpgraded(address indexed beacon)
```



*Emitted when the beacon is changed.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| beacon `indexed` | address | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```



*Triggered when the contract has been initialized or reinitialized.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

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
| policy  | bytes | Pool&#39;s deposit policy in bytes |
| pool `indexed` | address | Address of newly created pool |
| name `indexed` | string | Name of the pool |
| symbol `indexed` | string | Token symbol of the pool |

### PoolImplementationAdded

```solidity
event PoolImplementationAdded(address indexed poolImplementation, address indexed beaconAddress, uint256 indexed poolIndex)
```

Emitted when new pool implementations are supported by factory 



#### Parameters

| Name | Type | Description |
|---|---|---|
| poolImplementation `indexed` | address | Address of newly supported pool implementation |
| beaconAddress `indexed` | address | Address of Beacon smart contract |
| poolIndex `indexed` | uint256 | Index of new pool in set of pool implementations |

### PoolImplementationRemoved

```solidity
event PoolImplementationRemoved(address indexed beaconAddress, uint256 indexed poolIndex)
```

Emitted when a pool implementations is removed 



#### Parameters

| Name | Type | Description |
|---|---|---|
| beaconAddress `indexed` | address | Address of Beacon smart contract |
| poolIndex `indexed` | uint256 | Index of deleted pool in set of pool implementations |

### PoolImplementationUpgraded

```solidity
event PoolImplementationUpgraded(address indexed newPoolImplementation, address indexed beaconAddress, uint256 indexed poolIndex)
```

Emitted when a pool&#39;s beacon implementation updates 



#### Parameters

| Name | Type | Description |
|---|---|---|
| newPoolImplementation `indexed` | address | Address of new pool implementation |
| beaconAddress `indexed` | address | Address of Beacon smart contract |
| poolIndex `indexed` | uint256 | Index of new pool in set of pool implementations |

### PoolsBaseURIChanged

```solidity
event PoolsBaseURIChanged(string indexed newBaseURI, string indexed oldBaseURI)
```

Emitted whenever the pools&#39; base token URI is updated



#### Parameters

| Name | Type | Description |
|---|---|---|
| newBaseURI `indexed` | string | Pools&#39; updated base token URI |
| oldBaseURI `indexed` | string | Pools&#39; previous base token URI |

### RoleAdminChanged

```solidity
event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole)
```



*Emitted when `newAdminRole` is set as ``role``&#39;s admin role, replacing `previousAdminRole` `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite {RoleAdminChanged} not being emitted signaling this. _Available since v3.1._*

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



*Emitted when `account` is granted `role`. `sender` is the account that originated the contract call, an admin role bearer except when using {AccessControl-_setupRole}.*

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



*Emitted when `account` is revoked `role`. `sender` is the account that originated the contract call:   - if using `revokeRole`, it is the admin role bearer   - if using `renounceRole`, it is the role bearer (i.e. `account`)*

#### Parameters

| Name | Type | Description |
|---|---|---|
| role `indexed` | bytes32 | undefined |
| account `indexed` | address | undefined |
| sender `indexed` | address | undefined |

### Upgraded

```solidity
event Upgraded(address indexed implementation)
```



*Emitted when the implementation is upgraded.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| implementation `indexed` | address | undefined |



## Errors

### Disabled

```solidity
error Disabled()
```



*Emitted if function is disabled*


### InvalidInput

```solidity
error InvalidInput()
```



*Emitted if input is invalid*


### MustSupportInterface

```solidity
error MustSupportInterface(bytes4 interfaceId)
```



*Emitted for failed supportsInterface check - per ERC-165*

#### Parameters

| Name | Type | Description |
|---|---|---|
| interfaceId | bytes4 | undefined |

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



