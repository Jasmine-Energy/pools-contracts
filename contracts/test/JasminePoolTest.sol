// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "@crytic/properties/contracts/util/Hevm.sol";

import { CrypticInterface } from "./CrypticInterface.sol";
import { JasminePool as JasmineCorePool } from "../JasminePool.sol";
import { PoolPolicy } from "../libraries/PoolPolicy.sol";
import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import { ERC1155Holder } from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import { ArrayUtils } from "../libraries/ArrayUtils.sol";
import { ITokenMock } from "@crytic/properties/contracts/ERC20/external/util/ITokenMock.sol";
import { CryticERC20ExternalBasicProperties } from "@crytic/properties/contracts/ERC20/external/properties/ERC20ExternalBasicProperties.sol";
import { PropertiesConstants } from "@crytic/properties/contracts/util/PropertiesConstants.sol";


contract CryticERC20ExternalHarness is CryticERC20ExternalBasicProperties, CrypticInterface {
    constructor() CrypticInterface() {
        // Deploy ERC20
        hevm.prank(poolManager);
        poolFactory.updateImplementationAddress(address(new CryticTokenMock(eat, oracle, address(poolFactory), minter)), 0);
        token = ITokenMock(address(frontHalfPool));

        uint256 initialEATAmount = INITIAL_BALANCE / (10 ** 18);
        uint256 tokenId1 = mintEAT(USER1, initialEATAmount, 1672531201, 1);
        uint256 tokenId2 = mintEAT(USER2, initialEATAmount, 1672531202, 1);
        uint256 tokenId3 = mintEAT(USER3, initialEATAmount, 1672531203, 1);
        uint256 tokenId4 = mintEAT(msg.sender, initialEATAmount, 1672531204, 1);

        hevm.prank(USER1);
        IERC1155(eat).safeTransferFrom(USER1, address(frontHalfPool), tokenId1, initialEATAmount, "");
        hevm.prank(USER2);
        IERC1155(eat).safeTransferFrom(USER2, address(frontHalfPool), tokenId2, initialEATAmount, "");
        hevm.prank(USER3);
        IERC1155(eat).safeTransferFrom(USER3, address(frontHalfPool), tokenId3, initialEATAmount, "");
        hevm.prank(msg.sender);
        IERC1155(eat).safeTransferFrom(msg.sender, address(frontHalfPool), tokenId4, initialEATAmount, "");
    }

    function test_ERC20external_constantSupply() public override {
        // NO-OP
    }
}

contract CryticTokenMock is JasmineCorePool, PropertiesConstants {

    bool public isMintableOrBurnable;
    uint256 public initialSupply;
    constructor(
        address _eat,
        address _oracle,
        address _poolFactory,
        address _minter
    ) JasmineCorePool(_eat, _oracle, _poolFactory, _minter) {
        initialSupply = totalSupply();
        isMintableOrBurnable = true;
    }
}

// contract ExternalJasminePoolTest is CrypticInterface, ERC1155Holder {


//     event AssertionFailed(string reason);

//     function echidna_test_deposit() public returns(bool success) {
//         uint256 mintAmount = 1;
//         uint40 randEligibleVintage = uint40(block.timestamp % (1688083200 - 1672531200)) + 1672531200;

//         uint256 tokenId = mintEAT(msg.sender, mintAmount, randEligibleVintage, 1);

//         if (!frontHalfPool.meetsPolicy(tokenId)) {
//             emit AssertionFailed("Token does not meet policy");
//             return false;
//         }

//         uint256 preDepositBalance = frontHalfPool.balanceOf(msg.sender);
//         hevm.prank(msg.sender);
//         IERC1155(eat).safeTransferFrom(msg.sender, address(frontHalfPool), tokenId, mintAmount, "");
//         uint256 postDepositBalance = frontHalfPool.balanceOf(msg.sender);

//         if (postDepositBalance != preDepositBalance + (mintAmount * (10 ** 18))) {
//             emit AssertionFailed("Deposit failed to increment balance");
//             return false;
//         }

//         return true;
//     }

//     function echidna_test_withdraw_any() public returns(bool success) {
//         uint256 balance = frontHalfPool.balanceOf(msg.sender);
//         uint256 singleWithdrawalCost = frontHalfPool.withdrawalCost(1);

//         if (singleWithdrawalCost > balance) {
//             return true;
//         }

//         uint256 withdrawalQuantity = balance / singleWithdrawalCost;
//         if (withdrawalQuantity == 0) {
//             emit AssertionFailed("Expected caller to have sufficient JLT for withdrawal");
//             return false;
//         }

//         uint256 withdrawalCost = frontHalfPool.withdrawalCost(withdrawalQuantity);

//         (uint256[] memory expectedTokens, uint256[] memory expectedAmount) = frontHalfPool.selectWithdrawTokens(withdrawalQuantity);
//         uint256[] memory poolHoldings = IERC1155(eat).balanceOfBatch(ArrayUtils.fill(address(this), expectedTokens.length), expectedTokens);
//         uint256[] memory callerHoldings = IERC1155(eat).balanceOfBatch(ArrayUtils.fill(msg.sender, expectedTokens.length), expectedTokens);
//         for (uint256 i = 0; i < expectedTokens.length; i++) {
//             if (poolHoldings[i] < expectedAmount[i]) {
//                 emit AssertionFailed("Pool does not have sufficient holdings for withdrawal");
//                 return false;
//             }
//         }

//         frontHalfPool.withdraw(msg.sender, withdrawalQuantity, "");
//         if (frontHalfPool.balanceOf(msg.sender) != balance - withdrawalCost) {
//             emit AssertionFailed("Expected caller to have less JLT after withdrawal");
//             return false;
//         }

//         return true;
//     }
// }
