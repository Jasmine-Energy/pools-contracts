import { HardhatRuntimeEnvironment } from "hardhat/types";
import { blue, yellow, red } from "@colors/colors";
import { DeployFunction } from "hardhat-deploy/types";
import MinterABI from "@jasmine-energy/core-contracts/abi/src/JasmineMinter.sol/JasmineMinter.json";
import { impersonateAccount } from "@nomicfoundation/hardhat-network-helpers";

const deployCore: DeployFunction = async function ({
  ethers,
  network,
  hardhatArguments,
  getNamedAccounts,
}: HardhatRuntimeEnvironment) {
  if (hardhatArguments.verbose)
    console.log(yellow(`deploying core contracts to: ${network.name}`));

  // 1. Setup
  const { eat, minter, oracle, bridge } = await getNamedAccounts();

  if (hardhatArguments.verbose) {
    console.log(yellow(`EAT: ${eat} MINTER: ${minter} ORACLE: ${oracle}`));
  }

  if (eat && minter && oracle) {
    if (network.name === "hardhat" && network.autoImpersonate) {
      // NOTE: This screws up following deployment steps...
      // await hre.run("run", { script: "./scripts/set_bridge.ts", network: "hardhat" });
      const signers = await ethers.getSigners();
      let minterContract = new ethers.Contract(minter, MinterABI, signers[0]);
      const ownerAddress = await minterContract.owner();
      await impersonateAccount(ownerAddress);
      const ownerSigner = await ethers.getSigner(ownerAddress);
      let minterAsBridge = new ethers.Contract(minter, MinterABI, ownerSigner);
      await minterAsBridge.setBridge(bridge);

      console.log(blue(`JASMINE BRIDGE CHANGED TO: ${bridge}`));
    } else {
      if (hardhatArguments.verbose)
        console.log(
          yellow(
            "Skipping bridge setup, not on hardhat network or autoImpersonate is disabled"
          )
        );
    }
  } else {
    console.log(
      red("Unable to setup bridge. No core contract addresses found.")
    );
  }
};
deployCore.tags = ["Core", "JasminePools", "all"];
export default deployCore;
