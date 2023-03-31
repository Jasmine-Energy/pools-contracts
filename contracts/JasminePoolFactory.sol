// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Core Implementations
import { IJasminePoolFactory } from "./interfaces/IJasminePoolFactory.sol";
// TODO Should make new abstract class with TimelockController owner
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";

// External Contracts
import { IJasminePool } from "./interfaces/IJasminePool.sol";
import { JasmineEAT } from "@jasmine-energy/contracts/src/JasmineEAT.sol";

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Proxy } from "@openzeppelin/contracts/proxy/Proxy.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IERC1155Receiver } from "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";

// Utility Libraries
import { PoolPolicy } from "./libraries/PoolPolicy.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";
import { Address } from "@openzeppelin/contracts/utils/Address.sol";


//  ─────────────────────────────────────────────────────────────────────────────
//  Custom Errors
//  ─────────────────────────────────────────────────────────────────────────────

/// @dev Emitted if no pool(s) meet query
error NoPool();
/// @dev Emitted if a pool exists with given policy
error PoolExists(address pool);


/**
 * @title Jasmine Pool Factory
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
 * @custom:security-contact // TODO: set sec contact
 */
contract JasminePoolFactory is IJasminePoolFactory, Ownable2Step {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;
    using PoolPolicy for PoolPolicy.DepositPolicy;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @dev List of pool deposit policy hashes. As pools are deployed via create2,
     *      address of a pool from the hash can be computed as needed.
     */
    EnumerableSet.Bytes32Set internal _pools;

    /**
     * @dev Mapping of Deposit Policy (aka pool init data) hash to _poolImplementations
     *      index. Used to determine CREATE2 address
     */
    mapping(bytes32 => uint256) internal _poolVersions;

    /// @dev Implementation addresses for pools
    EnumerableSet.AddressSet internal _poolImplementations;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Setup
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @param _poolImplementation Address containing Jasmine Pool implementation
     */
    constructor(address _poolImplementation) Ownable2Step() {
        _validatePoolImplementation(_poolImplementation);

        _poolImplementations.add(_poolImplementation);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  User Functionality
    //  ─────────────────────────────────────────────────────────────────────────────


    //  ───────────────  Jasmine Pool Factory Interface Conformance  ────────────────  \\

    /// @notice Returns the total number of pools deployed
    function totalPools() external view returns(uint256) {
        return _pools.length();
    }

    /**
     * @notice Used to obtain the address of a pool in the set of pools - if it exists.
     * 
     * @param index Index of the deployed pool in set of pools
     * @return pool Address of pool in set
     */
    function getPoolAtIndex(uint256 index) external view returns(address pool) {
        if (index >= _pools.length()) revert NoPool();
        return computePoolAddress(_pools.at(index));
    }

    function eligiblePoolsForToken(uint256 tokenId) external view returns(address[] memory pools) {
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
     *      hash of Deposit Policy.
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
    ) external onlyOwner returns(address newPool) {
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
    ) public onlyOwner returns(address newPool) {

        // 1. Compute hash of init data
        bytes32 policyHash = keccak256(initData);

        // 2. Ensure policy does not exist
        if (_pools.contains(policyHash)) {
            revert PoolExists(computePoolAddress(policyHash));
        }

        // 3. Deploy new pool
        ERC1967Proxy poolProxy = new ERC1967Proxy{ salt: policyHash }(
            _poolImplementations.at(version), ""
        );

        // 4. Ensure new pool matches expected
        require(
            _predictDeploymentAddress(policyHash, 0) == address(poolProxy),
            "JasminePoolFactory: Deployment failed. Pool address does not match expected"
        );

        // 5. Initialize pool, add to pools, emit creation event and return new pool
        Address.functionCall(address(poolProxy), abi.encodePacked(initSelector, abi.encode(initData, name, symbol)));

        emit PoolCreated(initData, address(poolProxy), name, symbol);

        _addDeployedPool(policyHash, version);

        return address(poolProxy);
    }

    //  ────────────────────────────  Pool Management  ──────────────────────────────  \\


    /**
     * @dev Allows owner to update a pool implementation.
     * 
     * @param newPoolImplementation New address to replace
     * @param poolIndex Index of pool to replace
     * TODO: Would be nice to have an overloaded version that takes address of pool to update
     */
    function updateImplementationAddress(
        address newPoolImplementation,
        uint256 poolIndex
    ) external onlyOwner {
        removePoolImplementation(poolIndex);
        addPoolImplementation(newPoolImplementation);
    }

    /**
     * @dev Used to add a new pool implementation
     * 
     * @param newPoolImplementation New pool implementation address to support
     */
    function addPoolImplementation(address newPoolImplementation) 
        public onlyOwner
        returns(uint256 indexInPools) {
        _validatePoolImplementation(newPoolImplementation);

        require(
            _poolImplementations.add(newPoolImplementation),
            "JasminePoolFactory: Failed to add new pool"
        );

        emit PoolImplementationAdded(newPoolImplementation, _poolImplementations.length() - 1);
    }

    /**
     * @dev Used to remove a pool implementation
     * 
     * @param poolIndex Index of pool to remove
     * TODO: Would be nice to have an overloaded version that takes address of pool to remove
     * NOTE: This will break CREATE2 address predictions. Think of means around this
     */
    function removePoolImplementation(uint256 poolIndex)
        public onlyOwner {

        revert("JasminePoolFactory: Currently unsupported");

        address pool = _poolImplementations.at(poolIndex);
        require(
            _poolImplementations.remove(pool),
            "JasminePoolFactory: Failed to remove pool"
        );

        emit PoolImplementationRemoved(pool, poolIndex);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Utilities
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Utility function to calculate deployed address of a pool from its
     *         policy hash.
     * 
     * @dev Requirements:
     *     - Policy hash must exist in existing pools
     * 
     * @param policyHash Policy hash of pool to compute address of
     * @return poolAddress Address of deployed pool
     */
    function computePoolAddress(bytes32 policyHash)
        public view
        returns(address poolAddress) {
        return _predictDeploymentAddress(policyHash, _poolVersions[policyHash]);
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Determines the address of a newly deployed proxy, salted with the policy
     *      and deployed via CREATE2
     * 
     * @param policyHash Keccak256 hash of pool's deposit policy
     * @return poolAddress Predicted address of pool
     */
    function _predictDeploymentAddress(bytes32 policyHash, uint256 implementationIndex)
        internal view
        returns(address poolAddress) {
        bytes memory bytecode = type(ERC1967Proxy).creationCode;
        bytes memory proxyByteCode = abi.encodePacked(bytecode, abi.encode(_poolImplementations.at(implementationIndex), ""));
        return Create2.computeAddress(policyHash, keccak256(proxyByteCode));
    }

    /**
     * @dev Used to add newly deployed pools to list of pool and record pool implementation
     *      that was used.
     * 
     * @param policyHash Keccak256 hash of pool's deposit policy
     * @param poolImplementationIndex Index of pool implementation that was deployed
     */
    function _addDeployedPool(bytes32 policyHash, uint256 poolImplementationIndex) internal {
        _pools.add(policyHash);
        _poolVersions[policyHash] = poolImplementationIndex;
    }

    /**
     * @dev Checks if a given address implements JasminePool Interface and IERC1155Receiver, is not
     *      already in list of pool and is not empty.
     * 
     * @param poolImplementation Address of pool implementation
     */
    function _validatePoolImplementation(address poolImplementation)
        internal view {
        require(
            poolImplementation != address(0x0),
            "JasminePoolFactory: Pool implementation must be set"
        );
        require(
            IERC165(poolImplementation).supportsInterface(type(IJasminePool).interfaceId),
            "JasminePoolFactory: Pool does not conform to Jasmine Pool Interface"
        );
        require(
            IERC165(poolImplementation).supportsInterface(type(IERC1155Receiver).interfaceId),
            "JasminePoolFactory: Pool does not conform to IERC1155Receiver"
        );

        if (_poolImplementations.contains(poolImplementation)) revert PoolExists(poolImplementation);
    }
}
