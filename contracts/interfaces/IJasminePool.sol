// SPDX-License-Identifier: BUSL-1.1

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
import { IERC777 }  from "@openzeppelin/contracts/interfaces/IERC777.sol";
import { IERC1363 } from "@openzeppelin/contracts/interfaces/IERC1363.sol";
import { IERC2612 } from "@openzeppelin/contracts/interfaces/draft-IERC2612.sol";

// NOTE: Up for debate
import { IERC3156FlashLender } from "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";


/**
 * @title IJasminePool
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice 
 * @dev 
 */
interface IJasminePool is 
    IERC20,
    IEATBackedPool, IQualifiedPool, IRetireablePool,
    IERC20Metadata, IERC1046,
    IERC1155Receiver,
    IERC777, IERC2612, IERC1363 {

    /// @dev Required override due to ERC-20 & ERC-777 conflicts
    function totalSupply() external view override(IERC20, IERC777) returns (uint256);
    function balanceOf(address account) external view override(IERC20, IERC777) returns (uint256);
    function name() external view override(IERC20Metadata, IERC777) returns (string memory);
    function symbol() external view override(IERC20Metadata, IERC777) returns (string memory);

}
