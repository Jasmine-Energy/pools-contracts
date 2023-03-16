// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";

/**
 * @title PoolPolicy
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Utility library for Pool Policy types
 */
library PoolPolicy {

    using EnumerableMap for EnumerableMap.Bytes32ToBytes32Map;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Types
    //  ─────────────────────────────────────────────────────────────────────────────

    struct Policy {
        // TODO Use enumerable map (right?)
        Condition[] conditions;
    }

    struct Condition {
        address verifier;
        bytes4 selector;
        EvalOperation eval;
        bytes verificationCalldata;
    }

    /**
     * @dev Eval operation is used to validate the 
     */
    enum EvalOperation {
        oneOf,  // At least one of the verification calls must pass
        noneOf, // All of the verification calls must fail
        allOf   // All of the verification calls must pass
    }




    /**
     * @title Deposit Policy
     * @notice A deposit policy is a pool's constraints on what EATs may be depositted. 
     * @dev Only supports metadata V1
     */
    struct DepositPolicy {
        uint256[2] vintagePeriod;
        uint256[]  techTypes;
        uint256[]  registries;
        uint256[]  certificationTypes;
        uint256[]  endorsements;
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Type Casting Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Converts a policy to bytes
     * 
     * @param policy Input policy to convert to bytes
     */
    function toBytes(
        PoolPolicy.DepositPolicy calldata policy
    ) external pure returns(bytes memory) {
        return abi.encode(
            policy.vintagePeriod,
            policy.techTypes,
            policy.registries,
            policy.certificationTypes,
            policy.endorsements
        );
    }

    /**
     * @dev Converts bytes to Deposit Policy
     * 
     * @param _encodedPolicy Byte encode policy to decode
     */
    function toDepositPolicy(
        bytes calldata _encodedPolicy
    ) external pure returns(DepositPolicy memory) {
        uint256[2] memory vintagePeriod;
        uint256[]  memory techTypes;
        uint256[]  memory registries;
        uint256[]  memory certificationTypes;
        uint256[]  memory endorsements;
        (vintagePeriod, techTypes, registries, certificationTypes, endorsements) = abi.decode(_encodedPolicy, (uint256[2], uint256[], uint256[], uint256[], uint256[]));

        return DepositPolicy(
            vintagePeriod, techTypes, registries, certificationTypes, endorsements
        );
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Utility Functions
    //  ─────────────────────────────────────────────────────────────────────────────


    //  ───────────────────────────  Vintage Utilities  ─────────────────────────────  \\

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
