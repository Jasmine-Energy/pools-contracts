import { ethers, deployments, run, getNamedAccounts, network } from "hardhat";
import { Contracts, colouredLog } from "@/utils";
import { tryRequire } from "@/utils/safe_import";
import { AnyField } from "@/utils/constants";
import { CertificateEndorsement, CertificateEndorsementArr, CertificateArr, EnergyCertificateType } from "@/types/energy-certificate.types";
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

  const poolName = "Voluntary REC Front-Half 2023";
  const poolSymbol = "JLT-F23";

  const frontHalfPoolTx = await poolFactory.deployNewBasePool(
    {
      vintagePeriod: [
        1672531200, // Jan 1st, 2023 @ midnight UTC
        1688083200, // June 30th, 2023 @ midnight UTC
      ] as [number, number],
      techType: AnyField,
      registry: AnyField,
      certificateType: BigInt(CertificateArr.indexOf(EnergyCertificateType.REC)) & BigInt(2 ** 32 - 1),
      endorsement: BigInt(CertificateEndorsementArr.indexOf(CertificateEndorsement.GREEN_E)) & BigInt(2 ** 32 - 1),
    },
    poolName,
    poolSymbol,
    52873047440311824542580017936318311n // NOTE: $2.24 USDC - JLT
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
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
