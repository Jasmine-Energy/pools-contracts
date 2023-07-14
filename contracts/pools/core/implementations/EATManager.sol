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
 * @title Jasmine EAT Manager
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

    /// @dev Maps deposit ID to whether it is frozen
    mapping(uint256 => bool) private _frozenDeposits;

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
        for (uint i; i < tokenIds.length;) {
            if (_frozenDeposits[_encodeDeposit(tokenIds[i])]) revert JasmineErrors.Prohibited();
            unchecked {
                i++;
            }
        }
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

    function _transferQueuedDeposits(
        address recipient,
        uint256 amount,
        bytes memory data
    ) 
        internal
        withdrawsUnlocked
        returns (
            uint256[] memory tokenIds,
            uint256[] memory amounts
        )
    {
        (uint256 withdrawLength, uint256 finalAmount, bool popLast) = _queuedTokenLength(amount);
        if (withdrawLength == 1) {
            if (popLast) {
                tokenIds = _asSingletonArray(_decodeDeposit(_depositsList.popFront()));
            } else {
                tokenIds = _asSingletonArray(_decodeDeposit(_depositsList.front()));
            }
            amounts = _asSingletonArray(finalAmount);
            
            _removeDeposit(tokenIds[0], finalAmount);
            IERC1155(eat).safeTransferFrom(
                address(this),
                recipient,
                tokenIds[0],
                finalAmount,
                data
            );
        } else {
            tokenIds = _decodeDeposits(_depositsList.popFront(withdrawLength, !popLast));
            amounts = IERC1155(eat).balanceOfBatch(ArrayUtils.fill(address(this), withdrawLength), tokenIds);
            amounts[withdrawLength-1] = finalAmount;

            _removeDeposits(tokenIds, amounts);
            IERC1155(eat).safeBatchTransferFrom(
                address(this),
                recipient,
                tokenIds,
                amounts,
                data
            );
        }
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Withdrawal Internal Utilities
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Determines the number of token IDs required to get "amount" withdrawn
     * 
     * @param amount Number of tokens to withdraw from contract
     */
    function _queuedTokenLength(uint256 amount)
        private view 
        returns (
            uint256 length,
            uint256 finalWithdrawAmount,
            bool fullAmountOfLastToken
        ) 
    {
        uint256 sum = 0;
        uint256 current = LIST_HEAD;
        bool exists = true;

        while (sum != amount && exists) {
            (exists, current) = _depositsList.getNextNode(current);
            
            if (!exists) continue;

            uint256 balance = _balances[current];

            if (sum + balance < amount) {
                unchecked {
                    sum += balance;
                    length++;
                }
            } else {
                unchecked {
                    finalWithdrawAmount = amount - sum;
                    sum = amount;
                    length++;
                }
                break;
            }
        }

        fullAmountOfLastToken = finalWithdrawAmount == _balances[current];
    }

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
        (uint256 withdrawLength, uint256 finalAmount,) = _queuedTokenLength(amount);

        uint256 current = LIST_HEAD;
        tokenIds = new uint256[](withdrawLength);
        for (uint i = 0; i < withdrawLength;) {
            (,current) = _depositsList.getNextNode(current);
            tokenIds[i] = _decodeDeposit(current);

            unchecked {
                i++;
            }
        }
        amounts = IERC1155(eat).balanceOfBatch(ArrayUtils.fill(address(this), withdrawLength), tokenIds);
        amounts[withdrawLength-1] = finalAmount;

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
        if (balance == value) {
            _depositsList.remove(encodedDeposit);
            _balances[encodedDeposit] = 0;
        } else {
            _balances[encodedDeposit] -= value;
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

            uint256 encodedDeposit = _encodeDeposit(tokenIds[i]);
            if (balances[i] == values[i]) {
                _depositsList.remove(encodedDeposit);
                _balances[encodedDeposit] = 0;
            } else {
                _balances[encodedDeposit] -= values[i];
            }

            unchecked { i++; }
        }

        _totalDeposits -= total;
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal Upkeep Functionality
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Updates the status of a token ID to be frozen or unfrozen. If frozen,
     *      removes from deposits list. If unfrozen, adds to deposits list.
     * 
     * @param tokenId EAT ID to set status of
     * @param isWithdrawable Whether the token ID is withdrawable
     * 
     * @return wasUpdated Whether the token status was updated
     */
    function _updateTokenStatus(uint256 tokenId, bool isWithdrawable) internal returns (bool wasUpdated) {
        uint256 encodedDeposit = _encodeDeposit(tokenId);

        wasUpdated = _frozenDeposits[encodedDeposit] != isWithdrawable;

        _frozenDeposits[encodedDeposit] = !isWithdrawable;

        if (!isWithdrawable) {
            _depositsList.remove(encodedDeposit);
        } else {
            (bool exists, uint256 next,) = _depositsList.getNode(encodedDeposit);
            if (!exists) {
                _depositsList.insertBefore(next, encodedDeposit);
            }
        }
    }

    /**
     * @dev Checks the balance of a token ID held by contract. If different, updates 
     *      internal records and returns true.
     * 
     * @param tokenId EAT ID to check balance of
     * 
     * @return wasUpdated Whether the balance was updated
     */
    function _validateInternalBalance(uint256 tokenId) internal returns (bool wasUpdated) {
        uint256 encodedDeposit = _encodeDeposit(tokenId);
        uint256 balance = IERC1155(eat).balanceOf(address(this), tokenId);

        wasUpdated = _balances[encodedDeposit] != balance;
        if (wasUpdated) {
            if (balance == 0) {
                _totalDeposits -= _balances[encodedDeposit];
            } else if (_balances[encodedDeposit] == 0) {
                _frozenDeposits[encodedDeposit] = true;
            } else if (balance < _balances[encodedDeposit]) {
                _totalDeposits -= _balances[encodedDeposit] - balance;
            } else {
                _totalDeposits += balance - _balances[encodedDeposit];
            }
            _balances[encodedDeposit] = balance;
        }
    }

    /**
     * @dev Checks if a token ID is in the contract's internal records (either deposits
     *      list or frozen deposits set)
     * 
     * @param tokenId EAT ID to check if in contract's records
     * 
     * @return isRecorded Whether the token is in records
     */
    function _isTokenInRecords(uint256 tokenId) internal view returns (bool isRecorded) {
        uint256 encodedDeposit = _encodeDeposit(tokenId);
        (bool exists,,) = _depositsList.getNode(encodedDeposit);
        isRecorded = exists || _frozenDeposits[encodedDeposit];
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Encoding and Decoding Functions
    //  ─────────────────────────────────────────────────────────────────────────────

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

    /// @dev Batch version of decodeDeposit
    function _decodeDeposits(uint256[] memory deposits) private pure returns (uint256[] memory tokenIds) {
        tokenIds = new uint256[](deposits.length);
        for (uint256 i = 0; i < deposits.length;) {
            tokenIds[i] = _decodeDeposit(deposits[i]);

            unchecked {
                i++;
            }
        }
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
