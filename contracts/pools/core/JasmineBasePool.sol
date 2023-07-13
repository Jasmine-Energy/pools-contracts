// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;

//  ─────────────────────────────────  Imports  ─────────────────────────────────  \\

// Implemented Interfaces
import { IJasminePool }                              from "../../interfaces/IJasminePool.sol";
import { IJasmineEATBackedPool  as IEATBackedPool  } from "../../interfaces/pool/IEATBackedPool.sol";
import { IJasmineQualifiedPool  as IQualifiedPool  } from "../../interfaces/pool/IQualifiedPool.sol";
import { IJasmineRetireablePool as IRetireablePool } from "../../interfaces/pool/IRetireablePool.sol";
import { IERC1046 }                                  from "../../interfaces/ERC/IERC1046.sol";
import { JasmineErrors }                             from "../../interfaces/errors/JasmineErrors.sol";

// Inheritted Contracts
import { EATManager }      from "./implementations/EATManager.sol";
import { Initializable }   from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ERC20 }           from "./implementations/ERC20.sol";
import { ERC20Permit }     from "./implementations/ERC20Permit.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { ERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

// External Contracts
import { JasmineEAT }               from "@jasmine-energy/contracts/src/JasmineEAT.sol";
import { JasmineRetirementService } from "../../JasmineRetirementService.sol";
import { JasminePoolFactory }       from "../../JasminePoolFactory.sol";

// Utility Libraries
import { PoolPolicy }    from "../../libraries/PoolPolicy.sol";
import { Calldata }      from "../../libraries/Calldata.sol";
import { Math }          from "@openzeppelin/contracts/utils/math/Math.sol";
import { ArrayUtils }    from "../../libraries/ArrayUtils.sol";

import "hardhat/console.sol";

/**
 * @title Jasmine Base Pool
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Jasmine's Base Pool contract which other pools extend as needed
 * @custom:security-contact dev@jasmine.energy
 */
abstract contract JasmineBasePool is
    IJasminePool,
    JasmineErrors,
    ERC20Permit,
    IERC1046,
    EATManager,
    Initializable,
    ReentrancyGuard
{
    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using ArrayUtils for uint256[];

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    //  ────────────────────────────────  Addresses  ────────────────────────────────  \\

    address public immutable retirementService;
    address public immutable poolFactory;

    //  ─────────────────────────────  Token Metadata  ──────────────────────────────  \\

    /// @notice Token Display name - per ERC-20
    string private _name;
    /// @notice Token Symbol - per ERC-20
    string private _symbol;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Errors
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @dev Emitted if a token does not meet pool's deposit policy
    error Unqualified(uint256 tokenId);

    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @param _eat Address of the Jasmine Energy Attribution Token (EAT) contract
     * @param _poolFactory Address of the Jasmine Pool Factory contract
     * @param _retirementService Address of the Jasmine retirement service contract
     * @param _contractName Name of the pool contract per EIP-712 and ERC-20
     *        NOTE: as pools are intended to be deployed via proxy, constructor name is not public facing
     */
    constructor(
        address _eat,
        address _poolFactory,
        address _retirementService,
        string memory _contractName
    )
        ERC20(_contractName, "JLT")
        ERC20Permit(_contractName)
        EATManager(_eat)
    {
        if (_eat == address(0x0) || 
            _poolFactory == address(0x0) || 
            _retirementService == address(0x0)) revert JasmineErrors.ValidationFailed();

        retirementService = _retirementService;
        poolFactory = _poolFactory;
    }

    /**
     * @dev Initializer function to set name and symbol
     *
     * @param name_ JLT token name
     * @param symbol_ JLT token symbol
     */
    function initialize(
        string calldata name_,
        string calldata symbol_
    )
        internal
        onlyInitializing
    {
        _name = name_;
        _symbol = symbol_;
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // User Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    //  ──────────────────────────  Retirement Functions  ───────────────────────────  \\

    /// @inheritdoc IRetireablePool
    function retire(
        address owner, 
        address beneficiary,
        uint256 amount, 
        bytes calldata data
    )
        external virtual
    {
        _retire(owner, beneficiary, amount, data);
    }

    /**
     * @dev Internal function to execute retirements
     * 
     * @param owner Address from which to burn JLT
     * @param beneficiary Address to receive retirement accredidation
     * @param amount Number of JLT to return
     * @param data Additional data to encode in retirement
     */
    function _retire(
        address owner, 
        address beneficiary,
        uint256 amount, 
        bytes calldata data
    )
        internal virtual
        withdrawal nonReentrant
    {
        // 1. Burn JLTs from owner
        uint256 cost = JasmineBasePool.retirementCost(amount);
        _spendJLT(owner, cost);

        // 2. Select quantity of EATs to retire
        uint256 eatQuantity = _totalDeposits - Math.ceilDiv(totalSupply(), 10 ** decimals());

        // 3. Encode transfer data
        bool hasFractional = eatQuantity > (amount / (10 ** decimals()));
        bytes memory retirementData;

        if (eatQuantity == 0) {
            emit Retirement(owner, beneficiary, amount);
            return;
        } else if (hasFractional && eatQuantity == 1) {
            retirementData = Calldata.encodeFractionalRetirementData();
        } else {
            retirementData = Calldata.encodeRetirementData(beneficiary, hasFractional);
        }

        if (data.length != 0) {
            retirementData = abi.encodePacked(retirementData, data);
        }

        // 4. Send to retirement service and emit retirement event
        (uint256[] memory tokenIds, uint256[] memory amounts) = selectWithdrawTokens(eatQuantity);

        // _transferDeposits(retirementService, tokenIds, amounts, retirementData);
        (uint256[] memory tokenIds2, uint256[] memory amounts2) = _transferQueuedDeposits(eatQuantity, retirementService, retirementData);

        // for (uint256 i; i < eatQuantity; i++) {
        //     console.log(tokenIds[i], tokenIds2[i]);
        // }

        emit Retirement(owner, beneficiary, amount);
    }


    //  ───────────────────────────  Deposit Functions  ─────────────────────────────  \\

    /// @inheritdoc IEATBackedPool
    function deposit(
        uint256 tokenId,
        uint256 amount
    )
        external virtual
        returns (uint256 jltQuantity)
    {
        return _deposit(_msgSender(), tokenId, amount);
    }

    /// @inheritdoc IEATBackedPool
    function depositFrom(
        address from,
        uint256 tokenId,
        uint256 amount
    )
        external virtual
        returns (uint256 jltQuantity)
    {
        return _deposit(from, tokenId, amount);
    }

    /// @inheritdoc IEATBackedPool
    function depositBatch(
        address from,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    )
        external virtual
        nonReentrant
        returns (uint256 jltQuantity)
    {
        JasmineEAT(eat).safeBatchTransferFrom(from, address(this), tokenIds, amounts, "");
        return _standardizeDecimal(amounts.sum());
    }

    /**
     * @dev Internal utility function to deposit EATs to pool
     * 
     * @param from Address from which EATs will be transfered
     * @param tokenId ID of EAT to deposit into pool
     * @param amount Number of EATs to deposit
     * 
     * @return jltQuantity Number of JLTs issued
     */
    function _deposit(
        address from,
        uint256 tokenId,
        uint256 amount
    )
        internal virtual
        nonReentrant
        returns (uint256 jltQuantity)
    {
        JasmineEAT(eat).safeTransferFrom(from, address(this), tokenId, amount, "");
        return _standardizeDecimal(amount);
    }


    //  ──────────────────────────  Withdrawal Functions  ───────────────────────────  \\

    /// @inheritdoc IEATBackedPool
    function withdraw(
        address recipient,
        uint256 amount,
        bytes calldata data
    )
        external virtual
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
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

    /// @inheritdoc IEATBackedPool
    function withdrawFrom(
        address from,
        address recipient,
        uint256 amount,
        bytes calldata data
    )
        external virtual
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
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
    {
        _withdraw(
            from,
            recipient,
            tokenIds,
            amounts,
            data
        );
    }

    /**
     * @dev Internal utility function for withdrawing EATs from pool
     *      in exchange for JLTs
     * 
     * @param from JLT holder from which token will be burned
     * @param recipient Address to receive EATs
     * @param tokenIds EAT token IDs to withdraw
     * @param amounts EAT token amounts to withdraw
     * @param data Calldata relayed during EAT transfer
     */
    function _withdraw(
        address from,
        address recipient,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) 
        internal virtual
        withdrawal nonReentrant
    {
        // 1. Ensure spender has sufficient JLTs and lengths match
        uint256 cost = JasmineBasePool.withdrawalCost(tokenIds, amounts);

        // 2. Burn Tokens
        _spendJLT(from, cost);

        // 3. Transfer Select Tokens
        _transferDeposits(recipient, tokenIds, amounts, data);
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // Jasmine Qualified Pool Implementations
    // ──────────────────────────────────────────────────────────────────────────────

    //  ────────────────────────────  Policy Functions  ─────────────────────────────  \\

    /// @inheritdoc IQualifiedPool
    function meetsPolicy(uint256 tokenId)
        public view virtual
        returns (bool isEligible)
    {
        isEligible = _isLegitimateToken(tokenId);
    }

    /// @inheritdoc IQualifiedPool
    function policyForVersion(uint8 metadataVersion)
        external view virtual
        returns (bytes memory policy)
    {
        if (metadataVersion != 1) revert JasmineErrors.UnsupportedMetadataVersion(metadataVersion);
        return abi.encode(
            JasmineEAT(eat).exists.selector,
            JasmineEAT(eat).frozen.selector
        );
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // Costing Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IEATBackedPool
    function withdrawalCost(
        uint256[] memory tokenIds,
        uint256[] memory amounts
    )
        public view virtual
        returns (uint256 cost)
    {
        if (tokenIds.length != amounts.length) {
            revert JasmineErrors.InvalidInput();
        }
        return _standardizeDecimal(amounts.sum());
    }

    /// @inheritdoc IEATBackedPool
    function withdrawalCost(uint256 amount) public view virtual returns (uint256 cost) {
        return _standardizeDecimal(amount);
    }

    /// @inheritdoc IRetireablePool
    function retirementCost(uint256 amount) public view virtual returns (uint256 cost) {
        return amount;
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // Overrides
    // ──────────────────────────────────────────────────────────────────────────────

    //  ───────────────────────  ERC-20 Metadata Conformance  ───────────────────────  \\

    /**
     * @inheritdoc ERC20
     * @dev See {IERC20Metadata-name}
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @inheritdoc ERC20
     * @dev See {IERC20Metadata-symbol}
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    //  ──────────────────────────  ERC-1046 Conformance  ───────────────────────────  \\

    /**
     * @inheritdoc IERC1046
     * @dev Appends token symbol to end of base URI
     */
    function tokenURI() external view virtual returns (string memory) {
        return string(
            abi.encodePacked(JasminePoolFactory(poolFactory).poolsBaseURI(), _symbol)
        );
    }

    //  ───────────────────────────  ERC-165 Conformance  ───────────────────────────  \\

    /**
     * @inheritdoc ERC20
     * @dev See {IERC165-supportsInterface}
     */
    function supportsInterface(bytes4 interfaceId)
        public view virtual
        override(EATManager, ERC20Permit)
        returns (bool)
    {
        return interfaceId == type(IJasminePool).interfaceId ||
            interfaceId == type(IERC1046).interfaceId ||
            super.supportsInterface(interfaceId);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Token Transfer Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ─────────────────────────  ERC-1155 Deposit Hooks  ──────────────────────────  \\

    /**
     * @dev Enforce EAT eligibility before deposits
     * 
     * @param tokenIds ERC-1155 token IDs received
     */
    function _beforeDeposit(
        address,
        uint256[] memory tokenIds,
        uint256[] memory
    )
        internal view override
    {
        _enforceEligibility(tokenIds);
    }

    /**
     * @dev Mint JLTs to depositor following EAT deposit
     * 
     * @param operator Address which initiated the deposit
     * @param from Address from which ERC-1155 tokens were transferred
     * @param quantity Number of ERC-1155 tokens received
     * 
     * Emits a {Withdraw} event.
     */
    function _afterDeposit(address operator, address from, uint256 quantity) 
        internal override
    {
        _mint(
            from,
            _standardizeDecimal(quantity)
        );

        emit Deposit(operator, from, quantity);
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Used to check a token exists and is not frozen
     * 
     * @param tokenId EAT token ID to check
     * @return isLegit Boolean if token passed legitimacy check
     */
    function _isLegitimateToken(uint256 tokenId)
        private view
        returns (bool isLegit)
    {
        return JasmineEAT(eat).exists(tokenId) && !JasmineEAT(eat).frozen(tokenId);
    }

    /**
     * @dev Standardizes an integers input to the pool's ERC-20 decimal storage value
     * 
     * @param input Integer value to standardize
     * 
     * @return value Decimal value of input per pool's decimal specificity
     */
    function _standardizeDecimal(uint256 input) 
        private pure
        returns (uint256 value)
    {
        return input * (10 ** 18);
    }

    /**
     * @dev Private function for burning JLT and decreasing allowance
     */
    function _spendJLT(address from, uint256 amount)
        private
    {
        if (amount == 0) revert JasmineErrors.InvalidInput();
        else if (from != _msgSender()) {
            _spendAllowance(from, _msgSender(), amount);
        }

        _burn(from, amount);
    }

    //  ────────────────────────────────  Modifiers  ────────────────────────────────  \\

    /**
     * @dev Utility function to enforce eligibility of many EATs
     * 
     * @dev Throws Unqualified(uint256 tokenId) on failure
     * 
     * @param tokenIds EAT token IDs to check eligibility
     */
    function _enforceEligibility(uint256[] memory tokenIds)
        private view
    {
        for (uint i = 0; i < tokenIds.length;) {
            if (!meetsPolicy(tokenIds[i])) revert Unqualified(tokenIds[i]);

            unchecked { i++; }
        }
    }
}
