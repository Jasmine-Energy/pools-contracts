import { ethers, upgrades, getNamedAccounts } from "hardhat";
import { Contracts, Libraries } from "@/utils";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import {
  createAnyTechAnnualPolicy,
  createSolarPolicy,
  createWindPolicy,
  makeMintFunction,
  mintFunctionType,
} from "./utilities";
import {
  JasminePool, JasmineRetirementService,
  JasmineEAT, JasmineOracle, JasmineMinter, JasminePoolFactory, 
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
  const { deployer } = await getNamedAccounts();
  const deployerSigner = await ethers.getSigner(deployer);
  const PolicyLib = await ethers.getContractFactory(Libraries.poolPolicy, deployerSigner);
  const CalldataLib = await ethers.getContractFactory(Libraries.calldata, deployerSigner);
  const ArrayUtilsLib = await ethers.getContractFactory(Libraries.arrayUtils, deployerSigner);
  const policyLib = await PolicyLib.deploy();
  const calldataLib = await CalldataLib.deploy();
  const arrayUtilsLib = await ArrayUtilsLib.deploy();
  return {
    policyLibAddress: policyLib.address,
    calldataLibAddress: calldataLib.address,
    arrayUtilsLibAddress: arrayUtilsLib.address,
  };
}

export async function deployRetirementService() {
  const { deployer } = await getNamedAccounts();
  const deployerSigner = await ethers.getSigner(deployer);
  const { eat, minter } = await loadFixture(deployCoreFixture);
  const { calldataLibAddress, arrayUtilsLibAddress } = await loadFixture(
    deployLibrariesFixture
  );

  const RetirementService = await ethers.getContractFactory(Contracts.retirementService, {
    libraries: {
      Calldata: calldataLibAddress,
      ArrayUtils: arrayUtilsLibAddress,
    },
    signer: deployerSigner,
  });
  const retirementService = await RetirementService.deploy(
    minter.address,
    eat.address,
  );
  return retirementService as JasmineRetirementService;
}

export async function deployPoolImplementation() {
  const { eat, oracle } = await loadFixture(deployCoreFixture);
  const { policyLibAddress, arrayUtilsLibAddress, calldataLibAddress } = await loadFixture(
    deployLibrariesFixture
  );
  const retirementService = await loadFixture(deployRetirementService);
  const { deployer } = await getNamedAccounts();
  const deployerSigner = await ethers.getSigner(deployer);

  const deployerNonce = await deployerSigner.getTransactionCount();
  const poolFactoryFutureAddress = ethers.utils.getContractAddress({
    from: deployerSigner.address,
    nonce: deployerNonce + 1,
  });

  const Pool = await ethers.getContractFactory(Contracts.pool, {
    libraries: {
      PoolPolicy: policyLibAddress,
      ArrayUtils: arrayUtilsLibAddress,
      Calldata: calldataLibAddress,
    },
    signer: deployerSigner,
  });
  const poolImplementation = await Pool.deploy(
    eat.address,
    oracle.address,
    poolFactoryFutureAddress,
    retirementService.address
  );
  return poolImplementation as JasminePool;
}

export async function deployPoolFactory() {
  const { owner, deployer, feeBeneficiary, uniswapPoolFactory, USDC } = await getNamedAccounts();
  const deployerSigner = await ethers.getSigner(deployer);
  const ownerSigner = await ethers.getSigner(owner);
  const poolImplementation = await loadFixture(deployPoolImplementation);

  const PoolFactory = await ethers.getContractFactory(Contracts.factory, deployerSigner);

  const poolFactory = await PoolFactory.deploy(
    owner,
    poolImplementation.address,
    feeBeneficiary,
    uniswapPoolFactory,
    USDC,
    "https://api.jasmine.energy/v1/pools/",
  );

  return poolFactory.connect(ownerSigner) as JasminePoolFactory;
}

export async function deployPoolsFixture() {
  const { owner } = await getNamedAccounts();
  const ownerSigner = await ethers.getSigner(owner);

  const { policyLibAddress, arrayUtilsLibAddress, calldataLibAddress } = await loadFixture(
    deployLibrariesFixture
  );
  const Pool = await ethers.getContractFactory(Contracts.pool, {
    libraries: {
      PoolPolicy: policyLibAddress,
      ArrayUtils: arrayUtilsLibAddress,
      Calldata: calldataLibAddress,
    },
    signer: ownerSigner,
  });
  const poolFactory = await loadFixture(deployPoolFactory);

  await poolFactory.deployNewBasePool(
    createSolarPolicy(),
    "Solar Tech",
    "sJLT"
  );
  const solarPoolAddress = await poolFactory.getPoolAtIndex(0);

  await poolFactory.deployNewBasePool(
    createWindPolicy(),
    "Wind Tech",
    "wJLT"
  );
  const windPoolAddress = await poolFactory.getPoolAtIndex(1);

  await poolFactory.deployNewBasePool(
    createAnyTechAnnualPolicy(),
    "Any Tech '23",
    "a23JLT"
  );
  const anyTechPoolAddress = await poolFactory.getPoolAtIndex(2);

  return {
    solarPool: Pool.attach(solarPoolAddress) as JasminePool,
    windPool: Pool.attach(windPoolAddress) as JasminePool,
    anyTechAnnualPool: Pool.attach(anyTechPoolAddress) as JasminePool,
  };
}
