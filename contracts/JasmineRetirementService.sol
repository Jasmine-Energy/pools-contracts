// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.17;


import { IRetirementService } from "./interfaces/IRetirementService.sol";
import { IRetirementRecipient } from "./interfaces/IRetirementRecipient.sol";

import { JasmineMinter } from "@jasmine-energy/contracts/src/JasmineMinter.sol";

contract JasmineRetirementService is IRetirementService {
    function tokensReceived(
        address,
        address,
        address,
        uint256,
        bytes calldata,
        bytes calldata
    ) external pure  override {
        revert("JasmineRetirementService: Unimplemented");
    }

    function supportsInterface(
        bytes4
    ) external pure  override returns (bool) {
        revert("JasmineRetirementService: Unimplemented");
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure  override returns (bytes4) {
        revert("JasmineRetirementService: Unimplemented");
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure  override returns (bytes4) {
        revert("JasmineRetirementService: Unimplemented");
    }

    function registerRetirementRecipient(
        address,
        address
    ) external pure override {
        revert("JasmineRetirementService: Unimplemented");
    }

    function requestResidualJLT(
        address
    ) external pure  override returns (bool) {
        revert("JasmineRetirementService: Unimplemented");
    }
}
