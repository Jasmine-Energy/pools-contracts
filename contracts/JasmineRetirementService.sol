// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

import { ERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";

// Implemented Interfaces
import { IRetirementService } from "./interfaces/IRetirementService.sol";
import { IRetirementRecipient } from "./interfaces/IRetirementRecipient.sol";

// External Contracts
import { JasmineEAT } from "@jasmine-energy/contracts/src/JasmineEAT.sol";
import { JasmineMinter } from "@jasmine-energy/contracts/src/JasmineMinter.sol";

// Libraries
import { Calldata } from "./libraries/Calldata.sol";
import { JasmineErrors } from "./interfaces/errors/JasmineErrors.sol";


contract JasmineRetirementService is ERC1155Receiver {

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    JasmineMinter public immutable minter;
    JasmineEAT public immutable EAT;


    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    constructor(address _minter, address _eat) {
        minter = JasmineMinter(_minter);
        EAT = JasmineEAT(_eat);

        EAT.setApprovalForAll(_minter, true);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  ERC-1155 Deposit Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    function onERC1155Received(
        address,
        address from,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    )
        external override
        onlyEAT
        returns (bytes4)
    {
        // 1. If transfer has data, forward to minter to burn. Else, create retire data
        if (data.length != 0) {
            // 2. Check if there is a fractional retirement included. If so, burn seperately
            (bool isRetirement, bool hasFractional) = Calldata.isRetirementOperation(data);
            if (isRetirement && hasFractional) {
                minter.burn(tokenId, 1, Calldata.encodeFractionalRetirementData());
                if (amount == 1) return this.onERC1155Received.selector;
                data[0] = Calldata.RETIREMENT_OP;
                minter.burn(tokenId, amount-1, data);
            } else {
                minter.burn(tokenId, amount, data);
            }
        } else {
            minter.burn(tokenId, amount, Calldata.encodeRetirementData(from, false));
        }
        
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) 
        external override
        onlyEAT
        returns (bytes4)
    {
        // 1. If transfer has data, forward to minter to burn. Else, create retire data
        if (data.length != 0) {
            // 2. Check if there is a fractional retirement included. If so, burn seperately
            (bool isRetirement, bool hasFractional) = Calldata.isRetirementOperation(data);
            if (isRetirement && hasFractional) {
                // TODO: Implement

                // minter.burn(tokenId, 1, Calldata.encodeFractionalRetirementData());
                // if (amount == 1) return this.onERC1155BatchReceived.selector;
                // data[0] = Calldata.RETIREMENT_OP;
                // minter.burn(tokenId, amount-1, data);
            } else {
                minter.burnBatch(tokenIds, amounts, data);
            }
        } else {
            minter.burnBatch(tokenIds, amounts, Calldata.encodeRetirementData(from, false));
        }

        return this.onERC1155BatchReceived.selector;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    modifier onlyEAT() {
        if (msg.sender != address(EAT)) revert JasmineErrors.Prohibited();
        _;
    }
}
