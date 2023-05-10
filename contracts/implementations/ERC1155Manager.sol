// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

import { ERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";


contract ERC1155Manager is ERC1155Receiver {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using EnumerableSet for EnumerableSet.UintSet;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    uint256 private _totalDeposits;
    EnumerableSet.UintSet private _holdings;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Getters
    //  ─────────────────────────────────────────────────────────────────────────────

    function totalDeposits() internal view returns (uint256) {
        return _totalDeposits;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  ERC-1155 Deposit Methods
    //  ─────────────────────────────────────────────────────────────────────────────

    function onERC1155Received(
        address,
        address,
        uint256 tokenId,
        uint256 value,
        bytes memory
    ) public virtual returns (bytes4) {
        _holdings.add(tokenId);
        _totalDeposits += value;
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory tokenIds,
        uint256[] memory values,
        bytes memory
    ) public virtual returns (bytes4) {
        uint256 total;
        for (uint256 i = 0; i < tokenIds.length; i++) {
            total += values[i];
            _holdings.add(tokenIds[i]);
        }
        _totalDeposits += total;
        return this.onERC1155BatchReceived.selector;
    }
}
