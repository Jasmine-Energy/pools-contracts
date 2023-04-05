// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Implemented Interfaces
import { IJasminePool } from "../interfaces/IJasminePool.sol";

// Implementation Contracts
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ERC1155Holder } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import { ERC777 } from "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import { ERC1046 } from "../implementations/ERC1046.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// External Contracts
import { JasmineEAT } from "@jasmine-energy/contracts/src/JasmineEAT.sol";

// Utility Libraries
import { PoolPolicy } from "../libraries/PoolPolicy.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { ArrayUtils } from "../libraries/ArrayUtils.sol";
import { 
    ERC20Errors,
    ERC1155Errors
} from "../interfaces/ERC/IERC6093.sol";
import { JasmineErrors } from "../interfaces/errors/JasmineErrors.sol";

// Interfaces
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import { IERC1155Receiver } from "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";
import { IERC777 } from "@openzeppelin/contracts/interfaces/IERC777.sol";
import { IERC1046 } from "../interfaces/ERC/IERC1046.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";


/**
 * @title Jasmine Base Pool
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Jasmine's Base Pool contract which other pools extend as needed
 * @custom:security-contact dev@jasmine.energy
 */
abstract contract JasmineBasePool is
    ERC777,
    ERC1046,
    ERC1155Holder,
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


    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────


    //  ────────────────────────  Deposit Management Fields  ────────────────────────  \\

    /// @dev Convenience mapping to record EATs held by a given pool
    EnumerableSet.UintSet internal _holdings;


    //  ────────────────────────────────  Addresses  ────────────────────────────────  \\

    JasmineEAT public immutable EAT;
    address public immutable poolFactory;


    //  ─────────────────────────────  Token Metadata  ──────────────────────────────  \\

    /// @notice Token Display name - per ERC-20/777
    string private _name;
    /// @notice Token Symbol - per ERC-20/777
    string private _symbol;
    /// @notice JLT's decimal precision - per ERC-20
    uint8 private constant _decimals = 9;


    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @dev
     */
    constructor(address _eat, address _poolFactory) 
        ERC777("Jasmine Liquidity Token Base", "JLT", new address[](0))
    {
        require(_eat != address(0), "JasminePool: EAT must be set");
        require(_poolFactory != address(0), "JasminePool: Pool factory must be set");

        EAT = JasmineEAT(_eat);
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

    // @inheritdoc {IRetireablePool}
    // TODO: Once pool conforms to IJasminePool again, add above line to natspec
    function retire(
        address sender,
        address beneficiary,
        uint256 quantity,
        bytes calldata data
    )
        external virtual
        nonReentrant onlyOperator(sender)
    {
        // TODO: Implement me
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
        nonReentrant checkEligibility(tokenId)
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
     */
    function operatorDeposit(
        address from,
        uint256 tokenId,
        uint256 amount
    )
        external virtual
        nonReentrant onlyOperator(from) checkEligibility(tokenId)
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
        nonReentrant onlyOperator(from) checkEligibilities(tokenIds)
        returns (uint256 jltQuantity)
    {
        // NOTE: JLTs are minted and _holdings updated upon ERC-1155 receipt
        try EAT.safeBatchTransferFrom(from, address(this), tokenIds, amounts, "") {
            return amounts.sum();
        } catch Error(string memory reason) {
            // TODO Attempt to determine other failure reasons
            if (tokenIds.length != amounts.length) {
                revert ERC1155Errors.ERC1155InvalidArrayLength(
                    tokenIds.length,
                    amounts.length
                );
            } else {
                revert(reason);
            }
        } catch {
            revert("JasmineBasePool: Deposit failed");
        }
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
        returns (uint256 jltQuantity)
    {
        // NOTE: JLTs are minted and _holdings updated upon ERC-1155 receipt
        try EAT.safeTransferFrom(from, address(this), tokenId, amount, "") {
            return amount;
        } catch Error(string memory reason) {
            // If failed, attempt to determine cause, else return reason string
            if (!EAT.isApprovedForAll(from, address(this))) {
                revert ERC1155Errors.ERC1155InsufficientApproval(address(this), tokenId);
            } else if (EAT.balanceOf(from, tokenId) < amount) {
                revert ERC1155Errors.ERC1155InsufficientBalance(
                    from,
                    EAT.balanceOf(from, tokenId),
                    amount,
                    tokenId
                );
            } else {
                revert(reason);
            }
        } catch {
            revert("JasmineBasePool: Deposit failed");
        }
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
        nonReentrant
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        return _withdraw(_msgSender(), recipient, amount, data);
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
        nonReentrant onlyOperator(sender)
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        return _withdraw(sender, recipient, amount, data);
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
        nonReentrant onlyOperator(sender)
    {
        // 1. Ensure sender has sufficient JLTs and lengths match
        uint256 amountSum = amounts.sum();
        if (balanceOf(sender) < amountSum)
            revert ERC20Errors.ERC20InsufficientBalance(
                sender,
                balanceOf(sender),
                amountSum
            );
        if (tokenIds.length != amounts.length)
            revert ERC1155Errors.ERC1155InvalidArrayLength(
                tokenIds.length,
                amounts.length
            );

        // 2. Burn Tokens
        _burn(sender, amountSum, "", "");

        // 3. Transfer Select Tokens
        _sendBatchEAT(recipient, tokenIds, amounts, data);
    }

    /**
     * @notice Internal implementation of withdraw
     * 
     * @dev Burns `amount` of JLTs from `sender` and transfers EATs to recipient with `data`.
     * 
     * @dev Throws ERC20InsufficientBalance if sender does not have sufficient JLTs
     * 
     */
    function _withdraw(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data // TODO: this should prob specify WHO is receiving data (burn or EAT transfer)
    )
        internal virtual
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        // 1. Ensure caller has sufficient JLTs
        if (balanceOf(sender) < amount) {
            revert ERC20Errors.ERC20InsufficientBalance(sender, balanceOf(sender), amount);
        }

        // 2. Burn Tokens
        _burn(sender, amount, "", "");

        // 3. Select tokens to withdraw
        uint256 sum = 0;
        tokenIds = new uint256[](1);
        amounts  = new uint256[](1);
        while (sum != amount) {
            uint256 tokenId = _holdings.at(0);
            uint256 balance = EAT.balanceOf(address(this), tokenId);

            tokenIds[tokenIds.length] = tokenId;
            if (sum + balance <= amount) {
                amounts[amounts.length] = balance;
                sum += balance;
                _holdings.remove(0);
                continue;
            } else {
                amounts[amounts.length] = amount - sum;
                break;
            }
        }

        // 4. Transfer EATs and return success
        _sendBatchEAT(recipient, tokenIds, amounts, data);

        return (tokenIds, amounts);
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // Jasmine Pool Conformance Implementations
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
        require(metadataVersion == 1, "JasminePool: No policy for version");
        return abi.encode(
            EAT.exists.selector,
            EAT.frozen.selector
        );
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // Admin Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    // ──────────────────────────────────────────────────────────────────────────────
    // Overrides
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @inheritdoc ERC777
     * @dev See {IERC777-balanceOf}
     */
    function balanceOf(address account) public view override(ERC777, IERC20) returns (uint256) {
        return super.balanceOf(account);
    }

    /**
     * @inheritdoc ERC777
     * @dev See {IERC777-totalSupply}
     */
    function totalSupply() public view override(ERC777, IERC20) returns (uint256) {
        return super.totalSupply();
    }

    /**
     * @inheritdoc ERC777
     * @dev See {IERC777-name}
     */
    function name() public view override(ERC777, IERC20Metadata) returns (string memory) {
        return _name;
    }

    /**
     * @inheritdoc ERC777
     * @dev See {IERC777-symbol}
     */
    function symbol() public view override(ERC777, IERC20Metadata) returns (string memory) {
        return _symbol;
    }

    /**
     * @notice All Jasmine Pools have 9 decimal points
     * 
     * @inheritdoc ERC777
     * @dev See {ERC20-decimals}.
     */
    function decimals() public pure override(ERC777, IERC20Metadata) returns (uint8) {
        return _decimals;
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
            interfaceId == type(IERC777).interfaceId ||
            interfaceId == type(IERC1155Receiver).interfaceId ||
            interfaceId == type(IJasminePool).interfaceId ||
            interfaceId == type(IERC1046).interfaceId ||
            super.supportsInterface(interfaceId);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Token Transfer Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ──────────────────────  ERC-1155 Receiver Conformance  ──────────────────────  \\

    /// @inheritdoc IERC1155Receiver
    function onERC1155Received(
        address operator,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes memory 
    )
        public virtual override
        nonReentrant onlyEAT checkEligibility(tokenId)
        returns (bytes4)
    {
        // 1. Add token ID to holdings
        _holdings.add(tokenId);

        // 2. Mint Tokens
        _mint(
            from,
            value,
            "", // TODO: Anything to pass here🤔
            ""
        );

        // TODO: Call data

        // 3. Emit Deposit and return onERC1155Received
        emit Deposit(operator, from, value);
        return this.onERC1155Received.selector;
    }

    /// @inheritdoc IERC1155Receiver
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] memory tokenIds,
        uint256[] memory values,
        bytes memory 
    )
        public virtual override
        nonReentrant onlyEAT checkEligibilities(tokenIds)
        returns (bytes4)
    {
        // 1. Ensure tokens received are EATs
        if (tokenIds.length != values.length)
            revert ERC1155Errors.ERC1155InvalidArrayLength(
                tokenIds.length,
                values.length
            );

        // 2. Verify all tokens are eligible for pool, add to holdings and sum total EATs received
        uint256 total;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            total += values[i];
            _holdings.add(tokenIds[i]);
        }

        // 3. Authorize JLT mint
        _mint(
            from,
            total,
            "", // TODO: Anything to pass here🤔
            ""
        );

        // TODO: Call data

        // 4. Emit Deposit and return onERC1155BatchReceived
        emit Deposit(operator, from, total);
        return this.onERC1155BatchReceived.selector;
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
        bytes calldata data
    ) internal {
        try EAT.safeTransferFrom(address(this), to, tokenId, amount, data) {
            if (EAT.balanceOf(address(this), tokenId) == 0) _holdings.remove(tokenId);
            emit Withdraw(address(this), to, amount);
        } catch Error(string memory reason) {
            // If failed, attempt to determine cause, else return reason string
            if (EAT.balanceOf(address(this), tokenId) < amount) {
                revert ERC1155Errors.ERC1155InsufficientBalance(
                    address(this),
                    EAT.balanceOf(address(this), tokenId),
                    amount,
                    tokenId
                );
            } else {
                revert(reason);
            }
        } catch {
            revert("JasmineBasePool: Send failed");
        }
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
        try EAT.safeBatchTransferFrom(address(this), to, tokenIds, amounts, data) {
            uint256[] memory balances = EAT.balanceOfBatch(ArrayUtils.fill(address(this), tokenIds.length), tokenIds);
            for (uint256 i = 0; i < balances.length; i++) {
                if (balances[i] == 0) _holdings.remove(tokenIds[i]);
            }
            emit Withdraw(address(this), to, amounts.sum());
        } catch Error(string memory reason) {
            // TODO: Attempt to determine reason
            revert(reason);
        } catch {
            revert("JasmineBasePool: Send failed");
        }
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

    //  ────────────────────────────────  Modifiers  ────────────────────────────────  \

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
     * @dev Enforce caller is approved for holder's JLTs - or caller is holder
     * 
     * @dev Throws Prohibited() on failure
     */
    modifier onlyOperator(address holder) {
        if (_msgSender() != holder || !isOperatorFor(_msgSender(), holder)) revert JasmineErrors.Prohibited();
        _;
    }

}
