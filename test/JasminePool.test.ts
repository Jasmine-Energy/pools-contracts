import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contracts } from "@/utils";
import { 
    JasminePool, JasminePoolFactory, 
    JasmineEAT, JasmineOracle, JasmineMinter
} from "@/typechain";
import { deployPoolImplementation, deployCoreFixture, deployLibrariesFixture } from "./shared/fixtures";

import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { disableLogging } from "@/utils/hardhat_utils";
import { mintEat } from "./shared/utilities";


describe(Contracts.pool, function () {
    let owner: SignerWithAddress;
    let bridge: SignerWithAddress;
    let accounts: SignerWithAddress[];
    
    let poolFactory: JasminePoolFactory;
    let poolImplementation: JasminePool;
    var pool: JasminePool;

    before(async function() {
        await disableLogging();
    });

    before(async function() {
        const namedAccounts = await getNamedAccounts();
        owner = await ethers.getSigner(namedAccounts.owner);
        bridge = await ethers.getSigner(namedAccounts.bridge);
        accounts = await ethers.getSigners();

        poolImplementation = (await loadFixture(deployPoolImplementation)).poolImplementation;

        const PoolFactory = await ethers.getContractFactory(Contracts.factory);
        // NOTE: This errors when no deployment folder's been created
        // TODO: Fix above requirement of having deploy
        poolFactory = (await PoolFactory.deploy(poolImplementation.address)) as JasminePoolFactory;
    });

    beforeEach(async function () {
        // TODO: Create new pool from factory
        // poolFactory.deployNewPool();
    });

    describe("Setup", async function () {
        it("Should revert if initialize is called by non factory", async function() {
            await expect(poolImplementation.connect(owner).initialize([], "Pool Name", "JLT")).to.be.revertedWithCustomError(
                poolImplementation, "Prohibited"
            );
        });

        it("Should have constants set", async function() {
            expect(await poolImplementation.decimals()).to.be.eq(9);
            expect(await poolImplementation.name()).to.be.empty;
            expect(await poolImplementation.symbol()).to.be.empty;
        });
    });

    describe("Access Control", async function () {
        // TODO
    });

    describe("Deposit", async function () {
        describe("#deposit", async function () {
            it("Should allow deposit of eligible tokens", async function() {
                await mintEat(owner.address);
            });
    
            it("Should reject ineligible tokens", async function() {
            });
        });

        describe("#operatorDeposit", async function () {
        });

        describe("#depositBatch", async function () {
        });

        describe("#onERC1155Received", async function () {
            it("Should allow deposit of eligible tokens", async function() {
            });
    
            it("Should reject ineligible tokens", async function() {
            });
        });

        describe("#onERC1155BatchReceived", async function () {
        });
    });

    describe("Withdraw", async function () {
    });

    describe("Retire", async function () {
    });

    describe("Transfer", async function () {
    });
});
