// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;


//  ─────────────────────────────────────────────────────────────────────────────
//  Jasmine Custom Errors
//  ─────────────────────────────────────────────────────────────────────────────

/**
 * @title Jasmine Errors
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Convenience interface for errors omitted by Jasmine's smart contracts
 * @custom:security-contact dev@jasmine.energy
 */
interface JasmineErrors {

    //  ──────────────────────────  Access Control Errors  ──────────────────────────  \\

    /// @dev Emitted if access control check fails
    error RequiresRole(bytes32 role);

    //  ───────────────────────────────  Pool Errors  ───────────────────────────────  \\

    /// @dev Emitted if a token does not meet pool's deposit policy
    error Unqualified(uint256 tokenId);

    /// @dev Emitted for unauthorized actions
    error Prohibited();
    

    //  ───────────────────────────  Pool Factory Errors  ───────────────────────────  \\

    /// @dev Emitted if no pool(s) meet query
    error NoPool();

    /// @dev Emitted if a pool exists with given policy
    error PoolExists(address pool);

    /// @dev Emitted for failed supportsInterface check - per ERC-165
    error InvalidConformance(bytes4 interfaceId);
}
