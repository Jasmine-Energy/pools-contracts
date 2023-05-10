// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


/**
 * @title Calldata
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Utility library encoding and decoding calldata between contracts
 * @custom:security-contact dev@jasmine.energy
 */
library Calldata {

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Constants
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ─────────────────────────────  Operation Codes  ─────────────────────────────  \\

    /// @dev Calldata prefix for retirement operations associated with a single user
    uint8 public constant RETIREMENT_OP = 0;

    /// @dev Calldata prefix for fractional retirement operations
    uint8 public constant RETIREMENT_FRACTIONAL_OP = 1;

    /// @dev Calldata prefix for bridge-off operations
    uint8 public constant BRIDGE_OFF_OP = 10;
    
    
    //  ─────────────────────────────────────────────────────────────────────────────
    //  Utility Functions
    //  ─────────────────────────────────────────────────────────────────────────────


    //  ────────────────────────────────  Encoding  ────────────────────────────────  \\

    function encodeRetirementCalldata(
        address beneficiary,
        uint256 quantity
    )
        external pure
        returns (bytes memory retirementData)
    {
        return abi.encodePacked("hello");
    }

    function encodeFractionalRetirementCalldata()
        external pure
        returns (bytes memory retirementData)
    {
        return abi.encodePacked("hello");
    }
}
