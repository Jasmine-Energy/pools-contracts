// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.18;


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

    /// @dev Calldata prefix for retirement operations
    bytes32 public constant RETIREMENT_OP = keccak256("RETIRE");

    /// @dev Calldata prefix for bridge-off operations
    bytes32 public constant BRIDGE_OFF_OP = keccak256("BRIDGE OFF");
    
    //  ─────────────────────────────────────────────────────────────────────────────
    //  Utility Functions
    //  ─────────────────────────────────────────────────────────────────────────────


    //  ────────────────────────────────  Encoding  ────────────────────────────────  \\

    function encodeRetirementCalldata(address, bytes32) external pure returns (bytes memory) {
        revert("Calldata: Unimplemented");
    }
}
