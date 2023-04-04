import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contracts } from "@/utils";
import { 
    JasminePool, JasminePoolFactory, 
    JasmineEAT, JasmineOracle, JasmineMinter
} from "@/typechain";
import { deployCoreFixture, deployLibrariesFixture } from "./shared/fixtures";

import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { disableLogging } from "@/utils/hardhat_utils";


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
        const { eat, oracle } = await loadFixture(deployCoreFixture);
        const { policyLibAddress, arrayUtilsLibAddress } = await loadFixture(deployLibrariesFixture);
        const namedAccounts = await getNamedAccounts();
        owner = await ethers.getSigner(namedAccounts.owner);
        bridge = await ethers.getSigner(namedAccounts.bridge);
        accounts = await ethers.getSigners();

        const ownerNonce = await owner.getTransactionCount();
        const poolFactoryFutureAddress = ethers.utils.getContractAddress({
            from: owner.address,
            nonce: ownerNonce + 1,
        });

        const Pool = await ethers.getContractFactory(Contracts.pool, {
            libraries: {
                PoolPolicy: policyLibAddress,
                ArrayUtils: arrayUtilsLibAddress
            }
        });
        poolImplementation = (await Pool.deploy(eat.address, oracle.address, poolFactoryFutureAddress)) as JasminePool;

        const PoolFactory = await ethers.getContractFactory(Contracts.factory);
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
    });

    describe("Deposit", async function () {
    });

    describe("Withdraw", async function () {
    });

    describe("Retire", async function () {
    });

    describe("Transfer", async function () {
    });
});
