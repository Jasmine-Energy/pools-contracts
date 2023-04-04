import { ethers, upgrades, getNamedAccounts } from "hardhat";
import { Contracts, Libraries } from "@/utils";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import {
  JasminePool,
  JasmineEAT, JasmineOracle, JasmineMinter,
} from "@/typechain";


export async function deployCoreFixture() {
  const EAT = await ethers.getContractFactory(Contracts.eat);
  const Oracle = await ethers.getContractFactory(Contracts.oracle);
  const Minter = await ethers.getContractFactory(Contracts.minter);

  const namedAccounts = await getNamedAccounts();
  const owner = await ethers.getSigner(namedAccounts.owner);
  const bridge = await ethers.getSigner(namedAccounts.bridge);

  const tokenURI = "https://api.jasmine.energy/v1/eat/{id}.json";
  const ownerNonce = await owner.getTransactionCount();
  const futureMinterAddress = ethers.utils.getContractAddress({
    from: owner.address,
    nonce: ownerNonce + 5,
  });

  const eat = (await upgrades.deployProxy(
    EAT,
    [
      tokenURI,             // initialURI
      futureMinterAddress,  // initialMinter
      owner.address,        // initialOwner
    ],
    {
      kind: "uups",
    }
  )) as JasmineEAT;
  await eat.deployed();

  const oracle = (await upgrades.deployProxy(
    Oracle,
    [
      futureMinterAddress, // initialMinter
      owner.address,       // initialOwner
    ],
    {
      kind: "uups",
    }
  )) as JasmineOracle;
  await oracle.deployed();

  const minter = (await upgrades.deployProxy(
    Minter,
    [Contracts.minter, "1", bridge.address, owner.address],
    {
      unsafeAllow: ["constructor", "state-variable-immutable"],
      constructorArgs: [eat.address, oracle.address],
      kind: "uups",
    }
  )) as JasmineMinter;
  await minter.deployed();

  return { eat, oracle, minter };
}

export async function deployLibrariesFixture() {
  const PolicyLib = await ethers.getContractFactory(Libraries.poolPolicy);
  const CalldataLib = await ethers.getContractFactory(Libraries.calldata);
  const ArrayUtilsLib = await ethers.getContractFactory(Libraries.arrayUtils);
  const policyLib = await PolicyLib.deploy();
  const calldataLib = await CalldataLib.deploy();
  const arrayUtilsLib = await ArrayUtilsLib.deploy();
  return {
    policyLibAddress: policyLib.address,
    calldataLibAddress: calldataLib.address,
    arrayUtilsLibAddress: arrayUtilsLib.address,
  };
}

export async function deployPoolImplementation() {
  const { eat, oracle } = await loadFixture(deployCoreFixture);
  const { policyLibAddress, arrayUtilsLibAddress } = await loadFixture(
    deployLibrariesFixture
  );
  const namedAccounts = await getNamedAccounts();
  const owner = await ethers.getSigner(namedAccounts.owner);

  const ownerNonce = await owner.getTransactionCount();
  const poolFactoryFutureAddress = ethers.utils.getContractAddress({
    from: owner.address,
    nonce: ownerNonce + 1,
  });

  const Pool = await ethers.getContractFactory(Contracts.pool, {
    libraries: {
      PoolPolicy: policyLibAddress,
      ArrayUtils: arrayUtilsLibAddress,
    },
  });
  const poolImplementation = (await Pool.deploy(
    eat.address,
    oracle.address,
    poolFactoryFutureAddress
  )) as JasminePool;
  return { poolImplementation };
}
