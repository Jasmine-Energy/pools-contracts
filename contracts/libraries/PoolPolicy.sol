// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { JasmineOracle } from "@jasmine-energy/contracts/src/JasmineOracle.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

/**
 * @title PoolPolicy
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Utility library for Pool Policy types
 */
library PoolPolicy {

    using Address for address;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableMap for EnumerableMap.Bytes32ToBytes32Map;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Types
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @title Deposit Policy
     * @notice A deposit policy is a pool's constraints on what EATs may be depositted. 
     * @dev Only supports metadata V1
     */
    struct DepositPolicy {
        uint256[2] vintagePeriod;
        uint32 techType;
        uint32 registry;
        uint32 certification;
        uint32 endorsement;
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Utility Functions
    //  ─────────────────────────────────────────────────────────────────────────────


    //  ────────────────────────────  Policy Utilities  ─────────────────────────────  \\


    function meetsPolicy(DepositPolicy storage policy, JasmineOracle oracle, uint256 tokenId) external view returns(bool isEligible) {
        // 1. If policy's vintage is not empty, check token has vintage
        if (policy.vintagePeriod[0] != 0 &&
            policy.vintagePeriod[1] != 0 &&
            !oracle.hasVintage(tokenId, policy.vintagePeriod[0], policy.vintagePeriod[1])) {
            return false;
        }
        // 2. If techType is not empty, check token has tech type
        if (policy.techType != 0 &&
            !oracle.hasFuel(tokenId, policy.techType)) {
            return false;
        }
        // 3. If registry is not empty, check token has registry
        if (policy.registry != 0 &&
            !oracle.hasRegistry(tokenId, policy.registry)) {
            return false;
        }
        // 4. If certification is not empty, check token has certification
        if (policy.certification != 0 &&
            !oracle.hasCertificateType(tokenId, policy.certification)) {
            return false;
        }
        // 5. If endorsement is not empty, check token has endorsement
        if (policy.endorsement != 0 &&
            !oracle.hasEndorsement(tokenId, policy.endorsement)) {
            return false;
        }
        // 6. If above checks pass, token meets policy
        return true;
    }

    //  ───────────────────────────  Vintage Utilities  ─────────────────────────────  \\

    function frontHalfOfYear(uint16 year) external pure returns(uint256[2] memory period) {


    }

    function backHalfOfYear(uint16 year) external pure returns(uint256[2] memory period) {

        
    }


    //  ───────────────────────────────  Comparision  ───────────────────────────────  \\


}
