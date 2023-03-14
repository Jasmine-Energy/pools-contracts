// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


/**
 * @title EAT Backed Pool Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Contains functionality and events for pools which issue JLTs for EATs
 *         deposits and permit withdrawals of EATs.
 * @dev Due to linearization issues, ERC-20 and ERC-1155 Receiver are not enforced
 *      conformances - but likely should be.
 */
interface IEATBackedPool {

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Events
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Emitted whenever EATs are deposited to the contract
     * 
     * @param operator Initiator of the deposit
     * @param owner Token holder depositting to contract
     * @param quantity Number of EATs deposited. Note: JLTs issued are 1-1 with EATs
     */
    event Deposit(
        address indexed operator,
        address indexed owner,
        uint256 quantity
    );

    /**
     * @dev Emitted whenever EATs are withdrawn from the contract
     * 
     * @param sender Initiator of the deposit
     * @param receiver Token holder depositting to contract
     * @param quantity Number of EATs withdrawn.
     */
    event Withdraw(
        address indexed sender,
        address indexed receiver,
        uint256 quantity
    );


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Deposit and Withdraw Functionality
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Used to deposit EATs into the pool to receive JLTs.
     * @dev Requirements:
     *     - Pool must be an approved operator of from address
     * 
     * @param from Address from which to transfer EATs to pool
     * @param tokenId EAT token ID to deposit
     * @param quantity Number of EATs for given tokenId to deposit
     * 
     * @return success If deposit operation was successful, true will be returned
     * @return jltQuantity Number of JLTs issued for deposit
     * 
     * Emits a {Deposit} event.
     */
    function deposit(
        address from, 
        uint256 tokenId, 
        uint256 quantity
    ) external returns(bool success, uint256 jltQuantity);

    /**
     * @notice Used to deposit numerous EATs of different IDs
     * into the pool to receive JLTs.
     * 
     * @dev Requirements:
     *     - Pool must be an approved operator of from address
     *     - Lenght of tokenIds and quantities must match
     * 
     * @param from Address from which to transfer EATs to pool
     * @param tokenIds EAT token IDs to deposit
     * @param quantities Number of EATs for tokenId at same index to deposit
     * 
     * @return success If deposit operation was successful, true will be returned
     * @return jltQuantity Number of JLTs issued for deposit
     * 
     * Emits a {Deposit} event.
     */
    function depositBatch(
        address from, 
        uint256[] calldata tokenIds, 
        uint256[] calldata quantities
    ) external returns(bool success, uint256 jltQuantity);


    /**
     * @notice Withdraw EATs from pool by burning 'quantity' of JLTs from 'owner'.
     * 
     * @dev Pool will automatically select EATs to withdraw. Defer to {withdrawSpecific}
     *      if selecting specific EATs to withdraw is important.
     * 
     * @dev Requirements:
     *     - msg.sender must be approved for owner's JLTs
     *     - Owner must have sufficient JLTs
     *     - If recipient is a contract, it must implement onERC1155Received & onERC1155BatchReceived
     *     - Owner and Recipient cannot be zero address
     * 
     * @param owner JLT owner from which to burn tokens
     * @param recipient Address to receive withdrawn EATs
     * @param quantity Number of JLTs to withdraw
     * @param data Optional calldata to relay to recipient via onERC1155Received
     * 
     * @return success If withdraw operation was successful, true will be returned
     * 
     * Emits a {Withdraw} event.
     */
    function withdraw(
        address owner, 
        address recipient, 
        uint256 quantity, 
        bytes calldata data
    ) external returns(bool success);

    /**
     * @notice Withdraw specific EATs from pool by burning the sum of 'quantities' in JLTs from 'owner'.
     * 
     * @dev Requirements:
     *     - msg.sender must be approved for owner's JLTs
     *     - Length of tokenIds and quantities must match
     *     - Owner must have more JLTs than sum of quantities
     *     - If recipient is a contract, it must implement onERC1155Received & onERC1155BatchReceived
     *     - Owner and Recipient cannot be zero address
     * 
     * @param owner JLT owner from which to burn tokens
     * @param recipient Address to receive withdrawn EATs
     * @param tokenIds EAT token IDs to withdraw from pool
     * @param quantities Number of EATs for tokenId at same index to deposit
     * @param data Optional calldata to relay to recipient via onERC1155Received
     * 
     * @return success If withdraw operation was successful, true will be returned
     * 
     * Emits a {Withdraw} event.
     */
    function withdrawSpecific(
        address owner, 
        address recipient, 
        uint256[] calldata tokenIds, 
        uint256[] calldata quantities, 
        bytes calldata data
    ) external returns(bool success);

}
