// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


/**
 * @title Jasmine Errors
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Convenience interface for errors omitted by Jasmine's smart contracts
 * @custom:security-contact dev@jasmine.energy
 */
interface JasmineErrors {

    //  ─────────────────────────────  General Errors  ──────────────────────────────  \\

    /// @dev Emitted if input is invalid
    error InvalidInput();

    /// @dev Emitted if internal validation failed
    error ValidationFailed();

    /// @dev Emitted if function is disabled
    error Disabled();

    /// @dev Emitted if contract does not support metadata version
    error UnsupportedMetadataVersion(uint8 metadataVersion);

    //  ──────────────────────────  Access Control Errors  ──────────────────────────  \\

    /// @dev Emitted if access control check fails
    error RequiresRole(bytes32 role);

    /// @dev Emitted for unauthorized actions
    error Prohibited();
}
