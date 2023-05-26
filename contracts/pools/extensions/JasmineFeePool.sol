// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Implementation Contracts
import { JasmineBasePool } from "../core/JasmineBasePool.sol";

// Interfaces
import { IFeePool } from "../../interfaces/pool/IFeePool.sol";

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
abstract contract JasmineFeePool is JasmineBasePool, IFeePool {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using ArrayUtils for uint256[];


    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Fee for withdrawals in basis points
    uint96 private _withdrawalRate;

    /// @dev Fee for withdrawals in basis points
    uint96 private _withdrawalSpecificRate;

    /// @dev Fee for retirements in basis points
    uint96 private  _retirementRate;


    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @param _eat Jasmine Energy Attribute Token address
     * @param _poolFactory Jasmine Pool Factory address
     */
    constructor(address _eat, address _poolFactory, address _minter)
        JasmineBasePool(_eat, _poolFactory, _minter)
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
     * @notice Returns the pool's JLT withdrawal rate for withdrawing specific tokens,
     *         in basis points
     * 
     * @dev If pool's specific withdrawal rate is not set, defer to pool factory's base rate
     * 
     * @return Withdrawal fee in basis points
     */
    function withdrawalSpecificRate() public view returns (uint96) {
        if (_withdrawalSpecificRate != 0) {
            return _withdrawalSpecificRate;
        } else {
            return JasminePoolFactory(poolFactory).baseWithdrawalSpecificRate();
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

    /// @inheritdoc JasmineBasePool
    function _withdraw(
        address sender,
        address recipient,
        uint256 cost,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) 
        internal virtual override
    {
        // 1. If fee is not 0, calculate and take fee from caller

        // NOTE: Implicit in this implementation is that both withdrawal cost
        // NOTE: functions in parent return same value for any and specific
        uint256 feeAmount = cost - super.withdrawalCost(tokenIds, amounts);
        if (feeAmount != 0 && 
            JasminePoolFactory(poolFactory).feeBeneficiary() != address(0x0))
        {
            _transfer(
                sender,
                JasminePoolFactory(poolFactory).feeBeneficiary(),
                feeAmount
            );
        }
        // 2. Call super
        super._withdraw(sender, recipient, cost - feeAmount, tokenIds, amounts, data);
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
        // NOTE: If no feeBeneficiary is set, fees may not be collected
        if (JasminePoolFactory(poolFactory).feeBeneficiary() != address(0x0)) {
            return Math.mulDiv(
                super.withdrawalCost(tokenIds, amounts), 
                (withdrawalRate() + 10_000), 
                10_000
            );
        } else {
            return super.withdrawalCost(tokenIds, amounts);
        }
    }

    /**
     * @notice Cost of withdrawing amount of tokens from pool where pool
     *         selects the tokens to withdraw, including withdrawal fee.
     * 
     * @param amount Number of EATs to withdraw.
     * 
     * @return cost Price of withdrawing EATs in JLTs
     */
    function withdrawalCost(
        uint256 amount
    )
        public view virtual override
        returns (uint256 cost)
    {
        // NOTE: If no feeBeneficiary is set, fees may not be collected
        if (JasminePoolFactory(poolFactory).feeBeneficiary() != address(0x0)) {
            return Math.mulDiv(
                super.withdrawalCost(amount), 
                (withdrawalSpecificRate() + 10_000), 
                10_000
            );
        } else {
            return super.withdrawalCost(amount);
        }
    }

    /**
     * @notice Cost of retiring JLTs from pool including retirement fees.
     * 
     * @param amount Amount of JLTs to retire.
     * 
     * @return cost Price of retiring in JLTs.
     */
    function retirementCost(
        uint256 amount
    )
        public view virtual override
        returns (uint256 cost)
    {
        // NOTE: If no feeBeneficiary is set, fees may not be collected
        if (JasminePoolFactory(poolFactory).feeBeneficiary() != address(0x0)) {
            return Math.mulDiv(
                super.retirementCost(amount), 
                (retirementRate() + 10_000), 
                10_000
            );
        } else {
            return super.retirementCost(amount);
        }
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
