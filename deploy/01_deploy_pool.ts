import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contracts, Libraries, colouredLog, LogColours } from "@/utils";

const deployPoolImplementation: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  colouredLog(LogColours.yellow, `deploying dependencies to: ${hre.network.name}`);

  const { deployments, network, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { owner } = await getNamedAccounts();

  // 1. Get deployements
  const policy = await deployments.get(Libraries.poolPolicy);

  // 2. Deploy Pool Contract
  const pool = await deploy(Contracts.pool, {
    from: owner,
    args: [
      // EAT contract address
      // Oracle contract address
    ],
    libraries: {
      PoolPolicy: policy.address
    }
  });

  colouredLog(LogColours.blue, `Deployed Pool impl to: ${pool.address}`);

  // 3. If on external network, verify contracts
  if (network.tags["public"]) {
    console.log("Verifyiyng on Etherscan...");
    await hre.run("verify:verify", {
      address: pool,
      constructorArguments: [],
    });
  }
};
deployPoolImplementation.tags = ['Pool'];
deployPoolImplementation.dependencies = ['Libraries'];
export default deployPoolImplementation;
