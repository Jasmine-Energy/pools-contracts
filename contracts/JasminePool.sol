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

// TODO Oracle interface in core contracts need to be updated
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


//  ─────────────────────────────────────────────────────────────────────────────
//  Custom Errors
//  ─────────────────────────────────────────────────────────────────────────────

error Unqualified(uint256 tokenId);
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

    using PoolPolicy for PoolPolicy.Policy;
    using PoolPolicy for bytes;

    using EnumerableSet for EnumerableSet.UintSet;
    using ArrayUtils for uint256[];

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Policy to deposit into pool
    // NOTE: Should be Constant but...
    PoolPolicy.Policy internal _policy;

    /// @dev Convenience mapping to record EATs held by a given pool
    EnumerableSet.UintSet internal _holdings;

    JasmineOracle public immutable oracle;
    JasmineEAT public immutable EAT;
    address public immutable poolFactory;

    string public _name;
    string public _symbol;
    // TODO: Should discuss internally before making this assumption
    uint8 public constant _decimals = 18;

    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    // TODO: Need to override ERC777 name and symbol methods
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
     * @dev
     *
     * @param policyConditions_ Deposit Policy Conditions
     * @param name_ JLT token name
     * @param symbol_ JLT token symbol
     */
    function initialize(
        bytes calldata policyConditions_,
        string calldata name_,
        string calldata symbol_
    ) external initializer onlyInitializing onlyFactory {
        // PoolPolicy.Condition[] memory conditions = abi.decode(policyConditions_, (PoolPolicy.Condition[]));
        // _policy.insert(conditions);
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
        isEligible = _policy.meetsPolicy(tokenId);
    }

    function policyForVersion(
        uint8 metadataVersion
    ) external view returns (bytes memory policy) {
        require(metadataVersion == 1, "JasminePool: No policy for version");
        // TODO: Encode packed conditions
        return abi.encode(1);
    }


    //  ──────────────────────────  Retirement Functions  ───────────────────────────  \\

    function retire(
        address owner,
        address beneficiary,
        uint256 quantity,
        bytes calldata data
    ) external nonReentrant returns (bool success) {}

    //  ───────────────────────────  Deposit Functions  ─────────────────────────────  \\

    function deposit(
        uint256 tokenId,
        uint256 amount
    ) external nonReentrant returns (bool success, uint256 jltQuantity) {
        return _deposit(_msgSender(), tokenId, amount);
    }

    function operatorDeposit(
        address from,
        uint256 tokenId,
        uint256 amount
    ) external nonReentrant returns (bool success, uint256 jltQuantity) {
        return _deposit(from, tokenId, amount);
    }

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

    function depositBatch(
        address from,
        uint256[] calldata tokenIds,
        uint256[] calldata amounts
    ) external nonReentrant returns (bool success, uint256 jltQuantity) {
        try EAT.safeBatchTransferFrom(from, address(this), tokenIds, amounts, "") {
            return (true, amounts.sum());
        } catch {
            return (false, 0);
        }
    }


    //  ──────────────────────────  Withdrawal Functions  ───────────────────────────  \\

    function withdraw(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external nonReentrant returns (bool success) {
        success = _withdraw(_msgSender(), recipient, amount, data);
    }

    function operatorWithdraw(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external nonReentrant returns (bool success) {
        // 1. Ensure caller is operator of sender
        require(
            isOperatorFor(_msgSender(), sender),
            "JasminePool: Unauthorized for sender"
        );

        // 2. Call withdraw
        success = _withdraw(sender, recipient, amount, data);
    }

    /**
     * @notice Internal implementation of withdraw
     * @dev Burns `amount` of JLTs from `sender` and
     * transfers EATs to recipient with `data`.
     */
    function _withdraw(
        address sender,
        address recipient,
        uint256 amount,
        bytes memory data
    ) private returns(bool success) {
        // 1. Ensure caller has sufficient JLTs
        require(
            balanceOf(sender) >= amount,
            "JasminePool: Insufficient funds"
        );

        // 2. Burn tokens
        _burn(sender, amount, "", "");

        // 3. Select token to withdraw
        

        // 4. Transfer EATs
    }

    function withdrawSpecific(
        address owner,
        address recipient,
        uint256[] calldata tokenIds,
        uint256[] calldata quantities,
        bytes calldata data
    ) external nonReentrant returns (bool success) {}

    // ──────────────────────────────────────────────────────────────────────────────
    // ERC Conformance Implementations
    // ──────────────────────────────────────────────────────────────────────────────

    //  ──────────────────────  ERC-1155 Receiver Conformance  ──────────────────────  \\

    function onERC1155Received(
        address operator,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes memory data
    ) public virtual override nonReentrant onlyEAT returns(bytes4)  {
        // 1. Verify token is eligible for pool
        if (!meetsPolicy(tokenId)) {
            revert Unqualified(tokenId);
        }

        // 2. Add token ID to holdings
        _holdings.add(tokenId);

        // 3. Mint Tokens
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
        address operator,
        address from,
        uint256[] memory tokenIds,
        uint256[] memory values,
        bytes memory data
    ) public virtual override nonReentrant onlyEAT returns(bytes4) {
        // 1. Ensure tokens received are EATs
        require(
            tokenIds.length == values.length,
            "JasminePool: Length of token IDs and values must match"
        );

        // 2. Verify all tokens are eligible for pool, add to holdings and sum total EATs received
        uint256 total;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            if (!meetsPolicy(tokenIds[i])) {
                revert Unqualified(tokenIds[i]);
            }
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

    function tokenURI() external view returns (string memory) {
        // TODO Implement
    }

    //  ────────────────────────────  ERC-777 Overrides  ────────────────────────────  \\

    /**
     * @inheritdoc ERC777
     * @dev See {IERC777-name}.
     */
    function name() public view override returns (string memory) {
        return _name;
    }

    /**
     * @inheritdoc ERC777
     * @dev See {IERC777-symbol}.
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

    function supportsInterface(
        bytes4 interfaceId
    ) public view override returns (bool) {
        return interfaceId == type(IERC20).interfaceId || interfaceId == type(IERC20Metadata).interfaceId ||
            interfaceId == type(IERC777).interfaceId ||
            interfaceId == type(IERC1155Receiver).interfaceId ||
            interfaceId == type(IJasminePool).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────
    
    //  ────────────────────────────────  Modifiers  ────────────────────────────────  \\
    /**
     * @dev Enforce msg sender is EAT contract
     */
    modifier onlyEAT {
        require(_msgSender() == address(EAT), "JasminePool: caller must be EAT contract");
        _;
    }

    /**
     * @dev Enforce msg sender is Pool Factory contract
     */
    modifier onlyFactory() {
        require(_msgSender() == poolFactory, "JasminePool: caller must be Pool Factory contract");
        _;
    }
}
