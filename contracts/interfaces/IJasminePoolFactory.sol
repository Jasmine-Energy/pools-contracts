// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;

import { PoolPolicy } from "../libraries/PoolPolicy.sol";

/**
 * @title Jasmine Pool Factory Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
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


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Pool Interactions
    //  ─────────────────────────────────────────────────────────────────────────────

    function totalPools() external view returns(uint256);

    function getPoolAtIndex(uint256 index) external view returns(address pool);

    function eligiblePoolsForToken(uint256 tokenId) external view returns(address[] memory pools);
}
