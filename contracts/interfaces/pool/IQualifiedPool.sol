// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


/**
 * @title IQualifiedPool
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Interface for any pool that has a deposit policy
 * which constrains deposits.
 */
interface IQualifiedPool {
    function meetsPolicy(uint256 tokenId) external view returns(bool isEligible);
	function policyForVersion(uint8 metadataVersion) external view returns(bytes memory policy);
}
