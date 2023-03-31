// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

import { IJasminePool } from "./interfaces/IJasminePool.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ERC1155Holder } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import { ERC777 } from "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import { JasmineOracle } from "@jasmine-energy/contracts/src/JasmineOracle.sol";
import { JasmineEAT } from "@jasmine-energy/contracts/src/JasmineEAT.sol";

// Utility Libraries
import { PoolPolicy } from "./libraries/PoolPolicy.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { ArrayUtils } from "./libraries/ArrayUtils.sol";

// Interfaces
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import { IERC1155Receiver } from "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";
import { IERC777 } from "@openzeppelin/contracts/interfaces/IERC777.sol";
import { IERC1046 } from "./interfaces/ERC/IERC1046.sol";
import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";


//  ─────────────────────────────────────────────────────────────────────────────
//  Custom Errors
//  ─────────────────────────────────────────────────────────────────────────────

/// @dev Emitted if a token does not meet pool's deposit policy
error Unqualified(uint256 tokenId);
/// @dev Emitted for unauthorized actions
error Prohibited();


/**
 * TODO: Write docs
 * @title Jasmine Reference Pool
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
 * @custom:security-contact // TODO: set sec contact
 */
// contract JasminePool is IJasminePool, ERC777, ERC1155Holder, Initializable, ReentrancyGuard {
contract JasminePool is ERC777, ERC1155Holder, Initializable, ReentrancyGuard {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using PoolPolicy for PoolPolicy.DepositPolicy;
    using PoolPolicy for bytes;

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

    /// @dev Policy to deposit into pool
    PoolPolicy.DepositPolicy internal _policy;

    /// @dev Convenience mapping to record EATs held by a given pool
    EnumerableSet.UintSet internal _holdings;

    JasmineOracle public immutable oracle;
    JasmineEAT public immutable EAT;
    address public immutable poolFactory;

    /// @notice Token Display name - per ERC-777/20
    string private _name;
    /// @notice Token Symbol - per ERC-777/20
    string private _symbol;
    /// @notice JLT's decimal precision
    uint8 private constant _decimals = 9;

    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    constructor(address _eat, address _oracle, address _poolFactory)
        ERC777("Jasmine Liquidity Token Core", "JLT", new address[](0)) {
        require(_eat != address(0), "JasminePool: EAT must be set");
        require(_oracle != address(0), "JasminePool: Oracle must be set");
        require(_poolFactory != address(0), "JasminePool: Pool factory must be set");

        // TODO: Add supports interface checks

        oracle = JasmineOracle(_oracle);
        EAT = JasmineEAT(_eat);
        poolFactory = _poolFactory;
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
    ) external initializer onlyInitializing onlyFactory {
        _policy = abi.decode(policy_, (PoolPolicy.DepositPolicy));
        _name = name_;
        _symbol = symbol_;
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // User Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    // ──────────────────────────────────────────────────────────────────────────────
    // Jasmine Pool Conformance Implementations
    // ──────────────────────────────────────────────────────────────────────────────


    //  ────────────────────────────  Policy Functions  ─────────────────────────────  \\

    function meetsPolicy(
        uint256 tokenId
    ) public view returns (bool isEligible) {
        isEligible = _isLegitimateToken(tokenId) && _policy.meetsPolicy(oracle, tokenId);
    }

    function policyForVersion(
        uint8 metadataVersion
    ) external view returns (bytes memory policy) {
        require(metadataVersion == 1, "JasminePool: No policy for version");
        return abi.encode(
            _policy.vintagePeriod,
            _policy.techType,
            _policy.registry,
            _policy.certification,
            _policy.endorsement
        );
    }


    //  ──────────────────────────  Retirement Functions  ───────────────────────────  \\

    function retire(
        address sender,
        address beneficiary,
        uint256 quantity,
        bytes calldata data
    ) external nonReentrant onlyOperator(sender) returns (bool success) {
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
     * @return success Whether deposit was successful
     * @return jltQuantity Number of JLTs issued
     */
    function deposit(
        uint256 tokenId,
        uint256 amount
    ) external nonReentrant checkEligibility(tokenId) returns (bool success, uint256 jltQuantity) {
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
     * @return success Whether deposit was successful
     * @return jltQuantity Number of JLTs issued
     */
    function operatorDeposit(
        address from,
        uint256 tokenId,
        uint256 amount
    ) external nonReentrant onlyOperator(from) checkEligibility(tokenId) returns (bool success, uint256 jltQuantity) {
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
     * @return success Whether deposit was successful
     * @return jltQuantity Number of JLTs issued
     */
    function depositBatch(
        address from,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    ) external nonReentrant onlyOperator(from) checkEligibilities(tokenIds) returns (bool success, uint256 jltQuantity) {
        try EAT.safeBatchTransferFrom(from, address(this), tokenIds, amounts, "") {
            return (true, amounts.sum());
        } catch {
            return (false, 0);
        }
    }

    /**
     * 
     * @param from Address from which EATs will be transfered
     * @param tokenId ID of EAT to deposit into pool
     * @param amount Number of EATs to deposit
     * @return success Whether deposit was successful
     * @return jltQuantity Number of JLTs issued
     */
    function _deposit(
        address from,
        uint256 tokenId,
        uint256 amount
    ) private returns (bool success, uint256 jltQuantity) {
        // NOTE: JLTs are minted on ERC-1155 receipt. This function merely transfers EATs to contract
        try EAT.safeTransferFrom(from, address(this), tokenId, amount, "") {
            return (true, amount);
        } catch {
            return (false, 0);
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
    ) external nonReentrant returns (bool success) {
        success = _withdraw(_msgSender(), recipient, amount, data);
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
    ) external nonReentrant onlyOperator(sender) returns (bool success) {
        success = _withdraw(sender, recipient, amount, data);
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
    ) external nonReentrant onlyOperator(sender) {
        // 1. Ensure sender has sufficient JLTs and lengths match
        uint256 amountSum = amounts.sum();
        require(
            balanceOf(sender) >= amountSum,
            "JasminePool: Insufficient funds"
        );
        require(
            tokenIds.length == amounts.length,
            "JasminePool: Length of token IDs and amounts must match"
        );

        // 2. Burn Tokens
        _burn(sender, amountSum, "", "");

        // 3. Transfer Select Tokens
        require(
            _sendBatchEAT(recipient, tokenIds, amounts, data),
            "JasminePool: Transfer failed"
        );
    }

    /**
     * @notice Internal implementation of withdraw
     * 
     * @dev Burns `amount` of JLTs from `sender` and transfers EATs to recipient with `data`.
     */
    function _withdraw(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data // TODO: this should prob specify WHO is receiving data (burn or EAT transfer)
    ) private returns(bool success) {
        // 1. Ensure caller has sufficient JLTs
        require(
            balanceOf(sender) >= amount,
            "JasminePool: Insufficient funds"
        );

        // 2. Burn Tokens
        _burn(sender, amount, "", "");

        // 3. Select tokens to withdraw
        uint256 sum = 0;
        uint256[] memory tokenIds;
        uint256[] memory amounts;
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

        // 4. Transfer EATs
        _sendBatchEAT(recipient, tokenIds, amounts, data);
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // ERC Conformance Implementations
    // ──────────────────────────────────────────────────────────────────────────────

    //  ──────────────────────  ERC-1155 Receiver Conformance  ──────────────────────  \\

    function onERC1155Received(
        address,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes memory data
    ) public virtual override nonReentrant onlyEAT checkEligibility(tokenId) returns(bytes4)  {
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

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] memory tokenIds,
        uint256[] memory values,
        bytes memory data
    ) public virtual override nonReentrant onlyEAT checkEligibilities(tokenIds) returns(bytes4) {
        // 1. Ensure tokens received are EATs
        require(
            tokenIds.length == values.length,
            "JasminePool: Length of token IDs and values must match"
        );

        // 2. Verify all tokens are eligible for pool, add to holdings and sum total EATs received
        uint256 total;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            total != values[i];
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

        return this.onERC1155BatchReceived.selector;
    }

    //  ──────────────────────────  ERC-1046 Conformance  ───────────────────────────  \\

    /**
     * @dev See {IERC1046-tokenURI}
     */
    function tokenURI() external view returns (string memory) {
        // TODO Implement in base64 data url
    }

    //  ────────────────────────────  ERC-777 Overrides  ────────────────────────────  \\

    /**
     * @inheritdoc ERC777
     * @dev See {IERC777-name}
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @inheritdoc ERC777
     * @dev See {IERC777-symbol}
     */
    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    /**
     * @inheritdoc ERC777
     * @dev See {ERC20-decimals}.
     *
     * Always returns 18, as per the
     * [ERC777 EIP](https://eips.ethereum.org/EIPS/eip-777#backward-compatibility).
     */
    function decimals() public pure override returns (uint8) {
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
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Used to check a token exists and is not frozen
     * 
     * @param tokenId EAT token ID to check
     * @return isLegit Boolean if token passed legitimacy check
     */
    function _isLegitimateToken(uint256 tokenId) internal view returns(bool isLegit) {
        return EAT.exists(tokenId) && !EAT.frozen(tokenId);
    }

    //  ─────────────────────────  EAT Transfer Utilities  ──────────────────────────  \\

    /**
     * @dev Internal method for sending EAT out of contract and updating holdings
     */
    function _sendEAT(
        address to,
        uint256 tokenId,
        uint256 amount,
        bytes calldata data
    ) private returns(bool success) {
        try EAT.safeTransferFrom(address(this), to, tokenId, amount, data) {
            if (EAT.balanceOf(address(this), tokenId) == 0) _holdings.remove(tokenId);
            emit Withdraw(address(this), to, amount);
            return true;
        } catch {
            return false;
        }
    }

    /**
     * @dev Internal method for sending batch of EATs out of contract and updating holdings
     */
    function _sendBatchEAT(
        address to,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) private returns(bool success) {
        try EAT.safeBatchTransferFrom(address(this), to, tokenIds, amounts, data) {
            uint256[] memory balances = EAT.balanceOfBatch(ArrayUtils.fill(address(this), tokenIds.length), tokenIds);
            for (uint256 i = 0; i < balances.length; i++) {
                if (balances[i] == 0) _holdings.remove(tokenIds[i]);
            }
            emit Withdraw(address(this), to, amounts.sum());
            return true;
        } catch {
            return false;
        }
    }
    
    //  ────────────────────────────────  Modifiers  ────────────────────────────────  \\

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

    function _enforceEligibility(uint256 tokenId) private view {
        if (!meetsPolicy(tokenId)) revert Unqualified(tokenId);
    }

    function _enforceEligibility(uint256[] memory tokenIds) private view {
        for (uint i = 0; i < tokenIds.length; i++) {
            _enforceEligibility(tokenIds[i]);
        }
    }

    /**
     * @dev Enforce msg sender is EAT contract
     */
    modifier onlyEAT {
        if (_msgSender() != address(EAT)) revert Prohibited();
        _;
    }

    /**
     * @dev Enforce msg sender is Pool Factory contract
     */
    modifier onlyFactory() {
        if (_msgSender() != poolFactory) revert Prohibited();
        _;
    }

    /**
     * @dev Enforce caller is approved for holder's JLTs - or caller is holder
     */
    modifier onlyOperator(address holder) {
        if (_msgSender() != holder || !isOperatorFor(_msgSender(), holder)) revert Prohibited();
        _;
    }
}
