import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contracts } from "@/utils";
import { DEFAULT_DECIMAL } from "@/utils/constants";
import {
  JasminePool,
  JasminePoolFactory,
  JasmineEAT,
  JasmineOracle,
  JasmineMinter,
} from "@/typechain";
import {
  deployPoolImplementation,
  deployCoreFixture,
  deployPoolFactory,
  deployPoolsFixture,
} from "./shared/fixtures";

import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { disableLogging } from "@/utils/hardhat_utils";
import { makeMintFunction, mintFunctionType } from "./shared/utilities";
import {
  FuelType,
  CertificateRegistry,
} from "@/types/energy-certificate.types";

describe(Contracts.pool, function () {
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

    poolFactory = await loadFixture(deployPoolFactory);
  });

  beforeEach(async function () {
    const testPools = await loadFixture(deployPoolsFixture);
    solarPool = testPools.solarPool;
    windPool = testPools.windPool;
    anyTechAnnualPool = testPools.anyTechAnnualPool;
  });

  describe("Setup", async function () {
    describe("Initializer", async function () {
      it("Should revert if initialize is called by non factory", async function () {
        await expect(
          poolImplementation.connect(owner).initialize([], "Pool Name", "JLT")
        ).to.be.reverted;
      });

      it("Should revert if initialize is called more than once", async function () {
        await expect(
          solarPool.initialize([], "New Name", "JLT2.0")
        ).to.be.revertedWith("Initializable: contract is already initialized");
      });
    });
    describe("State", async function () {
      it("Should have constants set", async function () {
        expect(await poolImplementation.decimals()).to.be.eq(DEFAULT_DECIMAL);
        expect(await poolImplementation.name()).to.be.empty;
        expect(await poolImplementation.symbol()).to.be.empty;

        expect(await poolImplementation.eat()).to.be.eq(eat.address);
        expect(await poolImplementation.oracle()).to.be.eq(oracle.address);
        expect(await poolImplementation.poolFactory()).to.be.eq(
          poolFactory.address
        );
      });
    });
  });

  describe("Deposit", async function () {
    var ownerTokens = {
      solarToken: { id: BigInt(0), amount: BigInt(0) },
      windToken: { id: BigInt(0), amount: BigInt(0) },
    };
    var userTokens = {
      solarToken: { id: BigInt(0), amount: BigInt(0) },
      windToken: { id: BigInt(0), amount: BigInt(0) },
    };

    beforeEach(async function () {
      ownerTokens.solarToken = await mintEat(owner.address, 5, FuelType.SOLAR);
      ownerTokens.windToken = await mintEat(owner.address, 5, FuelType.WIND);

      userTokens.solarToken = await mintEat(
        accounts[1].address,
        5,
        FuelType.SOLAR
      );
      userTokens.windToken = await mintEat(
        accounts[1].address,
        5,
        FuelType.WIND
      );
    });

    describe("#deposit", async function () {
      it("Should allow deposit of eligible tokens", async function () {});

      it("Should reject ineligible tokens", async function () {});
    });

    describe("#operatorDeposit", async function () {});

    describe("#depositBatch", async function () {});

    describe("#onERC1155Received", async function () {
      it("Should allow deposit of eligible tokens", async function () {
        expect(
          await eat.safeTransferFrom(
            owner.address,
            windPool.address,
            ownerTokens.windToken.id,
            ownerTokens.windToken.amount,
            []
          )
        )
          .to.be.ok.and.to.emit(poolImplementation, "Deposit")
          .withArgs(owner.address, owner.address, ownerTokens.windToken.amount)
          .and.to.emit(poolImplementation, "Minted")
          .withArgs(
            owner.address,
            owner.address,
            ownerTokens.windToken.amount,
            [],
            []
          )
          .and.to.emit(poolImplementation, "Transfer")
          .withArgs(owner.address, owner.address, ownerTokens.windToken.amount)
          .and.to.changeTokenBalance(
            windPool,
            owner.address,
            ownerTokens.windToken.amount
          );

        expect(
          await eat.balanceOf(owner.address, ownerTokens.windToken.id)
        ).to.be.eq(0);
      });

      it("Should reject ineligible tokens", async function () {
        const initalJltBal = await windPool.balanceOf(owner.address);
        const initalEATtBal = await eat.balanceOf(
          owner.address,
          ownerTokens.solarToken.id
        );
        await expect(
          eat.safeTransferFrom(
            owner.address,
            windPool.address,
            ownerTokens.solarToken.id,
            ownerTokens.solarToken.amount,
            []
          )
        ).to.be.revertedWith(
          "ERC1155: transfer to non-ERC1155Receiver implementer"
        );

        expect(await windPool.balanceOf(owner.address)).to.be.eq(initalJltBal);
        expect(
          await eat.balanceOf(owner.address, ownerTokens.windToken.id)
        ).to.be.eq(initalEATtBal);
      });

      it("Should reject tokens deposited to implementation contract", async function () {
        await expect(
          eat.safeTransferFrom(
            owner.address,
            poolImplementation.address,
            ownerTokens.solarToken.id,
            ownerTokens.solarToken.amount,
            []
          )
        ).to.be.revertedWith(
          "ERC1155: transfer to non-ERC1155Receiver implementer"
        );
      });
    });

    describe("#onERC1155BatchReceived", async function () {
      it("Should allow deposit of eligible tokens", async function () {
        const initalJltBal = await anyTechAnnualPool.balanceOf(owner.address);
        const initalEatBal = await eat.balanceOfBatch(
          [owner.address, owner.address],
          [ownerTokens.solarToken.id, ownerTokens.windToken.id]
        );
        expect(
          await eat.safeBatchTransferFrom(
            owner.address,
            anyTechAnnualPool.address,
            [ownerTokens.solarToken.id, ownerTokens.windToken.id],
            [ownerTokens.solarToken.amount, ownerTokens.windToken.amount],
            []
          )
        )
          .to.be.ok.and.to.emit(poolImplementation, "Deposit")
          .withArgs(
            owner.address,
            owner.address,
            ownerTokens.solarToken.amount + ownerTokens.windToken.amount
          )
          .and.to.emit(poolImplementation, "Minted")
          .withArgs(
            owner.address,
            owner.address,
            ownerTokens.solarToken.amount + ownerTokens.windToken.amount,
            [],
            []
          )
          .and.to.emit(poolImplementation, "Transfer")
          .withArgs(
            owner.address,
            owner.address,
            ownerTokens.solarToken.amount + ownerTokens.windToken.amount
          )
          .and.to.changeTokenBalance(
            anyTechAnnualPool,
            owner.address,
            initalJltBal.toBigInt() +
              ownerTokens.solarToken.amount +
              ownerTokens.windToken.amount
          );

        expect(
          await eat.balanceOfBatch(
            [owner.address, owner.address],
            [ownerTokens.solarToken.id, ownerTokens.windToken.id]
          )
        ).to.deep.equal([
          initalEatBal[0].toBigInt() - ownerTokens.solarToken.amount,
          initalEatBal[1].toBigInt() - ownerTokens.windToken.amount,
        ]);
      });

      it("Should reject ineligible tokens", async function () {
        const initalJltBal = await windPool.balanceOf(owner.address);
        const initalEatBal = await eat.balanceOfBatch(
          [owner.address, owner.address],
          [ownerTokens.solarToken.id, ownerTokens.windToken.id]
        );
        await expect(
          eat.safeBatchTransferFrom(
            owner.address,
            windPool.address,
            [ownerTokens.solarToken.id, ownerTokens.windToken.id],
            [ownerTokens.solarToken.amount, ownerTokens.windToken.amount],
            []
          )
        ).to.be.revertedWith(
          "ERC1155: transfer to non-ERC1155Receiver implementer"
        );

        expect(await windPool.balanceOf(owner.address)).to.be.eq(initalJltBal);
        expect(
          await eat.balanceOfBatch(
            [owner.address, owner.address],
            [ownerTokens.solarToken.id, ownerTokens.windToken.id]
          )
        ).to.deep.equal(initalEatBal);
      });

      it("Should reject tokens deposited to implementation contract", async function () {
        await expect(
          eat.safeBatchTransferFrom(
            owner.address,
            poolImplementation.address,
            [ownerTokens.solarToken.id, ownerTokens.windToken.id],
            [ownerTokens.solarToken.amount, ownerTokens.windToken.amount],
            []
          )
        ).to.be.revertedWith(
          "ERC1155: transfer to non-ERC1155Receiver implementer"
        );
      });
    });
  });

  describe("Withdraw", async function () {
    let tokenId: bigint;
    let tokenAmount: bigint;

    beforeEach(async function () {
      const { id, amount } = await mintEat(owner.address, 5, FuelType.SOLAR);
      tokenId = id;
      tokenAmount = amount;
      await eat.safeTransferFrom(
        owner.address,
        anyTechAnnualPool.address,
        id,
        amount,
        []
      );
    });

    it("Should allow specific withdrawals", async function () {
      expect(
        await anyTechAnnualPool.withdrawSpecific(
          owner.address,
          owner.address,
          [tokenId],
          [tokenAmount],
          []
        )
      )
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Withdraw")
        .withArgs(owner.address, owner.address, tokenAmount);
    });

    it("Should allow any withdrawals", async function () {
      expect(await anyTechAnnualPool.withdraw(owner.address, tokenAmount, []))
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Withdraw")
        .withArgs(owner.address, owner.address, tokenAmount)
        .and.to.changeTokenBalance(
          anyTechAnnualPool,
          owner.address,
          -tokenAmount
        );
    });

    it("Should allow operator withdrawals", async function () {
      const operator = accounts[4];
      const operatorPool = anyTechAnnualPool.connect(operator);
      const ownerBalance = await anyTechAnnualPool.balanceOf(owner.address);

      expect(
        await anyTechAnnualPool.increaseAllowance(
          operator.address,
          ownerBalance
        )
      )
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Approval")
        .withArgs(owner.address, operator.address, ownerBalance);
      expect(
        await operatorPool.withdrawFrom(
          owner.address,
          operator.address,
          tokenAmount,
          []
        )
      )
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Withdraw")
        .withArgs(owner.address, operator.address, tokenAmount)
        .and.to.changeTokenBalance(
          anyTechAnnualPool,
          owner.address,
          -tokenAmount
        );
    });

    it("Should allow allowance withdrawals", async function () {
      const allowed = accounts[5];
      const allowedPool = anyTechAnnualPool.connect(allowed);
      const balance = await anyTechAnnualPool.balanceOf(owner.address);

      expect(await anyTechAnnualPool.approve(allowed.address, balance))
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Approval")
        .withArgs(owner.address, allowed.address, balance);
      expect(
        await allowedPool.withdrawFrom(
          owner.address,
          allowed.address,
          tokenAmount,
          []
        )
      )
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Withdraw")
        .withArgs(owner.address, allowed.address, tokenAmount - 1n);
    });

    it("Should correctly withdraw tokens by vintage", async function () {
      const vintage = new Date().valueOf();

      // @ts-ignore
      const firstToken = await mintEat(
        owner.address,
        5,
        FuelType.SOLAR,
        CertificateRegistry.NAR,
        vintage
      );
      // @ts-ignore
      const secondToken = await mintEat(
        owner.address,
        5,
        FuelType.WIND,
        CertificateRegistry.NAR,
        vintage
      );

      expect(
        await eat.safeBatchTransferFrom(
          owner.address,
          anyTechAnnualPool.address,
          [firstToken.id, secondToken.id],
          [firstToken.amount, secondToken.amount],
          []
        )
      ).to.be.ok;

      expect(
        await eat.balanceOfBatch(
          [owner.address, owner.address],
          [firstToken.id, secondToken.id]
        )
      ).to.deep.equal([0n, 0n]);
      expect(
        await eat.balanceOfBatch(
          [anyTechAnnualPool.address, anyTechAnnualPool.address],
          [firstToken.id, secondToken.id]
        )
      ).to.deep.equal([firstToken.amount, secondToken.amount]);

      expect(await anyTechAnnualPool.withdraw(owner.address, 5, [])).to.be.ok;
      expect(await anyTechAnnualPool.withdraw(owner.address, 5, [])).to.be.ok;
    });

    it("Should successfully withdraw multiple EATs if required", async function () {
      const extraToken = await mintEat(owner.address, 5, FuelType.SOLAR);
      expect(
        await eat.safeTransferFrom(
          owner.address,
          anyTechAnnualPool.address,
          extraToken.id,
          extraToken.amount,
          []
        )
      ).to.be.ok;

      expect(await anyTechAnnualPool.withdraw(owner.address, 10, [])).to.be.ok;
    });

    it("Should not have zero tokens sent in last token ID", async function () {
      const token1 = await mintEat(owner.address, 5, FuelType.SOLAR);
      await eat.safeTransferFrom(
        owner.address,
        anyTechAnnualPool.address,
        token1.id,
        token1.amount,
        []
      );
      const token2 = await mintEat(owner.address, 5, FuelType.WIND);
      await eat.safeTransferFrom(
        owner.address,
        anyTechAnnualPool.address,
        token2.id,
        token2.amount,
        []
      );

      expect(
        await anyTechAnnualPool.withdraw(owner.address, 1, [])
      ).to.be.ok.and.to.emit(anyTechAnnualPool, "Withdraw");

      expect(
        await anyTechAnnualPool.withdrawSpecific(
          owner.address,
          owner.address,
          [token2.id],
          [token2.amount],
          []
        )
      ).to.be.ok;

      expect(
        await anyTechAnnualPool.withdraw(owner.address, 9, [])
      ).to.be.ok.and.to.emit(anyTechAnnualPool, "Withdraw");
    });

    it("Should successfully remove token via withdraw any when prior tx interacts with same token but expects it to be kept", async function () {
      const token1 = await mintEat(owner.address, 5, FuelType.SOLAR);
      await eat.safeTransferFrom(
        owner.address,
        anyTechAnnualPool.address,
        token1.id,
        token1.amount,
        []
      );
      const token2 = await mintEat(owner.address, 5, FuelType.WIND);
      await eat.safeTransferFrom(
        owner.address,
        anyTechAnnualPool.address,
        token2.id,
        token2.amount,
        []
      );

      expect(
        await anyTechAnnualPool.withdraw(owner.address, tokenAmount + 9n, [])
      ).to.be.ok.and.to.emit(anyTechAnnualPool, "Withdraw");

      expect(
        await anyTechAnnualPool.withdraw(owner.address, 1, [])
      ).to.be.ok.and.to.emit(anyTechAnnualPool, "Withdraw");
    });
  });

  describe("Retire", async function () {
    let tokenId: bigint;
    let tokenAmount: bigint;

    beforeEach(async function () {
      const { id, amount } = await mintEat(owner.address, 5, FuelType.SOLAR);
      tokenId = id;
      tokenAmount = amount;
      await eat.safeTransferFrom(
        owner.address,
        anyTechAnnualPool.address,
        id,
        amount,
        []
      );
    });

    it("Should allow retire exact", async function () {
      expect(
        await anyTechAnnualPool.retireExact(
          owner.address,
          owner.address,
          tokenAmount,
          []
        )
      ).to.be.ok.and.to.emit(anyTechAnnualPool, "Retirement");
    });

    it("Should retire accrued fractions", async function () {
      const retirementAmount = 25n * 10n ** (DEFAULT_DECIMAL - 1n);
      expect(
        await anyTechAnnualPool.retireExact(
          owner.address,
          owner.address,
          retirementAmount,
          []
        )
      )
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Retirement")
        .withArgs(owner.address, owner.address, retirementAmount);
      expect(
        await anyTechAnnualPool.retireExact(
          owner.address,
          owner.address,
          retirementAmount,
          []
        )
      )
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Retirement")
        .withArgs(owner.address, owner.address, retirementAmount);
    });

    it("Should retire accrued fractions across multiple token IDs", async function () {
      const retirementAmount = 25n * 10n ** (DEFAULT_DECIMAL - 1n);
      const { id, amount } = await mintEat(owner.address, 5, FuelType.SOLAR);
      await eat.safeTransferFrom(
        owner.address,
        anyTechAnnualPool.address,
        id,
        amount,
        []
      );
      expect(
        await anyTechAnnualPool.retireExact(
          owner.address,
          owner.address,
          retirementAmount,
          []
        )
      )
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Retirement")
        .withArgs(owner.address, owner.address, retirementAmount);
      expect(
        await anyTechAnnualPool.retireExact(
          owner.address,
          owner.address,
          75n * 10n ** (DEFAULT_DECIMAL - 1n),
          []
        )
      )
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Retirement")
        .withArgs(
          owner.address,
          owner.address,
          75n * 10n ** (DEFAULT_DECIMAL - 1n)
        );
    });

    it("Should support retiring numerous token IDs", async function () {
      const windDeposit = await mintEat(owner.address, 5, FuelType.WIND);
      await eat.safeTransferFrom(
        owner.address,
        anyTechAnnualPool.address,
        windDeposit.id,
        windDeposit.amount,
        []
      );

      expect(
        await anyTechAnnualPool.retireExact(
          owner.address,
          owner.address,
          tokenAmount + windDeposit.amount,
          []
        )
      ).to.be.ok.and.to.emit(anyTechAnnualPool, "Retirement");
    });

    it("Should support retiring numerous token IDs with fractional", async function () {
      const initialRetirementAmount = 35n * 10n ** (DEFAULT_DECIMAL - 1n);
      expect(
        await anyTechAnnualPool.retireExact(
          owner.address,
          owner.address,
          initialRetirementAmount,
          []
        )
      )
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Retirement")
        .withArgs(owner.address, owner.address, initialRetirementAmount)
        .and.to.emit(eat, "TransferSingle")
        .withArgs(
          owner.address,
          owner.address,
          anyValue,
          tokenId,
          initialRetirementAmount
        );

      const windDeposit = await mintEat(owner.address, 5, FuelType.WIND);
      const geoDeposit = await mintEat(owner.address, 10, FuelType.GEOTHERMAL);
      const bioDeposit = await mintEat(owner.address, 15, FuelType.BIOMASS);
      await eat.safeBatchTransferFrom(
        owner.address,
        anyTechAnnualPool.address,
        [windDeposit.id, geoDeposit.id, bioDeposit.id],
        [windDeposit.amount, geoDeposit.amount, bioDeposit.amount],
        []
      );

      const balance = await anyTechAnnualPool.balanceOf(owner.address);
      expect(
        await anyTechAnnualPool.retireExact(
          owner.address,
          owner.address,
          balance,
          []
        )
      )
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Retirement")
        .withArgs(owner.address, owner.address, balance)
        .and.to.emit(eat, "TransferBatch")
        .withArgs(
          owner.address,
          owner.address,
          anyValue,
          [tokenId, windDeposit.id, geoDeposit.id, bioDeposit.id],
          [2, windDeposit.amount, geoDeposit.amount, bioDeposit.amount]
        );
    });
  });

  describe("Metadata", async function () {
    it("Should have name set", async function () {
      expect(await solarPool.name()).to.be.eq("Solar Tech");
    });

    it("Should have symbol set", async function () {
      expect(await solarPool.symbol()).to.be.eq("sJLT");
    });

    it("Should have decimals set", async function () {
      expect(await solarPool.decimals()).to.be.eq(DEFAULT_DECIMAL);
    });

    it("Should have total supply set", async function () {
      const tokens = await mintEat(owner.address, 5, FuelType.SOLAR);
      await eat.safeTransferFrom(
        owner.address,
        solarPool.address,
        tokens.id,
        tokens.amount,
        []
      );

      expect(await solarPool.totalSupply()).to.exist.and.to.not.be.eq(
        0
      ).and.to.not.be.undefined;
    });

    it("Should correctly return tokenURI", async function () {
      const baseURI = await poolFactory.poolsBaseURI();
      const solarSymbol = await solarPool.symbol();
      expect(await solarPool.tokenURI()).to.be.eq(baseURI.concat(solarSymbol));
    });
  });

  describe("Invalidated Deposits", async function () {
    let frozenTokenId: bigint;
    let unfrozenTokenId: bigint;

    beforeEach(async function () {
      const token1 = await mintEat(owner.address, 5, FuelType.SOLAR);
      frozenTokenId = token1.id;
      await eat.safeTransferFrom(
        owner.address,
        anyTechAnnualPool.address,
        token1.id,
        token1.amount,
        []
      );
      const token2 = await mintEat(owner.address, 5, FuelType.WIND);
      unfrozenTokenId = token2.id;
      await eat.safeTransferFrom(
        owner.address,
        anyTechAnnualPool.address,
        token2.id,
        token2.amount,
        []
      );

      await eat.freeze(frozenTokenId);
    });

    it("Should allow withdrawals with frozen tokens in the pool", async function () {
      expect(
        await anyTechAnnualPool.validateDepositValidity(frozenTokenId)
      ).to.be.ok;

      expect(await anyTechAnnualPool.withdraw(owner.address, 1, []))
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Withdraw")
        .and.to.emit(anyTechAnnualPool, "TransferSingle")
        .withArgs(
          owner.address,
          owner.address,
          anyValue,
          unfrozenTokenId,
          anyValue
        );
    });

    it("Should prohibit withdrawals with of frozen tokens in the pool", async function () {
      expect(
        await anyTechAnnualPool.validateDepositValidity(frozenTokenId)
      ).to.be.ok;

      await expect(
        anyTechAnnualPool.withdrawSpecific(
          owner.address,
          owner.address,
          [frozenTokenId],
          [1],
          []
        )
      )
        .to.be.revertedWithCustomError(anyTechAnnualPool, "WithdrawBlocked")
        .withArgs(frozenTokenId);
    });

    it("Should allow withdrawals after a deposit is unfrozen", async function () {
      expect(await eat.thaw(frozenTokenId)).to.be.ok;
      expect(
        await anyTechAnnualPool.validateDepositValidity(frozenTokenId)
      ).to.be.ok;

      expect(await anyTechAnnualPool.withdraw(owner.address, 10, []))
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Withdraw")
        .and.to.emit(anyTechAnnualPool, "TransferBatch")
        .withArgs(
          owner.address,
          owner.address,
          anyValue,
          [frozenTokenId, unfrozenTokenId],
          anyValue
        );
    });

    it("Should allow burn JLT from caller is deposit becomes burned by owner", async function () {
      expect(
        await eat.slash(anyTechAnnualPool.address, frozenTokenId, 5)
      ).to.be.ok;
      expect(await anyTechAnnualPool.validateDepositValidity(frozenTokenId))
        .to.be.ok.and.to.emit(anyTechAnnualPool, "Transfer")
        .withArgs(
          anyTechAnnualPool.address,
          ethers.constants.AddressZero,
          anyValue
        )
        .and.to.emit(anyTechAnnualPool, "TransferSingle")
        .withArgs(
          anyTechAnnualPool.address,
          ethers.constants.AddressZero,
          anyValue,
          frozenTokenId,
          anyValue
        );
    });
  });
});
