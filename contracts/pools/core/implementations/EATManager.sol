// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;

//  ─────────────────────────────────  Imports  ─────────────────────────────────  \\

import { IERC1155 }         from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { ERC1155Receiver }  from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import { IERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import { RedBlackTree }     from "../../../libraries/RedBlackTreeLibrary.sol";
import { ArrayUtils }       from "../../../libraries/ArrayUtils.sol";


/**
 * @title Jasmien EAT Manager
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Manages deposits and withdraws of Jasmine EATs (ERC-1155).
 * @custom:security-contact dev@jasmine.energy
 */
abstract contract EATManager is ERC1155Receiver {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using RedBlackTree for RedBlackTree.Tree;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Address of the ERC-1155 contract
    address public immutable eat;
    // address public immutable eat;

    /// @dev Total number of ERC-1155 deposits
    uint256 internal _totalDeposits;

    /// @dev RBTree for storing vintage to token IDs mappings
    RedBlackTree.Tree private _tree;

    /// @dev Maps vintage to token IDs
    mapping(uint40 => uint256[]) private _tokenIds;

    uint8 private constant WITHDRAWS_LOCK = 1;
    uint8 private constant WITHDRAWS_UNLOCKED = 2;

    uint8 private _isUnlocked;


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Errors
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @dev Emitted if tokens (ERC-1155) are received from incorrect contract
    error InvalidTokenAddress(address received, address expected);

    /// @dev Emitted if withdraws are locked
    error WithdrawsLocked();


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Setup Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @param _eat Jasmine EAT contract whose tokens may be deposited
     */
    constructor(address _eat) {
        eat = _eat;

        _isUnlocked = WITHDRAWS_LOCK;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Hooks
    //  ─────────────────────────────────────────────────────────────────────────────

    function _beforeDeposit(address from, uint256[] memory tokenIds, uint256[] memory values) internal virtual;
    function _afterDeposit(address from, uint256 quantity) internal virtual;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  ERC-1155 Deposit Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IERC1155Receiver
    function onERC1155Received(
        address,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes memory
    )
        external override
        returns (bytes4)
    {
        _enforceTokenCaller();

        _beforeDeposit(from, _asSingletonArray(tokenId), _asSingletonArray(value));
        _addDeposit(tokenId, value);
        _afterDeposit(from, value);

        return this.onERC1155Received.selector;
    }

    /// @inheritdoc IERC1155Receiver
    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] memory tokenIds,
        uint256[] memory values,
        bytes memory
    )
        external override
        returns (bytes4)
    {
        _enforceTokenCaller();

        _beforeDeposit(from, tokenIds, values);
        uint256 quantityDeposited = _addDeposits(tokenIds, values);
        _afterDeposit(from, quantityDeposited);

        return this.onERC1155BatchReceived.selector;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Deposit Modifying Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Internal utility for sending tokens out of the contract.
     * 
     * @dev Requires withdraws to be unlocked via "unlocked" modifier.
     * 
     * @param recipient Address to receive tokens
     * @param tokenIds Token IDs held by the contract to transfer
     * @param values Number of tokens to transfer for each token ID
     * @param data Additional calldata to include in transfer
     */
    function _transferDeposits(
        address recipient,
        uint256[] memory tokenIds,
        uint256[] memory values,
        bytes memory data
    )
        internal
        withdrawsUnlocked
    {
        if (tokenIds.length == 1) {
            _removeDeposit(tokenIds[0], values[0]);
            IERC1155(eat).safeTransferFrom(
                address(this),
                recipient,
                tokenIds[0],
                values[0],
                data
            );
        } else {
            _removeDeposits(tokenIds, values);
            IERC1155(eat).safeBatchTransferFrom(
                address(this),
                recipient,
                tokenIds,
                values,
                data
            );
        }
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Withdrawal Internal Utilities
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Internal function to select tokens to withdraw from the contract
     * 
     * @param amount Number of tokens to withdraw from contract
     * 
     * @return tokenIds Token IDs to withdraw
     * @return amounts Number of tokens to withdraw for each token ID
     */
    function selectWithdrawTokens(uint256 amount)
        public view
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        uint256 sum = 0;
        uint256 i = 0;
        uint256 finalBalance;

        uint current = _tree.first();

        while (sum != amount) {
            uint256[] memory tokenIdsForVintage = _tokenIds[uint40(current)];
            for (uint256 j = 0; j < tokenIdsForVintage.length;) {
                uint256 balance = IERC1155(eat).balanceOf(address(this), tokenIdsForVintage[j]);

                if (balance == 0) {
                    // TODO: Should never hit this, but requires checks
                } else if (sum + balance < amount) {
                    unchecked {
                        sum += balance;
                        j++;
                        i++;
                    }
                } else {
                    unchecked {
                        finalBalance = amount - sum;
                        sum = amount;
                        i++;
                    }
                    break;
                }
            }

            if (current == _tree.last()) break;
            else current = _tree.next(current);
        }

        current = _tree.first();

        if (i == 1) {
            tokenIds = _asSingletonArray(_tokenIds[uint40(current)][0]);
            amounts  = _asSingletonArray(amount);
        } else {
            tokenIds = new uint256[](i);
            for (uint x = 0; x < i;) {
                uint256[] memory tokenIdsForVintage = _tokenIds[uint40(current)];
                assembly { // NOTE: Unable to use "memory-safe"
                    let len := mload(tokenIdsForVintage)
                    for { let n := 0 } lt(n, len) { n := add(n, 1) } { 
                        mstore(
                            add(tokenIds, add(mul(x, 32), mul(add(n, 1), 32))),
                            mload(add(tokenIdsForVintage, mul(add(n, 1), 32)))
                        )
                    }
                }
                x += tokenIdsForVintage.length;

                if (current == _tree.last()) break;
                else current = _tree.next(current);
            }

            amounts = IERC1155(eat).balanceOfBatch(ArrayUtils.fill(address(this), i), tokenIds);
            amounts[i-1] = finalBalance;
        }

        return (tokenIds, amounts);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Deposit Management Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ─────────────────────────────  Adding Deposits  ─────────────────────────────  \\

    /**
     * @dev Adds a deposit to the contract's tree of vintages and token IDs
     * 
     * @param tokenId Newly deposited token ID to store
     * @param value Amount of the token received
     */
    function _addDeposit(
        uint256 tokenId,
        uint256 value
    )
        private
    {
        uint40 vintage = _getVintageFromTokenId(tokenId);

        if (!_tree.exists(vintage)) {
            // If token does not exist in tree, add to tree and set of token IDs
            _tree.insert(vintage);
            _tokenIds[vintage].push(tokenId);
        } else if (IERC1155(eat).balanceOf(address(this), tokenId) == value) {
            // If contract's balance of token is equal to value, token ID is new and must be added to token IDs
            _tokenIds[vintage].push(tokenId);
        }

        _totalDeposits += value;
    }

    /**
     * @dev Adds a deposit to the contract's tree of vintages and token IDs
     * 
     * @param tokenIds Newly deposited token IDs to store
     * @param values Amounts of the token received
     */
    function _addDeposits(
        uint256[] memory tokenIds,
        uint256[] memory values
    )
        private
        returns (uint256 quantity)
    {
        uint256[] memory balances = IERC1155(eat).balanceOfBatch(ArrayUtils.fill(address(this), tokenIds.length), tokenIds);

        for (uint256 i = 0; i < tokenIds.length;) {
            quantity += values[i];

            uint40 vintage = _getVintageFromTokenId(tokenIds[i]);
            if (!_tree.exists(vintage)) {
                // If token does not exist in tree, add to tree and set of token IDs
                _tree.insert(vintage);
                _tokenIds[vintage].push(tokenIds[i]);
            } else if (balances[i] == values[i]) { // TODO: Once efficient contains exists, rewrite the following
                // If contract's balance of token is equal to value, token ID is new and must be added to token IDs
                _tokenIds[vintage].push(tokenIds[i]);
            }

            unchecked { i++; }
        }

        _totalDeposits += quantity;
    }

    //  ────────────────────────────  Removing Deposits  ────────────────────────────  \\

    /**
     * @dev Used to record a token removal from the contract's internal records. Removes
     * token ID from tree and vintage to token ID mapping if possible.
     * 
     * @param tokenId Token ID to remove from internal records
     * @param value Amount of token being removed
     */
    function _removeDeposit(
        uint256 tokenId,
        uint256 value
    )
        private
    {
        uint256 balance = IERC1155(eat).balanceOf(address(this), tokenId);
        // TODO: Edge cases (balance == 0, balance < value)
        if (balance == value) {
            uint40 vintage = _getVintageFromTokenId(tokenId);
            if (_tokenIds[vintage].length == 1) {
                _tree.remove(vintage);
                delete _tokenIds[vintage];
            } else {
                // TODO: Find an optimal way to remove tokenId from _tokenIds[vintage]. This will not suffice
                for (uint256 i = 0; i < _tokenIds[vintage].length; i++) {
                    if (_tokenIds[vintage][i] == tokenId) {
                        _tokenIds[vintage][i] = _tokenIds[vintage][_tokenIds[vintage].length - 1];
                        _tokenIds[vintage].pop();
                        break;
                    }
                }
            }
        }

        _totalDeposits -= value;
    }

    /**
     * @dev Used to record a token removal from the contract's internal records. Removes
     * token ID from tree and vintage to token ID mapping if possible.
     * 
     * @param tokenIds Token IDs to remove from internal records
     * @param values Amount per token being removed
     */
    function _removeDeposits(
        uint256[] memory tokenIds,
        uint256[] memory values
    )
        private
    {
        uint256[] memory balances = IERC1155(eat).balanceOfBatch(ArrayUtils.fill(address(this), tokenIds.length), tokenIds);

        uint256 total;
        for (uint256 i = 0; i < tokenIds.length;) {
            total += values[i];
            // TODO: Edge cases (balance == 0, balance < value)
            if (balances[i] == values[i]) {
                uint40 vintage = _getVintageFromTokenId(tokenIds[i]);
                if (_tokenIds[vintage].length == 1) {
                    _tree.remove(vintage);
                } else {
                    // TODO: Find an optimal way to remove tokenId from _tokenIds[vintage]. This will not suffice
                    for (uint256 j = 0; j < _tokenIds[vintage].length; j++) {
                        if (_tokenIds[vintage][j] == tokenIds[i]) {
                            _tokenIds[vintage][j] = _tokenIds[vintage][_tokenIds[vintage].length - 1];
                            _tokenIds[vintage].pop();
                            break;
                        }
                    }
                }
            }

            unchecked { i++; }
        }

        _totalDeposits -= total;
    }

    /// @dev Returns the vintage given a Jasmine EAT token ID
    function _getVintageFromTokenId(uint256 tokenId) private pure returns (uint40 vintage) {
        return uint40((tokenId >> 56) & type(uint40).max);
    }

    /// @dev Returns element in an array by iteself
    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory array) {
        array = new uint256[](1);
        assembly ("memory-safe") {
            mstore(add(array, 32), element)
        }
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Modifiers and State Enforcement Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @dev Enforces that contract is in an explicitly set unlocked state for transfers
    function _enforceUnlocked() private view {
        if (_isUnlocked != WITHDRAWS_UNLOCKED) revert WithdrawsLocked();
    }

    /// @dev Unlocks withdrawals for the contract
    modifier withdrawal() {
        _isUnlocked = WITHDRAWS_UNLOCKED;
        _;
        _isUnlocked = WITHDRAWS_LOCK;
    }

    /// @dev Enforces that withdraw modifier is explicitly stated by invoking function
    modifier withdrawsUnlocked() {
        _enforceUnlocked();
        _;
    }

    /// @dev Enforces that caller is the expect token address
    function _enforceTokenCaller() private view {
        if (eat != msg.sender) revert InvalidTokenAddress(msg.sender, eat);
    }
}
