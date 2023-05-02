import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contracts } from "@/utils";
import { JasminePool, JasminePoolFactory } from "@/typechain";
import { deployPoolImplementation } from "./shared/fixtures";

import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { disableLogging } from "@/utils/hardhat_utils";
import { DEFAULT_ADMIN_ROLE, FEE_MANAGER_ROLE } from "@/utils/constants";

describe(Contracts.uniswap.pool, function () {
  let owner: SignerWithAddress;
  let bridge: SignerWithAddress;
  let feeBeneficiary: SignerWithAddress;
  let accounts: SignerWithAddress[];

  let USDC: string;
  let uniswapPoolFactory: string;

  let poolFactory: JasminePoolFactory;
  let poolImplementation: JasminePool;

  before(async function () {
    await disableLogging();
  });

  before(async function () {
    poolImplementation = await loadFixture(deployPoolImplementation);

    const namedAccounts = await getNamedAccounts();
    owner = await ethers.getSigner(namedAccounts.owner);
    bridge = await ethers.getSigner(namedAccounts.bridge);
    feeBeneficiary = await ethers.getSigner(namedAccounts.feeBeneficiary);
    accounts = await ethers.getSigners();
    USDC = namedAccounts.USDC;
    uniswapPoolFactory = namedAccounts.uniswapPoolFactory;

    const PoolFactory = await ethers.getContractFactory(Contracts.factory);
    poolFactory = (await PoolFactory.deploy(
      poolImplementation.address,
      feeBeneficiary.address,
      uniswapPoolFactory,
      USDC
    )) as JasminePoolFactory;
  });

  describe("Setup", async function () {
    
  });

  describe("Pool Deployment", async function () {
    
  });

  describe("Liquidity management", async function () {
    
  });

  describe("Conversions", async function () {
    
  });
});
