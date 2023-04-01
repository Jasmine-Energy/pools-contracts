// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


import { IERC777Recipient } from "@openzeppelin/contracts/interfaces/IERC777Recipient.sol";
// ERC-1155 support (for EAT receipt)
import { IERC1155Receiver } from "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";

/**
 * @title Retirement Service Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
 * @custom:security-contact dev@jasmine.energy
 */
interface IRetirementService is IERC777Recipient, IERC1155Receiver {

    /**
     * @notice Allows user to designate an address to receive retirement hooks.
     * @dev Contract must implement IRetirementRecipient's onRetirement function
     * @param holder User address to notify recipient address of retirements
     * @param recipient Smart contract to receive retirement hooks. Address
     * must implement IRetirementRecipient interface.
     */
    function registerRetirementRecipient(address holder, address recipient) external;

    /**
     * @dev Called by pools for fractional retirements
     * @param pool address of pool requesting residual JLTs
     * @return success True if residual JLTs sent, false if ineligible
     */
    function requestResidualJLT(address pool) external returns (bool success);

}
