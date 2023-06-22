import { ethers, deployments, run, getNamedAccounts } from "hardhat";
import { Contracts, colouredLog } from "@/utils";
import { tryRequire } from "@/utils/safe_import";
import { AnyField } from "@/utils/constants";
import { FuelType, FuelTypesArray } from "@/types/energy-certificate.types";


async function main() {
  // 1. Connect to contract
  if (!tryRequire("@/typechain")) {
    await run("compile");
    await run("typechain");
  }
  // @ts-ignore
  const { JasminePoolFactory__factory } = await import("@/typechain");
  const { owner } = await getNamedAccounts();
  const ownerSigner = await ethers.getSigner(owner);
  const deployedFactory = await deployments.get(Contracts.factory);
  const poolFactory = JasminePoolFactory__factory.connect(
    deployedFactory.address,
    ownerSigner
  );

  const frontHalfPoolTx = await poolFactory.deployNewBasePool(
    {
      vintagePeriod: [
        1672531200, // Jan 1st, 2023
        1688169599, // June 30th, 2023
      ] as [number, number],
      techType: AnyField,
      registry: AnyField,
      certificateType: AnyField,
      endorsement: AnyField,
    },
    "Any Tech Front-Half '23",
    "aF23JLT",
    177159557114295710296101716160n
  );

  const frontHalfDeployedPool = await frontHalfPoolTx.wait();
  const frontHalfPoolAddress = frontHalfDeployedPool.events?.find((e) => e.event === "PoolCreated")?.args?.at(1);
  colouredLog.blue(`Deployed front-half pool to: ${frontHalfPoolAddress}`);

  const backHalfPoolTx = await poolFactory.deployNewBasePool(
    {
      vintagePeriod: [
        1688169600, // July 1st, 2023
        1704067199, // December 31st, 2023
      ] as [number, number],
      techType: AnyField,
      registry: AnyField,
      certificateType: AnyField,
      endorsement: AnyField,
    },
    "Any Tech Back-Half '23",
    "aB23JLT",
    177159557114295710296101716160n
  );
  const backHalfDeployedPool = await backHalfPoolTx.wait();
  const backHalfPoolAddress = backHalfDeployedPool.events?.find((e) => e.event === "PoolCreated")?.args?.at(1);
  colouredLog.blue(`Deployed back-half pool to: ${backHalfPoolAddress}`);

  const solarPoolTx = await poolFactory.deployNewBasePool(
    {
      vintagePeriod: [
        AnyField,
        AnyField,
      ] as [number, number],
      techType: BigInt(FuelTypesArray.indexOf(FuelType.SOLAR)) & BigInt(2 ** 32 - 1),
      registry: AnyField,
      certificateType: AnyField,
      endorsement: AnyField,
    },
    "Solar Tech",
    "sJLT",
    177159557114295710296101716160n
  );
  const solarDeployedPool = await solarPoolTx.wait();
  const solarPoolAddress = solarDeployedPool.events?.find((e) => e.event === "PoolCreated")?.args?.at(1);
  colouredLog.blue(`Deployed solar pool to: ${solarPoolAddress}`);

  const windPoolTx = await poolFactory.deployNewBasePool(
    {
      vintagePeriod: [
        AnyField,
        AnyField,
      ] as [number, number],
      techType: BigInt(FuelTypesArray.indexOf(FuelType.WIND)) & BigInt(2 ** 32 - 1),
      registry: AnyField,
      certificateType: AnyField,
      endorsement: AnyField,
    },
    "Wind Tech",
    "wJLT",
    177159557114295710296101716160n
  );
  const windDeployedPool = await windPoolTx.wait();
  const windPoolAddress = windDeployedPool.events?.find((e) => e.event === "PoolCreated")?.args?.at(1);
  colouredLog.blue(`Deployed wind pool to: ${windPoolAddress}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
