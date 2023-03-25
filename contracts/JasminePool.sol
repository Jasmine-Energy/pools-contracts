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
contract JasminePool is IJasminePool, ERC777, ERC1155Holder, Initializable, ReentrancyGuard {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using PoolPolicy for PoolPolicy.Policy;
    using PoolPolicy for bytes;

    using EnumerableSet for EnumerableSet.UintSet;

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

    string public _name;
    string public _symbol;
    // TODO: Should discuss internally before making this assumption
    uint8 public constant _decimals = 18;

    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    // TODO: Need to override ERC777 name and symbol methods
    constructor(address _eat, address _oracle) 
        ERC777("Jasmine Liquidity Token Core", "JLT", new address[](0)) {
        require(_eat != address(0), "JasminePool: EAT must be set");
        require(_oracle != address(0), "JasminePool: Oracle must be set");

        // TODO: Add supports interface checks

        oracle = JasmineOracle(_oracle);
        EAT = JasmineEAT(_eat);
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
    ) external initializer onlyInitializing {
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
    ) external view override returns (bytes memory policy) {
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
    ) external override nonReentrant returns (bool success) {}

    //  ───────────────────────────  Deposit Functions  ─────────────────────────────  \\

    function deposit(
        address from,
        uint256 tokenId,
        uint256 quantity
    ) external override nonReentrant returns (bool success, uint256 jltQuantity) {}

    function depositBatch(
        address from,
        uint256[] calldata tokenIds,
        uint256[] calldata quantities
    ) external override nonReentrant returns (bool success, uint256 jltQuantity) {}


    //  ──────────────────────────  Withdrawal Functions  ───────────────────────────  \\

    function withdraw(
        address owner,
        address recipient,
        uint256 quantity,
        bytes calldata data
    ) external override nonReentrant returns (bool success) {
        
    }

    function withdrawSpecific(
        address owner,
        address recipient,
        uint256[] calldata tokenIds,
        uint256[] calldata quantities,
        bytes calldata data
    ) external override nonReentrant returns (bool success) {}

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
    ) public virtual override nonReentrant returns (bytes4)  {
        // 1. Ensure tokens received are EATs
        require(
            _msgSender() == address(EAT),
            "JasminePool: Pool only accept Jasmine Energy Attribution Tokens"
        );

        // 2. Verify token is eligible for pool
        if (!meetsPolicy(tokenId)) {
            revert Unqualified(tokenId);
        }

        // 3. Add token ID to holdings
        _holdings.add(tokenId);

        // 4. Mint Tokens
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
    ) public virtual override returns (bytes4) {
        // 1. Ensure tokens received are EATs
        require(
            _msgSender() == address(EAT),
            "JasminePool: Pool only accept Jasmine Energy Attribution Tokens"
        );
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
    
}
