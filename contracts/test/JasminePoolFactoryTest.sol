// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;

import {CrypticInterface} from "./CrypticInterface.sol";
import {JasminePoolFactory} from "../JasminePoolFactory.sol";

contract InternalJasminePoolFactoryTest is JasminePoolFactory {
    constructor()
        JasminePoolFactory(
            0x1F98431c8aD98523631AE4a59f267346ea31F984,
            0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174
        )
    {}
}

contract ExternalJasminePoolFactoryTest is CrypticInterface {
    event AssertionFailed(string reason);

    function test_setup() public view {
        assert(address(eat) != address(0x0));
        assert(address(oracle) != address(0x0));
        assert(address(minter) != address(0x0));
        assert(address(retirementService) != address(0x0));
        assert(address(poolFactory) != address(0x0));
        assert(address(poolImplementation) != address(0x0));
        assert(address(frontHalfPool) != address(0x0));
    }

    function test_owner() public view {
        // NOTE: Bit of a hacky way to check owner
        assert(poolFactory.owner() == owner);
    }
}
