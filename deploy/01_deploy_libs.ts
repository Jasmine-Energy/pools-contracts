import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Libraries, colouredLog, LogColours } from "@/utils";

const deployDependencies: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  colouredLog(LogColours.yellow, `deploying libraries to: ${hre.network.name}`);

  const { deployments, network, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { owner } = await getNamedAccounts();

  // 1. Deploy Pool Policy Library
  const policyLib = await deploy(Libraries.poolPolicy, {
    from: owner,
    log: true,
  });
  
  // 2. Deploy Calldata Library
  const calldataLib = await deploy(Libraries.calldata, {
    from: owner,
    log: true,
  });

  colouredLog(LogColours.blue, `Deployed Policy Lib to: ${policyLib.address} Calldata Lib to: ${calldataLib.address}`);
  
  // 3. If on external network, verify contracts
  if (network.tags["public"]) {
    console.log("Verifyiyng on Etherscan...");
    await hre.run("verify:verify", {
      address: calldataLib,
      constructorArguments: [],
    });

    await hre.run("verify:verify", {
        address: policyLib,
        constructorArguments: [],
      });
  }
};
deployDependencies.tags = ['Libraries', 'all'];
export default deployDependencies;
