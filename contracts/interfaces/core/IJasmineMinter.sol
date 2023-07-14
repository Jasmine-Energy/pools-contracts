// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

interface IJasmineMinter {
    //  ─────────────────────────────────────────────────────────────────────────────
    //  Events
    //  ─────────────────────────────────────────────────────────────────────────────

    event BurnedBatch(
        address indexed owner,
        uint256[] ids,
        uint256[] amounts,
        bytes metadata
    );

    event BurnedSingle(
        address indexed owner,
        uint256 id,
        uint256 amount,
        bytes metadata
    );

    //  ─────────────────────────────────────────────────────────────────────────────
    //  Mint and Burn Functionality
    //  ─────────────────────────────────────────────────────────────────────────────

    function mint(
        address receiver,
        uint256 id,
        uint256 amount,
        bytes memory transferData,
        bytes memory oracleData,
        uint256 deadline,
        bytes32 nonce,
        bytes memory sig
    ) external;

    function mintBatch(
        address receiver,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory transferData,
        bytes[] memory oracleDatas,
        uint256 deadline,
        bytes32 nonce,
        bytes memory sig
    ) external;

    function burn(uint256 id, uint256 amount, bytes memory metadata) external;

    function burnBatch(
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory metadata
    ) external;
}
