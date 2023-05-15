// SPDX-License-Identifier: BUSL-1.1
// solhint-disable quotes

pragma solidity >=0.8.17;


//  ─────────────────────────────────────────────────────────────────────────────
//  Imports
//  ─────────────────────────────────────────────────────────────────────────────

import { IERC1046 } from "../interfaces/ERC/IERC1046.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { Base64 } from "@openzeppelin/contracts/utils/Base64.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";


/**
 * @title ERC1046
 * @author Kai Aldag<kai.aldag@jasmine.energy>
 * @notice Abstract class to add ERC-1046 conformance
 * @dev tokenURI returns URI in Base64 encoded data URL format
 * @custom:security-contact dev@jasmine.energy
 * 
 * NOTE: Alternate implementation that uses key values
 */
abstract contract ERC1046 is IERC1046, IERC20Metadata {

    // ──────────────────────────────────────────────────────────────────────────────
    // Libraries
    // ──────────────────────────────────────────────────────────────────────────────

    using Strings for uint8;

    // ──────────────────────────────────────────────────────────────────────────────
    // Fields
    // ──────────────────────────────────────────────────────────────────────────────

    string[] private _metadataKeys;
    mapping(bytes32 => string) private _metadataValues;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  ERC-1046 Implementation
    //  ─────────────────────────────────────────────────────────────────────────────

    /// @inheritdoc IERC1046
    function tokenURI() external view  returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
             '{',
                 '"name": "', this.name(), '", ',
                 '"symbol": "', this.symbol(), '", ',
                 '"decimals": ', this.decimals().toString(), ', ',
                 _encodeEntries(),
                 '"interop": {',
                    '"erc1046": true, ',
                    '"erc721": false, ',
                    '"erc1155": false',
                 '}',
             '}'
         );
 
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Metadata Methods
    //  ─────────────────────────────────────────────────────────────────────────────

    function addMetadataEntry(string memory key, string memory value) internal {
        // Check if key does not exist. If so, add to keys
        if (bytes(_metadataValues[keccak256(bytes(key))]).length == 0) {
            _metadataKeys.push(key);
        }
        _metadataValues[keccak256(bytes(key))] = value;
    }

    function removeMetadataEntry(bytes32 key) internal {
        require(
            bytes(_metadataValues[key]).length != 0,
            "ERC1046: Entry does not exist"
        );
        if (_metadataKeys.length == 1) _metadataKeys.pop();

        _metadataValues[key] = "";
        uint256 i = 0;
        while (true) {
            if (keccak256(bytes(_metadataKeys[i])) == key) {
                // Key found. Delete element
                delete _metadataKeys[i];
                return;
            }

            unchecked {
                i++;
            }
        }
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Internal
    //  ─────────────────────────────────────────────────────────────────────────────

    function _encodeEntries() internal view returns (string memory) {
        string memory result = "";
        for (uint256 i = 0; i < _metadataKeys.length;) {
            if (bytes(_metadataKeys[i]).length != 0) {
                result = string(abi.encodePacked(result, 
                    '"', _metadataKeys[i], '": "', _metadataValues[keccak256(bytes(_metadataKeys[i]))], 
                    i != _metadataKeys.length ? '", ' : '"'
                ));
            }
            unchecked { ++i; }
        }

        return result;
    }

    function _encodeArray(string[] memory list) internal pure returns (string memory) {
        string memory result = "[";
        for (uint256 i = 0; i < list.length;) {
            result = string(abi.encodePacked(result, '"', list[i], i != list.length - 1 ? '", ' : '"'));

            unchecked { ++i; }
        }
        result = string(abi.encodePacked(result, "]"));

        return result;
    }
}


// abstract contract ERC1046 is IERC1046, IERC20Metadata {

//     // ──────────────────────────────────────────────────────────────────────────────
//     // Libraries
//     // ──────────────────────────────────────────────────────────────────────────────

//     using Strings for uint8;


//     //  ─────────────────────────────────────────────────────────────────────────────
//     //  ERC-1046 Implementation
//     //  ─────────────────────────────────────────────────────────────────────────────

//     /// @inheritdoc IERC1046
//     function tokenURI() external view override returns (string memory) {
//         bytes memory dataURI = abi.encodePacked(
//              '{',
//                  '"name": "', this.name(), '", ',
//                  '"symbol": "', this.symbol(), '", ',
//                  '"decimals": ', this.decimals().toString(), ', ',
//                  bytes(tokenDescription()).length != 0 ? string(abi.encodePacked('"description": "', tokenDescription(), '", ')) : "",
//                  bytes(tokenImage()).length != 0 ? string(abi.encodePacked('"image": "', tokenImage(), '", ')) : "",
//                 tokenImages().length != 0 ? string(abi.encodePacked('"images": "', _encodeArray(tokenImages()), '", ')) : "",
//                 tokenIcons().length != 0 ? string(abi.encodePacked('"icons": "', _encodeArray(tokenIcons()), '", ')) : "",
//                  '"interop": {',
//                     '"erc1046": true, ',
//                     '"erc721": false, ',
//                     '"erc1155": false',
//                  '}',
//              '}'
//          );
 
//         return string(
//             abi.encodePacked(
//                 "data:application/json;base64,",
//                 Base64.encode(dataURI)
//             )
//         );
//     }


//     //  ─────────────────────────────────────────────────────────────────────────────
//     //  Metadata Methods
//     //  ─────────────────────────────────────────────────────────────────────────────

//     /**
//      * @dev Override the following to set an image in ERC-1046 metadata
//      */
//     function tokenImage() public view virtual returns (string memory) {
//         return "";
//     }

//     /**
//      * @dev Override the following to set a description in ERC-1046 metadata
//      */
//     function tokenDescription() public view virtual returns (string memory) {
//         return "";
//     }

//     /**
//      * @dev Override the following to set images in ERC-1046 metadata
//      */
//     function tokenImages() public view virtual returns (string[] memory) {
//         return new string[](0);
//     }

//     /**
//      * @dev Override the following to set icons in ERC-1046 metadata
//      */
//     function tokenIcons() public view virtual returns (string[] memory) {
//         return new string[](0);
//     }


//     //  ─────────────────────────────────────────────────────────────────────────────
//     //  Internal
//     //  ─────────────────────────────────────────────────────────────────────────────

//     /**
//      * @dev Encodes an array of strings to JSON formatted string
//      * 
//      * @param list List of string to encode
//      * @return JSON formatted array of list
//      */
//     function _encodeArray(string[] memory list) public pure returns (string memory) {
//         string memory result = "[";
        
//         for (uint256 i = 0; i < list.length; i++) {
            
//             result = string(abi.encodePacked(result, '"', list[i], i != list.length - 1 ? '", ' : '"'));
//         }
//         result = string(abi.encodePacked(result, "]"));

//         return result;
//     }
// }
