// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//  ─────────────────────────────────  Imports  ─────────────────────────────────  \\

// Jasmine Type Conformances
import { IJasmineEATBackedPool  as IEATBackedPool  } from "./pool/IEATBackedPool.sol";
import { IJasmineQualifiedPool  as IQualifiedPool  } from "./pool/IQualifiedPool.sol";
import { IJasmineRetireablePool as IRetireablePool } from "./pool/IRetireablePool.sol";


/**
 * @title Jasmine Pool Interface
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Jasmine Pools allow users to deposit their EATs given certain conditions
 *         are met to receive pool specific Jasmine Liquidity Tokens (JLT).
 * @custom:security-contact dev@jasmine.energy
 */
interface IJasminePool is IEATBackedPool, IQualifiedPool, IRetireablePool {
        function initialize(bytes calldata policy, string calldata name, string calldata symbol) external;
}
