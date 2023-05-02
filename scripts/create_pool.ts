import { ethers, deployments, run, getNamedAccounts } from "hardhat";
import { Contracts, colouredLog } from "@/utils";
import { tryRequire } from "@/utils/safe_import";
import { AnyField } from "@/utils/constants";

// TODO: Would be amazing if (1) deploy new pool on public network auto verified newly deployed
// TODO: proxy on etherscan and (2) created a new ERC-1967 proxy file containing the new pool's
// TODO name, symbol, policy, and other metadata in docstring

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

  const deployPoolTx = await poolFactory.deployNewBasePool(
    {
      vintagePeriod: [
        Math.ceil(new Date().valueOf() / 1_000) - 10_000_000,
        Math.ceil(new Date().valueOf() / 1_000) + 10_000_000,
      ] as [number, number],
      techType: AnyField,
      registry: AnyField,
      certification: AnyField,
      endorsement: AnyField,
    },
    "Any Tech '23",
    "a23JLT"
  );

  await deployPoolTx.wait();
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
