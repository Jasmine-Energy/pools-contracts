import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contracts } from "@/utils";
import { JasminePool, JasminePoolFactory } from "@/typechain";


describe(Contracts.pool, function () {
    let owner: SignerWithAddress;
    let bridge: SignerWithAddress;
    let accounts: SignerWithAddress[];
    
    let poolFactory: JasminePoolFactory;
    var pool: JasminePool;

    before(async function() {
        const namedAccounts = await getNamedAccounts();
        owner = await ethers.getSigner(namedAccounts.owner);
        bridge = await ethers.getSigner(namedAccounts.bridge);
        accounts = await ethers.getSigners();

        const Pool = await ethers.getContractFactory(Contracts.pool);
        // pool = await Pool.deploy(); // TODO: correctly deploy w/ constructor args
        const PoolFactory = await ethers.getContractFactory(Contracts.factory);
        // poolFactory = await PoolFactory.deploy() // TODO: correctly deploy w/ constructor args
    });

    beforeEach(async function () {
        // TODO: Create new pool from factory
        // poolFactory.deployNewPool();
    });

    describe("Setup", async function () {
        it("Should revert if initialize is called by non factory", async function() {
            await expect(pool.connect(owner).initialize("", "Pool Name", "JLT")).to.be.revertedWith(
                "JasminePool: caller must be Pool Factory contract"
            );
        });

        it("Should have constants set", async function() {
            expect(await pool.decimals()).to.be.eq(18);

            // TODO: Validate name()

            // TODO: Validate symbol()
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
