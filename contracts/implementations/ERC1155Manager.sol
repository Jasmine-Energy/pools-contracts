// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { ERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import { RedBlackTree } from "../libraries/RedBlackTreeLibrary.sol";
import { ArrayUtils } from "../libraries/ArrayUtils.sol";
import { JasmineErrors } from "../interfaces/errors/JasmineErrors.sol";

/**
 * @title ERC-1155 Manager
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Manages deposits of ERC-1155 tokens (from a single contract) and enables
 *         interactions with the underlying deposits through explicit conventions.
 * @custom:security-contact dev@jasmine.energy
 */
abstract contract ERC1155Manager is ERC1155Receiver {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using RedBlackTree for RedBlackTree.Tree;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    address private immutable _tokenAddress;

    uint256 public totalDeposits;
    RedBlackTree.Tree private tree;

    /// @dev Maps vintage to token ID
    mapping(uint40 => uint256) private _tokenIds;

    uint8 private constant WITHDRAWS_LOCK = 1;
    uint8 private constant WITHDRAWS_UNLOCKED = 2;

    uint8 private _isUnlocked;


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Setup Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @param tokenAddress_ ERC-1155 contract to restrict deposits from
     */
    constructor(address tokenAddress_) {
        _tokenAddress = tokenAddress_;

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

    function onERC1155Received(
        address,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes memory
    )
        public virtual override
        returns (bytes4)
    {
        _enforceTokenAddress(msg.sender);

        (uint256[] memory tokenIds, uint256[] memory values) = (new uint256[](1), new uint256[](1));
        tokenIds[0] = tokenId;
        values[0] = value;
        _beforeDeposit(from, tokenIds, values);
        _addDeposit(tokenId, value);
        _afterDeposit(from, value);

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] memory tokenIds,
        uint256[] memory values,
        bytes memory
    )
        public virtual override
        returns (bytes4)
    {
        _enforceTokenAddress(msg.sender);

        _beforeDeposit(from, tokenIds, values);
        uint256 quantityDepositted = _addDeposits(tokenIds, values);
        _afterDeposit(from, quantityDepositted);

        return this.onERC1155BatchReceived.selector;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Deposit Modifying Functions
    //  ─────────────────────────────────────────────────────────────────────────────

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
            IERC1155(_tokenAddress).safeTransferFrom(
                address(this),
                recipient,
                tokenIds[0],
                values[0],
                data
            );
        } else {
            _removeDeposits(tokenIds, values);
            IERC1155(_tokenAddress).safeBatchTransferFrom(
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

    function _selectWithdrawTokens(uint256 amount)
        internal view
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        uint256 sum = 0;
        uint256 i = 0;
        uint256 finalBalance;

        uint current = tree.first();

        while (sum != amount) {
            uint256 tokenId = _tokenIds[uint40(current)];
            uint256 balance = IERC1155(_tokenAddress).balanceOf(address(this), tokenId);
            if (sum + balance < amount) {
                unchecked {
                    sum += balance;
                    i++;
                    current = tree.next(current);
                }
                continue;
            } else {
                unchecked {
                    finalBalance = amount - sum;
                    i++;
                }
                break;
            }
        }

        current = tree.first();

        if (i == 1) {
            tokenIds = new uint256[](1);
            tokenIds[0] = _tokenIds[uint40(current)];
            amounts = new uint256[](1);
            amounts[0] = finalBalance;
        } else {
            tokenIds = new uint256[](i);
            for (uint x = 0; x < i;) {
                tokenIds[x] = _tokenIds[uint40(current)];
                current = tree.next(current);
                unchecked { x++; }
            }
            amounts = IERC1155(_tokenAddress).balanceOfBatch(ArrayUtils.fill(address(this), i), tokenIds);
            amounts[i-1] = finalBalance;
        }

        return (tokenIds, amounts);
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Deposit Management Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ─────────────────────────────  Adding Deposits  ─────────────────────────────  \\

    function _addDeposit(
        uint256 tokenId,
        uint256 value
    )
        private
    {
        totalDeposits += value;

        uint40 vintage = _getVintageFromTokenId(tokenId);
        if (tree.exists(vintage)) return;
        tree.insert(vintage);
        _tokenIds[vintage] = tokenId;
    }

    function _addDeposits(
        uint256[] memory tokenIds,
        uint256[] memory values
    )
        private
        returns (uint256 quantity)
    {
        for (uint256 i = 0; i < tokenIds.length;) {
            quantity += values[i];

            uint40 vintage = _getVintageFromTokenId(tokenIds[i]);
            if (tree.exists(vintage)) {
                unchecked { i++; }
                continue;
            }
            tree.insert(vintage);
            _tokenIds[vintage] = tokenIds[i];

            unchecked { i++; }
        }
        totalDeposits += quantity;
    }

    //  ────────────────────────────  Removing Deposits  ────────────────────────────  \\

    function _removeDeposit(
        uint256 tokenId,
        uint256 value
    )
        private
    {
        uint256 balance = IERC1155(_tokenAddress).balanceOf(address(this), tokenId);
        if (balance == 0) {
            uint40 vintage = _getVintageFromTokenId(tokenId);
            tree.remove(vintage);
            delete _tokenIds[vintage];
        }
        totalDeposits -= value;
    }

    function _removeDeposits(
        uint256[] memory tokenIds,
        uint256[] memory values
    )
        private
    {
        uint256[] memory balances = IERC1155(_tokenAddress).balanceOfBatch(ArrayUtils.fill(address(this), tokenIds.length), tokenIds);

        uint256 total;
        for (uint256 i = 0; i < tokenIds.length;) {
            total += values[i];
            if (balances[i] == 0) {
                uint40 vintage = _getVintageFromTokenId(tokenIds[i]);
                tree.remove(vintage);
                delete _tokenIds[vintage];
            }

            unchecked { i++; }
        }
        totalDeposits -= total;
    }

    function _getVintageFromTokenId(uint256 tokenId) private pure returns (uint40) {
        return uint40(tokenId >> 216);
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Modifiers and State Enforcement Functions
    //  ─────────────────────────────────────────────────────────────────────────────


    function _enforceUnlock() private view {
        if (_isUnlocked != WITHDRAWS_UNLOCKED) revert JasmineErrors.WithdrawsLocked();
    }

    modifier withdrawal() {
        _isUnlocked = WITHDRAWS_UNLOCKED;
        _;
        _isUnlocked = WITHDRAWS_LOCK;
    }

    modifier withdrawsUnlocked() {
        _enforceUnlock();
        _;
    }

    function _enforceTokenAddress(address tokenAddress) private view {
        if (_tokenAddress != tokenAddress) revert JasmineErrors.InvalidTokenAddress(tokenAddress, _tokenAddress);
    }
}
