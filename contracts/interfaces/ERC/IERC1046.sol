// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

//  ─────────────────────────────────  Imports  ─────────────────────────────────  \\

import { IERC20 } from "@openzeppelin/contracts/interfaces/IERC20.sol";

/**
 * @title  ERC-20 Metadata Extension (ERC-1046)
 * @notice tokenURI interoperability for ERC-20
 * @dev    Implements tokenURI on ERC-20 to support interoperability with
 *         ERC-721 & 1155. [See EIP-1046](https://eips.ethereum.org/EIPS/eip-1046).
 */
interface IERC1046 is IERC20 {
    /**
     * @notice   Gets an ERC-721-like token URI
     * @dev      The resolved data MUST be in JSON format and
     *           support ERC-1046's ERC-20 Token Metadata Schema
     */
    function tokenURI() external view returns (string memory);
}
