// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Core Implementations
import { ERC1155Receiver } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import { IRetirementService } from "./interfaces/IRetirementService.sol";
import { ERC1363Receiver } from "./implementations/ERC1363Receiver.sol";

// Implemented Interfaces
import { IERC1363Receiver } from "@openzeppelin/contracts/interfaces/IERC1363Receiver.sol";

// External Contracts
import { JasmineEAT } from "@jasmine-energy/contracts/src/JasmineEAT.sol";
import { JasmineMinter } from "@jasmine-energy/contracts/src/JasmineMinter.sol";
import { IRetirementRecipient } from "./interfaces/IRetirementRecipient.sol";

// Libraries
import { Calldata } from "./libraries/Calldata.sol";
import { ArrayUtils } from "./libraries/ArrayUtils.sol";
import { JasmineErrors } from "./interfaces/errors/JasmineErrors.sol";

/**
 * @title Jasmine Retirement Service
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Facilitates retirements of EATs and JLTs in the Jasmine protocol
 * @custom:security-contact dev@jasmine.energy
 */
contract JasmineRetirementService is IRetirementService, ERC1155Receiver, ERC1363Receiver {

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
    //  ERC-1155 Receiver Functions
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
                minter.burn(tokenIds[0], 1, Calldata.encodeFractionalRetirementData());
                if (amounts[0] == 1) {
                    bytes memory slicedTokens = ArrayUtils.slice(abi.encode(tokenIds), 1, tokenIds.length-1);
                    bytes memory slicedAmounts = ArrayUtils.slice(abi.encode(amounts), 1, amounts.length-1);
                    minter.burnBatch(
                        abi.decode(slicedTokens, (uint256[])),
                        abi.decode(slicedAmounts, (uint256[])),
                        Calldata.encodeRetirementData(from, false)
                    );
                } else {
                    amounts[0]--;
                    minter.burnBatch(
                        tokenIds,
                        amounts,
                        Calldata.encodeRetirementData(from, false)
                    );
                }
            } else {
                minter.burnBatch(tokenIds, amounts, data);
            }
        } else {
            minter.burnBatch(tokenIds, amounts, Calldata.encodeRetirementData(from, false));
        }

        return this.onERC1155BatchReceived.selector;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  ERC-1363 Receiver
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IERC1363Receiver
    function onTransferReceived(
        address operator,
        address from,
        uint256 value,
        bytes memory data
    ) 
        external override(ERC1363Receiver, IERC1363Receiver) 
        returns (bytes4)
    {
        // TODO: Implement me

        return this.onTransferReceived.selector;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Retirement Notification Recipient
    //  ─────────────────────────────────────────────────────────────────────────────

    function registerRetirementRecipient(
        address holder,
        address recipient
    ) external {
        // TODO: Implement me
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    modifier onlyEAT() {
        if (msg.sender != address(EAT)) revert JasmineErrors.Prohibited();
        _;
    }
}
