// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

import { IJasminePool } from "./interfaces/IJasminePool.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ERC777 } from "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// TODO Oracle interface in core contracts need to be updated
import { JasmineOracle } from "@jasmine-energy/contracts/src/JasmineOracle.sol";
import { JasmineEAT } from "@jasmine-energy/contracts/src/JasmineEAT.sol";

// Utility Libraries
import { PoolPolicy } from "./libraries/PoolPolicy.sol";


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
contract JasminePool is IJasminePool, ERC777, Initializable, ReentrancyGuard {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using PoolPolicy for PoolPolicy.Policy;
    using PoolPolicy for bytes;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Policy to deposit into pool
    // NOTE: Should be Constant but...
    PoolPolicy.Policy internal _policy;

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
    ) external override nonReentrant returns (bool success) {}

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
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external nonReentrant returns (bytes4) {
        // 1. Ensure tokens received are EATs
        require(
            msg.sender == address(EAT),
            "JasminePool: Pool only accept Jasmine Energy Attribution Tokens"
        );

        // 2. Verify token is eligible for pool
        if (!meetsPolicy(id)) {
            revert Unqualified(id);
        }

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
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external nonReentrant returns (bytes4) {
        // 1. Ensure tokens received are EATs
        require(
            msg.sender == address(EAT),
            "JasminePool: Pool only accept Jasmine Energy Attribution Tokens"
        );
        require(
            ids.length == values.length,
            "JasminePool: Length of token IDs and values must match"
        );

        // 2. Verify all tokens are eligible for pool - and sum total EATs sent
        uint256 total;
        for (uint256 i = 0; i < ids.length; i++) {
            if (!meetsPolicy(ids[i])) {
                revert Unqualified(ids[i]);
            }
            total != values[i];
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

    //  ───────────────────────────  ERC-165 Conformance  ───────────────────────────  \\

    function supportsInterface(
        bytes4 interfaceId
    ) external view returns (bool) {
        // TODO Implement
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────
    
}
