// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0;

// Base
import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";
// Jasmine Types
import { IEATBackedPool  } from "./pool/IEATBackedPool.sol";
import { IQualifiedPool  } from "./pool/IQualifiedPool.sol";
import { IRetireablePool } from "./pool/IRetireablePool.sol";
// Token Metadata Support
import { IERC20Metadata } from "@openzeppelin/contracts/interfaces/IERC20Metadata.sol";
import { IERC1046 }       from "../interfaces/ERC/IERC1046.sol";
// ERC-1155 support (for EAT interactions)
import { IERC1155Receiver } from "@openzeppelin/contracts/interfaces/IERC1155Receiver.sol";
// Token utility extensions
import { IERC1363 } from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import { IERC2612 } from "@openzeppelin/contracts/interfaces/draft-IERC2612.sol";


/**
 * @title IJasminePool
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
 * @dev 
 * @custom:security-contact dev@jasmine.energy
 */
interface IJasminePool is IEATBackedPool, IQualifiedPool, IRetireablePool,
        IERC20Metadata {
        function initialize(bytes calldata policy, string calldata name, string calldata symbol) external;
}
