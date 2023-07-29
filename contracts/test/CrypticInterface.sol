// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import { JasminePoolFactory } from "../JasminePoolFactory.sol";
import { JasmineRetirementService } from "../JasmineRetirementService.sol";
import { JasminePool } from "../JasminePool.sol";


abstract contract CrypticInterface {
    address public constant eat = 0xAE205e00C7DCb5292388BD8962E79582a5AE14d0;
    address public constant oracle = 0x3F3f61a613504166302C5Ee3546b0e85c0a61934;
    address public constant minter = 0xe9c135b9Fb2942982e3DF5B89a03E51D8EE6CB74;

    JasmineRetirementService public constant retirementService = JasmineRetirementService(0x8a654E827Df68ed727F23C7a82e75eaC9e7999Bd);
    JasminePoolFactory public constant poolFactory = JasminePoolFactory(0x66e04bc791c2BE81639bC277A813D782a967aBE7);
    JasminePool public constant poolImplementation = JasminePool(0xfd82bB56A9c6b86709A6BCfae9f3b58253C966ef);

    JasminePool public immutable frontHalfPool;

    constructor() {
        frontHalfPool = JasminePool(poolFactory.getPoolAtIndex(0));
    }

    address public constant bridge = 0x2dcAd29De8a67d70b7B5bf32B19f1480f333D8dD;
}
