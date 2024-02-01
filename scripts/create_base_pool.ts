import { ethers, deployments, run, getNamedAccounts, network } from "hardhat";
import { Contracts, colouredLog } from "@/utils";
import { tryRequire } from "@/utils/safe_import";
import { AnyField, POOL_MANAGER_ROLE } from "@/utils/constants";
import { CertificateEndorsement, CertificateEndorsementArr, CertificateArr, EnergyCertificateType } from "@/types";
import { delay } from "@/utils/delay";

async function main() {
  // 1. Connect to contract
  if (!tryRequire("@/typechain")) {
    await run("compile");
    await run("typechain");
  }
  // @ts-ignore
  const { JasminePoolFactory__factory } = await import("@/typechain");
  const { poolManager } = await getNamedAccounts();
  const managerSigner = await ethers.getSigner(poolManager);
  // const deployedFactory = await deployments.get(Contracts.factory);
  const poolFactory = JasminePoolFactory__factory.connect(
    "0x66e04bc791c2be81639bc277a813d782a967abe7",
    managerSigner
  );

  const isManager = await poolFactory.hasRole(POOL_MANAGER_ROLE, poolManager);
  if (!isManager) {
    colouredLog.red(`Error: Pool manager: ${poolManager} lacks permission for POOL_MANAGER_ROLE`);
    return;
  }

  // const frontHalfPoolName = "Voluntary REC Front-Half 2023";
  // const frontHalfPoolSymbol = "JLT-F23";   

  // const frontHalfPoolTx = await poolFactory.deployNewBasePool(
  //   {
  //     vintagePeriod: [
  //       1672531200, // Jan 1st, 2023 @ midnight UTC
  //       1688083200, // June 30th, 2023 @ midnight UTC
  //     ] as [number, number],
  //     techType: AnyField,
  //     registry: AnyField,
  //     certificateType: BigInt(CertificateArr.indexOf(EnergyCertificateType.REC)) & BigInt(2 ** 32 - 1),
  //     endorsement: BigInt(CertificateEndorsementArr.indexOf(CertificateEndorsement.GREEN_E)) & BigInt(2 ** 32 - 1),
  //   },
  //   frontHalfPoolName,
  //   frontHalfPoolSymbol,
  //   52873047440311824542580017936318311n // NOTE: $2.24 USDC - JLT
  // );

  // const frontHalfDeployedPool = await frontHalfPoolTx.wait();
  // console.log(frontHalfDeployedPool.events);
  // const frontHalfPoolAddress = frontHalfDeployedPool.events
  //   ?.find((e) => e.event === "PoolCreated")
  //   ?.args?.at(1);
  // colouredLog.blue(`Deployed ${frontHalfPoolName} pool to: ${frontHalfPoolAddress}`);

  const backHalfPoolName = "Voluntary REC Back-Half 2023";
  const backHalfPoolSymbol = "JLT-B23";   

  const backHalfPool = await poolFactory.deployNewBasePool({
    vintagePeriod: [
        1688169600, // Jul 01 2023 00:00:00 GMT
        1703980800, // Dec 31 2023 00:00:00 GMT
      ] as [number, number],
      techType: AnyField,
      registry: AnyField,
      certificateType: BigInt(CertificateArr.indexOf(EnergyCertificateType.REC)) & BigInt(2 ** 32 - 1),
      endorsement: BigInt(CertificateEndorsementArr.indexOf(CertificateEndorsement.GREEN_E)) & BigInt(2 ** 32 - 1),
  }, backHalfPoolName, backHalfPoolSymbol, 177159557114295710296101716160n);
  const backHalfDeployedPool = await backHalfPool.wait();
  const backHalfPoolAddress = backHalfDeployedPool.events
      ?.find((e) => e.event === "PoolCreated")
      ?.args?.at(1);
  colouredLog.blue(`Deployed back half pool to: ${backHalfPoolAddress}`);
  // colouredLog.yellow('Verifyiyng on Etherscan...');

  // try {
  //   const pool = await deployments.get(Contracts.pool);
  //   console.log(pool.address)

  //   await run('verify:verify', {
  //       address: frontHalfPoolAddress,
  //       contract: "./node_modules/@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol:BeaconProxy",
  //       constructorArguments: [pool.address, ""],
  //   });
  // } catch (err) {
  //   colouredLog.red(`Verification failed. Error: ${err}`);
  // }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
