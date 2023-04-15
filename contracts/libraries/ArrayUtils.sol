// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;

/**
 * @title ArrayUtils
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Utility library for interacting with arrays
 * @custom:security-contact dev@jasmine.energy
 */
library ArrayUtils {

    /**
     * @dev Sums all elements in an array
     * 
     * @param inputs Array of numbers to sum
     * @return total The sum of all elements
     */
    function sum(
        uint256[] calldata inputs
    ) external pure returns (uint256 total) {
        for (uint256 i = 0; i < inputs.length; i++) {
            total += inputs[i];
        }
    }

    /**
     * @dev Creates an array of `repeatedAddress` with `amount` occurences.
     * NOTE: Useful for ERC1155.balanceOfBatch
     * 
     * @param repeatedAddress Input address to duplicate
     * @param amount Number of times to duplicate
     * @return filledArray Array of length `amount` containing `repeatedAddress`
     */
    function fill(
        address repeatedAddress,
        uint256 amount
    ) external pure returns (address[] memory filledArray) {
        filledArray = new address[](amount);
        for (uint256 i = 0; i < amount; i++) {
            filledArray[i] = repeatedAddress;
        }
    }
}
