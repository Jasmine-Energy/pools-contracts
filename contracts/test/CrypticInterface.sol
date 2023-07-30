// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.20;

import "@crytic/properties/contracts/util/Hevm.sol";

import {JasminePoolFactory} from "../JasminePoolFactory.sol";
import {JasmineRetirementService} from "../JasmineRetirementService.sol";
import {JasminePool} from "../JasminePool.sol";

interface IJasmineOracle {
    function updateSeries(uint256 id, bytes memory encodedMetadata) external;
}

interface IERC1155Mintable {
    function mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;
}

interface Minter {
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
}

interface ERC712 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}

abstract contract CrypticInterface {
    address public constant owner = 0x77f774c6632B1CA6BD248068fBaA952355eAE2b5;
    address public constant poolManager =
        0x694d38e74b52fBb2C2DDfA54D229097eeAb304dD;
    address public constant feeManager =
        0xd2F49a52c07Be026804FcE08ca46eDa6631fca6e;
    address public constant feeBeneficiary =
        0xc6e9B1a30E604cE6c2d32e33B290286b6c1cE555;
    address public constant bridge = 0x2dcAd29De8a67d70b7B5bf32B19f1480f333D8dD;
    uint256 private constant bridege_priv_key = 0x94397d81bb5172917d4b23ffd85afd2df9b99006ce1be993f93de6643175253f;

    address public constant eat = 0xba3aa8083F8978257aAAFB19Ed698a623197A7C1; // 0xAE205e00C7DCb5292388BD8962E79582a5AE14d0;
    address public constant oracle = 0x954F12aB1e40fbD7C28f2ab5285d3C74bA6faf6f; // 0x3F3f61a613504166302C5Ee3546b0e85c0a61934;
    address public constant minter = 0x5E71fa178F3b8cA0FC4736B8A85a1B669c042DdE; // 0xe9c135b9Fb2942982e3DF5B89a03E51D8EE6CB74;

    JasmineRetirementService public constant retirementService =
        JasmineRetirementService(0xa41Ee73984a9DAD0fA22937DB3097EBFE4cee791);
    // JasmineRetirementService(0x8a654E827Df68ed727F23C7a82e75eaC9e7999Bd); // Mumbai
    JasminePoolFactory public constant poolFactory =
        JasminePoolFactory(0xAE205e00C7DCb5292388BD8962E79582a5AE14d0);
    // JasminePoolFactory(0x66e04bc791c2BE81639bC277A813D782a967aBE7); // Mumbai
    JasminePool public constant poolImplementation =
        JasminePool(0xd09b8538Ea6D7147C00C3283e0298836E21DE956);
    // JasminePool(0xfd82bB56A9c6b86709A6BCfae9f3b58253C966ef); // Mumbai
    JasminePool public immutable frontHalfPool;

    constructor() {
        address poolAddress = poolFactory.getPoolAtIndex(0);
        require(poolAddress != address(0), "No front half pool deployed");
        frontHalfPool = JasminePool(poolAddress);

        require(poolFactory.owner() == owner, "Owner must be owner");
        require(poolFactory.hasRole(poolFactory.POOL_MANAGER_ROLE(), poolManager), "Pool manager must be a manager");
    }

    function mintEAT(
        address recipient,
        uint256 amount,
        uint40 vintage,
        uint32 techType
    ) public returns (uint256 tokenId) {
        bytes memory metadata;
        (tokenId, metadata) = getOracleData(1, vintage, 1, techType, 0, 0);

        hevm.prank(minter);
        IJasmineOracle(oracle).updateSeries(tokenId, metadata);
        hevm.prank(minter);
        IERC1155Mintable(eat).mint(recipient, tokenId, amount, "");
    }

    function getOracleData(
        uint256 series,
        uint40 vintage,
        uint32 registry,
        uint32 techType,
        uint32 certificateType,
        uint32 endorsement
    ) internal pure returns (uint256, bytes memory) {
        uint256 uuid = uint128(
            uint256(keccak256(bytes.concat("EAT UUID\x00", bytes32(series))))
        );
        uint256 id = (uint256(uuid) << 128) |
            (uint256(registry) << 96) |
            (uint256(vintage) << 56);
        bytes memory metadata = abi.encode(
            uint8(1),
            uuid,
            registry,
            vintage,
            techType,
            certificateType,
            endorsement
        );
        return (id, metadata);
    }
}
