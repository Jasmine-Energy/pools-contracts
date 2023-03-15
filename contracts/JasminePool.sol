// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


import { IJasminePool } from "./interfaces/IJasminePool.sol";
import { Initializable } from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import { ERC777 } from "@openzeppelin/contracts/token/ERC777/ERC777.sol";
// import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
// import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
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

    using PoolPolicy for PoolPolicy.DepositPolicy;
    using PoolPolicy for bytes;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Policy to deposit into pool
    // NOTE: Should be Constant but...
    PoolPolicy.DepositPolicy internal _depositPolicy;

    JasmineOracle public immutable oracle;
    JasmineEAT public immutable EAT;

    string public _name;
    string public _symbol;

    // TODO: Should discuss internally before making this assumption
    uint8 public constant _decimals = 18;

    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    constructor(address _eat, address _oracle) ERC777("", "", new address[](0)) {
        require(_eat != address(0), "JasminePool: EAT must be set");
        require(_oracle != address(0), "JasminePool: Oracle must be set");

        // TODO: Add supports interface checks

        oracle = JasmineOracle(_oracle);
        EAT = JasmineEAT(_eat);
    }

    /**
     * @dev
     *
     * @param policy_ Deposit Policy
     * @param name_ JLT token name
     * @param symbol_ JLT token symbol
     */
    function initialize(
        bytes calldata policy_,
        string calldata name_,
        string calldata symbol_
    ) external initializer onlyInitializing {
        _depositPolicy = policy_.toDepositPolicy();
        _name = name_;
        _symbol = symbol_;
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // User Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    // ──────────────────────────────────────────────────────────────────────────────
    // Jasmine Pool Conformance Implementations
    // ──────────────────────────────────────────────────────────────────────────────

    function meetsPolicy(
        uint256 tokenId
    ) public view returns (bool isEligible) {}

    function policyForVersion(
        uint8 metadataVersion
    ) external view override returns (bytes memory policy) {}

    function retire(
        address owner,
        address beneficiary,
        uint256 quantity,
        bytes calldata data
    ) external override returns (bool success) {}

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
    ) external returns (bytes4) {
        // 1. Ensure tokens received are EATs
        require(
            operator == address(EAT),
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
    ) external returns (bytes4) {
        // 1. Ensure tokens received are EATs
        require(
            operator == address(EAT),
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

    function tokenURI() external view returns (string memory) {}

    function deposit(
        address from,
        uint256 tokenId,
        uint256 quantity
    ) external override returns (bool success, uint256 jltQuantity) {}

    function depositBatch(
        address from,
        uint256[] calldata tokenIds,
        uint256[] calldata quantities
    ) external override returns (bool success, uint256 jltQuantity) {}

    function withdraw(
        address owner,
        address recipient,
        uint256 quantity,
        bytes calldata data
    ) external override returns (bool success) {}

    function withdrawSpecific(
        address owner,
        address recipient,
        uint256[] calldata tokenIds,
        uint256[] calldata quantities,
        bytes calldata data
    ) external override returns (bool success) {}


    function supportsInterface(
        bytes4 interfaceId
    ) external view returns (bool) {}

    

    

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    // function _mint(

    // )


    
}
