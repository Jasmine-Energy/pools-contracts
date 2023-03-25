// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;

/**
 * @title ArrayUtils
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Utility library for interacting with arrays
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
    ) external pure returns(uint256 total) {
        for (uint256 i = 0; i < inputs.length; i++) {
            total += inputs[i];
        }
    }
}
