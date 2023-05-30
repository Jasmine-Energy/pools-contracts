// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

// Interfaces
import { IERC1046 } from "../interfaces/ERC/IERC1046.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";


/**
 * @title ERC-1046
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Abstract class to add ERC-1046 conformance
 * @custom:security-contact dev@jasmine.energy
 */
abstract contract ERC1046 is IERC1046, IERC20Metadata, ERC165 {

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    string private _tokenURI;


    // ──────────────────────────────────────────────────────────────────────────────
    // Setup
    // ──────────────────────────────────────────────────────────────────────────────

    /**
     * @param tokenURI_ Initial token URI value where more information may be obtained
     */
    constructor(string memory tokenURI_) {
        _tokenURI = tokenURI_;
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  ERC-1046 Implementation
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IERC1046
    function tokenURI() public view virtual returns (string memory) {
        return _tokenURI;
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  State Management Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    /**
     * @dev Internal function to update the stored tokenURI
     * 
     * @param newTokenURI New token URI to replace current
     */
    function _updateTokenURI(string memory newTokenURI) internal virtual {
        _tokenURI = newTokenURI;
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  ERC-165 Interface Support
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @inheritdoc ERC165
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC1046).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
