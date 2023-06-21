// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;


import { IERC1155ReceiverUpgradeable as IERC1155Receiver } from "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155ReceiverUpgradeable.sol";

/**
 * @title Retirement Service Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
 * @custom:security-contact dev@jasmine.energy
 */
interface IRetirementService is IERC1155Receiver {

    /**
     * @notice Allows user to designate an address to receive retirement hooks.
     * @dev Contract must implement IRetirementRecipient's onRetirement function
     * @param holder User address to notify recipient address of retirements
     * @param recipient Smart contract to receive retirement hooks. Address
     * must implement IRetirementRecipient interface.
     */
    function registerRetirementRecipient(address holder, address recipient) external;

}
