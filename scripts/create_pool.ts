import { ethers, deployments, run, getNamedAccounts, network } from "hardhat";
import { Contracts, colouredLog } from "@/utils";
import { tryRequire } from "@/utils/safe_import";
import { AnyField } from "@/utils/constants";
import { FuelType, FuelTypesArray } from "@/types/energy-certificate.types";
import { delay } from "@/utils/delay";

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

  const factoryListedOwner = await poolFactory.owner();
  if (factoryListedOwner !== owner) {
    colouredLog.red(`Error: Factory owner (${factoryListedOwner}) is not ${owner}!`);
    return;
  }

  const poolName = "Any Tech Front-Half '23";
  const poolSymbol = "aF23JLT";

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
    poolName,
    poolSymbol,
    52873047440311824542580017936318311n
  );

  const frontHalfDeployedPool = await frontHalfPoolTx.wait();
  const frontHalfPoolAddress = frontHalfDeployedPool.events
    ?.find((e) => e.event === "PoolCreated")
    ?.args?.at(1);
  colouredLog.blue(`Deployed ${poolName} pool to: ${frontHalfPoolAddress}`);

  if (network.tags["public"]) {
    colouredLog.yellow("Waiting for 30 seconds for the contract to be deployed...");
    await delay(30 * 1_000);

    colouredLog.yellow("Verifyiyng on Etherscan...");
    try {
      await run("verify:verify", {
        address: frontHalfPoolAddress,
        constructorArguments: [],
      });
      colouredLog.green(`Verification successful!`);
    } catch (err) {
      colouredLog.red(`Verification failed. Error: ${err}`);
    }
  }

  // const backHalfPoolTx = await poolFactory.deployNewBasePool(
  //   {
  //     vintagePeriod: [
  //       1688169600, // July 1st, 2023
  //       1704067199, // December 31st, 2023
  //     ] as [number, number],
  //     techType: AnyField,
  //     registry: AnyField,
  //     certificateType: AnyField,
  //     endorsement: AnyField,
  //   },
  //   "Any Tech Back-Half '23",
  //   "aB23JLT",
  //   177159557114295710296101716160n
  // );
  // const backHalfDeployedPool = await backHalfPoolTx.wait();
  // const backHalfPoolAddress = backHalfDeployedPool.events?.find((e) => e.event === "PoolCreated")?.args?.at(1);
  // colouredLog.blue(`Deployed back-half pool to: ${backHalfPoolAddress}`);

  // const solarPoolTx = await poolFactory.deployNewBasePool(
  //   {
  //     vintagePeriod: [
  //       AnyField,
  //       AnyField,
  //     ] as [number, number],
  //     techType: BigInt(FuelTypesArray.indexOf(FuelType.SOLAR)) & BigInt(2 ** 32 - 1),
  //     registry: AnyField,
  //     certificateType: AnyField,
  //     endorsement: AnyField,
  //   },
  //   "Solar Tech",
  //   "sJLT",
  //   177159557114295710296101716160n
  // );
  // const solarDeployedPool = await solarPoolTx.wait();
  // const solarPoolAddress = solarDeployedPool.events?.find((e) => e.event === "PoolCreated")?.args?.at(1);
  // colouredLog.blue(`Deployed solar pool to: ${solarPoolAddress}`);

  // const windPoolTx = await poolFactory.deployNewBasePool(
  //   {
  //     vintagePeriod: [
  //       AnyField,
  //       AnyField,
  //     ] as [number, number],
  //     techType: BigInt(FuelTypesArray.indexOf(FuelType.WIND)) & BigInt(2 ** 32 - 1),
  //     registry: AnyField,
  //     certificateType: AnyField,
  //     endorsement: AnyField,
  //   },
  //   "Wind Tech",
  //   "wJLT",
  //   177159557114295710296101716160n
  // );
  // const windDeployedPool = await windPoolTx.wait();
  // const windPoolAddress = windDeployedPool.events?.find((e) => e.event === "PoolCreated")?.args?.at(1);
  // colouredLog.blue(`Deployed wind pool to: ${windPoolAddress}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
