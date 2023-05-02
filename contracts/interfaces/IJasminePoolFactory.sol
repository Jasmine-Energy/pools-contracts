// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

import { PoolPolicy } from "../libraries/PoolPolicy.sol";

/**
 * @title Jasmine Pool Factory Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
 * @custom:security-contact dev@jasmine.energy
 */
interface IJasminePoolFactory {

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Events
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Emitted when a new Jasmine pool is created
     * 
     * @param policy Pool's deposit policy in bytes
     * @param pool Address of newly created pool
     * @param name Name of the pool
     * @param symbol Token symbol of the pool
     */
    event PoolCreated(
        bytes policy,
        address indexed pool,
        string  indexed name,
        string  indexed symbol
    );

    /**
     * @notice Emitted when new pool implementations are supported by factory
     * 
     * @param poolImplementation Address of newly supported pool implementation
     * @param beaconAddress Address of Beacon smart contract
     * @param poolIndex Index of new pool in set of pool implementations
     */
    event PoolImplementationAdded(
        address indexed poolImplementation,
        address indexed beaconAddress,
        uint256 indexed poolIndex
    );

    /**
     * @notice Emitted when a pool's beacon implementation updates
     * 
     * @param newPoolImplementation Address of new pool implementation
     * @param beaconAddress Address of Beacon smart contract
     * @param poolIndex Index of new pool in set of pool implementations
     */
    event PoolImplementationUpgraded(
        address indexed newPoolImplementation,
        address indexed beaconAddress,
        uint256 indexed poolIndex
    );

    /**
     * @notice Emitted when a pool implementations is removed
     * 
     * @param poolImplementation Address of deleted pool implementation
     * @param beaconAddress Address of Beacon smart contract
     * @param poolIndex Index of deleted pool in set of pool implementations
     */
    event PoolImplementationRemoved(
        address indexed poolImplementation,
        address indexed beaconAddress,
        uint256 indexed poolIndex
    );


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Pool Interactions
    //  ─────────────────────────────────────────────────────────────────────────────

    function totalPools() external view returns (uint256);

    function getPoolAtIndex(uint256 index) external view returns (address pool);

    function eligiblePoolsForToken(uint256 tokenId) external view returns (address[] memory pools);
}
