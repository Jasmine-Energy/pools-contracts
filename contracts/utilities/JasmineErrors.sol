// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.4;


//  ─────────────────────────────────────────────────────────────────────────────
//  Jasmine Custom Errors
//  ─────────────────────────────────────────────────────────────────────────────

/**
 * @title Jasmine Errors
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Convenience interface for errors omitted by Jasmine's smart contracts
 * @custom:security-contact dev@jasmine.energy
 */
interface JasmineErrors {

    //  ───────────────────────────────  Pool Errors  ───────────────────────────────  \\

    /// @dev Emitted if a token does not meet pool's deposit policy
    error Unqualified(uint256 tokenId);

    /// @dev Emitted for unauthorized actions
    error Prohibited();
    

    //  ───────────────────────────  Pool Factory Errors  ───────────────────────────  \\

    /// @dev Emitted if no pool(s) meet query
    error NoPool();

    /// @dev Emitted if a pool exists with given policy
    error PoolExists(address pool);

    /// @dev Emitted for failed supportsInterface check - per ERC-165
    error InvalidConformance(bytes4 interfaceId);
}


//  ─────────────────────────────────────────────────────────────────────────────
//
//  ERC-6093 Errors
// 
//  NOTE: See [EIP](https://eips.ethereum.org/EIPS/eip-6093#security-considerations) for further info.
//
//  ─────────────────────────────────────────────────────────────────────────────


/// @title Standard ERC20 Errors
/// @dev See https://eips.ethereum.org/EIPS/eip-20
///  https://eips.ethereum.org/EIPS/eip-6093
interface ERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}

/// @title Standard ERC721 Errors
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  https://eips.ethereum.org/EIPS/eip-6093
interface ERC721Errors {
    error ERC721InvalidOwner(address sender, uint256 tokenId, address owner);
    error ERC721InvalidSender(address sender);
    error ERC721InvalidReceiver(address receiver);
    error ERC721InsufficientApproval(address operator, uint256 tokenId);
    error ERC721InvalidApprover(address approver);
    error ERC721InvalidOperator(address operator);
}

/// @title Standard ERC1155 Errors
/// @dev See https://eips.ethereum.org/EIPS/eip-1155
///  https://eips.ethereum.org/EIPS/eip-6093
interface ERC1155Errors {
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
    error ERC1155InvalidSender(address sender);
    error ERC1155InvalidReceiver(address receiver);
    error ERC1155InsufficientApproval(address operator, uint256 tokenId);
    error ERC1155InvalidApprover(address approver);
    error ERC1155InvalidOperator(address operator);
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
