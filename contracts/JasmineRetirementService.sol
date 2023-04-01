// SPDX-License-Identifier: BUSL-1.1

pragma solidity >=0.8.0;


import { IRetirementService } from "./interfaces/IRetirementService.sol";
import { IRetirementRecipient } from "./interfaces/IRetirementRecipient.sol";

import { JasmineMinter } from "@jasmine-energy/contracts/src/JasmineMinter.sol";

contract JasmineRetirementService is IRetirementService {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override {}

    function supportsInterface(
        bytes4 interfaceId
    ) external view override returns (bool) {}

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {}

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4) {}

    function registerRetirementRecipient(
        address holder,
        address recipient
    ) external override {}

    function requestResidualJLT(
        address pool
    ) external override returns (bool success) {}
}
