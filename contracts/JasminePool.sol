// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.18;


import { IJasminePool } from "./interfaces/IJasminePool.sol";

contract JasminePool is IJasminePool {


    // TODO must use onlyProxy modifier
    function initialize(
        bytes calldata policy,
        string calldata name,
        string calldata symbol
    ) external override {}

    function meetsPolicy(
        uint256 tokenId
    ) external view override returns (bool isEligible) {}

    function policyForVersion(
        uint8 metadataVersion
    ) external view override returns (bytes memory policy) {}

    function deposit(
        address from,
        uint256 tokenId,
        uint256 quantity
    ) external override returns (bool success, uint256 jltQuantity) {}

    function depositBatch(
        address from,
        uint256[] calldata tokenIds,
        uint256[] calldata quantities
    ) external override returns (bool success, uint256 jltQuantity) {}

    function withdraw(
        address owner,
        address recipient,
        uint256 quantity,
        bytes calldata data
    ) external override returns (bool success) {}

    function withdrawSpecific(
        address owner,
        address recipient,
        uint256[] calldata tokenIds,
        uint256[] calldata quantities,
        bytes calldata data
    ) external override returns (bool success) {}

    function retire(
        address owner,
        address beneficiary,
        uint256 quantity,
        bytes calldata data
    ) external override returns (bool success) {}

    function supportsInterface(
        bytes4 interfaceId
    ) external view override returns (bool) {}

    function totalSupply() external view override returns (uint256) {}

    function balanceOf(
        address account
    ) external view override returns (uint256) {}

    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {}

    function allowance(
        address owner,
        address spender
    ) external view override returns (uint256) {}

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {}

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {}

    function name() external view override returns (string memory) {}

    function symbol() external view override returns (string memory) {}

    function decimals() external view override returns (uint8) {}

    function tokenURI() external view override returns (string memory) {}

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

    function granularity() external view override returns (uint256) {}

    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external override {}

    function burn(uint256 amount, bytes calldata data) external override {}

    function isOperatorFor(
        address operator,
        address tokenHolder
    ) external view override returns (bool) {}

    function authorizeOperator(address operator) external override {}

    function revokeOperator(address operator) external override {}

    function defaultOperators()
        external
        view
        override
        returns (address[] memory)
    {}

    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external override {}

    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external override {}

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override {}

    function nonces(address owner) external view override returns (uint256) {}

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {}

    function transferAndCall(
        address to,
        uint256 value
    ) external override returns (bool) {}

    function transferAndCall(
        address to,
        uint256 value,
        bytes memory data
    ) external override returns (bool) {}

    function transferFromAndCall(
        address from,
        address to,
        uint256 value
    ) external override returns (bool) {}

    function transferFromAndCall(
        address from,
        address to,
        uint256 value,
        bytes memory data
    ) external override returns (bool) {}

    function approveAndCall(
        address spender,
        uint256 value
    ) external override returns (bool) {}

    function approveAndCall(
        address spender,
        uint256 value,
        bytes memory data
    ) external override returns (bool) {}
}
