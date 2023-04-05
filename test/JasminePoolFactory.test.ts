import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contracts } from "@/utils";
import { JasminePool, JasminePoolFactory } from "@/typechain";
import { deployPoolImplementation } from "./shared/fixtures";

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


    describe("Setup", async function () {
        it("Should have owner correctly set", async function() {
            expect(await poolFactory.owner()).to.be.eq(owner.address);
        });

        it("Should revert if no pool implementation is provided", async function() {
            const PoolFactory = await ethers.getContractFactory(Contracts.factory);
            await expect(PoolFactory.deploy(ethers.constants.AddressZero)).to.be.revertedWith("JasminePoolFactory: Pool implementation must be set");
        });

        it("Should revert if pool implementation does not support expect interfaces", async function() {
            // NOTE: This test could be better. Only checks if EAT supports interface
            const PoolFactory = await ethers.getContractFactory(Contracts.factory);
            await expect(PoolFactory.deploy(await poolImplementation.Eat())).to.be.revertedWithCustomError(
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
            // TODO Check ok and ensure PoolImplementationAdded was emitted
        });

        it("Should revert if non-owner calls add, remove or update pool implementation", async function() {
            const factoryFromExt = poolFactory.connect(accounts[1]);
            await expect(factoryFromExt.addPoolImplementation(poolImplementation.address)).to.be.revertedWith(
                "Ownable: caller is not the owner"
            );
            await expect(factoryFromExt.removePoolImplementation(0)).to.be.revertedWith(
                "Ownable: caller is not the owner"
            );
            await expect(factoryFromExt.updateImplementationAddress(poolImplementation.address, 0)).to.be.revertedWith(
                "Ownable: caller is not the owner"
            );
        });
    });

    describe("Pool Creation", async function () {
        it("Should allow owner to deploy new base pool", async function() {
            const newPolicy = {
                vintagePeriod: [
                    Math.ceil(new Date().valueOf() / 1_000),
                    Math.ceil(new Date().valueOf() + 100_000  / 1_000)
                ] as [number, number],
                techType: 1,
                registry: 0,
                certification: 0,
                endorsement: 0
            };

            // Check Pool creation was ok and emitted PoolCreated
            expect(await poolFactory.deployNewBasePool(newPolicy, 'Solar Tech \'23', 'a23JLT'))
                .to.be.ok
                .and.to.emit(poolFactory, "PoolCreated") // TODO: add .withArgs() to ensure correct emission
                .and.to.emit(poolFactory, "Initialized").withArgs(1);

            // Check total pools increased to 1
            expect(await poolFactory.totalPools()).to.be.eq(1);
        });

        it("Should allow owner to deploy new pool", async function() {
            // TODO: Validate deployNewPool function
        });

        it("Should correcly predict the new pool's address from policy", async function() {
            const newPolicy = {
                vintagePeriod: [
                    Math.ceil(new Date().valueOf() / 1_000),
                    Math.ceil(new Date().valueOf() + 100_000  / 1_000)
                ] as [number, number],
                techType: 2,
                registry: 0,
                certification: 0,
                endorsement: 0
            };
            const hashedPolicy = ethers.utils.solidityKeccak256(
                ["uint256[2]", "uint256", "uint256", "uint256", "uint256"], 
                [newPolicy.vintagePeriod, newPolicy.techType, newPolicy.registry, newPolicy.certification, newPolicy.endorsement]
            );
            const predictedAddress = await poolFactory.computePoolAddress(hashedPolicy);

            expect(await poolFactory.deployNewBasePool(newPolicy, 'Solar Tech \'23', 'a23JLT')).to.be.ok;
            expect(await poolFactory.getPoolAtIndex(1)).to.be.eq(predictedAddress);
        });
    });

    describe("Access Control", async function () {
        it("Should allow owner to initiate ownership transfer", async function() {
            const newOwner = accounts[1].address;
            expect(await poolFactory.transferOwnership(newOwner)).to.emit(
                poolFactory, "OwnershipTransferStarted"
            ).withArgs(owner.address, newOwner);

            expect(await poolFactory.pendingOwner()).to.be.eq(newOwner);
        });

        it("Should allow new owner accept ownership transfer", async function() {
            const newOwner = accounts[1].address;
            const factoryFromNewOwner = poolFactory.connect(accounts[1]);
            expect(await factoryFromNewOwner.acceptOwnership()).to.emit(
                poolFactory, "OwnershipTransferred"
            ).withArgs(owner.address, newOwner);

            expect(await poolFactory.owner()).to.be.eq(newOwner);
        });
    });
});
