// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

//  ─────────────────────────────────  Imports  ─────────────────────────────────  \\

import { IJasmineOracle } from "../interfaces/core/IJasmineOracle.sol";


/**
 * @title Jasmine Pool Policy Library
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Utility library for Pool Policy types
 * @custom:security-contact dev@jasmine.energy
 */
library PoolPolicy {

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Constants
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @dev Use this value in DepositPolicy to set no constraints for attribute
    uint32 internal constant ANY_VALUE = type(uint32).max;


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Types
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @title Deposit Policy
     * @notice A deposit policy is a pool's constraints on what EATs may be deposited. 
     * @dev Only supports metadata V1
     * @dev Due to EAT metadata attribytes being zero indexed, to specify no deposit  
     *      constraints for a given attribute, use `ANY_VALUE` constant.
     *      NOTE: This applies for vintage period as well.
     */
    struct DepositPolicy {
        uint56[2] vintagePeriod;
        uint32 techType;
        uint32 registry;
        uint32 certificateType;
        uint32 endorsement;
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Utility Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ────────────────────────────  Policy Utilities  ─────────────────────────────  \\

    /**
     * @dev Checks if a given EAT meets a given policy by querying the Jasmine Oracle
     * 
     * @param policy An eligibility cretieria for an EAT
     * @param oracle The Jasmine Oracle contract to query against
     * @param tokenId The EAT for which to check eligibility
     */
    function meetsPolicy(
        DepositPolicy storage policy,
        IJasmineOracle oracle,
        uint256 tokenId
    ) 
        internal view 
        returns (bool isEligible) 
    {
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
        // 4. If certificateType is not empty, check token has certificateType
        if (policy.certificateType != ANY_VALUE &&
            !oracle.hasCertificateType(tokenId, policy.certificateType)) {
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
}
