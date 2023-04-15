import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contracts } from "@/utils";
import {
  JasminePool,
  JasminePoolFactory,
  JasmineEAT,
  JasmineOracle,
  JasmineMinter,
} from "@/typechain";
import { deployPoolImplementation, deployCoreFixture } from "./shared/fixtures";

import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { disableLogging } from "@/utils/hardhat_utils";
import {
  createAnyTechAnnualPolicy,
  createSolarPolicy,
  createWindPolicy,
  makeMintFunction,
  mintFunctionType,
} from "./shared/utilities";
import {
  CertificateEndorsement,
  CertificateRegistry,
  EnergyCertificateType,
  FuelType,
} from "@/types/energy-certificate.types";

describe("Fee Pool", function () {
  let owner: SignerWithAddress;
  let bridge: SignerWithAddress;
  let accounts: SignerWithAddress[];

  let eat: JasmineEAT;
  let oracle: JasmineOracle;
  let minter: JasmineMinter;

  let mintEat: mintFunctionType;

  let poolFactory: JasminePoolFactory;
  let poolImplementation: JasminePool;
  let anyTechAnnualPool: JasminePool;
  let solarPool: JasminePool;
  let windPool: JasminePool;

  before(async function () {
    await disableLogging();
  });

  before(async function () {
    const namedAccounts = await getNamedAccounts();
    owner = await ethers.getSigner(namedAccounts.owner);
    bridge = await ethers.getSigner(namedAccounts.bridge);
    accounts = await ethers.getSigners();

    const coreContract = await loadFixture(deployCoreFixture);
    eat = coreContract.eat;
    minter = coreContract.minter;
    oracle = coreContract.oracle;

    mintEat = makeMintFunction(minter);

    poolImplementation = await loadFixture(deployPoolImplementation);

    const PoolFactory = await ethers.getContractFactory(Contracts.factory);
    // NOTE: This errors when no deployment folder's been created
    // TODO: Fix above requirement of having deploy
    poolFactory = (await PoolFactory.deploy(
      poolImplementation.address,
      owner.address
    )) as JasminePoolFactory;
  });

  async function deployPoolsFixture() {
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
      solarPool: poolImplementation.attach(solarPoolAddress),
      windPool: poolImplementation.attach(windPoolAddress),
      anyTechAnnualPool: poolImplementation.attach(anyTechPoolAddress),
    };
  }

  beforeEach(async function () {
    const testPools = await loadFixture(deployPoolsFixture);
    solarPool = testPools.solarPool;
    windPool = testPools.windPool;
    anyTechAnnualPool = testPools.anyTechAnnualPool;
  });

  describe("Base Fees", async function () {
    it("Should allow fee manager to set a fee beneficiary", async function () {
      const newFeeBeneficiary = accounts[1].address;
      expect(await poolFactory.setFeeBeneficiary(newFeeBeneficiary))
        .to.be.ok.and.to.emit(poolFactory, "BaseWithdrawalFeeUpdate")
        .and.to.emit(poolFactory, "BaseRetirementFeeUpdate");
    });

    it("Should allow fee manager to set a base withdrawal fee", async function () {
      expect(await poolFactory.setBaseWithdrawalRate(500))
        .to.be.ok.and.to.emit(poolFactory, "BaseWithdrawalFeeUpdate")
        .withArgs(500, await poolFactory.feeBeneficiary());
    });

    it("Should allow fee manager to set a base retirement fee", async function () {
      expect(await poolFactory.setBaseRetirementRate(500))
        .to.be.ok.and.to.emit(poolFactory, "BaseRetirementFeeUpdate")
        .withArgs(500, await poolFactory.feeBeneficiary());
    });

    it("Should use base withdrawal rate for pool if none set", async function () {
      const withdrawalRate = 100;
      expect(await poolFactory.setBaseWithdrawalRate(withdrawalRate)).to.be.ok;
      expect(await solarPool.withdrawalRate()).to.be.eq(withdrawalRate);
    });

    it("Should use base retirement rate for pool if none set", async function () {
      const retirementRate = 100;
      expect(await poolFactory.setBaseRetirementRate(retirementRate)).to.be.ok;
      expect(await solarPool.retirementRate()).to.be.eq(retirementRate);
    });
  });

  describe("Setting Pool Fees", async function () {
    it("Should allow fee manager to set a pool's withdrawal fee", async function () {
      const withdrawalRate = 1_000;
      expect(await solarPool.updateWithdrawalRate(withdrawalRate))
        .to.be.ok.and.to.emit(poolFactory, "WithdrawalRateUpdate")
        .withArgs(withdrawalRate, await poolFactory.feeBeneficiary());
    });

    it("Should allow fee manager to set a pool's retirement fee", async function () {
      const retirementRate = 1_000;
      expect(await solarPool.updateRetirementRate(retirementRate))
        .to.be.ok.and.to.emit(poolFactory, "RetirementRateUpdate")
        .withArgs(1_000, await poolFactory.feeBeneficiary());
    });
  });

  describe("Paying Pool Fees", async function () {
    it("Should take withdrawal fees if set", async function () {
      // TODO
    });

    it("Should take retirement fees if set", async function () {
      // TODO
    });
  });
});
