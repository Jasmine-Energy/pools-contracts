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
    function meetsPolicy(uint256 tokenId) external view returns (bool isEligible);
	function policyForVersion(uint8 metadataVersion) external view returns (bytes memory policy);
}
