// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Base
import { IEATBackedPool } from "./IEATBackedPool.sol";
import { IRetireablePool } from "./IRetireablePool.sol";


/**
 * @title Fee Pool Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Contains functionality and events for pools which have fees for
 *         withdrawals and retirements.
 * @custom:security-contact dev@jasmine.energy
 */
interface IFeePool is IEATBackedPool, IRetireablePool {

    // ──────────────────────────────────────────────────────────────────────────────
    // Events
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Emitted whenever fee manager updates withdrawal fee
     * 
     * @param withdrawFeeBips New withdrawal fee in basis points
     * @param beneficiary Address to receive fees
     * @param isSpecificRate Whether fee was update for specific withdrawals or any
     */
    event WithdrawalRateUpdate(
        uint96 withdrawFeeBips,
        address indexed beneficiary,
        bool isSpecificRate
    );

    /**
     * @dev Emitted whenever fee manager updates retirement fee
     * 
     * @param retirementFeeBips new retirement fee in basis points
     * @param beneficiary Address to receive fees
     */
    event RetirementRateUpdate(
        uint96 retirementFeeBips,
        address indexed beneficiary
    );


    // ──────────────────────────────────────────────────────────────────────────────
    // Fee Getters
    // ──────────────────────────────────────────────────────────────────────────────

    /// @notice Withdrawal fee for any EATs from a pool in basis points
    function withdrawalRate() external view returns (uint96);

    /// @notice Withdrawal fee for specific EATs from a pool in basis points
    function withdrawalSpecificRate() external view returns (uint96);

    /// @notice Retirement fee for a pool's JLT in basis points
    function retirementRate() external view returns (uint96);


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Retireable Extensions
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Retires an exact amount of JLTs. If fees or other conversions are set,
     *         cost of retirement will be greater than amount.
     * 
     * @param owner JLT holder to retire from
     * @param beneficiary Address to receive retirement attestation
     * @param amount Exact number of JLTs to retire
     * @param data Optional calldata to relay to retirement service via onERC1155Received
     */
    function retireExact(
        address owner, 
        address beneficiary, 
        uint256 amount, 
        bytes calldata data
    ) external;

}
