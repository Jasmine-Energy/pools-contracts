// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.18;


import { IJasminePool } from "./interfaces/IJasminePool.sol";

contract JasminePool is IJasminePool {
    function meetsPolicy(
        uint256 tokenId
    ) external view override returns (bool isEligible) {}

    function policyForVersion(
        uint8 metadataVersion
    ) external view override returns (bytes memory policy) {}

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

    function name() external view override returns (string memory) {}

    function symbol() external view override returns (string memory) {}

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

    function decimals() external view override returns (uint8) {}

    function asset()
        external
        view
        override
        returns (address assetTokenAddress)
    {}

    function totalAssets()
        external
        view
        override
        returns (uint256 totalManagedAssets)
    {}

    function convertToShares(
        uint256 assets
    ) external view override returns (uint256 shares) {}

    function convertToAssets(
        uint256 shares
    ) external view override returns (uint256 assets) {}

    function maxDeposit(
        address receiver
    ) external view override returns (uint256 maxAssets) {}

    function previewDeposit(
        uint256 assets
    ) external view override returns (uint256 shares) {}

    function deposit(
        uint256 assets,
        address receiver
    ) external override returns (uint256 shares) {}

    function maxMint(
        address receiver
    ) external view override returns (uint256 maxShares) {}

    function previewMint(
        uint256 shares
    ) external view override returns (uint256 assets) {}

    function mint(
        uint256 shares,
        address receiver
    ) external override returns (uint256 assets) {}

    function maxWithdraw(
        address owner
    ) external view override returns (uint256 maxAssets) {}

    function previewWithdraw(
        uint256 assets
    ) external view override returns (uint256 shares) {}

    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external override returns (uint256 shares) {}

    function maxRedeem(
        address owner
    ) external view override returns (uint256 maxShares) {}

    function previewRedeem(
        uint256 shares
    ) external view override returns (uint256 assets) {}

    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external override returns (uint256 assets) {}

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
