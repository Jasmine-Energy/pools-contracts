// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Jasmine Fee Manager Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Standard interface for fee manager contract in 
 *         Jasmine reference pools
 * @custom:security-contact dev@jasmine.energy
 */
interface IJasmineFeeManager {

    // ──────────────────────────────────────────────────────────────────────────────
    // Events
    // ──────────────────────────────────────────────────────────────────────────────


    //  ───────────────────────────────  Fee Events  ───────────────────────────────  \\

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
    // Fee Visibility Functions
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Default fee for withdrawals across pools. May be overridden per pool
    function baseWithdrawalRate() external returns(uint96);

    /// @dev Default fee for withdrawing specific EATs from pools. May be overridden per pool
    function baseWithdrawalSpecificRate() external returns(uint96);

    /// @dev Default fee for retirements across pools. May be overridden per pool
    function baseRetirementRate() external returns(uint96);

    /// @dev Address to receive fees
    function feeBeneficiary() external returns(address);
}
