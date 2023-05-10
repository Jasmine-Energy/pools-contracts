// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Implemented Interfaces
import { IJasminePool } from "../../interfaces/IJasminePool.sol";

// Implementation Contracts
import { ERC1155Manager } from "../../implementations/ERC1155Manager.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ERC1155Holder } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC1046 } from "../../implementations/ERC1046.sol";
import { ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// External Contracts
import { JasmineEAT } from "@jasmine-energy/contracts/src/JasmineEAT.sol";
import { JasmineMinter } from "@jasmine-energy/contracts/src/JasmineMinter.sol";

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

import "hardhat/console.sol";

/**
 * @title Jasmine Base Pool
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Jasmine's Base Pool contract which other pools extend as needed
 * @custom:security-contact dev@jasmine.energy
 */
abstract contract JasmineBasePool is
    ERC20,
    ERC20Permit,
    ERC1046,
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
    // Events
    // ──────────────────────────────────────────────────────────────────────────────
    
    // TODO These are define in IEATBackedPool, importing here for now

    /**
     * @dev Emitted whenever EATs are deposited to the contract
     * 
     * @param operator Initiator of the deposit
     * @param owner Token holder depositting to contract
     * @param quantity Number of EATs deposited. Note: JLTs issued are 1-1 with EATs
     */
    event Deposit(
        address indexed operator,
        address indexed owner,
        uint256 quantity
    );

    /**
     * @dev Emitted whenever EATs are withdrawn from the contract
     * 
     * @param sender Initiator of the deposit
     * @param receiver Token holder depositting to contract
     * @param quantity Number of EATs withdrawn.
     */
    event Withdraw(
        address indexed sender,
        address indexed receiver,
        uint256 quantity
    );

    /**
     * @notice emitted when tokens from a pool are retired
     * 
     * @dev must be accompanied by a token burn event
     * 
     * @param operator Initiator of retirement
     * @param beneficiary Designate beneficiary of retirement
     * @param quantity Number of tokens being retired
     */
    event Retirement(
        address indexed operator,
        address indexed beneficiary,
        uint256 quantity
    );


    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    //  ─────────────────  Deposit & Retirement Management Fields  ──────────────────  \\

    /// @dev Convenience mapping to record EATs held by a given pool
    EnumerableSet.UintSet internal _holdings;

    /// @dev Counter of all EAT deposits
    uint256 internal _totalDeposits;


    //  ────────────────────────────────  Addresses  ────────────────────────────────  \\

    JasmineEAT public immutable EAT;
    JasmineMinter public immutable minter;
    // QUESTION: Should prob standardize and make this a contract
    address public immutable poolFactory;


    //  ─────────────────────────────  Token Metadata  ──────────────────────────────  \\

    /// @notice Token Display name - per ERC-20
    string private _name;
    /// @notice Token Symbol - per ERC-20
    string private _symbol;
    // TODO: Can prob be deleted. Default is 18
    /// @notice JLT's decimal precision - per ERC-20
    uint8 private constant DECIMALS = 18;


    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @dev
     */
    constructor(address _eat, address _poolFactory, address _minter)
        ERC20("Jasmine Liquidity Token Base", "JLT")
        ERC20Permit("Jasmine Liquidity Token Base")
        ERC1155Manager(_eat)
    {
        require(_eat != address(0), "JasminePool: EAT must be set");
        require(_poolFactory != address(0), "JasminePool: Pool factory must be set");

        EAT = JasmineEAT(_eat);
        minter = JasmineMinter(_minter);
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

        EAT.setApprovalForAll(address(minter), true);
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // User Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    //  ──────────────────────────  Retirement Functions  ───────────────────────────  \\

    // @inheritdoc {IRetireablePool}
    // TODO: Once pool conforms to IJasminePool again, add above line to natspec
    function retire(
        address owner, 
        address beneficiary, 
        uint256 amount, 
        bytes calldata data
    )
        external virtual
        onlyAllowed(owner, amount)
        nonReentrant enforceDeposits
    {
        // 1. Burn JLTs from owner
        _burn(owner, amount);

        // 2. Select quantity of EATs to retire
        uint256 oneEATCost = _standardizeDecimal(1);
        if (amount < oneEATCost) {

        }

        // 3. Select tokens to withdraw
        (uint256[] memory tokenIds, uint256[] memory amounts) = (new uint256[](0), new uint256[](0));
        (tokenIds, amounts) = _selectAnyTokens(amount);
    }

    /**
     * @notice Retires an exact amount of JLTs. If fees or other conversions are set,
     *         cost of retirement will be greater than amount.
     * 
     * @param owner JLT holder to retire from
     * @param beneficiary Address to receive retirement attestation
     * @param amount Exact number of JLTs to retire
     * @param data Optional calldata to relay to retirement service via onERC1155Received
     */
    function retireExact(
        address owner, 
        address beneficiary, 
        uint256 amount, 
        bytes calldata data
    )
        external virtual
        onlyAllowed(owner, amount)
        nonReentrant enforceDeposits
    {
        // 1. Burn JLTs from owner
        uint256 cost = retirementCost(amount);
        _burn(owner, cost);

        // 2. Select quantity of EATs to retire
        console.log("Total deposits: ", _totalDeposits, " Rounded supply: ", Math.ceilDiv(totalSupply(), 10 ** DECIMALS));
        uint256 eatQuantity = _totalDeposits - Math.ceilDiv(totalSupply(), 10 ** DECIMALS);
        console.log("Withdrawal quantity: ", eatQuantity);

        // 3. Select tokens to withdraw
        (uint256[] memory tokenIds, uint256[] memory amounts) = (new uint256[](0), new uint256[](0));
        (tokenIds, amounts) = _selectAnyTokens(eatQuantity);
        console.log("Token length: ", tokenIds.length);
        console.log("Amounts: ", amounts.sum());

        // 4. If EAT quantity is greater than amount // TODO: Write comment
        if (eatQuantity > (amount / (10 ** DECIMALS))) {
            // TODO: Seperate one EAT from tokens to forward as fractional amount
            console.log("Should withdraw fractional");
            minter.burn(tokenIds[tokenIds.length-1], 1, Calldata.encodeFractionalRetirementData());
            if (amounts[amounts.length-1] == 1) {
                if (amounts.length == 1) return; // TODO: Avoid this if then return. Will fail to emit event
                assembly {
                    mstore(tokenIds, sub(mload(tokenIds), 1))
                    mstore(amounts, sub(mload(amounts), 1))
                }
            } else {
                amounts[amounts.length-1]--;
            }
        }

        minter.burnBatch(tokenIds, amounts, Calldata.encodeRetirementData(beneficiary));

        // TODO: Move to private function
        uint256[] memory balances = EAT.balanceOfBatch(ArrayUtils.fill(address(this), tokenIds.length), tokenIds);
        for (uint256 i = 0; i < balances.length; i++) {
            if (balances[i] == 0) _holdings.remove(tokenIds[i]);
        }
        uint256 withdrawSum = amounts.sum();
        _totalDeposits -= withdrawSum;

        emit Retirement(owner, beneficiary, amount);
    }


    //  ───────────────────────────  Deposit Functions  ─────────────────────────────  \\

    /**
     * @notice Used to deposit EATs into the pool.
     * 
     * @dev Requirements:
     *     - Pool must be an approved operator of caller's EATs
     *     - Caller must hold tokenId and have balance greater than or equal to amount
     * 
     * @param tokenId ID of EAT to deposit into pool
     * @param amount Number of EATs to deposit
     * 
     * @return jltQuantity Number of JLTs issued
     */
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

    /**
     * @notice Used to deposit EATs on behalf of another address into the pool.
     * 
     * @dev Requirements:
     *     - Pool must be an approved operator of from's EATs
     *     - Caller must be an approved operator of from's EATs
     *     - From account must hold tokenId and have balance greater than or equal to amount
     * 
     * @param from Address from which EATs will be transfered
     * @param tokenId ID of EAT to deposit into pool
     * @param amount Number of EATs to deposit
     * 
     * @return jltQuantity Number of JLTs issued
     * TODO: Rename from operator deposit
     */
    function operatorDeposit(
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

    /**
     * @notice 
     * 
     * @dev Requirements:
     * 
     * @param from Address from which EATs will be transfered
     * @param tokenIds IDs of EAT to deposit into pool
     * @param amounts Number of EATs to deposit
     * 
     * @return jltQuantity Number of JLTs issued
     */
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
        // NOTE: JLTs are minted and _holdings updated upon ERC-1155 receipt
        EAT.safeBatchTransferFrom(from, address(this), tokenIds, amounts, "");
        return _standardizeDecimal(amounts.sum());
    }

    /**
     * @dev Utility function to deposit EATs to pool
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
        // NOTE: JLTs are minted and _holdings updated upon ERC-1155 receipt
        EAT.safeTransferFrom(from, address(this), tokenId, amount, "");
        return _standardizeDecimal(amount);
    }


    //  ──────────────────────────  Withdrawal Functions  ───────────────────────────  \\

    /**
     * @notice Used to convert JLTs into EATs. Withdraws JLTs from caller. To withdraw
     *         from an alternate address - that the caller's approved for - 
     *         defer to operatorWithdraw.
     * 
     * @dev Requirements:
     *     - Caller must have sufficient JLTs
     *     - If recipient is a contract, must implements ERC1155Receiver
     * 
     * @param recipient Address to receive EATs
     * @param amount Number of JLTs to burn and EATs to withdraw
     * @param data Optional calldata to forward to recipient
     */
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
        (tokenIds, amounts) = (new uint256[](0), new uint256[](0));
        (tokenIds, amounts) = _selectAnyTokens(amount);
        _withdraw(
            _msgSender(),
            recipient,
            withdrawalCost(amount),
            tokenIds,
            amounts,
            data
        );
        return (tokenIds, amounts);
    }

    /**
     * @notice Used to convert JLTs from sender into EATs which are sent
     *         to recipient.
     * 
     * @dev Requirements:
     *     - Caller must be approved operator for sender
     *     - Sender must have sufficient JLTs
     *     - If recipient is a contract, must implements ERC1155Receiver
     * 
     * @param sender Account to which will have JLTs burned
     * @param recipient Address to receive EATs
     * @param amount Number of JLTs to burn and EATs to withdraw
     * @param data Optional calldata to forward to recipient
     */
    function operatorWithdraw(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data
    )
        external virtual
        onlyAllowed(sender, _standardizeDecimal(amount))
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        (tokenIds, amounts) = (new uint256[](0), new uint256[](0));
        (tokenIds, amounts) = _selectAnyTokens(amount);
        _withdraw(
            sender,
            recipient,
            withdrawalCost(amount),
            tokenIds,
            amounts,
            data
        );
        return (tokenIds, amounts);
    }

    /**
     * @notice Used to withdraw specific EATs held by pool by burning
     *         JLTs from sender.
     * 
     * @dev Requirements:
     *     - Caller must be approved operator for sender
     *     - Sender must have sufficient JLTs
     *     - If recipient is a contract, must implements ERC1155Receiver
     *     - Length of token IDs and amounts must match
     *     - Pool must hold all token IDs specified
     * 
     * @param sender Account to which will have JLTs burned
     * @param recipient Address to receive EATs
     * @param tokenIds EAT token IDs to withdraw
     * @param amounts Amount of EATs to withdraw per token ID
     * @param data Optional calldata to forward to recipient
     */
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
            withdrawalCost(tokenIds, amounts),
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
        uint256 cost,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) 
        internal virtual
        nonReentrant enforceDeposits
    {
        // 1. Ensure sender has sufficient JLTs and lengths match
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
        tokenIds.length == 1 
            ? _sendEAT(recipient, tokenIds[0], amounts[0], data)
            : _sendBatchEAT(recipient, tokenIds, amounts, data);
    }


    // ──────────────────────────────────────────────────────────────────────────────
    // Jasmine Qualified Pool Implementations
    // ──────────────────────────────────────────────────────────────────────────────

    //  ────────────────────────────  Policy Functions  ─────────────────────────────  \\

    // @inheritdoc {IQualifiedPool}
    // TODO: Once pool conforms to IJasminePool again, add above line to natspec
    function meetsPolicy(uint256 tokenId)
        public view virtual
        returns (bool isEligible)
    {
        isEligible = _isLegitimateToken(tokenId);
    }

    // @inheritdoc {IQualifiedPool}
    // TODO: Once pool conforms to IJasminePool again, add above line to natspec
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

    // QUESTION: Should these two costing functions be seperately named?

    /**
     * @notice Cost of withdrawing specified amounts of tokens from pool.
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

    /**
     * @notice Cost of withdrawing amount of tokens from pool where pool
     *         selects the tokens to withdraw.
     * 
     * @param amount Number of EATs to withdraw.
     * 
     * @return cost Price of withdrawing EATs in JLTs
     */
    function withdrawalCost(
        uint256 amount
    )
        public view virtual
        returns (uint256 cost)
    {
        return _standardizeDecimal(amount);
    }

    /**
     * @notice Cost of retiring JLTs from pool.
     * 
     * @param amount Amount of JLTs to retire.
     * 
     * @return cost Price of retiring in JLTs.
     */
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
     * @inheritdoc IERC20Metadata
     * @dev See {IERC20Metadata-decimals}.
     */
    function decimals() public pure override(ERC20, IERC20Metadata) returns (uint8) {
        return DECIMALS;
    }

    //  ───────────────────────────  ERC-165 Conformance  ───────────────────────────  \\

    /**
     * @inheritdoc IERC165
     * @dev See {IERC165-supportsInterface}
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return interfaceId == type(IERC20).interfaceId || interfaceId == type(IERC20Metadata).interfaceId ||
            interfaceId == type(IJasminePool).interfaceId ||
            interfaceId == type(IERC1046).interfaceId ||
            super.supportsInterface(interfaceId);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Token Transfer Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ─────────────────────────  ERC-1155 Deposit Hooks  ──────────────────────────  \\

    function beforeDeposit(
        address,
        uint256[] memory tokenIds,
        uint256[] memory
    )
        internal override
    {
        _enforceEligibility(tokenIds);
    }

    function afterDeposit(address from, uint256 quantity) internal override {
        _mint(
            from,
            _standardizeDecimal(quantity)
        );

        console.log("Deposit from: ", from, " quantity: ", quantity);

        emit Deposit(from, from, quantity);
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ─────────────────────────  EAT Transfer Utilities  ──────────────────────────  \\

    /**
     * @dev Internal method for sending EAT out of contract and updating holdings
     * 
     * @param to Address to receive EAT
     * @param tokenId EAT token ID to send
     * @param amount Number of EAT to send
     * @param data Calldata to forward to `to` during ERC-1155 `safeTransferFrom`
     */
    function _sendEAT(
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) internal {
        EAT.safeTransferFrom(address(this), to, tokenId, amount, data);
        if (EAT.balanceOf(address(this), tokenId) == 0) _holdings.remove(tokenId);
        _totalDeposits -= amount;
        emit Withdraw(address(this), to, amount);
    }

    /**
     * @dev Internal method for sending batch of EATs out of contract and updating holdings
     * 
     * @param to Address to receive EAT
     * @param tokenIds EAT token IDs to send
     * @param amounts Number of EATs to send
     * @param data Calldata to forward to `to` during ERC-1155 `safeTransferFrom`
     */
    function _sendBatchEAT(
        address to,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) internal {
        EAT.safeBatchTransferFrom(address(this), to, tokenIds, amounts, data);
        uint256[] memory balances = EAT.balanceOfBatch(ArrayUtils.fill(address(this), tokenIds.length), tokenIds);
        for (uint256 i = 0; i < balances.length; i++) {
            if (balances[i] == 0) _holdings.remove(tokenIds[i]);
        }
        uint256 withdrawSum = amounts.sum();
        _totalDeposits -= withdrawSum;
        emit Withdraw(address(this), to, withdrawSum);
    }

    /**
     * @dev Used to select an `amout` of tokens to withdraw if unspecified by user
     * 
     * @param amount The numer of EATs to select from holdings
     * 
     * @return tokenIds List of EAT IDs to withdraw
     * @return amounts Number of EATs to withdraw, corresponding to same index in tokenIds
     */
    function _selectAnyTokens(
        uint256 amount
    )
        internal virtual view
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        uint256 sum = 0;
        uint256 i = 0;
        tokenIds = new uint256[](1);
        amounts  = new uint256[](1);
        while (sum != amount) {
            if (i >= _holdings.length()) revert JasmineErrors.ValidationFailed();

            uint256 tokenId = _holdings.at(i);
            uint256 balance = EAT.balanceOf(address(this), tokenId);

            tokenIds[i] = tokenId;
            if (sum + balance <= amount) {
                amounts[i] = balance;
                sum += balance;
                i++;
                continue;
            } else {
                amounts[i] = amount - sum;
                break;
            }
        }

        return (tokenIds, amounts);
    }

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
        internal pure
        returns (uint256 value)
    {
        return input * (10 ** DECIMALS);
    }

    //  ────────────────────────────────  Modifiers  ────────────────────────────────  \\

    /**
     * @dev Enforce the pool holds more in deposit reserves than outstanding supply
     */
    modifier enforceDeposits() {
        _;
        if (_standardizeDecimal(_totalDeposits) < totalSupply()) revert JasmineErrors.InbalancedDeposits();
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
        for (uint i = 0; i < tokenIds.length; i++) {
            _enforceEligibility(tokenIds[i]);
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
