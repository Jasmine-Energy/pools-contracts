import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contracts, colouredLog, LogColours } from "@/utils";

const deployFactory: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  console.log("deploying Pool Factory to: ", hre.network.name);
  const { ethers, network, deployments } = hre;
//   const { owner, admin } = await hre.getNamedAccounts();

  const policy = await deployments.get(Contracts.poolPolicy);  
  const pool = await deployments.get(Contracts.pool);

  const factoryContract = await ethers.getContractFactory(Contracts.factory, {
        libraries: {
            PoolPolicy: policy.address
        }
    });
  const factory = await factoryContract.deploy(pool.address);

  colouredLog(LogColours.blue, `Deployed factory to: ${factory.address}`)

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
