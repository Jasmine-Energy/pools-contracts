// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


// Base
import { IEATBackedPool } from "./IEATBackedPool.sol";


/**
 * @title Retireable Pool Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Extends pools with retirement functionality and events.
 * @custom:security-contact dev@jasmine.energy
 */
interface IRetireablePool is IEATBackedPool {

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Events
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @notice emitted when tokens from a pool are retired
     * 
     * @dev must be accompanied by a token burn event
     * 
     * @param operator Initiator of retirement
     * @param beneficiary Designate beneficiary of retirement
     * @param quantity Number of tokens being retired
     */
    event Retirement(
        address indexed operator,
        address indexed beneficiary,
        uint256 quantity
    );


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Retirement Functionality
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Burns 'quantity' of tokens from 'owner' in the name of 'beneficiary'.
     * 
     * @dev Internally, calls are routed to Retirement Service to facilitate the retirement.
     * 
     * @dev Requirements:
     *     - msg.sender must be approved for owner's JLTs
     *     - Owner must have sufficient JLTs
     *     - Owner cannot be zero address
     * 
     * @param owner JLT owner from which to burn tokens
     * @param beneficiary Address to receive retirement acknowledgment. If none, assume msg.sender
     * @param quantity Number of JLTs to withdraw
     * @param data Optional calldata to relay to retirement service via onERC1155Received
     * 
     * @return success If retirement operation was successful, true will be returned
     * 
     * Emits a {Retirement} event.
     */
    function retire(
        address owner, 
        address beneficiary, 
        uint256 quantity, 
        bytes calldata data
    ) external returns (bool success);

}
