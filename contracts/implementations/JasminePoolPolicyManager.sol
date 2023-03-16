// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

import { PoolPolicy } from "../libraries/PoolPolicy.sol";
import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";


// TODO: Move
interface IJasminePoolPolicyManager {
    function basePolicy() external view returns(PoolPolicy.Policy memory);
    function totalPolicies() external view returns(uint256);
    function getPolicy(bytes32 policyKey) external view returns(PoolPolicy.Policy memory);
}

/**
 * @title Jasmine Pool Policy Manager
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Convenience abstract contract responsible for storing and 
 * retrieving pool policies
 * @custom:security-contact // TODO: set sec contact
 */
abstract contract JasminePoolPolicyManager is IJasminePoolPolicyManager {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using EnumerableMap for EnumerableMap.Bytes32ToBytes32Map;

    using PoolPolicy for PoolPolicy.DepositPolicy;
    using PoolPolicy for bytes;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    PoolPolicy.Policy private _basePolicy;

    // TODO Not chill, rewrite this. Ideally, make enumerable mapping from Bytes32 to Policy (likely through slots)
    EnumerableMap.Bytes32ToBytes32Map private _policyKeys;
    mapping(bytes32 => PoolPolicy.Policy) private _policies;


    // ──────────────────────────────────────────────────────────────────────────────
    // External Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    function basePolicy() public view returns(PoolPolicy.Policy memory) {
        return _basePolicy;
    }

    function totalPolicies() external view returns(uint256) {
        return _policyKeys.length();
    }

    function getPolicy(bytes32 policyKey) external view returns(PoolPolicy.Policy memory) {
        return _policies[_policyKeys.get(policyKey)];
    }

    // ──────────────────────────────────────────────────────────────────────────────
    // Internal Functionality
    // ──────────────────────────────────────────────────────────────────────────────

    function _addPolicy(PoolPolicy.Policy calldata _newPolicy) internal returns(bool success, bytes32 key) {
        key = keccak256(abi.encode(_newPolicy));

        if (_policyKeys.contains(key)) {
            return (false, key);
        }

        // TODO Verify _newPolicy is subPolicy of _basePolicy


        _policies[key] = _newPolicy;
        _policyKeys.set(key, key);
    }

    function _removePolicy(bytes32 policyKey) internal returns(bool success) {

        if (!_policyKeys.contains(policyKey)) {
            return (false);
        }

        delete _policies[policyKey];
        return _policyKeys.remove(policyKey);
    }
}
