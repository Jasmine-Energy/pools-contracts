import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contracts, colouredLog } from "@/utils";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";
import { JasmineMinter } from "@/typechain";

const deployCore: DeployFunction = async function ({
  ethers,
  network,
  hardhatArguments,
  getNamedAccounts,
}: HardhatRuntimeEnvironment) {
  colouredLog.yellow(`deploying core contracts to: ${network.name}`);

  // 1. Setup
  const { eat, minter, oracle, bridge } = await getNamedAccounts();

  if (hardhatArguments.verbose) {
    colouredLog.yellow(`EAT: ${eat} MINTER: ${minter} ORACLE: ${oracle}`);
  }

  if (eat && minter && oracle) {
    if (network.name === "hardhat" && network.autoImpersonate) {
      // NOTE: This screws up following deployment steps...
      // await hre.run("run", { script: "./scripts/set_bridge.ts", network: "hardhat" });
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
    } else {
        colouredLog.yellow("Skipping bridge setup, not on hardhat network or autoImpersonate is disabled");
    }
  } else {
    colouredLog.red("Unable to setup bridge. No core contract addresses found.");
  }
};
deployCore.tags = ["Core", "all"];
export default deployCore;
