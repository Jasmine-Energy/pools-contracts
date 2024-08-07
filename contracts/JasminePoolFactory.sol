// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.23;

/*

     ██╗ █████╗ ███████╗███╗   ███╗██╗███╗   ██╗███████╗        ███████╗███╗   ██╗███████╗██████╗  ██████╗██╗   ██╗
     ██║██╔══██╗██╔════╝████╗ ████║██║████╗  ██║██╔════╝        ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝
     ██║███████║███████╗██╔████╔██║██║██╔██╗ ██║█████╗          █████╗  ██╔██╗ ██║█████╗  ██████╔╝██║  ███╗╚████╔╝ 
██   ██║██╔══██║╚════██║██║╚██╔╝██║██║██║╚██╗██║██╔══╝          ██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██║   ██║ ╚██╔╝  
╚█████╔╝██║  ██║███████║██║ ╚═╝ ██║██║██║ ╚████║███████╗        ███████╗██║ ╚████║███████╗██║  ██║╚██████╔╝  ██║   
 ╚════╝ ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝        ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝ ®

*/

//  ─────────────────────────────────  Imports  ─────────────────────────────────  \\

// Inheritted Contracts
import {Ownable2StepUpgradeable as Ownable2Step} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {AccessControlUpgradeable as AccessControl} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// Implemented Interfaces
import {IJasminePoolFactory} from "./interfaces/IJasminePoolFactory.sol";
import {IJasmineFeeManager} from "./interfaces/IJasmineFeeManager.sol";
import {JasmineErrors} from "./interfaces/errors/JasmineErrors.sol";

// External Contracts
import {IJasminePool} from "./interfaces/IJasminePool.sol";
import {IUniswapV3Factory} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";

// Proxies Contracts
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

// Utility Libraries
import {PoolPolicy} from "./libraries/PoolPolicy.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {ERC165Checker} from "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

/**
 * @title Jasmine Pool Factory
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Deploys new Jasmine Reference Pools, manages pool implementations and
 *         controls fees across the Jasmine protocol
 * @custom:security-contact dev@jasmine.energy
 */
contract JasminePoolFactory is
    IJasminePoolFactory,
    IJasmineFeeManager,
    JasmineErrors,
    Ownable2Step,
    AccessControl,
    UUPSUpgradeable
{
    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using ERC165Checker for address;
    using Address for address;

    // ──────────────────────────────────────────────────────────────────────────────
    // Events
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Emitted whenever the pools' base token URI is updated
     * @param newBaseURI Pools' updated base token URI
     * @param oldBaseURI Pools' previous base token URI
     */
    event PoolsBaseURIChanged(
        string indexed newBaseURI,
        string indexed oldBaseURI
    );

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    //  ───────────────────────  Pool Deployment Management  ────────────────────────  \\

    /**
     * @dev List of pool deposit policy hashes. As pools are deployed via create2,
     *      address of a pool from the hash can be computed as needed.
     */
    EnumerableSet.Bytes32Set internal _pools;

    //  ─────────────────────  Pool Implementation Management  ──────────────────────  \\

    /**
     * @dev Mapping of Deposit Policy (aka pool init data) hash to _poolImplementations
     *      index. Used to determine CREATE2 address
     */
    mapping(bytes32 => uint256) internal _poolVersions;

    /// @dev Pool beacon proxy addresses containing pool implementations
    EnumerableSet.AddressSet internal _poolBeacons;

    /// @dev Mapping of pool implementation versions to whether they are deprecated
    mapping(uint256 => bool) internal _deprecatedPoolImplementations;

    //  ─────────────────────────────  Access Control  ──────────────────────────────  \\

    /// @dev Access control roll for pool fee management
    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");

    /// @dev Access control roll for managers of pool implementations and deployments
    bytes32 public constant POOL_MANAGER_ROLE = keccak256("POOL_MANAGER_ROLE");

    //  ───────────────────────────  External Addresses  ────────────────────────────  \\

    /// @dev Address of Uniswap V3 Factory to automatically deploy JLT liquidity pools
    address public immutable uniswapFactory;

    /// @dev Address of USDC contract used to create UniSwap V3 pools for new JLTs
    address public immutable usdc;

    //  ────────────────────────────────  Pool Fees  ────────────────────────────────  \\

    /// @dev Default fee for withdrawals across pools. May be overridden per pool
    uint96 public baseWithdrawalRate;

    /// @dev Default fee for withdrawing specific EATs from pools. May be overridden per pool
    uint96 public baseWithdrawalSpecificRate;

    /// @dev Default fee for retirements across pools. May be overridden per pool
    uint96 public baseRetirementRate;

    /// @dev Address to receive fees
    address public feeBeneficiary;

    /// @dev Default fee tier for Uniswap V3 pools. Default is 0.3%
    uint24 public constant UNISWAP_FEE_TIER = 3_000;

    //  ────────────────────────────────  Pool Fees  ────────────────────────────────  \\

    /// @dev Base API route from which pool information may be obtained
    string private _poolsBaseURI;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Errors
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @dev Emitted if no pool(s) meet query
    error NoPool();

    /// @dev Emitted if a pool exists with given policy
    error PoolExists(address pool);

    /// @dev Emitted for failed supportsInterface check - per ERC-165
    error MustSupportInterface(bytes4 interfaceId);

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Setup
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Constructor to set immutable external addresses
     *
     * @param _uniswapFactory Address of Uniswap V3 Factory
     * @param _usdc Address of USDC token
     *
     * @custom:oz-upgrades-unsafe-allow constructor state-variable-immutable
     */
    constructor(address _uniswapFactory, address _usdc) initializer {
        // 1. Validate inputs
        if (_uniswapFactory == address(0x0) || _usdc == address(0x0))
            revert JasmineErrors.InvalidInput();

        // 2. Set immutable external addresses
        uniswapFactory = _uniswapFactory;
        usdc = _usdc;
    }

    /**
     * @dev UUPS initializer to set feilds, setup access control roles,
     *     transfer ownership to initial owner, and add an initial pool
     *
     * @param _owner Address to receive initial ownership of contract
     * @param _poolImplementation Address containing Jasmine Pool implementation
     * @param _poolManager Address of initial pool manager. May be zero address
     * @param _feeManager Address of initial fee manager. May be zero address
     * @param _feeBeneficiary Address to receive all pool fees
     * @param _tokensBaseURI Base URI of used for ERC-1046 token URI function
     */
    function initialize(
        address _owner,
        address _poolImplementation,
        address _poolManager,
        address _feeManager,
        address _feeBeneficiary,
        string memory _tokensBaseURI
    ) external initializer onlyProxy {
        // 1. Initialize dependencies
        __UUPSUpgradeable_init();
        __Ownable2Step_init();
        __AccessControl_init();

        // 2. Validate inputs
        _validatePoolImplementation(_poolImplementation);
        _validateFeeReceiver(_feeBeneficiary);
        if (_owner == address(0x0)) revert JasmineErrors.InvalidInput();

        // 3. Set fields
        _poolsBaseURI = _tokensBaseURI;
        feeBeneficiary = _feeBeneficiary;

        // 3. Transfer ownership to initial owner
        _transferOwnership(_owner);

        // 4. Setup access control roles and role admins
        _setupRole(DEFAULT_ADMIN_ROLE, _owner);

        _setupRole(POOL_MANAGER_ROLE, _owner);
        _setRoleAdmin(POOL_MANAGER_ROLE, DEFAULT_ADMIN_ROLE);

        _setupRole(FEE_MANAGER_ROLE, _owner);
        _setRoleAdmin(FEE_MANAGER_ROLE, DEFAULT_ADMIN_ROLE);

        // 5. Grant owner pool manager and fee manager roles
        _grantRole(POOL_MANAGER_ROLE, _owner);
        _grantRole(FEE_MANAGER_ROLE, _owner);

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());

        if (_poolManager != address(0x0))
            _grantRole(POOL_MANAGER_ROLE, _poolManager);
        if (_feeManager != address(0x0))
            _grantRole(FEE_MANAGER_ROLE, _feeManager);

        // 6. Setup default pool implementation
        _grantRole(POOL_MANAGER_ROLE, _msgSender());
        addPoolImplementation(_poolImplementation);
        _revokeRole(POOL_MANAGER_ROLE, _msgSender());

        _revokeRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  User Functionality
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ───────────────  Jasmine Pool Factory Interface Conformance  ────────────────  \\

    /// @notice Returns the total number of pools deployed
    function totalPools() external view returns (uint256 numberOfPools) {
        return _pools.length();
    }

    /**
     * @notice Used to obtain the address of a pool in the set of pools - if it exists
     *
     * @dev Throw NoPool() on failure
     *
     * @param index Index of the deployed pool in set of pools
     * @return pool Address of pool in set
     */
    function getPoolAtIndex(
        uint256 index
    ) external view returns (address pool) {
        if (index >= _pools.length()) revert NoPool();
        return computePoolAddress(_pools.at(index));
    }

    /**
     * @notice Gets a list of Jasmine pool addresses that an EAT is eligible
     *         to be deposited into.
     *
     * @dev Runs in O(n) with respect to number of pools and does not support
     *      a max count. This should only be used by off-chain services and
     *      should not be called by other smart contracts due to the potentially
     *      unlimited gas that may be spent.
     *
     * @param tokenId EAT token ID to check for eligible pools
     *
     * @return pools List of pool addresses token meets eligibility criteria
     */
    function eligiblePoolsForToken(
        uint256 tokenId
    ) external view returns (address[] memory pools) {
        address[] memory eligiblePools = new address[](_pools.length());
        uint256 eligiblePoolsCount = 0;

        for (uint256 i; i < _pools.length(); ) {
            address poolAddress = computePoolAddress(_pools.at(i));
            if (IJasminePool(poolAddress).meetsPolicy(tokenId)) {
                eligiblePools[eligiblePoolsCount] = poolAddress;
                eligiblePoolsCount++;
            }

            unchecked {
                i++;
            }
        }

        pools = new address[](eligiblePoolsCount);

        for (uint256 i; i < eligiblePoolsCount; ) {
            unchecked {
                pools[i] = eligiblePools[i];

                i++;
            }
        }

        return pools;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Admin Functionality
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ────────────────────────────  Pool Deployment  ──────────────────────────────  \\

    /**
     * @notice Deploys a new pool with given deposit policy
     *
     * @dev Pool is deployed via ERC-1967 proxy to deterministic address derived from
     *      hash of Deposit Policy
     *
     * @dev Requirements:
     *     - Caller must be owner
     *     - Policy must not exist
     *
     * @param policy Deposit Policy for new pool
     * @param name Token name of new pool (per ERC-20)
     * @param symbol Token symbol of new pool (per ERC-20)
     * @param initialSqrtPriceX96 Initial Uniswap price of pool. If 0, no Uniswap pool will be deployed
     *
     * @return newPool Address of newly created pool
     */
    function deployNewBasePool(
        PoolPolicy.DepositPolicy calldata policy,
        string calldata name,
        string calldata symbol,
        uint160 initialSqrtPriceX96
    ) external onlyPoolManager returns (address newPool) {
        // 1. Encode packed policy and create hash
        bytes memory encodedPolicy = abi.encode(
            policy.vintagePeriod,
            policy.techType,
            policy.registry,
            policy.certificateType,
            policy.endorsement
        );

        return
            deployNewPool(
                0,
                IJasminePool.initialize.selector,
                encodedPolicy,
                name,
                symbol,
                initialSqrtPriceX96
            );
    }

    /**
     * @notice Deploys a new pool from list of pool implementations
     *
     * @dev initData must omit method selector, name and symbol. These arguments
     *      are encoded automatically as:
     *
     *   ┌──────────┬──────────┬─────────┬─────────┐
     *   │ selector │ initData │ name    │ symbol  │
     *   │ (bytes4) │ (bytes)  │ (bytes) │ (bytes) │
     *   └──────────┴──────────┴─────────┴─────────┘
     *
     * @dev Requirements:
     *     - Caller must be owner
     *     - Policy must not exist
     *     - Version must be valid pool implementation index
     *
     * @dev Throws PoolExists(address pool) on failure
     *
     * @param version Index of pool implementation to deploy
     * @param initSelector Method selector of initializer
     * @param initData Initializer data (excluding method selector, name and symbol)
     * @param name New pool's token name
     * @param symbol New pool's token symbol
     * @param initialSqrtPriceX96 Initial Uniswap price of pool. If 0, no Uniswap pool will be deployed
     *
     * @return newPool address of newly created pool
     */
    function deployNewPool(
        uint256 version,
        bytes4 initSelector,
        bytes memory initData,
        string calldata name,
        string calldata symbol,
        uint160 initialSqrtPriceX96
    ) public onlyPoolManager returns (address newPool) {
        // 1. Validate pool implementation version
        _validatePoolVersion(version);

        // 2. Compute hash of init data
        bytes32 policyHash = keccak256(initData);

        // 3. Ensure policy does not exist
        if (_pools.contains(policyHash))
            revert PoolExists(_predictDeploymentAddress(policyHash, version));

        // 4. Deploy new pool
        BeaconProxy poolProxy = new BeaconProxy{salt: policyHash}(
            _poolBeacons.at(version),
            ""
        );

        // 5. Ensure new pool matches expected
        if (
            _predictDeploymentAddress(policyHash, version) != address(poolProxy)
        ) revert JasmineErrors.ValidationFailed();

        // 6. Initialize pool, add to pools and emit creation event
        Address.functionCall(
            address(poolProxy),
            abi.encodePacked(initSelector, abi.encode(initData, name, symbol))
        );
        _addDeployedPool(policyHash, version);
        emit PoolCreated(initData, address(poolProxy), name, symbol);

        // 7. Create Uniswap pool and return new pool
        if (initialSqrtPriceX96 != 0) {
            _createUniswapPool(address(poolProxy), initialSqrtPriceX96);
        }
        return address(poolProxy);
    }

    //  ────────────────────────────  Pool Management  ──────────────────────────────  \\

    /**
     * @notice Allows owner to update a pool implementation
     *
     * @dev emits PoolImplementationUpgraded
     *
     * @param newPoolImplementation New address to replace
     * @param poolIndex Index of pool to replace
     */
    function updateImplementationAddress(
        address newPoolImplementation,
        uint256 poolIndex
    ) external onlyPoolManager {
        _validatePoolImplementation(newPoolImplementation);

        UpgradeableBeacon implementationBeacon = UpgradeableBeacon(
            _poolBeacons.at(poolIndex)
        );
        implementationBeacon.upgradeTo(newPoolImplementation);

        emit PoolImplementationUpgraded(
            newPoolImplementation,
            address(implementationBeacon),
            poolIndex
        );
    }

    /**
     * @notice Used to add a new pool implementation
     *
     * @dev emits PoolImplementationAdded
     *
     * @param newPoolImplementation New pool implementation address to support
     */
    function addPoolImplementation(
        address newPoolImplementation
    ) public onlyPoolManager returns (uint256 indexInPools) {
        _validatePoolImplementation(newPoolImplementation);

        bytes32 poolSalt = keccak256(abi.encodePacked(_poolBeacons.length()));

        UpgradeableBeacon implementationBeacon = new UpgradeableBeacon{
            salt: poolSalt
        }(newPoolImplementation);

        require(
            _poolBeacons.add(address(implementationBeacon)),
            "JasminePoolFactory: Failed to add new pool"
        );

        emit PoolImplementationAdded(
            newPoolImplementation,
            address(implementationBeacon),
            _poolBeacons.length() - 1
        );
        return _poolBeacons.length() - 1;
    }

    /**
     * @notice Used to remove a pool implementation
     *
     * @dev Marks a pool implementation as deprecated. This is a soft delete
     *      preventing new pool deployments from using the implementation while
     *      allowing upgrades to occur.
     *
     * @dev emits PoolImplementationRemoved
     *
     * @param implementationsIndex Index of pool to remove
     *
     */
    function removePoolImplementation(
        uint256 implementationsIndex
    ) external onlyPoolManager {
        if (
            implementationsIndex >= _poolBeacons.length() ||
            _deprecatedPoolImplementations[implementationsIndex]
        ) revert JasmineErrors.ValidationFailed();

        _deprecatedPoolImplementations[implementationsIndex] = true;

        emit PoolImplementationRemoved(
            _poolBeacons.at(implementationsIndex),
            implementationsIndex
        );
    }

    /**
     * @notice Used to undo a pool implementation removal
     *
     * @dev emits PoolImplementationAdded
     *
     * @param implementationsIndex Index of pool to undo removal
     */
    function readdPoolImplementation(
        uint256 implementationsIndex
    ) external onlyPoolManager {
        if (
            implementationsIndex >= _poolBeacons.length() ||
            !_deprecatedPoolImplementations[implementationsIndex]
        ) revert JasmineErrors.ValidationFailed();

        _deprecatedPoolImplementations[implementationsIndex] = false;

        emit PoolImplementationAdded(
            UpgradeableBeacon(_poolBeacons.at(implementationsIndex))
                .implementation(),
            _poolBeacons.at(implementationsIndex),
            implementationsIndex
        );
    }

    //  ─────────────────────────────  Fee Management  ──────────────────────────────  \\

    /**
     * @notice Allows pool fee managers to update the base withdrawal rate across pools
     *
     * @dev Requirements:
     *     - Caller must have fee manager role
     *
     * @dev emits BaseWithdrawalFeeUpdate
     *
     * @param newWithdrawalRate New base rate for withdrawals in basis points
     */
    function setBaseWithdrawalRate(
        uint96 newWithdrawalRate
    ) external onlyFeeManager {
        baseWithdrawalRate = newWithdrawalRate;

        emit BaseWithdrawalFeeUpdate(newWithdrawalRate, feeBeneficiary, false);
    }

    /**
     * @notice Allows pool fee managers to update the base withdrawal rate across pools
     *
     * @dev Requirements:
     *     - Caller must have fee manager role
     *     - Specific rate must be greater than base rate
     *
     * @dev emits BaseWithdrawalFeeUpdate
     *
     * @param newWithdrawalRate New base rate for withdrawals in basis points
     */
    function setBaseWithdrawalSpecificRate(
        uint96 newWithdrawalRate
    ) external onlyFeeManager {
        if (newWithdrawalRate < baseWithdrawalRate)
            revert JasmineErrors.InvalidInput();
        baseWithdrawalSpecificRate = newWithdrawalRate;

        emit BaseWithdrawalFeeUpdate(newWithdrawalRate, feeBeneficiary, true);
    }

    /**
     * @notice Allows pool fee managers to update the base retirement rate across pools
     *
     * @dev Requirements:
     *     - Caller must have fee manager role
     *
     * @dev emits BaseRetirementFeeUpdate
     *
     * @param newRetirementRate New base rate for retirements in basis points
     */
    function setBaseRetirementRate(
        uint96 newRetirementRate
    ) external onlyFeeManager {
        baseRetirementRate = newRetirementRate;

        emit BaseRetirementFeeUpdate(newRetirementRate, feeBeneficiary);
    }

    /**
     * @notice Allows pool fee managers to update the beneficiary to receive pool fees
     *         across all Jasmine pools
     *
     * @dev Requirements:
     *     - Caller must have fee manager role
     *     - New beneficiary cannot be zero address
     *
     * @dev emits BaseWithdrawalFeeUpdate & BaseRetirementFeeUpdate
     *
     * @param newFeeBeneficiary Address to receive all pool JLT fees
     */
    function setFeeBeneficiary(
        address newFeeBeneficiary
    ) external onlyFeeManager {
        _validateFeeReceiver(newFeeBeneficiary);
        feeBeneficiary = newFeeBeneficiary;

        emit BaseWithdrawalFeeUpdate(
            baseWithdrawalRate,
            newFeeBeneficiary,
            false
        );
        emit BaseRetirementFeeUpdate(baseRetirementRate, newFeeBeneficiary);
    }

    //  ───────────────────────────  Base URI Management  ───────────────────────────  \\

    /**
     * @notice Allows pool managers to update the base URI of pools
     *
     * @dev No validation is done on the new URI. Onus is on caller to ensure the new
     *      URI is valid
     *
     * @dev emits PoolsBaseURIChanged
     *
     * @param newPoolsURI New base endpoint for pools to point to
     */
    function updatePoolsBaseURI(
        string calldata newPoolsURI
    ) external onlyPoolManager {
        emit PoolsBaseURIChanged(newPoolsURI, _poolsBaseURI);
        _poolsBaseURI = newPoolsURI;
    }

    //  ────────────────────────────────  Upgrades  ─────────────────────────────────  \\

    /// @dev `Ownable` owner is authorized to upgrade contract, not the ERC1967 admin
    function _authorizeUpgrade(address) internal override onlyOwner {} // solhint-disable-line no-empty-blocks

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Utilities
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Utility function to calculate deployed address of a pool from its
     *         policy hash
     *
     * @dev Requirements:
     *     - Policy hash must exist in existing pools
     *
     * @param policyHash Policy hash of pool to compute address of
     * @return poolAddress Address of deployed pool
     */
    function computePoolAddress(
        bytes32 policyHash
    ) public view returns (address poolAddress) {
        return _predictDeploymentAddress(policyHash, _poolVersions[policyHash]);
    }

    /**
     * @notice Base API endpoint from which a pool's information may be obtained
     *         by appending token symbol to end
     *
     * @dev Used by pools to return their respect tokenURI functions
     */
    function poolsBaseURI() external view returns (string memory baseURI) {
        return _poolsBaseURI;
    }

    //  ─────────────────────────────  Access Control  ──────────────────────────────  \\

    /**
     * @dev Checks if account has pool fee manager roll
     *
     * @param account Account to check fee manager roll against
     */
    function hasFeeManagerRole(
        address account
    ) external view returns (bool isFeeManager) {
        return hasRole(FEE_MANAGER_ROLE, account);
    }

    /**
     * @inheritdoc Ownable2Step
     * @dev Revokes admin role for previous owner and grants to newOwner
     */
    function _transferOwnership(address newOwner) internal override {
        _revokeRole(DEFAULT_ADMIN_ROLE, owner());
        _grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        super._transferOwnership(newOwner);
    }

    /// @notice Renouncing ownership is deliberately disabled
    function renounceOwnership() public view override onlyOwner {
        revert JasmineErrors.Disabled();
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Creates a Uniswap V3 pool between JLT and USDC
     *
     * @param jltPool Address of JLT pool to create Uniswap pool between USDC
     * @param sqrtPriceX96 Initial price of the pool. See [docs]().
     */
    function _createUniswapPool(
        address jltPool,
        uint160 sqrtPriceX96
    ) private returns (address pool) {
        (address token0, address token1) = jltPool < usdc
            ? (jltPool, usdc)
            : (usdc, jltPool);
        if (token0 > token1) revert JasmineErrors.ValidationFailed();

        pool = IUniswapV3Factory(uniswapFactory).getPool(
            token0,
            token1,
            UNISWAP_FEE_TIER
        );

        if (pool == address(0)) {
            pool = IUniswapV3Factory(uniswapFactory).createPool(
                jltPool,
                usdc,
                UNISWAP_FEE_TIER
            );
            IUniswapV3Pool(pool).initialize(sqrtPriceX96);
        } else {
            (uint160 sqrtPriceX96Existing, , , , , , ) = IUniswapV3Pool(pool)
                .slot0();
            if (sqrtPriceX96Existing == 0) {
                IUniswapV3Pool(pool).initialize(sqrtPriceX96);
            }
        }
    }

    /**
     * @dev Determines the address of a newly deployed proxy, salted with the policy
     *      and deployed via CREATE2
     *
     * @param policyHash Keccak256 hash of pool's deposit policy
     *
     * @return poolAddress Predicted address of pool
     */
    function _predictDeploymentAddress(
        bytes32 policyHash,
        uint256 implementationIndex
    ) internal view returns (address poolAddress) {
        bytes memory bytecode = type(BeaconProxy).creationCode;
        bytes memory proxyByteCode = abi.encodePacked(
            bytecode,
            abi.encode(_poolBeacons.at(implementationIndex), "")
        );
        return Create2.computeAddress(policyHash, keccak256(proxyByteCode));
    }

    /**
     * @dev Used to add newly deployed pools to list of pool and record pool implementation
     *      that was used
     *
     * @param policyHash Keccak256 hash of pool's deposit policy
     * @param poolImplementationIndex Index of pool implementation that was deployed
     */
    function _addDeployedPool(
        bytes32 policyHash,
        uint256 poolImplementationIndex
    ) internal {
        _pools.add(policyHash);
        _poolVersions[policyHash] = poolImplementationIndex;
    }

    /**
     * @dev Checks if a given address implements JasminePool Interface and IERC1155Receiver, is not
     *      already in list of pool and is not empty
     *
     * @dev Throws PoolExists(address pool) if policyHash exists or throws MustSupportInterface(bytes4 interfaceId)
     *      if implementation fails interface checks or errors if address is empty
     *
     * @param poolImplementation Address of pool implementation
     */
    function _validatePoolImplementation(
        address poolImplementation
    ) private view {
        bytes4[] memory interfaceIds = new bytes4[](2);
        interfaceIds[0] = type(IJasminePool).interfaceId;
        interfaceIds[1] = type(IERC1155Receiver).interfaceId;
        bool[] memory interfaceChecks = ERC165Checker.getSupportedInterfaces(
            poolImplementation,
            interfaceIds
        );
        if (!interfaceChecks[0]) {
            revert MustSupportInterface(type(IJasminePool).interfaceId);
        } else if (!interfaceChecks[1]) {
            revert MustSupportInterface(type(IERC1155Receiver).interfaceId);
        }

        for (uint256 i = 0; i < _poolBeacons.length(); ) {
            UpgradeableBeacon beacon = UpgradeableBeacon(_poolBeacons.at(i));
            if (beacon.implementation() == poolImplementation) {
                revert PoolExists(poolImplementation);
            }

            unchecked {
                i++;
            }
        }
    }

    /**
     * @dev Checks if a given pool implementation version exists and is not deprecated
     *
     * @param poolImplementationVersion Index of pool implementation to check
     */
    function _validatePoolVersion(
        uint256 poolImplementationVersion
    ) private view {
        if (
            poolImplementationVersion >= _poolBeacons.length() ||
            _deprecatedPoolImplementations[poolImplementationVersion]
        ) {
            revert JasmineErrors.ValidationFailed();
        }
    }

    /**
     * @dev Checks if a given address is valid to receive JLT fees. Address cannot be zero.
     *
     * @param newFeeBeneficiary Address to validate
     */
    function _validateFeeReceiver(address newFeeBeneficiary) private pure {
        if (newFeeBeneficiary == address(0x0))
            revert JasmineErrors.InvalidInput();
    }

    //  ────────────────────────────────  Modifiers  ────────────────────────────────  \\

    /// @dev Enforces caller has fee manager role in pool factory
    modifier onlyFeeManager() {
        if (!hasRole(FEE_MANAGER_ROLE, _msgSender())) {
            revert JasmineErrors.RequiresRole(FEE_MANAGER_ROLE);
        }
        _;
    }

    /// @dev Enforces caller has fee manager role in pool factory
    modifier onlyPoolManager() {
        if (!hasRole(POOL_MANAGER_ROLE, _msgSender())) {
            revert JasmineErrors.RequiresRole(POOL_MANAGER_ROLE);
        }
        _;
    }
}
