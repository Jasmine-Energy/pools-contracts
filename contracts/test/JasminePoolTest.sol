// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "@crytic/properties/contracts/util/Hevm.sol";

import { CrypticInterface } from "./CrypticInterface.sol";
import { JasminePool } from "../JasminePool.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { ERC1155Holder } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

// contract InternalJasminePoolTest is JasminePool {

//     constructor() JasminePool() {

//     }

// }

contract ExternalJasminePoolTest is CrypticInterface, ERC1155Holder {


    event AssertionFailed(string reason);

    function echidna_check_deposit() public returns(bool) {
        uint256 mintAmount = 1;
        uint40 randEligibleVintage = uint40(block.timestamp % (1688083200 - 1672531200)) + 1672531200;

        uint256 tokenId = mintEAT(msg.sender, mintAmount, randEligibleVintage, 1);

        uint256 preDepositBalance = frontHalfPool.balanceOf(msg.sender);
        hevm.prank(msg.sender);
        IERC1155(eat).safeTransferFrom(msg.sender, address(frontHalfPool), tokenId, mintAmount, "");
        uint256 postDepositBalance = frontHalfPool.balanceOf(msg.sender);

        return postDepositBalance == preDepositBalance + (mintAmount * (10 ** 18));
    }
}
