// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import { CrypticInterface } from "./CrypticInterface.sol";
import { JasminePool } from "../JasminePool.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

// contract InternalJasminePoolTest is JasminePool {

//     constructor() JasminePool() {

//     }

// }

contract ExternalJasminePoolTest is CrypticInterface {


    event AssertionFailed(string reason);

    function echidna_check_deposit() public returns(bool) {
        uint256 tokenId = mintEAT(address(this), 1, uint40(block.timestamp), 1);

        uint256 preDepositBalance = frontHalfPool.balanceOf(address(this));
        IERC1155(eat).safeTransferFrom(address(this), address(frontHalfPool), tokenId, 1, "");
        uint256 postDepositBalance = frontHalfPool.balanceOf(address(this));

        return postDepositBalance == preDepositBalance + 1;
    }
}
