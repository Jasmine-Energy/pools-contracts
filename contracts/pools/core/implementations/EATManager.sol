// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;

//  ─────────────────────────────────  Imports  ─────────────────────────────────  \\

import { JasmineErrors }        from "../../../interfaces/errors/JasmineErrors.sol";
import { IERC1155 }             from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { IERC165 }              from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IERC1155Receiver }     from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import { StructuredLinkedList } from "../../../libraries/StructuredLinkedList.sol";
import { ArrayUtils }           from "../../../libraries/ArrayUtils.sol";


/**
 * @title Jasmien EAT Manager
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Manages deposits and withdraws of Jasmine EATs (ERC-1155).
 * @custom:security-contact dev@jasmine.energy
 */
abstract contract EATManager is IERC1155Receiver {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using StructuredLinkedList for StructuredLinkedList.List;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Address of the ERC-1155 contract
    address public immutable eat;
    // address public immutable eat;

    /// @dev Total number of ERC-1155 deposits
    uint256 internal _totalDeposits;

    /// @dev Sorted link list to store token IDs by vintage
    StructuredLinkedList.List private _depositsList;

    /// @dev Maps vintage to token IDs
    mapping(uint256 => uint256) private _balances;

    uint8 private constant WITHDRAWS_LOCK = 1;
    uint8 private constant WITHDRAWS_UNLOCKED = 2;

    uint8 private _isUnlocked;

    uint256 private constant LIST_HEAD = 0;


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
    function _afterDeposit(address operator, address from, uint256 quantity) internal virtual;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  ERC-1155 Deposit Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IERC1155Receiver
    function onERC1155Received(
        address operator,
        address from,
        uint256 tokenId,
        uint256 value,
        bytes memory
    )
        external
        returns (bytes4)
    {
        _enforceTokenCaller();

        _beforeDeposit(from, _asSingletonArray(tokenId), _asSingletonArray(value));
        _addDeposit(tokenId, value);
        _afterDeposit(operator, from, value);

        return this.onERC1155Received.selector;
    }

    /// @inheritdoc IERC1155Receiver
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] memory tokenIds,
        uint256[] memory values,
        bytes memory
    )
        external
        returns (bytes4)
    {
        _enforceTokenCaller();

        _beforeDeposit(from, tokenIds, values);
        uint256 quantityDeposited = _addDeposits(tokenIds, values);
        _afterDeposit(operator, from, quantityDeposited);

        return this.onERC1155BatchReceived.selector;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) { //
        return interfaceId == type(IERC1155Receiver).interfaceId || 
            interfaceId == type(IERC165).interfaceId;
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

        uint256 current = LIST_HEAD;

        while (sum != amount && i < _depositsList.sizeOf()) {
            bool exists;
            (exists, current) = _depositsList.getNextNode(current);

            if (!exists) continue;

            uint256 balance = _balances[current];

            if (sum + balance < amount) {
                unchecked {
                    sum += balance;
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

        current = LIST_HEAD;
        tokenIds = new uint256[](i);
        for (uint x = 0; x < i;) {
            (,current) = _depositsList.getNextNode(current);
            tokenIds[x] = _decodeDeposit(current);
            x++;
        }
        amounts = IERC1155(eat).balanceOfBatch(ArrayUtils.fill(address(this), i), tokenIds);
        amounts[i-1] = finalBalance;

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
        // 1. Encode the token ID to deposit format
        uint256 encodedDeposit;
        encodedDeposit = _encodeDeposit(tokenId);

        // 2. Get next node in list and check if it exists
        (bool exists, uint256 next,) = _depositsList.getNode(encodedDeposit);

        // 3. If node does not exist, add to list
        if (!exists) {
            _depositsList.insertBefore(next, encodedDeposit);
        }

        // 4. Update balance and total deposits
        _balances[encodedDeposit] += value;
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
        quantity = _totalDeposits;
        for (uint256 i = 0; i < tokenIds.length;) {
            _addDeposit(tokenIds[i], values[i]);
            unchecked {
                i++;
            }
        }
        quantity = _totalDeposits - quantity;
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
        uint256 encodedDeposit = _encodeDeposit(tokenId);
        if (balance == 0) {
            _depositsList.remove(encodedDeposit);
        }
        _balances[encodedDeposit] -= value;
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

            uint256 encodedDeposit = _encodeDeposit(tokenIds[i]);
            if (balances[i] == 0) {
                _depositsList.remove(encodedDeposit);
            }
            _balances[encodedDeposit] = values[i];

            unchecked { i++; }
        }

        _totalDeposits -= total;
    }

    /// @dev Returns the vintage given a Jasmine EAT token ID
    function _getVintageFromTokenId(uint256 tokenId) private pure returns (uint40 vintage) {
        return uint40((tokenId >> 56) & type(uint40).max);
    }

    /**
     * @dev Encodes an EAT ID for internal storage by ordering vintage. 
     * @dev Encodes an EAT ID for internal storage by ordering vintage. 
     *      Additionally, stores balance in 56 bit of expected padding.
     * @dev Encodes an EAT ID for internal storage by ordering vintage.
     *      Additionally, stores balance in 56 bit of expected padding.
     * 
     * @param tokenId EAT token ID to format for storage
     */
    function _encodeDeposit(uint256 tokenId) private pure returns (uint256 formatted) {
        (uint256 uuid, uint256 registry, uint256 vintage, uint256 pad) = (
          tokenId >> 128,
          (tokenId >> 96) & type(uint32).max,
          (tokenId >> 56) & type(uint40).max,
          tokenId & type(uint56).max
        );

        if (pad != 0) revert JasmineErrors.ValidationFailed();

        formatted = (vintage << 216) |
                      (uuid << 88)     |
                      (registry << 56);
    }

    /**
     * @dev Decode a deposit from linked list to EAT token ID and balance
     * 
     * @param deposit Encoded deposit id to decode to EAT token ID
     * @return tokenId EAT token ID
     */
    function _decodeDeposit(uint256 deposit) private pure returns (uint256 tokenId) {
        (uint256 vintage, uint256 uuid, uint256 registry) = (
          deposit >> 216,
          (deposit >> 88) & type(uint128).max,
          (deposit >> 56) & type(uint32).max
        );

        tokenId = (uuid << 128) |
                    (registry << 96) |
                    (vintage << 56);
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
