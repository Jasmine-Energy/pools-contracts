import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import {
  JasminePool,
  JasminePoolFactory,
  JasmineEAT,
  JasmineOracle,
  JasmineMinter,
} from "@/typechain";
import { deployPoolsFixture, deployCoreFixture, deployPoolFactory } from "./shared/fixtures";

import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { disableLogging } from "@/utils/hardhat_utils";
import {
  makeMintFunction,
  mintFunctionType,
} from "./shared/utilities";
import { FuelType } from "@/types";
import { DEFAULT_DECIMAL_MULTIPLE } from "@/utils/constants";


describe("Fee Pool", function () {
  let owner: SignerWithAddress;
  let bridge: SignerWithAddress;
  let feeBeneficiary: SignerWithAddress;
  let accounts: SignerWithAddress[];

  let eat: JasmineEAT;
  let oracle: JasmineOracle;
  let minter: JasmineMinter;

  let mintEat: mintFunctionType;

  let poolFactory: JasminePoolFactory;
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
    feeBeneficiary = await ethers.getSigner(namedAccounts.feeBeneficiary);
    accounts = await ethers.getSigners();

    const coreContract = await loadFixture(deployCoreFixture);
    eat = coreContract.eat;
    minter = coreContract.minter;
    oracle = coreContract.oracle;

    mintEat = makeMintFunction(minter);

    poolFactory = await loadFixture(deployPoolFactory);
  });

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
        .withArgs(500, await poolFactory.feeBeneficiary(), false);
    });

    it("Should allow fee manager to set a base specific withdrawal fee", async function () {
        await poolFactory.setBaseWithdrawalRate(500);
        expect(await poolFactory.setBaseWithdrawalSpecificRate(550))
          .to.be.ok.and.to.emit(poolFactory, "BaseWithdrawalFeeUpdate")
          .withArgs(550, await poolFactory.feeBeneficiary(), true);
    });

    it("Should revert if base specific withdrawal fee is set to be less than any withdrawal rate", async function () {
        await poolFactory.setBaseWithdrawalRate(500);
        await expect(poolFactory.setBaseWithdrawalSpecificRate(100)).to.be.revertedWithCustomError(
            poolFactory, "InvalidInput"
        );
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
    it("Should allow fee manager to set a pool's any withdrawal fee", async function () {
      const withdrawalRate = 1_000;
      expect(await solarPool.updateWithdrawalRate(withdrawalRate, false))
        .to.be.ok.and.to.emit(poolFactory, "WithdrawalRateUpdate")
        .withArgs(withdrawalRate, await poolFactory.feeBeneficiary(), false);
    });

    it("Should allow fee manager to set a pool's specific withdrawal fee", async function () {
      const withdrawalRate = 1_000;
      expect(await solarPool.updateWithdrawalRate(withdrawalRate, true))
        .to.be.ok.and.to.emit(poolFactory, "WithdrawalRateUpdate")
        .withArgs(withdrawalRate, await poolFactory.feeBeneficiary(), true);
    });

    it("Should allow fee manager to set a pool's retirement fee", async function () {
      const retirementRate = 1_000;
      expect(await solarPool.updateRetirementRate(retirementRate))
        .to.be.ok.and.to.emit(poolFactory, "RetirementRateUpdate")
        .withArgs(1_000, await poolFactory.feeBeneficiary());
    });
  });

  describe("Paying Pool Fees", async function () {
    const baseWithdrawalRate = 500n;
    const baseWithdrawalSpecificRate = 550n;
    const baseRetirementRate = 125n;
    var solarTokens: { id: bigint; amount: bigint; };

    beforeEach(async function () {
        await poolFactory.setFeeBeneficiary(feeBeneficiary.address);
        await poolFactory.setBaseWithdrawalRate(baseWithdrawalRate);
        await poolFactory.setBaseWithdrawalSpecificRate(baseWithdrawalSpecificRate);
        await poolFactory.setBaseRetirementRate(baseRetirementRate);

        solarTokens = await mintEat(owner.address, 10_000, FuelType.SOLAR);
        await eat.safeTransferFrom(owner.address, solarPool.address, solarTokens.id, solarTokens.amount, []);
    });

    describe("Withdrawal Fees", async function () {
      it("Should take withdrawal fees if set", async function () {
        const withdrawAmount = 1_000n;
        expect(await solarPool.withdraw(owner.address, withdrawAmount, [])).to.be.ok
          .and.to.changeTokenBalance(solarPool, owner.address,  withdrawAmount * ((10_000n + baseWithdrawalRate) / 10_000n) * DEFAULT_DECIMAL_MULTIPLE)
          .and.to.changeTokenBalance(solarPool, feeBeneficiary, withdrawAmount * (baseWithdrawalRate / 10_000n) * DEFAULT_DECIMAL_MULTIPLE);
      });

      it("Should take specific withdrawal fees if set", async function () {
          const withdrawAmount = 1_000n;
          expect(await solarPool.withdrawSpecific(owner.address, owner.address, [solarTokens.id], [withdrawAmount], [])).to.be.ok
            .and.to.changeTokenBalance(solarPool, owner.address,  withdrawAmount * ((10_000n + baseWithdrawalSpecificRate) / 10_000n) * DEFAULT_DECIMAL_MULTIPLE)
            .and.to.changeTokenBalance(solarPool, feeBeneficiary, withdrawAmount * (baseWithdrawalSpecificRate / 10_000n) * DEFAULT_DECIMAL_MULTIPLE);
        });
    });

    describe("Retirement Fees", async function () {
      it("Should take retirement fees if set", async function () {
        const retirementAmount = 1_000n;
        expect(await solarPool.retire(owner.address, owner.address, retirementAmount, [])).to.be.ok
          .and.to.changeTokenBalance(solarPool, owner.address,  retirementAmount * ((10_000n + baseRetirementRate) / 10_000n) * DEFAULT_DECIMAL_MULTIPLE)
          .and.to.changeTokenBalance(solarPool, feeBeneficiary, retirementAmount * (baseRetirementRate / 10_000n) * DEFAULT_DECIMAL_MULTIPLE);
      });

      it("Should add retirement fees as excess if using retire exact", async function () {
        const retirementAmount = 1_000n;
        expect(await solarPool.retireExact(owner.address, owner.address, retirementAmount, [])).to.be.ok
          .and.to.changeTokenBalance(solarPool, owner.address,  retirementAmount * DEFAULT_DECIMAL_MULTIPLE)
          .and.to.changeTokenBalance(solarPool, feeBeneficiary.address, retirementAmount * (baseRetirementRate / 10_000n) * DEFAULT_DECIMAL_MULTIPLE);
      });
    });
  });
});
