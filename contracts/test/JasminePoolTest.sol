// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "@crytic/properties/contracts/util/Hevm.sol";

import {CrypticInterface} from "./CrypticInterface.sol";
import {JasminePool as JasmineCorePool} from "../JasminePool.sol";
import {PoolPolicy} from "../libraries/PoolPolicy.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ArrayUtils} from "../libraries/ArrayUtils.sol";
import {ITokenMock} from "@crytic/properties/contracts/ERC20/external/util/ITokenMock.sol";
import {CryticERC20ExternalBasicProperties} from "@crytic/properties/contracts/ERC20/external/properties/ERC20ExternalBasicProperties.sol";
import {PropertiesConstants} from "@crytic/properties/contracts/util/PropertiesConstants.sol";

contract CryticERC20ExternalHarness is
    CryticERC20ExternalBasicProperties,
    CrypticInterface
{

    uint40 public constant MIN_VINTAGE = 1672531200;
    uint40 public constant MAX_VINTAGE = 1688083200;

    // Array of [tokenID, amount]
    uint256[2][] internal deposits;

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Setup
    //  ─────────────────────────────────────────────────────────────────────────────

    constructor() CrypticInterface() {
        // Deploy ERC20
        hevm.prank(poolManager);
        poolFactory.updateImplementationAddress(
            address(
                new CryticTokenMock(eat, oracle, address(poolFactory), minter)
            ),
            0
        );
        token = ITokenMock(address(frontHalfPool));

        uint256 initialEATAmount = INITIAL_BALANCE / (10 ** 18);
        // TODO: Override USER-n to reflect enchidna confid
        mintJLT(USER1, initialEATAmount, MIN_VINTAGE + 1);
        mintJLT(USER2, initialEATAmount, MIN_VINTAGE + 2);
        mintJLT(USER3, initialEATAmount, MIN_VINTAGE + 3);
        mintJLT(msg.sender, initialEATAmount, MIN_VINTAGE + 4);
    }


    //  ─────────────────────────────────────────────────────────────────────────────
    //  Deposit Tests
    //  ─────────────────────────────────────────────────────────────────────────────

    function test_deposit(uint256 mintAmount, uint256 vintage) public {
        vintage = clampBetween(vintage, MIN_VINTAGE, MAX_VINTAGE);

        uint256 tokenId = mintEAT(
            msg.sender,
            mintAmount,
            uint40(vintage),
            1
        );

        assert(frontHalfPool.meetsPolicy(tokenId));

        uint256 preDepositBalance = frontHalfPool.balanceOf(msg.sender);
        hevm.prank(msg.sender);
        IERC1155(eat).safeTransferFrom(
            msg.sender,
            address(frontHalfPool),
            tokenId,
            mintAmount,
            ""
        );
        deposits.push([tokenId, mintAmount]);
        uint256 postDepositBalance = frontHalfPool.balanceOf(msg.sender);

        assert(
            postDepositBalance == preDepositBalance + (mintAmount * (10 ** 18))
        );
    }

    function test_invalid_deposit(uint256 mintAmount, uint40 vintage) public {
        vintage = uint40(clampBetween(uint256(vintage), MIN_VINTAGE, MAX_VINTAGE));
        vintage = mintAmount % 2 == 0 ?
            uint40(vintage - MIN_VINTAGE) :
            uint40(vintage + MAX_VINTAGE);

        uint256 tokenId = mintEAT(
            msg.sender,
            mintAmount,
            vintage,
            1
        );

        assert(!frontHalfPool.meetsPolicy(tokenId));

        uint256 preDepositBalance = frontHalfPool.balanceOf(msg.sender);
        hevm.prank(msg.sender);
        try IERC1155(eat).safeTransferFrom(msg.sender, address(frontHalfPool), tokenId, mintAmount, "") {
            revert("Accepted deposit of ineligible token");
        } catch {
            uint256 postDepositBalance = frontHalfPool.balanceOf(msg.sender);

            assert(postDepositBalance == preDepositBalance);
        }
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Withdraw Tests
    //  ─────────────────────────────────────────────────────────────────────────────

    function test_withdraw_any(uint256 amount) public {
        uint256 balance = frontHalfPool.balanceOf(msg.sender);
        amount = clampBetween(amount, 1, 1_000);
        uint256 withdrawalCost = frontHalfPool.withdrawalCost(amount);

        if (withdrawalCost > balance) {
            mintJLT(msg.sender, withdrawalCost - balance, MIN_VINTAGE + 1);
            balance = frontHalfPool.balanceOf(msg.sender);
            assert(balance >= withdrawalCost);
        }

        (
            uint256[] memory expectedTokens,
            uint256[] memory expectedAmount
        ) = frontHalfPool.selectWithdrawTokens(amount);
        uint256[] memory poolHoldings = IERC1155(eat).balanceOfBatch(
            ArrayUtils.fill(address(frontHalfPool), expectedTokens.length),
            expectedTokens
        );
        uint256[] memory callerHoldings = IERC1155(eat).balanceOfBatch(
            ArrayUtils.fill(msg.sender, expectedTokens.length),
            expectedTokens
        );
        for (uint256 i = 0; i < expectedTokens.length; i++) {
            assert(poolHoldings[i] >= expectedAmount[i]);
        }

        frontHalfPool.withdraw(msg.sender, amount, "");
        assert(frontHalfPool.balanceOf(msg.sender) == balance - withdrawalCost);

        for (uint256 i = 0; i < expectedTokens.length; i++) {
            assert(
                IERC1155(eat).balanceOf(msg.sender, expectedTokens[i]) ==
                    callerHoldings[i] + expectedAmount[i]
            );
            assert(
                IERC1155(eat).balanceOf(address(frontHalfPool), expectedTokens[i]) ==
                    poolHoldings[i] - expectedAmount[i]
            );
        }
    }

    function test_withdraw_specific_single(uint256 indexSeed) public {
        uint256[2] memory deposit = deposits[indexSeed % deposits.length];

        // TODO: Not a huge fan of this approach to checking if the deposit is held by the pool. Fix it
        bool isHeldByPool = IERC1155(eat).balanceOf(address(frontHalfPool), deposit[0]) >= deposit[1];
        while(!isHeldByPool) {
            delete deposits[indexSeed % deposits.length];
            indexSeed++;
            deposit = deposits[indexSeed % deposits.length];
            uint256 balance = IERC1155(eat).balanceOf(address(frontHalfPool), deposit[0]);
            isHeldByPool = balance  >= deposit[1];
            deposits[indexSeed % deposits.length][1] = balance;
        }

        uint256 withdrawalCost = frontHalfPool.withdrawalCost(_asSingletonArray(deposit[0]), _asSingletonArray(deposit[1]));
        uint256 preWithdrawalBalance = frontHalfPool.balanceOf(msg.sender);

        if (withdrawalCost > preWithdrawalBalance) {
            mintJLT(msg.sender, withdrawalCost - preWithdrawalBalance, MIN_VINTAGE);
            preWithdrawalBalance = frontHalfPool.balanceOf(msg.sender);
            assert(withdrawalCost <= preWithdrawalBalance);
        }

        uint256 preWithdrawalPoolHolding = IERC1155(eat).balanceOf(address(frontHalfPool), deposit[0]);
        uint256 preWithdrawalCallerHolding = IERC1155(eat).balanceOf(msg.sender, deposit[0]);
        hevm.prank(msg.sender);
        frontHalfPool.withdrawSpecific(msg.sender, msg.sender, _asSingletonArray(deposit[0]), _asSingletonArray(deposit[1]), "");
        uint256 postWithdrawalPoolHolding = IERC1155(eat).balanceOf(address(frontHalfPool), deposit[0]);
        uint256 postWithdrawalCallerHolding = IERC1155(eat).balanceOf(msg.sender, deposit[0]);
        uint256 postWithdrawalBalance = frontHalfPool.balanceOf(msg.sender);

        assert(postWithdrawalBalance == preWithdrawalBalance - withdrawalCost);
        assert(postWithdrawalPoolHolding == preWithdrawalPoolHolding - deposit[1]);
        assert(postWithdrawalCallerHolding == preWithdrawalCallerHolding + deposit[1]);
    }

    function test_withdraw_specific_batch(uint256 indexSeed, uint256 quantity) public {
        quantity = clampBetween(quantity, 1, 10);
        uint256[] memory tokenIds = new uint256[](quantity);
        uint256[] memory amounts = new uint256[](quantity);

        uint256 insertIndex = 0;
        while (insertIndex < quantity) {
            uint256[2] memory deposit = deposits[(indexSeed % deposits.length) + insertIndex];
            if (IERC1155(eat).balanceOf(address(frontHalfPool), deposit[0]) >= deposit[1]) {
                tokenIds[insertIndex] = deposit[0];
                amounts[insertIndex] = deposit[1];
                insertIndex++;
            } else {
                indexSeed++;
            }
        }

        uint256 withdrawalCost = frontHalfPool.withdrawalCost(tokenIds, amounts);
        uint256 preWithdrawalBalance = frontHalfPool.balanceOf(msg.sender);
        uint256[] memory poolHoldings = IERC1155(eat).balanceOfBatch(
            ArrayUtils.fill(address(frontHalfPool), quantity),
            tokenIds
        );
        uint256[] memory callerHoldings = IERC1155(eat).balanceOfBatch(
            ArrayUtils.fill(msg.sender, quantity),
            tokenIds
        );

        hevm.prank(msg.sender);
        frontHalfPool.withdrawSpecific(msg.sender, msg.sender, tokenIds, amounts, "");

        uint256 postWithdrawalBalance = frontHalfPool.balanceOf(msg.sender);
        uint256[] memory postWithdrawalPoolHoldings = IERC1155(eat).balanceOfBatch(
            ArrayUtils.fill(address(frontHalfPool), quantity),
            tokenIds
        );
        uint256[] memory postWithdrawalCallerHoldings = IERC1155(eat).balanceOfBatch(
            ArrayUtils.fill(msg.sender, quantity),
            tokenIds
        );

        assert(postWithdrawalBalance == preWithdrawalBalance - withdrawalCost);
        for (uint256 i = 0; i < quantity; i++) {
            assert(postWithdrawalPoolHoldings[i] == poolHoldings[i] - amounts[i]);
            assert(postWithdrawalCallerHoldings[i] == callerHoldings[i] + amounts[i]);
        }
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Retire Tests
    //  ─────────────────────────────────────────────────────────────────────────────

    function test_retire(uint256 retireAmount) public {
        uint256 balance = frontHalfPool.balanceOf(msg.sender);
        retireAmount = clampLte(retireAmount, balance);

        uint256 preRetireBalance = frontHalfPool.balanceOf(msg.sender);
        uint256 preRetireSupply = frontHalfPool.totalSupply();
        hevm.prank(msg.sender);
        frontHalfPool.retire(msg.sender, msg.sender, retireAmount, "");
        uint256 postRetireBalance = frontHalfPool.balanceOf(msg.sender);
        uint256 postRetireSupply = frontHalfPool.totalSupply();

        assert(postRetireBalance == preRetireBalance - retireAmount);
        assert(postRetireSupply == preRetireSupply - retireAmount);
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Test Overrides
    //  ─────────────────────────────────────────────────────────────────────────────

    function test_ERC20external_constantSupply() public override {
        // NO-OP
    }

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Utility Functions
    //  ─────────────────────────────────────────────────────────────────────────────

    function mintJLT(address recipient, uint256 amount, uint256 vintage) public {
        vintage = clampBetween(vintage, MIN_VINTAGE, MAX_VINTAGE);
        uint256 tokenId = mintEAT(recipient, amount, uint40(vintage), 1);
        hevm.prank(recipient);
        IERC1155(eat).safeTransferFrom(
            recipient,
            address(frontHalfPool),
            tokenId,
            amount,
            ""
        );
        deposits.push([tokenId, amount]);
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory array) {
        array = new uint256[](1);
        assembly ("memory-safe") {
            mstore(add(array, 32), element)
        }
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
