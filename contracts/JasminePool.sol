// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Parent Contract
import { JasmineBasePool } from "./pools/core/JasmineBasePool.sol";
import { JasmineFeePool }  from "./pools/extensions/JasmineFeePool.sol";

// Implemented Interfaces
import { IJasminePool }    from "./interfaces/IJasminePool.sol";
import { IQualifiedPool }  from "./interfaces/pool/IQualifiedPool.sol";
import { IRetireablePool } from "./interfaces/pool/IRetireablePool.sol";
import { IEATBackedPool }  from "./interfaces/pool/IEATBackedPool.sol";

// External Contracts
import { JasmineOracle } from "@jasmine-energy/contracts/src/JasmineOracle.sol";

// Utility Libraries
import { PoolPolicy }    from "./libraries/PoolPolicy.sol";
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

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Policy to deposit into pool
    PoolPolicy.DepositPolicy internal _policy;

    /// @dev Jasmine Oracle contract
    JasmineOracle public immutable oracle;


    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @param _eat Address of the Jasmine Energy Attribution Token (EAT) contract
     * @param _oracle Address of the Jasmine Oracle contract
     * @param _poolFactory Address of the Jasmine Pool Factory contract
     */
    constructor(
        address _eat,
        address _oracle,
        address _poolFactory,
        address _minter
    )
        JasmineFeePool(_eat, _poolFactory, _minter)
    {
        // NOTE: EAT, Pool Factory and Minting contracts are validated in JasmineBasePool
        if ( _oracle == address(0x0)) revert JasmineErrors.InvalidInput();

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
        initializer
    {
        _policy = abi.decode(policy_, (PoolPolicy.DepositPolicy));

        super.initialize(name_, symbol_);
    }


    // ──────────────────────────────────────────────────────────────────────────────
    // Deposit Policy Overrides
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Checks if a token is eligible for deposit into the pool based on the
     *      pool's Deposit Policy.
     * 
     * @param tokenId EAT token ID to check eligibility
     */
    function meetsPolicy(uint256 tokenId)
        public view override
        returns (bool isEligible)
    {
        return super.meetsPolicy(tokenId) && _policy.meetsPolicy(oracle, tokenId);
    }

    /// @inheritdoc IQualifiedPool
    function policyForVersion(uint8 metadataVersion)
        external view override
        returns (bytes memory policy)
    {
        if (metadataVersion != 1) revert JasmineErrors.UnsupportedMetadataVersion(metadataVersion);

        return abi.encode(
            _policy.vintagePeriod,
            _policy.techType,
            _policy.registry,
            _policy.certification,
            _policy.endorsement
        );
    }


    // ──────────────────────────────────────────────────────────────────────────────
    // Overrides
    // ──────────────────────────────────────────────────────────────────────────────

    //  ───────────────────────────  Withdraw Overrides  ────────────────────────────  \\

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

    /// @inheritdoc JasmineBasePool
    function withdraw(
        address recipient,
        uint256 amount,
        bytes calldata data
    )
        public override(JasmineFeePool, JasmineBasePool)
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        return super.withdraw(
            recipient,
            amount,
            data
        );
    }

    /// @inheritdoc JasmineBasePool
    function withdrawFrom(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data
    )
        public override(JasmineFeePool, JasmineBasePool)
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        return super.withdrawFrom(
            sender,
            recipient,
            amount,
            data
        );
    }

    /// @inheritdoc JasmineBasePool
    function withdrawSpecific(
        address sender,
        address recipient,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) 
        external override(JasmineFeePool, JasmineBasePool)
    {
        super._withdraw(
            sender,
            recipient,
            tokenIds,
            amounts,
            data
        );
    }    

    //  ──────────────────────────  Retirement Overrides  ───────────────────────────  \\

    /// @inheritdoc IRetireablePool
    function retire(
        address owner,
        address beneficiary,
        uint256 amount,
        bytes calldata data
    )
        external override(JasmineFeePool, JasmineBasePool)
    {
        _retire(owner, beneficiary, amount, data);
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

}