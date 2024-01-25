import { ethers, deployments, run, getNamedAccounts, network } from "hardhat";
import { Contracts, colouredLog } from "@/utils";
import { tryRequire } from "@/utils/safe_import";
import { AnyField, POOL_MANAGER_ROLE } from "@/utils/constants";
import {
  CertificateEndorsement,
  CertificateEndorsementArr,
  CertificateArr,
  EnergyCertificateType,
} from "@/types/energy-certificate.types";

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
  const { poolManager, poolFactory: poolFactoryAddress } =
    await getNamedAccounts();
  const managerSigner = await ethers.getSigner(poolManager);
  const deployedFactory = await deployments.get(Contracts.factory);
  const poolFactory = JasminePoolFactory__factory.connect(
    poolFactoryAddress ?? deployedFactory.address,
    managerSigner
  );

  const isManager = await poolFactory.hasRole(POOL_MANAGER_ROLE, poolManager);
  if (!isManager) {
    colouredLog.red(
      `Error: Pool manager: ${poolManager} lacks permission for POOL_MANAGER_ROLE`
    );
    return;
  }

  let poolVersion;

  if (network.name === "polygon") {
    poolVersion = 1;
  } else if (network.name === "mumbai") {
    poolVersion = 7;
  } else {
    poolVersion = 1;
  }

  const poolName = "Voluntary REC Front-Half 2024";
  const poolSymbol = "JLT-F24";
  const vintagePeriod = [
    1704067200, // Jan 01 2024 00:00:00 GMT
    1719705600, // June 30 2024 00:00:00 GMT
  ] as [number, number];
  const techType = AnyField;
  const registry = AnyField;
  const certificateType =
    BigInt(CertificateArr.indexOf(EnergyCertificateType.REC)) &
    BigInt(2 ** 32 - 1);
  const endorsement =
    BigInt(CertificateEndorsementArr.indexOf(CertificateEndorsement.GREEN_E)) &
    BigInt(2 ** 32 - 1);

  const poolInterface = new JasminePool__factory().interface;
  const initSelector = poolInterface.getSighash(
    "initialize(bytes,string,string)"
  );
  const initData = ethers.utils.AbiCoder.prototype.encode(
    ["uint56[2]", "uint32", "uint32", "uint32", "uint32"],
    [vintagePeriod, techType, registry, certificateType, endorsement]
  );

  const backHalfPoolTx = await poolFactory.deployNewPool(
    poolVersion,
    initSelector,
    initData,
    poolName,
    poolSymbol,
    0n
  );

  const backHalfDeployedPool = await backHalfPoolTx.wait();
  const backHalfPoolAddress = backHalfDeployedPool.events
    ?.find((e) => e.event === "PoolCreated")
    ?.args?.at(1);
  colouredLog.blue(`Deployed ${poolName} pool to: ${backHalfPoolAddress}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
