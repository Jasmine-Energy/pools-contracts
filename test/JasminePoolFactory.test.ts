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


describe(Contracts.factory, function () {
    let owner: SignerWithAddress;
    let bridge: SignerWithAddress;
    let accounts: SignerWithAddress[];
    
    let poolFactory: JasminePoolFactory;
    let poolImplementation: JasminePool;

    before(async function() {
        await disableLogging();
    });

    before(async function() {
        poolImplementation = (await loadFixture(deployPoolImplementation)).poolImplementation;

        const namedAccounts = await getNamedAccounts();
        owner = await ethers.getSigner(namedAccounts.owner);
        bridge = await ethers.getSigner(namedAccounts.bridge);
        accounts = await ethers.getSigners();

        const PoolFactory = await ethers.getContractFactory(Contracts.factory);
        poolFactory = (await PoolFactory.deploy(poolImplementation.address)) as JasminePoolFactory;
    });

    beforeEach(async function () {
        // TODO: Create new pool from factory
        // poolFactory.deployNewPool();
    });

    describe("Setup", async function () {
        it("Should revert if no pool implementation is provided", async function() {
            const PoolFactory = await ethers.getContractFactory(Contracts.factory);
            await expect(PoolFactory.deploy(ethers.constants.AddressZero)).to.be.revertedWith("JasminePoolFactory: Pool implementation must be set");
        });

        it("Should revert if no pool implementation does not support expect interface", async function() {
            const PoolFactory = await ethers.getContractFactory(Contracts.factory);
            await expect(PoolFactory.deploy(await poolImplementation.EAT())).to.be.revertedWithCustomError(
                poolFactory, "InvalidConformance"
            );
        });
    });

    describe("Pool Implementation Management", async function () {
        it("Should revert when adding new pool type if implementation exists", async function() {
            await expect(poolFactory.addPoolImplementation(poolImplementation.address)).to.be.revertedWithCustomError(
                poolFactory, "PoolExists"
            );
        });

        it("Should allow owner to add a new pool implementation", async function() {
            // TODO
        });

        it("Should revert if add or remove pool implementation are called by non-owner", async function() {
            // const factory
        });
    });

    describe("Pool Creation", async function () {
        it("Should allow owner to deploy new pool", async function() {
        });
    });

    describe("Access Control", async function () {
    });

    

    

    describe("Retire", async function () {
    });

    describe("Transfer", async function () {
    });
});
