// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.18;


/**
 * @title PoolPolicy
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Utility library for Pool Policy types
 */
library PoolPolicy {
    /**
     * @title DepositPolicy
     * @dev A deposit policy is a pool's constraints on what EATs may
     * be depositted. 
     * @notice Only supports metadata V1
     */
    struct DepositPolicy {
        uint256[2] vintagePeriod;
        uint256[]  techTypes;
        uint256[]  registries;
        uint256[]  certificationTypes;
        uint256[]  endorsements;
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Utility Functions
    //  ─────────────────────────────────────────────────────────────────────────────


    //  ───────────────────────────  Vintage Utilities  ────────────────────────────  \\

    function frontHalfOfYear(uint16 year) external pure returns(uint256[2] memory period) {


    }

    function backHalfOfYear(uint16 year) external pure returns(uint256[2] memory period) {

        
    }


    //  ───────────────────────────────  Comparision  ───────────────────────────────  \\

    /**
     * @dev Checks if comparativePolicy is a subset of basePolicy. To be true,
     * all inputs to comparativePolicy must hold tru for basePolicy.
     * 
     * @param basePolicy Policy to base comparision against
     * @param comparativePolicy Policy to be evaluated as subset of basePolicy
     */
    function isSubset(
        DepositPolicy calldata basePolicy, 
        DepositPolicy calldata comparativePolicy
    ) external returns(bool) {

    }
}
