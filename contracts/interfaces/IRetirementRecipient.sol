// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

/**
 * @title Retirement Recipient Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
 * @custom:security-contact dev@jasmine.energy
 */
interface IRetirementRecipient {
    
    /**
     * @dev Retirement hook invoked by retirement service if set for address
     * @param retiree Address which is retiring EATs
     * @param tokenIds IDs of EATs being retired
     * @param quantities Quantity of EATs being retired
     */
    function onRetirement(address retiree, uint256[] memory tokenIds, uint256[] memory quantities) external;
    
}
