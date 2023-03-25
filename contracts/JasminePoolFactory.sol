// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Core Implementations
import { IJasminePoolFactory } from "./interfaces/IJasminePoolFactory.sol";
// TODO Should make new abstract class with TimelockController owner
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";

// External Contracts
import { IJasminePool } from "./interfaces/IJasminePool.sol";
import { JasmineEAT } from "@jasmine-energy/contracts/src/JasmineEAT.sol";

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Proxy } from "@openzeppelin/contracts/proxy/Proxy.sol";

// Utility Libraries
import { PoolPolicy } from "./libraries/PoolPolicy.sol";
import { EnumerableMap } from "@openzeppelin/contracts/utils/structs/EnumerableMap.sol";
import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";


//  ─────────────────────────────────────────────────────────────────────────────
//  Custom Errors
//  ─────────────────────────────────────────────────────────────────────────────

error NoPools();
error PoolExists();


/**
 * @title Jasmine Pool Factory
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
 * @custom:security-contact // TODO: set sec contact
 */
contract JasminePoolFactory is IJasminePoolFactory, Ownable2Step {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    // TODO: Move to library and create type for Bytes32 to Address
    using EnumerableMap for EnumerableMap.Bytes32ToBytes32Map;

    using PoolPolicy for PoolPolicy.DepositPolicy;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    /// @dev Maps policy hash to pool address
    // Note: Can probably remove since pool addresses are deterministic through CREATE2
    EnumerableMap.Bytes32ToBytes32Map private _pools;

    /// @dev Implementation address for pools
    address public poolImplementation;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Setup
    //  ─────────────────────────────────────────────────────────────────────────────

    constructor(address _poolImplementation) Ownable2Step() {
        poolImplementation = _poolImplementation;
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  User Functionality
    //  ─────────────────────────────────────────────────────────────────────────────


    //  ───────────────  Jasmine Pool Factory Interface Conformance  ────────────────  \\


    function totalPools() external view returns(uint256) {
        return _pools.length();
    }

    function getPoolAtIndex(uint256 index) external view returns(address pool) {
        require(index < _pools.length(), "JasminePoolFactory: Pool does not exist");
        (, bytes32 value) = _pools.at(index);
        return address(uint160(uint256(value)));
    }

    function eligiblePoolsForToken(uint256 tokenId) external view returns(address[] memory pools) {
        revert("JasminePoolFactory: Unimplemented");
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Admin Functionality
    //  ─────────────────────────────────────────────────────────────────────────────

    //  ────────────────────────────  Pool Management  ──────────────────────────────  \\

    function deployNewPool(
        PoolPolicy.DepositPolicy calldata policy, 
        string calldata name, 
        string calldata symbol
    ) external onlyOwner returns(address newPool) {
        bytes32 policyHash = keccak256(policy.toBytes());

        if (_pools.contains(policyHash)) {
            revert PoolExists();
        }

        ERC1967Proxy poolProxy = new ERC1967Proxy{ salt: policyHash }(
            poolImplementation,
            abi.encodeCall(
                IJasminePool.initialize,
                (policy.toBytes(), name, symbol)
            )
        );

        emit PoolCreated(policy.toBytes(), address(poolProxy), name, symbol);

        _pools.set(policyHash, bytes32(uint256(uint160(address(poolProxy)))));

        return address(poolProxy);
    }


    /**
     * @dev Allows owner to update the address pool proxies point to.
     * 
     * @param newPoolImplementation Address new pool proxies will point to
     */
    function updateImplementationAddress(
        address newPoolImplementation
    ) external onlyOwner {
        poolImplementation = newPoolImplementation;

        // TODO: Should prob update existing proxy implementations
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

}
