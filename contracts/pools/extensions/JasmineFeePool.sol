// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;

//  ─────────────────────────────────  Imports  ─────────────────────────────────  \\

// Inheritted Contracts
import { JasmineBasePool } from "../core/JasmineBasePool.sol";

// Implemented Interfaces
import { IJasminePool }                              from "../../interfaces/IJasminePool.sol";
import { IJasmineEATBackedPool  as IEATBackedPool }  from "../../interfaces/pool/IEATBackedPool.sol";
import { IJasmineFeePool        as IFeePool }        from "../../interfaces/pool/IFeePool.sol";
import { IJasmineRetireablePool as IRetireablePool } from "../../interfaces/pool/IRetireablePool.sol";
import { JasmineErrors }                             from "../../interfaces/errors/JasmineErrors.sol";

// External Contracts
import { IJasmineFeeManager } from "../../interfaces/IJasmineFeeManager.sol";

// Utility Libraries
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";


/**
 * @title Jasmine Fee Pool
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Extends JasmineBasePool with withdrawal and retirement fees managed by
 *         a protocol wide fee manager roll.
 * @custom:security-contact dev@jasmine.energy
 */
abstract contract JasmineFeePool is JasmineBasePool, IFeePool {

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
     * @param _minter Address of the Jasmine Minter address
     * @param _contractName Name of the pool contract per EIP-712 and ERC-20
     */
    constructor(
        address _eat,
        address _poolFactory,
        address _minter,
        string memory _contractName
    )
        JasmineBasePool(_eat, _poolFactory, _minter, _contractName)
    { } // solhint-disable-line no-empty-blocks


    // ──────────────────────────────────────────────────────────────────────────────
    // User Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    //  ──────────────────────────  Retirement Functions  ───────────────────────────  \\

    /// @inheritdoc JasmineBasePool
    function retire(
        address spender,
        address beneficiary,
        uint256 amount,
        bytes calldata data
    )
        external virtual 
        override(IRetireablePool, JasmineBasePool)
    {
        // 1. If fee is set, calculate fee to take from amount given
        if (retirementRate() != 0) {
            uint256 feeAmount = Math.ceilDiv(amount, retirementRate());
            // 1.1 If spender if not caller, decrease allowance
            if (spender != _msgSender()) {
                _spendAllowance(spender, _msgSender(), feeAmount);
            }
            _transfer(
                spender,
                IJasmineFeeManager(poolFactory).feeBeneficiary(),
                feeAmount
            );
            amount -= feeAmount;
        }

        // 2. Execute retirement
        _retire(spender, beneficiary, amount, data);
    }

    /// @inheritdoc IFeePool
    function retireExact(
        address spender, 
        address beneficiary, 
        uint256 amount, 
        bytes calldata data
    )
        external virtual
    {
        // 1. If fee is set, calculate excess fee on top of given amount
        if (retirementRate() != 0) {
            uint256 feeAmount = retirementCost(amount) - amount;
            // 1.1 If spender if not caller, decrease allowance
            if (spender != _msgSender()) {
                _spendAllowance(spender, _msgSender(), feeAmount);
            }
            _transfer(
                spender,
                IJasmineFeeManager(poolFactory).feeBeneficiary(),
                feeAmount
            );
        }
        
        // 2. Execute retirement
        _retire(spender, beneficiary, amount, data);
    }


    //  ──────────────────────────  Withdrawal Functions  ───────────────────────────  \\


    /// @inheritdoc JasmineBasePool
    function withdraw(
        address recipient,
        uint256 amount,
        bytes calldata data
    )
        external virtual
        override(IEATBackedPool, JasmineBasePool)
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        // 1. If fee is not 0, calculate and take fee from caller
        if (withdrawalRate() != 0) {
            uint256 feeAmount = JasmineFeePool.withdrawalCost(amount) - super.withdrawalCost(amount);
            _transfer(
                _msgSender(),
                IJasmineFeeManager(poolFactory).feeBeneficiary(),
                feeAmount
            );
        }

        // 2. Execute withdrawal
        (tokenIds, amounts) = selectWithdrawTokens(amount);
        _withdraw(
            _msgSender(),
            recipient,
            tokenIds,
            amounts,
            data
        );
        return (tokenIds, amounts);
    }

    /// @inheritdoc JasmineBasePool
    function withdrawFrom(
        address from,
        address recipient,
        uint256 amount,
        bytes calldata data
    )
        external virtual 
        override(IEATBackedPool, JasmineBasePool)
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        // 1. If fee is not 0, calculate and take fee from caller
        if (withdrawalRate() != 0) {
            uint256 feeAmount = JasmineFeePool.withdrawalCost(amount) - super.withdrawalCost(amount);
            // 1.1 If spender if not caller, decrease allowance
            if (from != _msgSender()) {
                _spendAllowance(from, _msgSender(), feeAmount);
            }
            _transfer(
                from,
                IJasmineFeeManager(poolFactory).feeBeneficiary(),
                feeAmount
            );
        }

        // 2. Execute withdrawal
        (tokenIds, amounts) = selectWithdrawTokens(amount);
        _withdraw(
            from,
            recipient,
            tokenIds,
            amounts,
            data
        );
        return (tokenIds, amounts);
    }

    /// @inheritdoc IEATBackedPool
    function withdrawSpecific(
        address from,
        address recipient,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) 
        external virtual 
        override(IEATBackedPool, JasmineBasePool)
    {
        // 1. If fee is not 0, calculate and take fee from caller
        if (withdrawalSpecificRate() != 0) {
            uint256 feeAmount = JasmineFeePool.withdrawalCost(tokenIds, amounts) - super.withdrawalCost(tokenIds, amounts);
            // 1.1 If spender if not caller, decrease allowance
            if (from != _msgSender()) {
                _spendAllowance(from, _msgSender(), feeAmount);
            }
            _transfer(
                from,
                IJasmineFeeManager(poolFactory).feeBeneficiary(),
                feeAmount
            );
        }

        // 2. Execute withdrawal
        _withdraw(
            from,
            recipient,
            tokenIds,
            amounts,
            data
        );
    }


    //  ────────────────────────────  Costing Functions  ────────────────────────────  \\


    /**
     * @notice Returns the pool's JLT withdrawal rate in basis points
     * 
     * @dev If pool's withdrawal rate is not set, defer to pool factory's base rate
     * 
     * @return Withdrawal fee in basis points
     */
    function withdrawalRate() public view returns (uint96) {
        if (IJasmineFeeManager(poolFactory).feeBeneficiary() == address(0x0)) {
            return 0;
        } else if (_withdrawalRate != 0) {
            return _withdrawalRate;
        } else {
            return IJasmineFeeManager(poolFactory).baseWithdrawalRate();
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
        if (IJasmineFeeManager(poolFactory).feeBeneficiary() == address(0x0)) {
            return 0;
        } else if (_withdrawalSpecificRate != 0) {
            return _withdrawalSpecificRate;
        } else {
            return IJasmineFeeManager(poolFactory).baseWithdrawalSpecificRate();
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
        if (IJasmineFeeManager(poolFactory).feeBeneficiary() == address(0x0)) {
            return 0;
        } else if ( _retirementRate != 0) {
            return  _retirementRate;
        } else {
            return IJasmineFeeManager(poolFactory).baseRetirementRate();
        }
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
        public view virtual 
        override(IEATBackedPool, JasmineBasePool)
        returns (uint256 cost)
    {
        if (tokenIds.length != amounts.length) {
            revert JasmineErrors.InvalidInput();
        }
        return Math.mulDiv(
            super.withdrawalCost(tokenIds, amounts), 
            (withdrawalRate() + 10_000), 
            10_000
        );
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
        public view virtual 
        override(IEATBackedPool, JasmineBasePool)
        returns (uint256 cost)
    {
        return Math.mulDiv(
            super.withdrawalCost(amount), 
            (withdrawalSpecificRate() + 10_000), 
            10_000
        );
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
        public view virtual 
        override(IRetireablePool, JasmineBasePool)
        returns (uint256 cost)
    {
        return Math.mulDiv(
            super.retirementCost(amount), 
            (retirementRate() + 10_000), 
            10_000
        );
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
     * @param isSpecificRate Whether the new rate is for specific tokens or any
     */
    function updateWithdrawalRate(uint96 newWithdrawalRate, bool isSpecificRate) external {
        _enforceFeeManagerRole();
        _updateWithdrawalRate(newWithdrawalRate, isSpecificRate);
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
    function updateRetirementRate(uint96 newRetirementRate) external {
        _enforceFeeManagerRole();
        _updateRetirementRate(newRetirementRate);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ─────────────────────────────  Fee Management  ──────────────────────────────  \\

    /**
     * @dev Internal method for setting withdrawal rate
     * 
     * @param newWithdrawalRate New rate on withdrawals in basis points
     * @param isSpecific Whether the rate is for specific or pool selected withdrawals
     */
    function _updateWithdrawalRate(uint96 newWithdrawalRate, bool isSpecific) private {
        if (isSpecific) {
            _withdrawalSpecificRate = newWithdrawalRate;
        } else {
            _withdrawalRate = newWithdrawalRate;
        }

        emit WithdrawalRateUpdate(newWithdrawalRate, _msgSender(), isSpecific);
    }

    /**
     * @dev Internal method for setting retirement fee
     * 
     * @param newRetirementRate New fee on retirements in basis points
     */
    function _updateRetirementRate(uint96 newRetirementRate) private {
        _retirementRate = newRetirementRate;

        emit RetirementRateUpdate(newRetirementRate, _msgSender());
    }
    
    //  ───────────────────────  Access Control Enforcement  ────────────────────────  \\

    /**
     * @dev Enforces caller has fee manager role in pool factory. 
     * 
     * @dev Throws {RequiresRole}
     */
    function _enforceFeeManagerRole() private view {
        if (!IJasmineFeeManager(poolFactory).hasFeeManagerRole(_msgSender())) {
            revert JasmineErrors.RequiresRole(IJasmineFeeManager(poolFactory).FEE_MANAGER_ROLE());
        }
    }
}
