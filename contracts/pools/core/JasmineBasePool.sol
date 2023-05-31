// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Implemented Interfaces
import { IJasminePool } from "../../interfaces/IJasminePool.sol";
import { IQualifiedPool } from "../../interfaces/pool/IQualifiedPool.sol";
import { IRetireablePool } from "../../interfaces/pool/IRetireablePool.sol";
import { IEATBackedPool } from "../../interfaces/pool/IEATBackedPool.sol";

// Implementation Contracts
import { ERC1155Manager } from "../../implementations/ERC1155Manager.sol";
import { ERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ERC1155Holder } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// External Contracts
import { JasmineEAT } from "@jasmine-energy/contracts/src/JasmineEAT.sol";
import { JasmineRetirementService } from "../../JasmineRetirementService.sol";
import { JasminePoolFactory } from "../../JasminePoolFactory.sol";

// Utility Libraries
import { PoolPolicy } from "../../libraries/PoolPolicy.sol";
import { Calldata } from "../../libraries/Calldata.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { ArrayUtils } from "../../libraries/ArrayUtils.sol";
import { 
    ERC20Errors,
    ERC1155Errors
} from "../../interfaces/ERC/IERC6093.sol";
import { JasmineErrors } from "../../interfaces/errors/JasmineErrors.sol";

// Interfaces
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import { IERC1046 } from "../../interfaces/ERC/IERC1046.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";


/**
 * @title Jasmine Base Pool
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Jasmine's Base Pool contract which other pools extend as needed
 * @custom:security-contact dev@jasmine.energy
 */
abstract contract JasmineBasePool is
    IJasminePool,
    ERC20,
    ERC20Permit,
    IERC1046,
    ERC1155Manager,
    Initializable,
    ReentrancyGuard
{
    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using EnumerableSet for EnumerableSet.UintSet;
    using ArrayUtils for uint256[];


    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    //  ────────────────────────────────  Addresses  ────────────────────────────────  \\

    JasmineEAT public immutable EAT;
    address public immutable retirementService;
    address public immutable poolFactory;


    //  ─────────────────────────────  Token Metadata  ──────────────────────────────  \\

    /// @notice Token Display name - per ERC-20
    string private _name;
    /// @notice Token Symbol - per ERC-20
    string private _symbol;


    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @param _eat Address of the Jasmine Energy Attribution Token (EAT) contract
     * @param _poolFactory Address of the Jasmine Pool Factory contract
     * @param _retirementService Address of the Jasmine retirement service contract
     */
    constructor(
        address _eat,
        address _poolFactory,
        address _retirementService
    )
        ERC20("Jasmine Liquidity Token Base", "JLT")
        ERC20Permit("Jasmine Liquidity Token Base")
        ERC1155Manager(_eat)
    {
        if (_eat == address(0x0) || 
            _poolFactory == address(0x0) || 
            _retirementService == address(0x0)) revert JasmineErrors.ValidationFailed();

        EAT = JasmineEAT(_eat);
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
        address beneficiary, // TODO: If set, use in lieu of msg.sender
        uint256 amount, 
        bytes calldata data // TODO: Concat to calldata
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
        bytes calldata data // TODO: Concat to calldata
    )
        internal virtual
        onlyAllowed(owner, amount)
        withdrawal enforceDeposits nonReentrant
    {
        // 1. Burn JLTs from owner
        uint256 cost = this.retirementCost(amount);
        _burn(owner, cost);

        // 2. Select quantity of EATs to retire
        uint256 eatQuantity = totalDeposits() - Math.ceilDiv(totalSupply(), 10 ** decimals());
        if (eatQuantity == 0) {
            emit Retirement(owner, beneficiary, amount);
            return;
        }

        // 3. Select tokens to withdraw
        (uint256[] memory tokenIds, uint256[] memory amounts) = (new uint256[](0), new uint256[](0));
        (tokenIds, amounts) = _selectWithdrawTokens(eatQuantity);

        // 4. Encode transfer data
        bool hasFractional = eatQuantity > (amount / (10 ** decimals()));
        bytes memory retirementData;

        // If it's a fractional retirement and only one EAT is to be retired, only encode fractional data
        if (hasFractional && eatQuantity == 1) {
            retirementData = Calldata.encodeFractionalRetirementData();
        } else {
            retirementData = Calldata.encodeRetirementData(beneficiary, hasFractional);
        }

        // 5. Send to retirement service and emit retirement event
        _transferDeposits(retirementService, tokenIds, amounts, retirementData);
        emit Retirement(owner, beneficiary, amount);
    }


    //  ───────────────────────────  Deposit Functions  ─────────────────────────────  \\

    /// @inheritdoc IEATBackedPool
    function deposit(
        uint256 tokenId,
        uint256 amount
    )
        external virtual
        checkEligibility(tokenId)
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
        onlyEATApproved(from) checkEligibility(tokenId)
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
        onlyEATApproved(from) checkEligibilities(tokenIds)
        nonReentrant enforceDeposits
        returns (uint256 jltQuantity)
    {
        EAT.safeBatchTransferFrom(from, address(this), tokenIds, amounts, "");
        return _standardizeDecimal(amounts.sum());
    }

    /**
     * @dev Internal utility function to deposit EATs to pool
     * 
     * @dev Throw ERC1155InsufficientApproval if pool is not an approved operator
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
        nonReentrant enforceDeposits
        returns (uint256 jltQuantity)
    {
        EAT.safeTransferFrom(from, address(this), tokenId, amount, "");
        return _standardizeDecimal(amount);
    }


    //  ──────────────────────────  Withdrawal Functions  ───────────────────────────  \\

    /// @inheritdoc IEATBackedPool
    function withdraw(
        address recipient,
        uint256 amount,
        bytes calldata data
    )
        public virtual
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        (tokenIds, amounts) = _selectWithdrawTokens(amount);
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
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data
    )
        public virtual
        onlyAllowed(sender, _standardizeDecimal(amount))
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        (tokenIds, amounts) = _selectWithdrawTokens(amount);
        _withdraw(
            sender,
            recipient,
            tokenIds,
            amounts,
            data
        );
        return (tokenIds, amounts);
    }

    /// @inheritdoc IEATBackedPool
    function withdrawSpecific(
        address sender,
        address recipient,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts,
        bytes calldata data
    ) 
        external virtual
        onlyAllowed(sender, _standardizeDecimal(amounts.sum()))
    {
        _withdraw(
            sender,
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
     * @param sender JLT holder from which token will be burned
     * @param recipient Address to receive EATs
     * @param tokenIds EAT token IDs to withdraw
     * @param amounts EAT token amounts to withdraw
     * @param data Calldata relayed during EAT transfer
     */
    function _withdraw(
        address sender,
        address recipient,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) 
        internal virtual
        withdrawal enforceDeposits nonReentrant
    {
        // 1. Ensure sender has sufficient JLTs and lengths match
        uint256 cost = this.withdrawalCost(tokenIds, amounts);

        if (balanceOf(sender) < cost)
            revert ERC20Errors.ERC20InsufficientBalance(
                sender,
                balanceOf(sender),
                cost
            );
        if (tokenIds.length != amounts.length)
            revert ERC1155Errors.ERC1155InvalidArrayLength(
                tokenIds.length,
                amounts.length
            );

        // 2. Burn Tokens
        _burn(sender, cost);

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
            EAT.exists.selector,
            EAT.frozen.selector
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
            revert ERC1155Errors.ERC1155InvalidArrayLength(
                tokenIds.length,
                amounts.length
            );
        }
        return _standardizeDecimal(amounts.sum());
    }

    /// @inheritdoc IEATBackedPool
    function withdrawalCost(
        uint256 amount
    )
        public view virtual
        returns (uint256 cost)
    {
        return _standardizeDecimal(amount);
    }

    /// @inheritdoc IEATBackedPool
    function retirementCost(
        uint256 amount
    )
        public view virtual
        returns (uint256 cost)
    {
        return amount;
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // Overrides
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @inheritdoc ERC20
     * @dev See {ERC20-balanceOf}
     */
    function balanceOf(address account) public view override(ERC20, IERC20) returns (uint256) {
        return super.balanceOf(account);
    }

    /**
     * @inheritdoc ERC20
     * @dev See {ERC20-totalSupply}
     */
    function totalSupply() public view override(ERC20, IERC20) returns (uint256) {
        return super.totalSupply();
    }

    /**
     * @inheritdoc IERC20Metadata
     * @dev See {IERC20Metadata-name}
     */
    function name() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return _name;
    }

    /**
     * @inheritdoc IERC20Metadata
     * @dev See {IERC20Metadata-symbol}
     */
    function symbol() public view override(ERC20, IERC20Metadata) returns (string memory) {
        return _symbol;
    }

    /**
     * @inheritdoc IERC1046
     * @dev Appends token symbol to end of base URI
     */
    function tokenURI() public view virtual returns (string memory) {
        return string(
            abi.encodePacked(JasminePoolFactory(poolFactory).poolsBaseURI(), _symbol)
        );
    }

    //  ───────────────────────────  ERC-165 Conformance  ───────────────────────────  \\

    /**
     * @inheritdoc IERC165
     * @dev See {IERC165-supportsInterface}
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155Receiver) returns (bool) {
        return interfaceId == type(IERC20).interfaceId || interfaceId == type(IERC20Metadata).interfaceId ||
            interfaceId == type(IJasminePool).interfaceId ||
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
    function beforeDeposit(
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
     * @param from Address from which ERC-1155 tokens were transferred
     * @param quantity Number of ERC-1155 tokens received
     * 
     * Emits a {Withdraw} event.
     */
    function afterDeposit(address from, uint256 quantity) internal override {
        _mint(
            from,
            _standardizeDecimal(quantity)
        );

        emit Deposit(from, from, quantity);
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
        internal view
        returns (bool isLegit)
    {
        return EAT.exists(tokenId) && !EAT.frozen(tokenId);
    }

    /**
     * @dev Standardizes an integers input to the pool's ERC-20 decimal storage value
     * 
     * @param input Integer value to standardize
     * 
     * @return value Decimal value of input per pool's decimal specificity
     */
    function _standardizeDecimal(uint256 input) 
        internal view
        returns (uint256 value)
    {
        return input * (10 ** decimals());
    }

    //  ────────────────────────────────  Modifiers  ────────────────────────────────  \\

    /**
     * @dev Enforce the pool holds more in deposit reserves than outstanding supply
     */
    modifier enforceDeposits() {
        _;
        if (_standardizeDecimal(totalDeposits()) < totalSupply()) revert JasmineErrors.InbalancedDeposits();
    }

    /**
     * @dev Enforce token ID meets pool's policy
     */
    modifier checkEligibility(uint256 tokenId) {
        _enforceEligibility(tokenId);
        _;
    }

    /**
     * @dev Enforces all token IDs meet pool's policy
     */
    modifier checkEligibilities(uint256[] memory tokenIds) {
        _enforceEligibility(tokenIds);
        _;
    }

    /**
     * @dev Utility function to enforce an EAT's eligibility
     * 
     * @dev Throws Unqualified(uint256 tokenId) on failure
     * 
     * @param tokenId EAT token ID to check eligibility
     */
    function _enforceEligibility(uint256 tokenId) private view {
        if (!meetsPolicy(tokenId)) revert JasmineErrors.Unqualified(tokenId);
    }

    /**
     * @dev Utility function to enforce eligibility of many EATs
     * 
     * @dev Throws Unqualified(uint256 tokenId) on failure
     * 
     * @param tokenIds EAT token IDs to check eligibility
     */
    function _enforceEligibility(uint256[] memory tokenIds) private view {
        for (uint i = 0; i < tokenIds.length;) {
            _enforceEligibility(tokenIds[i]);

            unchecked { i++; }
        }
    }

    /**
     * @dev Enforce msg sender is EAT contract
     * 
     * @dev Throws Prohibited() on failure
     */
    modifier onlyEAT {
        if (_msgSender() != address(EAT)) revert JasmineErrors.Prohibited();
        _;
    }

    /**
     * @dev Enforce msg sender is Pool Factory contract
     * 
     * @dev Throws Prohibited() on failure
     */
    modifier onlyFactory() {
        if (_msgSender() != poolFactory) revert JasmineErrors.Prohibited();
        _;
    }

    /**
     * @dev Enforce caller is approved for holder's EATs - or caller is holder
     * 
     * @dev Throws Prohibited() on failure
     */
    modifier onlyEATApproved(address holder) {
        if (!EAT.isApprovedForAll(holder, _msgSender())) revert JasmineErrors.Prohibited();
        _;
    }

     /**
     * @dev Extend onlyOperator to include addresses approved for an amount of JLTs
     * 
     * @dev Throws Prohibited() on failure or InvalidInput() if quantity is 0
     */
    modifier onlyAllowed(address holder, uint256 quantity) {
        if (quantity == 0) revert JasmineErrors.InvalidInput();
        if (holder != _msgSender() && allowance(holder, _msgSender()) < quantity) revert JasmineErrors.Prohibited();
        _;
    }
}
