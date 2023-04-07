import { expect } from "chai";
import { ethers, getNamedAccounts } from "hardhat";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Contracts } from "@/utils";
import { JasminePool, JasminePoolFactory } from "@/typechain";
import { deployPoolImplementation } from "./shared/fixtures";

import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { disableLogging } from "@/utils/hardhat_utils";
import { DEFAULT_ADMIN_ROLE, FEE_MANAGER_ROLE } from "@/utils/constants";


describe(Contracts.factory, function () {
    let owner: SignerWithAddress;
    let bridge: SignerWithAddress;
    let feeBeneficiary: SignerWithAddress;
    let accounts: SignerWithAddress[];
    
    let poolFactory: JasminePoolFactory;
    let poolImplementation: JasminePool;

    before(async function() {
        await disableLogging();
    });

    before(async function() {
        poolImplementation = await loadFixture(deployPoolImplementation);

        const namedAccounts = await getNamedAccounts();
        owner = await ethers.getSigner(namedAccounts.owner);
        bridge = await ethers.getSigner(namedAccounts.bridge);
        feeBeneficiary = await ethers.getSigner(namedAccounts.feeBeneficiary);
        accounts = await ethers.getSigners();

        const PoolFactory = await ethers.getContractFactory(Contracts.factory);
        poolFactory = (await PoolFactory.deploy(poolImplementation.address, feeBeneficiary.address)) as JasminePoolFactory;
    });


    describe("Setup", async function () {
        it("Should have owner correctly set", async function() {
            expect(await poolFactory.owner()).to.be.eq(owner.address);
        });

        it("Should revert if no pool implementation is provided", async function() {
            const PoolFactory = await ethers.getContractFactory(Contracts.factory);
            await expect(PoolFactory.deploy(ethers.constants.AddressZero, owner.address)).to.be.revertedWith("JasminePoolFactory: Pool implementation must be set");
        });

        it("Should revert if pool implementation does not support expect interfaces", async function() {
            // NOTE: This test could be better. Only checks if EAT supports interface
            const PoolFactory = await ethers.getContractFactory(Contracts.factory);
            await expect(PoolFactory.deploy(await poolImplementation.EAT(), owner.address)).to.be.revertedWithCustomError(
                poolFactory, "InvalidConformance"
            );
        });

        it("Should revert if fee beneficiary is set to zero address", async function() {
            const PoolFactory = await ethers.getContractFactory(Contracts.factory);
            await expect(PoolFactory.deploy(poolImplementation.address, ethers.constants.AddressZero)).to.be.revertedWith("JasminePoolFactory: Fee beneficiary must be set");
        });

        it("Should revert if fee beneficiary is a contract which doesn't support IERC777Recipient", async function() {
            const PoolFactory = await ethers.getContractFactory(Contracts.factory);
            await expect(PoolFactory.deploy(poolImplementation.address, await poolImplementation.EAT())).to.be.revertedWith("JasminePoolFactory: Fee beneficiary must support IERC777Recipient interface");
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
            // TODO: Predict client side via ethers.utils.getCreate2Address
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

        it("Should revoke DEFAULT_ADMIN_ROLE from old owner and assign to new owner", async function() {
            // TODO: If above tests fail, state will be in incorrect state and test will fail
            const firstOwner = accounts[1].address;
            const factoryFromNewOwner = poolFactory.connect(accounts[1]);
            expect(await poolFactory.hasRole(DEFAULT_ADMIN_ROLE, firstOwner)).to.be.true;
            expect(await poolFactory.hasRole(DEFAULT_ADMIN_ROLE, owner.address)).to.be.false;

            await factoryFromNewOwner.transferOwnership(owner.address);
            expect(await poolFactory.acceptOwnership()).to.emit(
                poolFactory, "OwnershipTransferred"
            ).withArgs(firstOwner, owner.address)
            .and.to.emit(
                poolFactory, "RoleGranted"
            ).withArgs(DEFAULT_ADMIN_ROLE, owner.address, owner.address)
            .and.to.emit(
                poolFactory, "RoleRevoked"
            ).withArgs(DEFAULT_ADMIN_ROLE, firstOwner, owner.address);

            expect(await poolFactory.hasRole(DEFAULT_ADMIN_ROLE, firstOwner)).to.be.false;
            expect(await poolFactory.hasRole(DEFAULT_ADMIN_ROLE, owner.address)).to.be.true;
        });

        describe("Fee Manager Role", async function () {
            const feeManager = accounts[5];

            it("Should allow owner to grant new fee managers", async function() {
                expect(await poolFactory.hasRole(FEE_MANAGER_ROLE, feeManager.address)).to.be.false;
                expect(await poolFactory.grantRole(FEE_MANAGER_ROLE, feeManager.address)).to.be.ok
                    .and.to.emit(
                        poolFactory, "RoleGranted"
                    ).withArgs(FEE_MANAGER_ROLE, feeManager.address, owner.address);
                expect(await poolFactory.hasRole(FEE_MANAGER_ROLE, feeManager.address)).to.be.true;
            });
    
            it("Should allow owner to revoke fee managers", async function() {
                expect(await poolFactory.hasRole(FEE_MANAGER_ROLE, feeManager.address)).to.be.true;
                expect(await poolFactory.revokeRole(FEE_MANAGER_ROLE, feeManager.address)).to.be.ok
                    .and.to.emit(
                        poolFactory, "RoleRevoked"
                    ).withArgs(FEE_MANAGER_ROLE, feeManager.address, owner.address);
                expect(await poolFactory.hasRole(FEE_MANAGER_ROLE, feeManager.address)).to.be.false;
            });

            it("Should not allow non-owner to grant or revoke fee managers", async function() {
                const factoryFromUser = poolFactory.connect(accounts[3]);
                expect(await factoryFromUser.grantRole(FEE_MANAGER_ROLE, accounts[3].address)).to.be.reverted;
                expect(await factoryFromUser.revokeRole(FEE_MANAGER_ROLE, feeManager.address)).to.be.reverted;
            });

            it("Should allow fee managers to resign roll", async function() {
                expect(await poolFactory.hasRole(FEE_MANAGER_ROLE, feeManager.address)).to.be.true;
                const factoryFromManager = poolFactory.connect(feeManager);

                expect(await factoryFromManager.renounceRole(FEE_MANAGER_ROLE, feeManager.address)).to.be.ok
                    .and.to.emit(
                        poolFactory, "RoleRevoked"
                    ).withArgs(FEE_MANAGER_ROLE, feeManager.address, feeManager.address);
                expect(await poolFactory.hasRole(FEE_MANAGER_ROLE, feeManager.address)).to.be.false;
            });
        });
    });

    describe("Pool Fees", async function () {
        const feeManager = accounts[5];
        const factoryFromManager = poolFactory.connect(feeManager);
        const factoryFromUser = poolFactory.connect(accounts[3]);

        before(async function() {
            await poolFactory.grantRole(FEE_MANAGER_ROLE, feeManager.address);
        });

        beforeEach(async function () {
            await factoryFromManager.setBaseWithdrawalRate(0);
            await factoryFromManager.setBaseRetirementRate(0);

            expect(await poolFactory.baseWithdrawalRate()).to.be.eq(0);
            expect(await poolFactory.baseRetirementRate()).to.be.eq(0);
        });

        describe("Withdrawal Rate", async function() {
            it("Should allow fee managers to set base withdrawal rate", async function() {
                const newRate = 500;
                expect(await factoryFromManager.setBaseWithdrawalRate(newRate)).to.be.ok
                    .and.to.emit(poolFactory, "BaseWithdrawalFeeUpdate").withArgs(newRate, feeBeneficiary);
    
                expect(await poolFactory.baseWithdrawalRate()).to.be.eql(newRate);
            });

            it("Should disallow non fee managers to set base withdrawal rate", async function() {
                const newRate = 500;
                await expect(factoryFromUser.setBaseWithdrawalRate(newRate)).to.be.revertedWithCustomError(
                    poolFactory, "RequiresRole"
                ).withArgs(FEE_MANAGER_ROLE);
    
                expect(await poolFactory.baseWithdrawalRate()).to.be.eql(0);
            });
        });

        describe("Retirement Rate", async function() {
            it("Should allow fee managers to set base retirement rate", async function() {
                const newRate = 500;
                expect(await factoryFromManager.setBaseRetirementRate(newRate)).to.be.ok
                    .and.to.emit(poolFactory, "BaseRetirementFeeUpdate").withArgs(newRate, feeBeneficiary);
    
                expect(await poolFactory.baseRetirementRate()).to.be.eql(newRate);
            });
    
            it("Should disallow non fee managers to set base retirement rate", async function() {
                const newRate = 500;
                await expect(factoryFromUser.setBaseRetirementRate(newRate)).to.be.revertedWithCustomError(
                    poolFactory, "RequiresRole"
                ).withArgs(FEE_MANAGER_ROLE);
    
                expect(await poolFactory.baseRetirementRate()).to.be.eql(0);
            });
        });

        describe("Retirement Rate", async function() {
            it("Should allow fee managers to set fee beneficiary", async function() {
                expect(await factoryFromManager.setFeeBeneficiary(owner.address)).to.be.ok
                    .and.to.emit(poolFactory, "BaseWithdrawalFeeUpdate").withArgs(0, owner.address)
                    .and.to.emit(poolFactory, "BaseRetirementFeeUpdate").withArgs(0, owner.address);
    
                expect(await poolFactory.feeBeneficiary()).to.be.eq(owner.address);
            });
    
            it("Should disallow non fee managers to set fee beneficiary", async function() {
                const initialBeneficiary = await poolFactory.feeBeneficiary();
                await expect(factoryFromUser.setFeeBeneficiary(feeManager.address)).to.be.revertedWithCustomError(
                    poolFactory, "RequiresRole"
                ).withArgs(FEE_MANAGER_ROLE);

                expect(await poolFactory.feeBeneficiary()).to.be.not.eq(initialBeneficiary);
            });
        });
    });
});
