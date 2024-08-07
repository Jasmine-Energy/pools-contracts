// SPDX-License-Identifier: BUSL-1.1

pragma solidity 0.8.23;

/*

     ██╗ █████╗ ███████╗███╗   ███╗██╗███╗   ██╗███████╗        ███████╗███╗   ██╗███████╗██████╗  ██████╗██╗   ██╗
     ██║██╔══██╗██╔════╝████╗ ████║██║████╗  ██║██╔════╝        ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔════╝╚██╗ ██╔╝
     ██║███████║███████╗██╔████╔██║██║██╔██╗ ██║█████╗          █████╗  ██╔██╗ ██║█████╗  ██████╔╝██║  ███╗╚████╔╝ 
██   ██║██╔══██║╚════██║██║╚██╔╝██║██║██║╚██╗██║██╔══╝          ██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██║   ██║ ╚██╔╝  
╚█████╔╝██║  ██║███████║██║ ╚═╝ ██║██║██║ ╚████║███████╗        ███████╗██║ ╚████║███████╗██║  ██║╚██████╔╝  ██║   
 ╚════╝ ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝        ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝   ╚═╝ ®

*/

//  ─────────────────────────────────  Imports  ─────────────────────────────────  \\

// Core Implementations
import {IRetirementService} from "./interfaces/IRetirementService.sol";
import {JasmineErrors} from "./interfaces/errors/JasmineErrors.sol";
import {ERC1155ReceiverUpgradeable as ERC1155Receiver} from "@openzeppelin/contracts-upgradeable/token/ERC1155/utils/ERC1155ReceiverUpgradeable.sol";
import {IERC1155ReceiverUpgradeable as IERC1155Receiver} from "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";
import {Ownable2StepUpgradeable as Ownable2Step} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

// External Contracts
import {IJasmineEAT} from "./interfaces/core/IJasmineEAT.sol";
import {IJasmineMinter} from "./interfaces/core/IJasmineMinter.sol";
import {IERC1820Registry} from "@openzeppelin/contracts/interfaces/IERC1820Registry.sol";
import {IRetirementRecipient} from "./interfaces/IRetirementRecipient.sol";

// Libraries
import {Calldata} from "./libraries/Calldata.sol";
import {ArrayUtils} from "./libraries/ArrayUtils.sol";

/**
 * @title Jasmine Retirement Service
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Facilitates retirements of EATs and JLTs in the Jasmine protocol
 * @custom:security-contact dev@jasmine.energy
 */
contract JasmineRetirementService is
    IRetirementService,
    JasmineErrors,
    ERC1155Receiver,
    Ownable2Step,
    UUPSUpgradeable
{
    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    IJasmineMinter public immutable minter;
    IJasmineEAT public immutable eat;

    IERC1820Registry public constant ERC1820_REGISTRY =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     *
     * @param _minter Jasmine Minter contract address
     * @param _eat Jasmine EAT contract address
     *
     * @custom:oz-upgrades-unsafe-allow constructor state-variable-immutable
     */
    constructor(address _minter, address _eat) initializer {
        minter = IJasmineMinter(_minter);
        eat = IJasmineEAT(_eat);
    }

    function initialize(address _owner) external initializer onlyProxy {
        _transferOwnership(_owner);

        __ERC1155Receiver_init();
        __Ownable2Step_init();
        __UUPSUpgradeable_init();

        eat.setApprovalForAll(address(minter), true);
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  ERC-1155 Receiver Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @dev inheritdoc ERC1155Receiver
    function onERC1155Received(
        address,
        address from,
        uint256 tokenId,
        uint256 amount,
        bytes memory data
    ) external override onlyEAT returns (bytes4) {
        // 1. If transfer has data, forward to minter to burn. Else, create retire data
        if (data.length != 0) {
            // 2. Execute retirement if data encodes retirement op, else burn with given data
            (bool isRetirement, bool hasFractional) = Calldata
                .isRetirementOperation(data);
            if (isRetirement) {
                _executeRetirement(from, tokenId, amount, hasFractional, data);
            } else {
                minter.burn(tokenId, amount, data);
            }
        } else {
            // 3. If no data, defaut to retire operation
            _executeRetirement(
                from,
                tokenId,
                amount,
                false,
                Calldata.encodeRetirementData(from, false)
            );
        }

        return this.onERC1155Received.selector;
    }

    /// @dev inheritdoc ERC1155Receiver
    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) external override onlyEAT returns (bytes4) {
        // 1. If transfer has data, forward to minter to burn. Else, create retire data
        if (data.length != 0) {
            // 2. Execute retirement if data encodes retirement op, else burn with given data
            (bool isRetirement, bool hasFractional) = Calldata
                .isRetirementOperation(data);
            if (isRetirement) {
                _executeRetirement(
                    from,
                    tokenIds,
                    amounts,
                    hasFractional,
                    data
                );
            } else {
                minter.burnBatch(tokenIds, amounts, data);
            }
        } else {
            // 3. If no data, defaut to retire operation
            _executeRetirement(
                from,
                tokenIds,
                amounts,
                false,
                Calldata.encodeRetirementData(from, false)
            );
        }

        return this.onERC1155BatchReceived.selector;
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
    //  Upgrades
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @dev `Ownable` owner is authorized to upgrade contract, not the ERC1967 admin
    function _authorizeUpgrade(address) internal override onlyOwner {} // solhint-disable-line no-empty-blocks

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
    ) private {
        if (amount == 0) revert JasmineErrors.InvalidInput();

        // 1. Decode beneficiary from data if able, set otherwise
        if (data.length >= 2) {
            (, beneficiary) = abi.decode(data, (bytes1, address));
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
    ) private {
        if (tokenIds.length != amounts.length || tokenIds.length == 0)
            revert JasmineErrors.InvalidInput();

        // 1. Decode beneficiary from data if able, set otherwise
        if (data.length >= 2) {
            (, beneficiary) = abi.decode(data, (bytes1, address));
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
                tokenIds = abi.decode(
                    ArrayUtils.slice(
                        abi.encode(tokenIds),
                        1,
                        tokenIds.length - 1
                    ),
                    (uint256[])
                );
                amounts = abi.decode(
                    ArrayUtils.slice(
                        abi.encode(amounts),
                        1,
                        amounts.length - 1
                    ),
                    (uint256[])
                );

                if (tokenIds.length == 0) return;
            } else {
                unchecked {
                    amounts[0]--;
                }
            }
        }

        // 3. Burn and notify recipient
        minter.burnBatch(tokenIds, amounts, data);
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
        address implementer = ERC1820_REGISTRY.getInterfaceImplementer(
            retiree,
            type(IRetirementRecipient).interfaceId
        );
        if (implementer != address(0x0)) {
            /* solhint-disable no-empty-blocks */
            try
                IRetirementRecipient(implementer).onRetirement(
                    retiree,
                    tokenIds,
                    amounts
                )
            {} catch {}
            /* solhint-enable no-empty-blocks */
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
        address implementer = ERC1820_REGISTRY.getInterfaceImplementer(
            retiree,
            type(IRetirementRecipient).interfaceId
        );
        if (implementer != address(0x0)) {
            (uint256[] memory tokenIds, uint256[] memory amounts) = (
                new uint256[](1),
                new uint256[](1)
            );
            tokenIds[0] = tokenId;
            amounts[0] = amount;
            /* solhint-disable no-empty-blocks */
            try
                IRetirementRecipient(implementer).onRetirement(
                    retiree,
                    tokenIds,
                    amounts
                )
            {} catch {}
            /* solhint-enable no-empty-blocks */
        }
    }

    //  ────────────────────────────────  Modifiers  ────────────────────────────────  \\

    /// @dev Enforces caller is EAT contract
    modifier onlyEAT() {
        if (msg.sender != address(eat)) revert JasmineErrors.Prohibited();
        _;
    }
}
