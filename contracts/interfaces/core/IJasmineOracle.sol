// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

interface IJasmineOracle {
    function getUUID(uint256 id) external pure returns (uint128);

    function hasRegistry(
        uint256 id,
        uint256 query
    ) external pure returns (bool);

    function hasVintage(
        uint256 id,
        uint256 min,
        uint256 max
    ) external pure returns (bool);

    function hasFuel(uint256 id, uint256 query) external view returns (bool);

    function hasCertificateType(uint256 id, uint256 query) external view returns (bool);

    function hasEndorsement(uint256 id, uint256 query) external view returns (bool);
}
