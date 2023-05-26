// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


/**
 * @title Fee Pool Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Contains functionality and events for pools which have fees for
 *         withdrawals and retirements.
 * @custom:security-contact dev@jasmine.energy
 */
interface IFeePool {

    // ──────────────────────────────────────────────────────────────────────────────
    // Events
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Emitted whenever fee manager updates withdrawal fee
     * 
     * @param withdrawFeeBips New withdrawal fee in basis points
     * @param beneficiary Address to receive fees
     */
    event WithdrawalRateUpdate(
        uint96 withdrawFeeBips,
        address indexed beneficiary
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
}
