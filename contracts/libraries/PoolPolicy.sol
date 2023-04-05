// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

import { JasmineOracle } from "@jasmine-energy/contracts/src/JasmineOracle.sol";


/**
 * @title PoolPolicy
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Utility library for Pool Policy types
 * @custom:security-contact dev@jasmine.energy
 */
library PoolPolicy {

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Constants
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @dev Use this value in DepositPolicy to set no constraints for attribute
    uint32 constant ANY_VALUE = type(uint32).max;


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Types
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @title Deposit Policy
     * @notice A deposit policy is a pool's constraints on what EATs may be depositted. 
     * @dev Only supports metadata V1
     * @dev Due to EAT metadata attribytes being zero indexed, to specify no deposit  
     *      constraints for a given attribute, use `ANY_VALUE` constant.
     *      NOTE: This applies for vintage period as well.
     */
    struct DepositPolicy {
        uint56[2] vintagePeriod; // Question: Confirm this is correct size
        uint32 techType;
        uint32 registry;
        uint32 certification;
        uint32 endorsement;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Utility Functions
    //  ─────────────────────────────────────────────────────────────────────────────


    //  ────────────────────────────  Policy Utilities  ─────────────────────────────  \\


    function meetsPolicy(DepositPolicy storage policy, JasmineOracle oracle, uint256 tokenId) external view returns (bool isEligible) {
        // 1. If policy's vintage is not empty, check token has vintage
        if (policy.vintagePeriod[0] != ANY_VALUE &&
            policy.vintagePeriod[1] != ANY_VALUE &&
            !oracle.hasVintage(tokenId, policy.vintagePeriod[0], policy.vintagePeriod[1])) {
            return false;
        }
        // 2. If techType is not empty, check token has tech type
        if (policy.techType != ANY_VALUE &&
            !oracle.hasFuel(tokenId, policy.techType)) {
            return false;
        }
        // 3. If registry is not empty, check token has registry
        if (policy.registry != ANY_VALUE &&
            !oracle.hasRegistry(tokenId, policy.registry)) {
            return false;
        }
        // 4. If certification is not empty, check token has certification
        if (policy.certification != ANY_VALUE &&
            !oracle.hasCertificateType(tokenId, policy.certification)) {
            return false;
        }
        // 5. If endorsement is not empty, check token has endorsement
        if (policy.endorsement != ANY_VALUE &&
            !oracle.hasEndorsement(tokenId, policy.endorsement)) {
            return false;
        }
        // 6. If above checks pass, token meets policy
        return true;
    }

    //  ───────────────────────────  Vintage Utilities  ─────────────────────────────  \\

    function frontHalfOfYear(uint16 year) external pure returns (uint256[2] memory period) {
        // TODO: Implement me
    }

    function backHalfOfYear(uint16 year) external pure returns (uint256[2] memory period) {
        // TODO: Implement me
    }


    //  ───────────────────────────────  Comparision  ───────────────────────────────  \\


}
