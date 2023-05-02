import { ethers, getNamedAccounts, run } from "hardhat";
import { tryRequire } from "@/utils/safe_import";
import { colouredLog } from "@/utils";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

async function main() {
  if (!tryRequire("@/typechain")) {
    await run("compile");
    await run("typechain");
  }
  // @ts-ignore
  const { JasmineMinter__factory } = await import("@/typechain");
  const { minter, bridge } = await getNamedAccounts();
  var minterContract = JasmineMinter__factory.connect(minter, await ethers.getDefaultProvider());
  
  const ownerAddress = await minterContract.owner();
  await impersonateAccount(ownerAddress);
  const ownerSigner = await ethers.getSigner(ownerAddress);
  minterContract = JasmineMinter__factory.connect(minter, ownerSigner);
  await minterContract.setBridge(bridge);
  colouredLog.blue(`BRIDGE CHANGED TO: ${bridge}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
