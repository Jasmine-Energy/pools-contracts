// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Implementation Contracts
import { JasmineBasePool } from "../core/JasmineBasePool.sol";

// External Contracts
import { JasminePoolFactory } from "../../JasminePoolFactory.sol";

// Utility Libraries
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
    // Events
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Emitted whenever fee manager updates withdrawal fee
     * 
     * @param withdrawFeeBips New withdrawal fee in basis points
     * @param beneficiary Address to receive fees
     */
    event WithdrawalFeeUpdate(
        uint96 withdrawFeeBips,
        address indexed beneficiary
    );

    /**
     * @dev Emitted whenever fee manager updates retirement fee
     * 
     * @param retirementFeeBips new retirement fee in basis points
     * @param beneficiary Address to receive fees
     */
    event RetirementFeeUpdate(
        uint96 retirementFeeBips,
        address indexed beneficiary
    );


    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Fee for withdrawals in basis points
    uint96 private _withdrawalFee;

    /// @dev Fee for retirements in basis points
    uint96 private _retirementFee;


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
     * @notice Returns the pool's JLT withdrawal fee in basis points
     * 
     * @dev If pool's withdrawal fee is not set, defer to pool factory's base fee
     * 
     * @return Withdrawal fee in basis points
     */
    function withdrawalFee() public view returns (uint96) {
        if (_withdrawalFee != 0) {
            return _withdrawalFee;
        } else {
            return JasminePoolFactory(poolFactory).baseWithdrawalFee();
        }
    }

    /**
     * @notice Returns the pool's JLT retirement fee in basis points
     * 
     * @dev If pool's retirement fee is not set, defer to pool factory's base fee
     * 
     * @return Retirement fee in basis points
     */
    function retirementFee() public view returns (uint96) {
        if (_retirementFee != 0) {
            return _retirementFee;
        } else {
            return JasminePoolFactory(poolFactory).baseRetirementFee();
        }
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // Admin Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Allows pool fee managers to update the withdrawal fee
     * 
     * @dev Requirements:
     *     - Caller must have fee manager role - in pool factory
     * 
     * @dev emits WithdrawalFeeUpdate
     * 
     * @param newWithdrawalFee New fee on withdrawals in basis points
     */
    function updateWithdrawalFee(uint96 newWithdrawalFee) 
        external virtual
        onlyFeeManager
    {
        _updateWithdrawalFee(newWithdrawalFee);
    }

    /**
     * @notice Allows pool fee managers to update the withdrawal fee
     * 
     * @dev Requirements:
     *     - Caller must have fee manager role - in pool factory
     * 
     * @dev emits RetirementFeeUpdate
     * 
     * @param newRetirementFee New fee on retirements in basis points
     */
    function updateRetirementFee(uint96 newRetirementFee) 
        external virtual
        onlyFeeManager
    {
        _updateRetirementFee(newRetirementFee);
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Overrides
    //  ─────────────────────────────────────────────────────────────────────────────

    // @inheritdoc {IRetireablePool}
    // TODO: Once pool conforms to IJasminePool again, add above line to natspec
    function retire(
        address sender,
        address,
        uint256,
        bytes calldata
    )
        external virtual override
        nonReentrant onlyOperator(sender)
    {
        // TODO: Implement me
        revert("JasmineBasePool: Unimplemented");
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Internal method for setting withdrawal fee
     * 
     * @param newWithdrawalFee New fee on withdrawals in basis points
     */
    function _updateWithdrawalFee(uint96 newWithdrawalFee) 
        internal virtual
    {
        _withdrawalFee = newWithdrawalFee;

        emit WithdrawalFeeUpdate(newWithdrawalFee, _msgSender());
    }

    /**
     * @dev Internal method for setting retirement fee
     * 
     * @param newRetirementFee New fee on retirements in basis points
     */
    function _updateRetirementFee(uint96 newRetirementFee) 
        internal virtual
    {
        _retirementFee = newRetirementFee;

        emit RetirementFeeUpdate(newRetirementFee, _msgSender());
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