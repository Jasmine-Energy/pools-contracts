// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────  Imports  ─────────────────────────────────  \\

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

    /**
     * @dev Encodes ERC-1155 transfer data representing a retirement operation to the bridge
     * 
     * @param beneficiary Address to receive the off-chain retirement attribution
     * @param hasFractional Whether the retirement is operation includes a fractional component
     */
    function encodeRetirementData(address beneficiary, bool hasFractional)
        internal pure
        returns (bytes memory retirementData)
    {
        return abi.encode(hasFractional ? RETIREMENT_FRACTIONAL_OP : RETIREMENT_OP, beneficiary);
    }

    /**
     * @dev Encodes ERC-1155 transfer data representing a single fractional retirement operation
     */
    function encodeFractionalRetirementData()
        internal pure
        returns (bytes memory retirementData)
    {
        return abi.encode(RETIREMENT_FRACTIONAL_OP);
    }

    /**
     * @dev Encodes ERC-1155 transfer data representing a bridge-off operation to the bridge
     * 
     * @param recipient Address associated with a bridge account to receive outbound certificate
     */
    function encodeBridgeOffData(address recipient)
        internal pure
        returns (bytes memory bridgeOffData)
    {
        return abi.encode(BRIDGE_OFF_OP, recipient);
    }


    //  ────────────────────────────────  Decoding  ────────────────────────────────  \\

    /**
     * @dev Parses ERC-1155 transfer data to determine if it is a retirement operation
     * 
     * @param data Calldata to decode 
     */
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

    /**
     * @dev Parses ERC-1155 transfer data to determine if it is a bridge-off operation
     * 
     * @param data Calldata to decode 
     */
    function isBridgeOffOperation(bytes memory data)
        internal pure
        returns (bool isBridgeOff)
    {
        if (data.length == 0) revert JasmineErrors.InvalidInput();
        bytes1 opCode = data[0];
        return opCode == BRIDGE_OFF_OP;
    }
}
