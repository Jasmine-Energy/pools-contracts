import { ethers, getNamedAccounts } from "hardhat";
import { JasmineMinter } from "@/typechain";
import { Contracts, colouredLog } from "@/utils";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

async function main() {
  const { minter, bridge } = await getNamedAccounts();
  var minterContract = (await ethers.getContractAt(
    Contracts.minter,
    minter
  )) as JasmineMinter;
  const ownerAddress = await minterContract.owner();
  await impersonateAccount(ownerAddress);
  const ownerSigner = await ethers.getSigner(ownerAddress);
  minterContract = (await ethers.getContractAt(
    Contracts.minter,
    minter,
    ownerSigner
  )) as JasmineMinter;
  await minterContract.setBridge(bridge);
  colouredLog.blue(`BRIDGE CHANGED TO: ${bridge}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
