// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

import { JasminePoolPolicyManager, IJasminePoolPolicyManager } from "./JasminePoolPolicyManager.sol";

import { PoolPolicy } from "../libraries/PoolPolicy.sol";
import { IJasmineEATExtensions } from "@jasmine-energy/contracts/src/interfaces/IJasmineEATExtensions.sol";

interface IJasmineEAT is IJasmineEATExtensions {
    function exists(uint256 id) external view returns (bool);
}

interface IJasmineOracle {
    function getUUID(uint256 id) external pure returns (uint128);
    function hasRegistry(uint256 id, uint256 query) external pure returns (bool);
    function hasVintage(uint256 id, uint256 min, uint256 max) external pure returns (bool);
    function hasFuel(uint256 id, uint256 query) external view returns (bool);
    function hasCertificateType(uint256 id, uint256 query) external view returns (bool);
    function hasEndorsement(uint256 id, uint256 query) external view returns (bool);
}





interface IJasmineCorePolicy is IJasminePoolPolicyManager {
    // NOTE: On the fench about removing/moving OG DepositPolicy struct here
    function convertDepositPolicy(PoolPolicy.DepositPolicy calldata newPolicy) external view returns(PoolPolicy.Policy memory policy);
    
    function makeVintageCondition        (uint256[2] calldata vintagePeriod) external view returns(PoolPolicy.Condition memory vintagePeriodCondition);
    function makeTechTypesCondition      (uint256[ ] calldata techTypes) external view returns(PoolPolicy.Condition memory techTypeCondition);
    function makeRegistriesCondition     (uint256[ ] calldata registries) external view returns(PoolPolicy.Condition memory registriesCondition);
    function makeCertificationsCondition (uint256[ ] calldata certificationTypes) external view returns(PoolPolicy.Condition memory certificationsCondition);
    function makeEndorsementCondition    (uint256[ ] calldata endorsements) external view returns(PoolPolicy.Condition memory endorsementsCondition);
}


abstract contract JasmineCorePolicy is JasminePoolPolicyManager, IJasmineCorePolicy {


    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    IJasmineEAT public immutable eat;
    IJasmineOracle public immutable oracle;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Setup
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev
     * 
     * @param _eat Jasmine Energy Attribution Token Contract address
     * @param _oracle Jasmine Oracle Contract address
     */
    constructor(address _eat, address _oracle) {
        require(_eat != address(0), "JasmineCorePolicy: EAT must be set");
        require(_oracle != address(0), "JasmineCorePolicy: Oracle must be set");

        eat = IJasmineEAT(_eat);
        oracle = IJasmineOracle(_oracle);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal Functionality
    //  ─────────────────────────────────────────────────────────────────────────────

    function convertDepositPolicy(PoolPolicy.DepositPolicy calldata newPolicy) external view returns(PoolPolicy.Policy memory policy) {
        // TODO: Checks not empty

        // 1. Create array of conditions
        PoolPolicy.Condition[] memory conditions;

        // 2. If vintage not empty, create vintage condition
        if (newPolicy.vintagePeriod[0] != 0 && 
            newPolicy.vintagePeriod[1] != 0) {
            PoolPolicy.Condition memory vintageCondition = makeVintageCondition(newPolicy.vintagePeriod);
            // conditions.push(
            //     vintageCondition
            // );
        }

        // 3. If 
        if (newPolicy.techTypes.length != 0) {
            PoolPolicy.Condition memory techTypeCondition = makeTechTypesCondition(newPolicy.techTypes);
        }

        // 3. If 
        if (newPolicy.registries.length != 0) {
            PoolPolicy.Condition memory registriesCondition = makeRegistriesCondition(newPolicy.registries);
        }

        // 3. If 
        if (newPolicy.certificationTypes.length != 0) {
            PoolPolicy.Condition memory certificationsCondition = makeCertificationsCondition(newPolicy.certificationTypes);
        }

        // 3. If endorsements
        if (newPolicy.endorsements.length != 0) {
            PoolPolicy.Condition memory endorsementsCondition = makeEndorsementCondition(newPolicy.endorsements);
        }

        // TODO: Apply new Conditions on top of _basePolicy
    }

    function makeVintageCondition(
        uint256[2] calldata vintagePeriod
    ) public view returns(PoolPolicy.Condition memory vintagePeriodCondition) {
        return PoolPolicy.Condition(
            address(oracle),
            IJasmineOracle.hasVintage.selector,
            PoolPolicy.EvalOperation.allOf,
            abi.encode(vintagePeriod)
        );
    }

    function makeTechTypesCondition(uint256[] calldata techTypes) public view returns(PoolPolicy.Condition memory techTypeCondition) {
        return PoolPolicy.Condition(
            address(oracle),
            IJasmineOracle.hasFuel.selector,
            PoolPolicy.EvalOperation.oneOf,
            abi.encode(techTypes)
        );
    }

    function makeRegistriesCondition(uint256[] calldata registries) public view returns(PoolPolicy.Condition memory registriesCondition) {
        return PoolPolicy.Condition(
            address(oracle),
            IJasmineOracle.hasRegistry.selector,
            PoolPolicy.EvalOperation.oneOf,
            abi.encode(registries)
        );
    }

    function makeCertificationsCondition(uint256[] calldata certificationTypes) public view returns(PoolPolicy.Condition memory certificationsCondition) {
        return PoolPolicy.Condition(
            address(oracle),
            IJasmineOracle.hasCertificateType.selector,
            PoolPolicy.EvalOperation.oneOf, // Question: Right assumption? Prob need two versions
            abi.encode(certificationTypes)
        );
    }

    function makeEndorsementCondition(uint256[] calldata endorsements) public view returns(PoolPolicy.Condition memory endorsementsCondition) {
        return PoolPolicy.Condition(
            address(oracle),
            IJasmineOracle.hasCertificateType.selector,
            PoolPolicy.EvalOperation.oneOf, // Question: Right assumption? Prob need two versions
            abi.encode(endorsements)
        );
    }
}
