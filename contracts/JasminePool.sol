// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Parent Contract
import { JasmineBasePool } from "./pools/core/JasmineBasePool.sol";
import { JasmineFeePool } from "./pools/extensions/JasmineFeePool.sol";

// External Contracts
import { JasmineOracle } from "@jasmine-energy/contracts/src/JasmineOracle.sol";

// Utility Libraries
import { PoolPolicy } from "./libraries/PoolPolicy.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { JasmineErrors } from "./interfaces/errors/JasmineErrors.sol";


/**
 * TODO: Write docs
 * @title Jasmine Reference Pool
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
 * @custom:security-contact dev@jasmine.energy
 */
contract JasminePool is JasmineBasePool, JasmineFeePool {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using PoolPolicy for PoolPolicy.DepositPolicy;
    using EnumerableSet for EnumerableSet.UintSet;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Policy to deposit into pool
    PoolPolicy.DepositPolicy internal _policy;

    JasmineOracle public immutable oracle;


    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    constructor(address _eat, address _oracle, address _poolFactory, address _minter)
        JasmineFeePool(_eat, _poolFactory, _minter)
    {
        require(_oracle != address(0), "JasminePool: Oracle must be set");

        oracle = JasmineOracle(_oracle);
    }

    /**
     * @dev Initializer function for proxy deployments to call.
     * 
     * @dev Requirements:
     *     - Caller must be factory
     *
     * @param policy_ Deposit Policy Conditions
     * @param name_ JLT token name
     * @param symbol_ JLT token symbol
     */
    function initialize(
        bytes calldata policy_,
        string calldata name_,
        string calldata symbol_
    )
        external
        initializer onlyInitializing onlyFactory
    {
        _policy = abi.decode(policy_, (PoolPolicy.DepositPolicy));

        super.initialize(name_, symbol_);
    }


    // ──────────────────────────────────────────────────────────────────────────────
    // Deposit Policy Overrides
    // ──────────────────────────────────────────────────────────────────────────────

    // @inheritdoc {IQualifiedPool}
    // TODO: Once pool conforms to IJasminePool again, add above line to natspec
    function meetsPolicy(uint256 tokenId)
        public view override
        returns (bool isEligible)
    {
        return super.meetsPolicy(tokenId) && _policy.meetsPolicy(oracle, tokenId);
    }

    // @inheritdoc {IQualifiedPool}
    // TODO: Once pool conforms to IJasminePool again, add above line to natspec
    function policyForVersion(uint8 metadataVersion)
        external view override
        returns (bytes memory policy)
    {
        require(metadataVersion == 1, "JasminePool: No policy for version");
        return abi.encode(
            _policy.vintagePeriod,
            _policy.techType,
            _policy.registry,
            _policy.certification,
            _policy.endorsement
        );
    }


    // ──────────────────────────────────────────────────────────────────────────────
    // Withdraw Overrides
    // ──────────────────────────────────────────────────────────────────────────────

    /// @inheritdoc JasmineFeePool
    function withdrawalCost(
        uint256[] memory tokenIds,
        uint256[] memory amounts
    )
        public view override(JasmineBasePool, JasmineFeePool)
        returns (uint256 cost)
    {
        return super.withdrawalCost(tokenIds, amounts);
    }

    /// @inheritdoc JasmineFeePool
    function withdrawalCost(
        uint256 amount
    )
        public view override(JasmineBasePool, JasmineFeePool)
        returns (uint256 cost)
    {
        return super.withdrawalCost(amount);
    }

    /// @inheritdoc JasmineFeePool
    function retirementCost(
        uint256 amount
    )
        public view override(JasmineBasePool, JasmineFeePool)
        returns (uint256 cost)
    {
        return super.retirementCost(amount);
    }

    /// @inheritdoc JasmineBasePool
    function _withdraw(
        address sender,
        address recipient,
        uint256 cost,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) 
        internal override(JasmineBasePool, JasmineFeePool)
    {
        super._withdraw(sender, recipient, cost, tokenIds, amounts, data);
    }
}
