import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contracts, colouredLog, LogColours } from "@/utils";

const deployPoolImplementation: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  colouredLog(LogColours.yellow, `deploying dependencies to: ${hre.network.name}`);

  const { deployments, network, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { owner } = await getNamedAccounts();

  // 1. Deploy Pool Contract
  const pool = await deploy(Contracts.pool, {
    from: owner
  });

  colouredLog(LogColours.blue, `Deployed Pool impl to: ${pool.address}`);

  // 2. If on external network, verify contracts
  if (network.tags["public"]) {
    console.log("Verifyiyng on Etherscan...");
    await hre.run("verify:verify", {
      address: pool,
      constructorArguments: [],
    });
  }
};
deployPoolImplementation.tags = ['Pool'];
export default deployPoolImplementation;
