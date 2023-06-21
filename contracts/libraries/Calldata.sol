// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

import { JasmineErrors } from "../interfaces/errors/JasmineErrors.sol";

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
    bytes1 internal constant RETIREMENT_OP = 0x00;

    /// @dev Calldata prefix for fractional retirement operations
    bytes1 internal constant RETIREMENT_FRACTIONAL_OP = 0x01;

    /// @dev Calldata prefix for bridge-off operations
    bytes1 internal constant BRIDGE_OFF_OP = 0x10;
    

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Utility Functions
    //  ─────────────────────────────────────────────────────────────────────────────


    //  ────────────────────────────────  Encoding  ────────────────────────────────  \\

    // QUESTION: Do we want to optionally include memo hash?
    function encodeRetirementData(address beneficiary, bool hasFractional)
        internal pure
        returns (bytes memory retirementData)
    {
        return abi.encode(hasFractional ? RETIREMENT_FRACTIONAL_OP : RETIREMENT_OP, beneficiary);
    }

    function encodeFractionalRetirementData()
        internal pure
        returns (bytes memory retirementData)
    {
        return abi.encode(RETIREMENT_FRACTIONAL_OP);
    }

    function encodeBridgeOffData(address recipient)
        internal pure
        returns (bytes memory bridgeOffData)
    {
        return abi.encode(BRIDGE_OFF_OP, recipient);
    }


    //  ────────────────────────────────  Decoding  ────────────────────────────────  \\

    function isRetirementOperation(bytes memory data)
        internal pure
        returns (bool isRetirement, bool hasFractional)
    {
        if (data.length == 0) revert JasmineErrors.InvalidInput();
        bytes1 opCode = data[0];
        return (
            opCode == RETIREMENT_OP || opCode == RETIREMENT_FRACTIONAL_OP,
            opCode == RETIREMENT_FRACTIONAL_OP
        );
    }

    function isBridgeOffOperation(bytes memory data)
        internal pure
        returns (bool isBridgeOff)
    {
        if (data.length == 0) revert JasmineErrors.InvalidInput();
        bytes1 opCode = data[0];
        return opCode == BRIDGE_OFF_OP;
    }
}
