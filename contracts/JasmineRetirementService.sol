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
import { IERC1820Registry } from "@openzeppelin/contracts/interfaces/IERC1820Registry.sol";
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

    IERC1820Registry public constant ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

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
            // 2. Execute retirement if data encodes retirement op, else burn with given data
            (bool isRetirement, bool hasFractional) = Calldata.isRetirementOperation(data);
            if (isRetirement) {
                _executeRetirement(from, tokenId, amount, hasFractional, data);
            } else {
                minter.burn(tokenId, amount, data);
            }
        } else {
            // 3. If no data, defaut to retire operation
            _executeRetirement(from, tokenId, amount, false, Calldata.encodeRetirementData(from, false));
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
            // 2. Execute retirement if data encodes retirement op, else burn with given data
            (bool isRetirement, bool hasFractional) = Calldata.isRetirementOperation(data);
            if (isRetirement) {
                _executeRetirement(from, tokenIds, amounts, hasFractional, data);
            } else {
                minter.burnBatch(tokenIds, amounts, data);
            }
        } else {
            // 3. If no data, defaut to retire operation
            _executeRetirement(from, tokenIds, amounts, false, Calldata.encodeRetirementData(from, false));
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

    /**
     * @notice Registers a smart contract to receive notifications on retirement events
     * 
     * @dev Requirements:
     *      - Retirement service must be an approved ERC-1820 manager of account
     *      - Implementer must support IRetirementRecipient interface via ERC-165
     * 
     * @param account Address to register retirement recipient for
     * @param implementer Smart contract address to register as retirement implementer
     */
    function registerRetirementRecipient(
        address account,
        address implementer
    ) external {
        ERC1820_REGISTRY.setInterfaceImplementer(
            account == address(0x0) ? msg.sender : account,
            type(IRetirementRecipient).interfaceId,
            implementer
        );
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Utility function to execute a retirement of EATs
     * 
     * @param beneficiary Address receiving retirement credit
     * @param tokenId EAT token ID being retired
     * @param amount Number of EATs being retired
     * @param hasFractional Whether to retire a fractional EAT
     * @param data Optional data to be emitted by retirement
     */
    function _executeRetirement(
        address beneficiary,
        uint256 tokenId,
        uint256 amount,
        bool hasFractional,
        bytes memory data
    )
        private
    {
        if (amount == 0) revert JasmineErrors.InvalidInput();

        // 1. Decode beneficiary from data if able, set otherwise
        if (data.length >= 2) {
            (,beneficiary) = abi.decode(data, (bytes1,address));
        } else if (data.length == 1) {
            data = abi.encodePacked(data, beneficiary);
        } else if (data.length == 0) {
            data = Calldata.encodeRetirementData(beneficiary, hasFractional);
        }

        // 2. If fractional, execute burn and decrement amount
        if (hasFractional) {
            _executeFractionalRetirement(tokenId);

            if (amount == 1) return;

            unchecked {
                amount--;
            }
            data[0] = Calldata.RETIREMENT_OP;
        }
        
        minter.burn(tokenId, amount, data);
        _notifyRetirementRecipient(beneficiary, tokenId, amount);
    }

    /**
     * @dev Utility function to execute a batch retirement of EATs
     * 
     * @param beneficiary Address receiving retirement credit
     * @param tokenIds EAT token IDs being retired
     * @param amounts Number of EATs being retired
     * @param hasFractional Whether to retire a fractional EAT
     * @param data Optional data to be emitted by retirement
     */
    function _executeRetirement(
        address beneficiary,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bool hasFractional,
        bytes memory data
    )
        private
    {
        if (tokenIds.length != amounts.length || tokenIds.length == 0) revert JasmineErrors.InvalidInput();

        // 1. Decode beneficiary from data if able, set otherwise
        if (data.length >= 2) {
            (,beneficiary) = abi.decode(data, (bytes1,address));
        } else if (data.length == 1) {
            data = abi.encodePacked(data, beneficiary);
        } else if (data.length == 0) {
            data = Calldata.encodeRetirementData(beneficiary, hasFractional);
        }

        // 2. If fractional, burn single and update tokens and data
        if (hasFractional) {
            _executeFractionalRetirement(tokenIds[0]);

            data[0] = Calldata.RETIREMENT_OP;

            // 2.1 If only one of first token, pop from tokenIds. Else decrement amount
            if (amounts[0] == 1) {
                tokenIds  = abi.decode(ArrayUtils.slice(abi.encode(tokenIds), 1, tokenIds.length-1), (uint256[]));
                amounts = abi.decode(ArrayUtils.slice(abi.encode(amounts), 1, amounts.length-1), (uint256[]));

                if (tokenIds.length == 0) return;
            } else {
                unchecked {
                    amounts[0]--;
                }
            }
        }

        // 3. Burn and notify recipient
        minter.burnBatch(
            tokenIds,
            amounts,
            data
        );
        _notifyRetirementRecipient(beneficiary, tokenIds, amounts);
    }

    /**
     * @dev Retires a single EAT for fractional purposes
     * 
     * @param tokenId EAT token ID to retire fraction of
     */
    function _executeFractionalRetirement(uint256 tokenId) private {
        minter.burn(tokenId, 1, Calldata.encodeFractionalRetirementData());
    }

    //  ────────────────────────────  Retirement Hooks  ─────────────────────────────  \\

    /**
     * @dev Checks if retiree has a Retirement Recipient set and notifies implementer
     *      of retirement event if possible. Will not revert if implementer's 
     *      onRetirement call fails.
     * 
     * @param retiree Account executing retirement
     * @param tokenIds EAT token IDs being retired
     * @param amounts Amount of EATs being retired
     */
    function _notifyRetirementRecipient(
        address retiree,
        uint256[] memory tokenIds,
        uint256[] memory amounts
    ) private {
        address implementer = ERC1820_REGISTRY.getInterfaceImplementer(retiree, type(IRetirementRecipient).interfaceId);
        if (implementer != address(0x0)) {
            try IRetirementRecipient(implementer).onRetirement(retiree, tokenIds, amounts) { }
            catch { }
        }
    }

    /**
     * @dev Checks if retiree has a Retirement Recipient set and notifies implementer
     *      of retirement event if possible. Will not revert if implementer's 
     *      onRetirement call fails.
     * 
     * @param retiree Account executing retirement
     * @param tokenId EAT token ID being retired
     * @param amount Amount of EATs being retired
     */
    function _notifyRetirementRecipient(
        address retiree,
        uint256 tokenId,
        uint256 amount
    ) private {
        address implementer = ERC1820_REGISTRY.getInterfaceImplementer(retiree, type(IRetirementRecipient).interfaceId);
        if (implementer != address(0x0)) {
            (uint256[] memory tokenIds, uint256[] memory amounts) = (new uint256[](1), new uint256[](1));
            tokenIds[0] = tokenId;
            amounts[0] = amount;
            try IRetirementRecipient(implementer).onRetirement(retiree, tokenIds, amounts) { }
            catch { }
        }
    }

    //  ────────────────────────────────  Modifiers  ────────────────────────────────  \\

    /// @dev Enforces caller is EAT contract
    modifier onlyEAT() {
        if (msg.sender != address(EAT)) revert JasmineErrors.Prohibited();
        _;
    }
}
