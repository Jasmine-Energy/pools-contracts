// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import { CrypticInterface } from "./CrypticInterface.sol";
import { JasminePoolFactory } from "../JasminePoolFactory.sol";

contract InternalJasminePoolFactoryTest is JasminePoolFactory {

    constructor() JasminePoolFactory(0x1F98431c8aD98523631AE4a59f267346ea31F984, 0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174) {

    }
}

contract ExternalJasminePoolFactoryTest is CrypticInterface {
    /// @dev NOTE: Address is assumed to be used the default mnemonic
    JasminePoolFactory public constant factory = JasminePoolFactory(0xAE205e00C7DCb5292388BD8962E79582a5AE14d0);

    event AssertionFailed(string reason);

    function echidna_check_setup() public view {
        assert(address(eat) != address(0x0));
        assert(address(oracle) != address(0x0));
        assert(address(minter) != address(0x0));
        assert(address(retirementService) != address(0x0));
        assert(address(poolFactory) != address(0x0));
        assert(address(poolImplementation) != address(0x0));
        assert(address(frontHalfPool) != address(0x0));
    }

    function echidna_check_owner() public view {
        // NOTE: Bit of a hacky way to check owner
        assert(JasminePoolFactory(poolFactory).owner() == owner);
    }
}
