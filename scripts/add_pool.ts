import { ethers, deployments, run, getNamedAccounts, network } from "hardhat";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { Contracts, colouredLog } from "@/utils";
import { tryRequire } from "@/utils/safe_import";
import { POOL_MANAGER_ROLE } from "@/utils/constants";
import { delay } from "@/utils/delay";

async function main() {
  // 1. Connect to contract
  if (!tryRequire("@/typechain")) {
    await run("compile");
    await run("typechain");
  }
  // @ts-ignore
  const { JasminePoolFactory__factory, JasminePool__factory } = await import(
    "@/typechain"
  );
  const {
    poolManager,
    poolFactory: poolFactoryAddress,
    eat,
    oracle,
    retirementService,
  } = await getNamedAccounts();
  const managerSigner = await ethers.getSigner(poolManager);
  const deployedFactory = await deployments.getOrNull(Contracts.factory);
  let poolFactory = JasminePoolFactory__factory.connect(
    poolFactoryAddress ?? deployedFactory.address,
    managerSigner
  );
  const owner = await poolFactory.owner();

  if (network.name === "hardhat" || network.name === "localhost") {
    await impersonateAccount(owner);
    const ownerSigner = await ethers.getSigner(owner);

    console.log(`Owner: ${owner}`);

    const isManager = await poolFactory.hasRole(POOL_MANAGER_ROLE, owner);
    if (!isManager) {
      colouredLog.red(
        `Error: Pool manager: ${owner} lacks permission for POOL_MANAGER_ROLE`
      );
      return;
    }

    poolFactory = poolFactory.connect(ownerSigner);
  } else {
    const isManager = await poolFactory.hasRole(POOL_MANAGER_ROLE, poolManager);
    if (!isManager) {
      colouredLog.red(
        `Error: Pool manager: ${poolManager} lacks permission for POOL_MANAGER_ROLE`
      );
      return;
    }
  }

  const newPoolImplFactory = new JasminePool__factory(managerSigner);
  const deployedPoolImpl = await newPoolImplFactory.deploy(
    eat,
    oracle,
    poolFactoryAddress ?? deployedFactory.address,
    retirementService
  );

  colouredLog.green(
    `Deployed new pool implementation at: ${deployedPoolImpl.address} with transaction: ${deployedPoolImpl.deployTransaction.hash}`
  );

  const deployedPoolImplTx = await deployedPoolImpl.deployTransaction.wait();

  await deployments.save("JasminePoolV2", {
    abi: JasminePool__factory.abi,
    address: deployedPoolImpl.address,
    transactionHash: deployedPoolImpl.deployTransaction.hash,
    receipt: deployedPoolImplTx,
    args: [
      eat,
      oracle,
      poolFactoryAddress ?? deployedFactory.address,
      retirementService,
    ],
  });

  // Wait 30 seconds for the contract to be deployed
  await delay(30 * 1_000);

  const addPoolImplTx = await poolFactory.addPoolImplementation(
    deployedPoolImpl.address
  );
  const addPoolReceipt = await addPoolImplTx.wait();

  const poolVersion = addPoolReceipt.events
    ?.find((e) => e.event === "PoolImplementationAdded")
    ?.args?.at(2);

  colouredLog.green(
    `Added new pool implementation to factory at: ${poolFactory.address} with version: ${poolVersion}`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
