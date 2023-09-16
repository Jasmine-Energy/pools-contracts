// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IJasmineEAT is IERC1155 {
    function frozen(uint256) external view returns (bool);
    function exists(uint256 id) external view returns (bool);
}
