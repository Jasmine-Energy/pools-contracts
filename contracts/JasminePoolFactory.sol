// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Core Implementations
import { IJasminePoolFactory } from "./interfaces/IJasminePoolFactory.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

// External Contracts
import { IJasminePool } from "./interfaces/IJasminePool.sol";
import { JasmineEAT } from "@jasmine-energy/contracts/src/JasmineEAT.sol";
import { IUniswapV3Factory } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import { IUniswapV3Pool } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

// Proxies
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

// Interfaces
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IERC1155Receiver } from "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";
import { IERC777Recipient } from "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";

// Utility Libraries
import { PoolPolicy } from "./libraries/PoolPolicy.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { JasmineErrors } from "./interfaces/errors/JasmineErrors.sol";


/**
 * @title Jasmine Pool Factory
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
 * @custom:security-contact dev@jasmine.energy
 */
contract JasminePoolFactory is 
    IJasminePoolFactory,
    Ownable2Step,
    AccessControl
{

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using PoolPolicy for PoolPolicy.DepositPolicy;
    using Address for address;


    // ──────────────────────────────────────────────────────────────────────────────
    // Events
    // ──────────────────────────────────────────────────────────────────────────────


    //  ───────────────────────────────  Fee Events  ───────────────────────────────  \\
    // TODO: Move to interface

    /**
     * @dev Emitted whenever fee manager updates withdrawal rate
     * 
     * @param withdrawRateBips New withdrawal rate in basis points
     * @param beneficiary Address to receive fees
     * @param specific Specifies whether new rate applies to specific or any withdrawals
     */
    event BaseWithdrawalFeeUpdate(
        uint96 withdrawRateBips,
        address indexed beneficiary,
        bool indexed specific
    );

    /**
     * @dev Emitted whenever fee manager updates retirement rate
     * 
     * @param retirementRateBips new retirement rate in basis points
     * @param beneficiary Address to receive fees
     */
    event BaseRetirementFeeUpdate(
        uint96 retirementRateBips,
        address indexed beneficiary
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

    /// @dev Implementation addresses for pools
    EnumerableSet.AddressSet internal _poolImplementations;


    //  ─────────────────────────────  Access Control  ──────────────────────────────  \\

    /// @dev Access control roll for pool fee management
    bytes32 public constant FEE_MANAGER_ROLE = keccak256("FEE_MANAGER_ROLE");


    //  ───────────────────────────  External Addresses  ────────────────────────────  \\

    /// @dev Address of Uniswap V3 Factory to automatically deploy JLT liquidity pools
    address public immutable UniswapFactory;

    /// @dev Address of USDC contract used to create UniSwap V3 pools for new JLTs
    address public immutable USDC;

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
    uint24 public constant defaultUniswapFee = 3_000;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Setup
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Deploys Pool Factory with a default pool implementation
     * 
     * @dev Requirements:
     *     - Pool implementation supports IJasminePool and IERC1155Receiver interface
     *       per {ERC165-supportsInterface} check
     *     - Pool implementation is not zero address
     * 
     * @param _poolImplementation Address containing Jasmine Pool implementation
     * @param _feeBeneficiary Address to receive all pool fees
     * @param _uniswapFactory Address of Uniswap V3 Factory
     * @param _usdc Address of USDC token
     */
    constructor(
        address _poolImplementation,
        address _feeBeneficiary,
        address _uniswapFactory,
        address _usdc
    )
        Ownable2Step() AccessControl()
    {
        _validatePoolImplementation(_poolImplementation);
        _validateFeeReceiver(_feeBeneficiary);

        _poolImplementations.add(_poolImplementation);

        UniswapFactory = _uniswapFactory;
        USDC = _usdc;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(FEE_MANAGER_ROLE, msg.sender);
        _setRoleAdmin(FEE_MANAGER_ROLE, DEFAULT_ADMIN_ROLE);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  User Functionality
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ───────────────  Jasmine Pool Factory Interface Conformance  ────────────────  \\

    /// @notice Returns the total number of pools deployed
    function totalPools() external view returns (uint256) {
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
    function getPoolAtIndex(uint256 index)
        external view
        returns (address pool)
    {
        if (index >= _pools.length()) revert JasmineErrors.NoPool();
        return computePoolAddress(_pools.at(index));
    }

    // TODO Implement me
    function eligiblePoolsForToken(uint256)
        external pure
        returns (address[] memory)
    {
        revert("JasminePoolFactory: Unimplemented");
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
     * 
     * @return newPool Address of newly created pool
     */
    function deployNewBasePool(
        PoolPolicy.DepositPolicy calldata policy, 
        string calldata name, 
        string calldata symbol
    )
        external
        onlyOwner
        returns (address newPool)
    {
        // 1. Encode packed policy and create hash
        bytes memory encodedPolicy = abi.encode(
            policy.vintagePeriod,
            policy.techType,
            policy.registry,
            policy.certification,
            policy.endorsement
        );

        return deployNewPool(
            0,
            IJasminePool.initialize.selector,
            encodedPolicy,
            name,
            symbol
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
     * 
     * @return newPool address of newly created pool
     */
    function deployNewPool(
        uint256 version,
        bytes4  initSelector,
        bytes  memory   initData, // QUESTION: Consider renaming. This is more a generic deposit policy than init data as name and symbol are appended
        string calldata name, 
        string calldata symbol
    )
        public
        onlyOwner
        returns (address newPool)
    {
        // 1. Compute hash of init data
        bytes32 policyHash = keccak256(initData);

        // 2. Ensure policy does not exist
        if (_pools.contains(policyHash)) revert JasmineErrors.PoolExists(computePoolAddress(policyHash));

        // TODO: Beacon proxies may be preferable here
        // 3. Deploy new pool
        ERC1967Proxy poolProxy = new ERC1967Proxy{ salt: policyHash }(
            _poolImplementations.at(version), ""
        );

        // 4. Ensure new pool matches expected
        require(
            _predictDeploymentAddress(policyHash, 0) == address(poolProxy),
            "JasminePoolFactory: Pool address does not match expected"
        );

        // 5. Initialize pool, add to pools and emit creation event
        Address.functionCall(address(poolProxy), abi.encodePacked(initSelector, abi.encode(initData, name, symbol)));
        _addDeployedPool(policyHash, version);
        emit PoolCreated(initData, address(poolProxy), name, symbol);

        // 6. Create Uniswap pool and return new pool
        // QUESTION: How do we want to set initial price? $5/JLT is default
        _createUniswapPool(address(poolProxy), 177159557114295710296101716160); // NOTE: = $5/JLT
        // * uint160(10**IJasminePool(address(poolProxy)).decimals())
        return address(poolProxy);
    }

    //  ────────────────────────────  Pool Management  ──────────────────────────────  \\

    /**
     * @dev Allows owner to update a pool implementation
     * 
     * @ param newPoolImplementation New address to replace
     * @param poolIndex Index of pool to replace
     * TODO: Would be nice to have an overloaded version that takes address of pool to update
     */
    function updateImplementationAddress(
        address, // newPoolImplementation,
        uint256 poolIndex
    )
        external view
        onlyOwner
    {
        removePoolImplementation(poolIndex);
        // addPoolImplementation(newPoolImplementation); // NOTE: Currently unreachable
    }

    /**
     * @dev Used to add a new pool implementation
     * 
     * @param newPoolImplementation New pool implementation address to support
     */
    function addPoolImplementation(address newPoolImplementation) 
        public
        onlyOwner
        returns (uint256 indexInPools)
    {
        _validatePoolImplementation(newPoolImplementation);

        require(
            _poolImplementations.add(newPoolImplementation),
            "JasminePoolFactory: Failed to add new pool"
        );

        emit PoolImplementationAdded(newPoolImplementation, _poolImplementations.length() - 1);
        return _poolImplementations.length() - 1;
    }

    /**
     * @dev Used to remove a pool implementation
     * 
     * @ param poolIndex Index of pool to remove
     * TODO: Would be nice to have an overloaded version that takes address of pool to remove
     * NOTE: This will break CREATE2 address predictions. Think of means around this
     */
    function removePoolImplementation(uint256)
        public view
        onlyOwner
    {

        revert("JasminePoolFactory: Currently unsupported");

        // address pool = _poolImplementations.at(poolIndex);
        // require(
        //     _poolImplementations.remove(pool),
        //     "JasminePoolFactory: Failed to remove pool"
        // );

        // emit PoolImplementationRemoved(pool, poolIndex);
    }


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
    function computePoolAddress(bytes32 policyHash)
        public view
        returns (address poolAddress)
    {
        return _predictDeploymentAddress(policyHash, _poolVersions[policyHash]);
    }


    //  ─────────────────────────────  Access Control  ──────────────────────────────  \\

    /**
     * @dev Checks if account has pool fee manager roll
     * 
     * @param account Account to check fee manager roll against
     */
    function hasFeeManagerRole(address account) external view returns (bool) {
        return hasRole(FEE_MANAGER_ROLE, account);
    }

    /**
     * @inheritdoc Ownable2Step
     * @dev Revokes admin role for previous owner and grants to newOwner
     */
    function _transferOwnership(address newOwner) internal virtual override {
        _revokeRole(DEFAULT_ADMIN_ROLE, owner());
        _grantRole(DEFAULT_ADMIN_ROLE, newOwner);
        super._transferOwnership(newOwner);
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
    function setBaseWithdrawalRate(uint96 newWithdrawalRate) external onlyFeeManager {
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
    function setBaseWithdrawalSpecificRate(uint96 newWithdrawalRate) external onlyFeeManager {
        if (newWithdrawalRate < baseWithdrawalRate) revert JasmineErrors.InvalidInput();
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
    function setBaseRetirementRate(uint96 newRetirementRate) external onlyFeeManager {
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
     *     - If new beneficiary is a contract, must support IERC777Recipient interface
     * 
     * @dev emits BaseWithdrawalFeeUpdate & BaseRetirementFeeUpdate
     * 
     * @param newFeeBeneficiary Address to receive all pool JLT fees
     */
    function setFeeBeneficiary(address newFeeBeneficiary) external onlyFeeManager {
        _validateFeeReceiver(newFeeBeneficiary);
        feeBeneficiary = newFeeBeneficiary;

        emit BaseWithdrawalFeeUpdate(baseWithdrawalRate, newFeeBeneficiary, false);
        emit BaseRetirementFeeUpdate(baseRetirementRate, newFeeBeneficiary);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Creates a Uniswap V3 pool between JLT and USDC
     * 
     * @param JLTPool Address of JLT pool to create Uniswap pool between USDC
     * @param sqrtPriceX96 Initial price of the pool. See [docs]().
     */
    function _createUniswapPool(
        address JLTPool,
        uint160 sqrtPriceX96
    ) 
        private
        returns (address pool)
    {
        (address token0, address token1) = JLTPool < USDC ? (JLTPool, USDC) : (USDC, JLTPool);
        require(token0 < token1);
        
        pool = IUniswapV3Factory(UniswapFactory).getPool(token0, token1, defaultUniswapFee);

        if (pool == address(0)) {
            pool = IUniswapV3Factory(UniswapFactory).createPool(JLTPool, USDC, defaultUniswapFee);
            IUniswapV3Pool(pool).initialize(sqrtPriceX96);
        } else {
            (uint160 sqrtPriceX96Existing, , , , , , ) = IUniswapV3Pool(pool).slot0();
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
    )
        internal view
        returns (address poolAddress)
    {
        bytes memory bytecode = type(ERC1967Proxy).creationCode;
        bytes memory proxyByteCode = abi.encodePacked(bytecode, abi.encode(_poolImplementations.at(implementationIndex), ""));
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
    )
        internal
    {
        _pools.add(policyHash);
        _poolVersions[policyHash] = poolImplementationIndex;
    }

    /**
     * @dev Checks if a given address implements JasminePool Interface and IERC1155Receiver, is not
     *      already in list of pool and is not empty
     * 
     * @dev Throws PoolExists(address pool) if policyHash exists or throws InvalidConformance(bytes4 interfaceId)
     *      if implementation fails interface checks or errors if address is empty
     * 
     * @param poolImplementation Address of pool implementation
     */
    function _validatePoolImplementation(address poolImplementation)
        internal view 
    {
        require(
            poolImplementation != address(0x0),
            "JasminePoolFactory: Pool implementation must be set"
        );

        if (!IERC165(poolImplementation).supportsInterface(type(IJasminePool).interfaceId))
            revert JasmineErrors.InvalidConformance(type(IJasminePool).interfaceId);
        
        if (!IERC165(poolImplementation).supportsInterface(type(IERC1155Receiver).interfaceId))
            revert JasmineErrors.InvalidConformance(type(IERC1155Receiver).interfaceId);

        if (_poolImplementations.contains(poolImplementation)) 
            revert JasmineErrors.PoolExists(poolImplementation);
    }

    /**
     * @dev Checks if a given address is valid to receive JLT fees. Address cannot be zero and if
     *      address is a contract, must support IERC777Recipient interface via ERC-165
     * 
     * @param newFeeBeneficiary Address to validate
     */
    function _validateFeeReceiver(address newFeeBeneficiary)
        internal view
    {
        require(
            newFeeBeneficiary != address(0x0),
            "JasminePoolFactory: Fee beneficiary must be set"
        );
        if (newFeeBeneficiary.isContract()) {
            require(
                IERC165(newFeeBeneficiary).supportsInterface(type(IERC777Recipient).interfaceId),
                "JasminePoolFactory: Fee beneficiary must support IERC777Recipient interface"
            );
        }
    }

    //  ────────────────────────────────  Modifiers  ────────────────────────────────  \\

    /**
     * @dev Enforces caller has fee manager role in pool factory
     */
    modifier onlyFeeManager() {
        if (!hasRole(FEE_MANAGER_ROLE, _msgSender())) {
            revert JasmineErrors.RequiresRole(FEE_MANAGER_ROLE);
        }
        _;
    }

}
