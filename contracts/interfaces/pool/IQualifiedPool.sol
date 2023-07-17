// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


/**
 * @title Jasmine Qualified Pool Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Interface for any pool that has a deposit policy
 * which constrains deposits.
 * @custom:security-contact dev@jasmine.energy
 */
interface IJasmineQualifiedPool {

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Errors
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @dev Emitted if a token does not meet pool's deposit policy
    error Unqualified(uint256 tokenId);

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Qualification Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @notice Checks if a given Jasmine EAT token meets the pool's deposit policy
     * 
     * @param tokenId Token to check pool eligibility for
     * 
     * @return isEligible True if token meets policy and may be deposited. False otherwise.
     */
    function meetsPolicy(uint256 tokenId) external view returns (bool isEligible);

    /**
     * @notice Get a pool's deposit policy for a given metadata version
     * 
     * @param metadataVersion Version of metadata to return policy for
     * 
     * @return policy Deposit policy for given metadata version
     */
	function policyForVersion(uint8 metadataVersion) external view returns (bytes memory policy);
}
