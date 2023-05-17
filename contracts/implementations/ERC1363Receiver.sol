// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Implemented Interfaces
import { IERC1363Receiver } from "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

// TODO: Add ERC-165 support

/**
 * @title ERC-1363 Receiver
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Implementation of ERC-1363 Receiver
 * @custom:security-contact dev@jasmine.energy
 */
abstract contract ERC1363Receiver is IERC1363Receiver {

    //  ─────────────────────────────────────────────────────────────────────────────
    //  ERC-1363 Receiver Implementation
    //  ─────────────────────────────────────────────────────────────────────────────
    
    /// @inheritdoc IERC1363Receiver
    function onTransferReceived(
        address,
        address,
        uint256,
        bytes memory
    ) external virtual returns (bytes4) {
        return this.onTransferReceived.selector;
    }
}
