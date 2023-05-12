// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { ERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { ArrayUtils } from "../libraries/ArrayUtils.sol";

error InvalidTokenAddress(address received, address expected);
error InsufficientDeposits();
error WithdrawsLocked();

abstract contract ERC1155Manager is ERC1155Receiver {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using EnumerableSet for EnumerableSet.UintSet;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    address private immutable _tokenAddress;

    uint256 private _totalDeposits;
    EnumerableSet.UintSet private _holdings;

    uint256 private immutable WITHDRAWS_LOCK = 1;
    uint256 private immutable WITHDRAWS_UNLOCKED = 2;

    uint256 private _isUnlocked;


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Setup Functions
    //  ─────────────────────────────────────────────────────────────────────────────
    constructor(address tokenAddress_) {
        _tokenAddress = tokenAddress_;

        _isUnlocked = WITHDRAWS_LOCK;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Getters
    //  ─────────────────────────────────────────────────────────────────────────────

    function totalDeposits() internal view returns (uint256) {
        return _totalDeposits;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Hooks
    //  ─────────────────────────────────────────────────────────────────────────────

    function beforeDeposit(address from, uint256[] memory tokenIds, uint256[] memory values) internal virtual;
    function afterDeposit(address from, uint256 quantity) internal virtual;

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
        public virtual
        onlyToken
        returns (bytes4)
    {
        (uint256[] memory tokenIds, uint256[] memory values) = (new uint256[](1), new uint256[](1));
        tokenIds[0] = tokenId;
        values[0] = value;
        beforeDeposit(from, tokenIds, values);
        _addDeposit(tokenId, value);
        afterDeposit(from, value);
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] memory tokenIds,
        uint256[] memory values,
        bytes memory
    )
        public virtual
        onlyToken
        returns (bytes4)
    {
        beforeDeposit(from, tokenIds, values);
        uint256 quantityDepositted = _addDeposits(tokenIds, values);
        afterDeposit(from, quantityDepositted);
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
        IERC1155(_tokenAddress).safeBatchTransferFrom(
            address(this),
            recipient,
            tokenIds,
            values,
            data
        );
        _removeDeposits(tokenIds, values);
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Withdrawal Internal Utilities
    //  ─────────────────────────────────────────────────────────────────────────────

    function _selectWithdrawTokens(uint256 amount)
        internal view
        withdrawsUnlocked
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
            if (i >= _holdings.length()) revert InsufficientDeposits();

            uint256 tokenId = _holdings.at(i);
            uint256 balance = IERC1155(_tokenAddress).balanceOf(address(this), tokenId);

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
        _holdings.add(tokenId);
        _totalDeposits += value;
    }

    function _addDeposits(
        uint256[] memory tokenIds,
        uint256[] memory values
    )
        private
        returns (uint256 quantity)
    {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            quantity += values[i];
            _holdings.add(tokenIds[i]);
        }
        _totalDeposits += quantity;
    }

    //  ────────────────────────────  Removing Deposits  ────────────────────────────  \\

    function _removeDeposit(
        uint256 tokenId,
        uint256 value
    )
        private
    {
        uint256 balance = IERC1155(_tokenAddress).balanceOf(address(this), tokenId);
        if (balance == 0) _holdings.remove(tokenId);
        _totalDeposits -= value;
    }

    function _removeDeposits(
        uint256[] memory tokenIds,
        uint256[] memory values
    )
        private
    {
        uint256[] memory balances = IERC1155(_tokenAddress).balanceOfBatch(ArrayUtils.fill(address(this), tokenIds.length), tokenIds);

        uint256 total;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            total += values[i];
            if (balances[i] == 0) _holdings.remove(tokenIds[i]);
        }
        _totalDeposits -= total;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Modifiers
    //  ─────────────────────────────────────────────────────────────────────────────


    function _enforceUnlock() private view {
        if (_isUnlocked != WITHDRAWS_UNLOCKED) revert WithdrawsLocked();
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

    modifier onlyToken() {
        if (msg.sender != _tokenAddress) revert InvalidTokenAddress(msg.sender, _tokenAddress);
        _;
    }
}
