// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Implementation Contracts
import { JasmineBasePool } from "../core/JasmineBasePool.sol";

// External Contracts
import { JasminePoolFactory } from "../../JasminePoolFactory.sol";

// Utility Libraries
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { ArrayUtils } from "../../libraries/ArrayUtils.sol";
import { 
    ERC20Errors,
    ERC1155Errors
} from "../../interfaces/ERC/IERC6093.sol";
import { JasmineErrors } from "../../interfaces/errors/JasmineErrors.sol";


/**
 * @title Jasmine Fee Pool
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Extends JasmineBasePool with withdrawal and retirement fees managed by
 *         a universal admin entity.
 * @custom:security-contact dev@jasmine.energy
 * 
 * QUESTION: Should there be a maximum permitted fee?
 */
abstract contract JasmineFeePool is JasmineBasePool {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using ArrayUtils for uint256[];

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
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Fee for withdrawals in basis points
    uint96 private _withdrawalRate;

    /// @dev Fee for retirements in basis points
    uint96 private  _retirementRate;


    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @param _eat Jasmine Energy Attribute Token address
     * @param _poolFactory Jasmine Pool Factory address
     */
    constructor(address _eat, address _poolFactory) 
        JasmineBasePool(_eat, _poolFactory)
    {
        
    }


    // ──────────────────────────────────────────────────────────────────────────────
    // User Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Returns the pool's JLT withdrawal rate in basis points
     * 
     * @dev If pool's withdrawal rate is not set, defer to pool factory's base rate
     * 
     * @return Withdrawal fee in basis points
     */
    function withdrawalRate() public view returns (uint96) {
        if (_withdrawalRate != 0) {
            return _withdrawalRate;
        } else {
            return JasminePoolFactory(poolFactory).baseWithdrawalRate();
        }
    }

    /**
     * @notice Returns the pool's JLT retirement rate in basis points
     * 
     * @dev If pool's retirement rate is not set, defer to pool factory's base rate
     * 
     * @return Retirement rate in basis points
     */
    function retirementRate() public view returns (uint96) {
        if ( _retirementRate != 0) {
            return  _retirementRate;
        } else {
            return JasminePoolFactory(poolFactory).baseRetirementRate();
        }
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // Admin Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Allows pool fee managers to update the withdrawal rate
     * 
     * @dev Requirements:
     *     - Caller must have fee manager role - in pool factory
     * 
     * @dev emits WithdrawalRateUpdate
     * 
     * @param newWithdrawalRate New rate on withdrawals in basis points
     */
    function updateWithdrawalRate(uint96 newWithdrawalRate) 
        external virtual
        onlyFeeManager
    {
        _updateWithdrawalRate(newWithdrawalRate);
    }

    /**
     * @notice Allows pool fee managers to update the retirement rate
     * 
     * @dev Requirements:
     *     - Caller must have fee manager role - in pool factory
     * 
     * @dev emits RetirementRateUpdate
     * 
     * @param newRetirementRate New rate on retirements in basis points
     */
    function updateRetirementRate(uint96 newRetirementRate) 
        external virtual
        onlyFeeManager
    {
        _updateRetirementRate(newRetirementRate);
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Overrides
    //  ─────────────────────────────────────────────────────────────────────────────

    function _withdraw(
        address sender,
        address recipient,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) 
        internal virtual override
        nonReentrant onlyOperator(sender)
    {
        // 1. Take fee from caller
        // TODO Take fee and send to fee beneficiary

        // 2. Call super
        super._withdraw(sender, recipient, tokenIds, amounts, data);
    }

    /**
     * @notice Cost of withdrawing specified amounts of tokens from pool including
     *         withdrawal fee.
     * 
     * @param tokenIds IDs of EATs to withdaw
     * @param amounts Amounts of EATs to withdaw
     * 
     * @return cost Price of withdrawing EATs in JLTs
     */
    function withdrawalCost(
        uint256[] memory tokenIds,
        uint256[] memory amounts
    )
        public view virtual override
        returns (uint256 cost)
    {
        if (tokenIds.length != amounts.length) {
            revert ERC1155Errors.ERC1155InvalidArrayLength(
                tokenIds.length,
                amounts.length
            );
        }
        return Math.mulDiv(
            super.withdrawalCost(tokenIds, amounts), 
            (withdrawalRate() + 10_000), 
            10_000
        );
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Internal method for setting withdrawal rate
     * 
     * @param newWithdrawalRate New rate on withdrawals in basis points
     */
    function _updateWithdrawalRate(uint96 newWithdrawalRate) 
        internal virtual
    {
        _withdrawalRate = newWithdrawalRate;

        emit WithdrawalRateUpdate(newWithdrawalRate, _msgSender());
    }

    /**
     * @dev Internal method for setting retirement fee
     * 
     * @param newRetirementRate New fee on retirements in basis points
     */
    function _updateRetirementRate(uint96 newRetirementRate) 
        internal virtual
    {
         _retirementRate = newRetirementRate;

        emit RetirementRateUpdate(newRetirementRate, _msgSender());
    }
    
    //  ────────────────────────────────  Modifiers  ────────────────────────────────  \\

    /**
     * @dev Enforces caller has fee manager role in pool factory
     */
    modifier onlyFeeManager() {
        if (!JasminePoolFactory(poolFactory).hasFeeManagerRole(_msgSender())) {
            revert JasmineErrors.RequiresRole(JasminePoolFactory(poolFactory).FEE_MANAGER_ROLE());
        }
        _;
    }

}