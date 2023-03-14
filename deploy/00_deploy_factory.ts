import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contracts, colouredLog, LogColours } from "@/utils";

const deployFactory: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  console.log("deploying Pool Factory to: ", hre.network.name);
  const { ethers, network } = hre;
//   const { owner, admin } = await hre.getNamedAccounts();

    
  const baseJasminePool = await ethers.getContractFactory(Contracts.pool);
  const poolAddress = await baseJasminePool.deploy();

  const factoryContract = await ethers.getContractFactory(Contracts.factory);
  const factory = await factoryContract.deploy(poolAddress.address);

  colouredLog(LogColours.blue, `Deployed factory to: ${factory.address} Poo impl to: ${poolAddress.address}`)

  if (network.name === "polygon" || network.name === "mumbai") {
    console.log("Verifyiyng on Etherscan...");
    await hre.run("verify:verify", {
      address: poolAddress,
      constructorArguments: [],
    });

    await hre.run("verify:verify", {
        address: factory,
        constructorArguments: [poolAddress.address],
    });
  }
};
deployFactory.tags = ['Factory'];
export default deployFactory;