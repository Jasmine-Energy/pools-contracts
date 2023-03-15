import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contracts, Libraries, colouredLog, LogColours } from "@/utils";

const deployFactory: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  colouredLog(LogColours.yellow, `deploying Pool Factory to: ${hre.network.name}`);

  const { deployments, network, getNamedAccounts } = hre;
  const { deploy } = deployments;
  const { owner } = await getNamedAccounts();

  // 1. Get deployments
  const pool = await deployments.get(Contracts.pool);
  const policy = await deployments.get(Libraries.poolPolicy);  

  // 2. Deploy Pool Factory Contract
  const factory = await deploy(Contracts.factory, {
    from: owner,
    args: [pool.address],
    libraries: {
      PoolPolicy: policy.address
    }
  });

  colouredLog(LogColours.blue, `Deployed factory to: ${factory.address}`);

  // 3. If on external network, verify contracts
  if (network.name === "polygon" || network.name === "mumbai") {
    console.log("Verifyiyng on Etherscan...");
    await hre.run("verify:verify", {
        address: factory,
        constructorArguments: [pool.address],
    });
  }
};
deployFactory.tags = ['Factory'];
export default deployFactory;
