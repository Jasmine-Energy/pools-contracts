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

// Utility Libraries
import { PoolPolicy } from "./libraries/PoolPolicy.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";


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
    using PoolPolicy for PoolPolicy.DepositPolicy;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @dev List of pool deposit policy hashes. As pools are deployed via create2,
     *      address of a pool from the hash can be computed as needed.
     */
    EnumerableSet.Bytes32Set private _pools;

    /// @dev Implementation address for pools
    address public poolImplementation;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Setup
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @param _poolImplementation Address containing Jasmine Pool implementation
     */
    constructor(address _poolImplementation) Ownable2Step() {
        require(
            poolImplementation != address(0x0),
            "JasminePoolFactory: Pool implementation must be set"
        );
        require(
            IERC165(poolImplementation).supportsInterface(type(IJasminePool).interfaceId),
            "JasminePoolFactory: Pool does not conform to Jasmine Pool Interface"
        );
        poolImplementation = _poolImplementation;
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
        require(index < _pools.length(), "JasminePoolFactory: Pool does not exist");
        return _predictDeploymentAddress(_pools.at(index));
    }

    function eligiblePoolsForToken(uint256 tokenId) external view returns(address[] memory pools) {
        revert("JasminePoolFactory: Unimplemented");
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Admin Functionality
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ────────────────────────────  Pool Management  ──────────────────────────────  \\

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
    function deployNewPool(
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
        bytes32 policyHash = keccak256(encodedPolicy);

        // 2. Ensure policy does not exist
        if (_pools.contains(policyHash)) {
            revert PoolExists(_predictDeploymentAddress(policyHash));
        }

        // 3. Deploy new pool
        ERC1967Proxy poolProxy = new ERC1967Proxy{ salt: policyHash }(
            poolImplementation, ""
        );

        // 4. Ensure new pool matches expected
        require(
            _predictDeploymentAddress(policyHash) == address(poolProxy),
            "JasminePoolFactory: Deployment failed. Pool address does not match expected"
        );

        // 5. Initialize pool, add to pools, emit creation event and return new pool
        IJasminePool(address(poolProxy)).initialize(encodedPolicy, name, symbol);

        emit PoolCreated(encodedPolicy, address(poolProxy), name, symbol);

        _pools.add(policyHash);

        return address(poolProxy);
    }


    /**
     * @dev Allows owner to update the address pool proxies point to.
     * 
     * @param newPoolImplementation Address new pool proxies will point to
     */
    function updateImplementationAddress(
        address newPoolImplementation
    ) external onlyOwner {
        poolImplementation = newPoolImplementation;

        // TODO: Should prob update existing proxy implementations
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Determines the address of a newly deployed proxy, salted with the policy
     *      and deployed via CREATE2
     * 
     * @param policyHash Keccak256 hash of pool's deposit policy
     * @return Predicted address of pool
     */
    function _predictDeploymentAddress(bytes32 policyHash)
        internal view
        returns(address) {
        bytes memory bytecode = type(ERC1967Proxy).creationCode;
        bytes memory proxyByteCode = abi.encodePacked(bytecode, abi.encode(poolImplementation, ""));
        return Create2.computeAddress(policyHash, keccak256(proxyByteCode));
    }

}
