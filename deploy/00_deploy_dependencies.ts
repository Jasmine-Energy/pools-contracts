import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { FormatTypes } from "@ethersproject/abi";
import { Contracts, colouredLog, LogColours } from "@/utils";

const deployDependencies: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  console.log("deploying Pool Factory to: ", hre.network.name);
  const { ethers, deployments, network } = hre;
//   const { owner, admin } = await hre.getNamedAccounts();

  // 1. Deploy Pool Policy Library
  const PolicyLib = await ethers.getContractFactory(Contracts.poolPolicy);
  const policyLib = await PolicyLib.deploy();

  // 2. Deploy Pool Contract
  const JasminePool = await ethers.getContractFactory(Contracts.pool);
  const pool = await JasminePool.deploy();

  colouredLog(LogColours.blue, `Deployed Policy Lib to: ${policyLib.address} Pool impl to: ${pool.address}`)

  // 3. Save Deployments
  deployments.save(Contracts.poolPolicy, {
      abi: <any[]>PolicyLib.interface.format(FormatTypes.full),
      address: policyLib.address,
      transactionHash: policyLib.deployTransaction.hash,
    }
  );

  deployments.save(Contracts.pool, {
      abi: <any[]>JasminePool.interface.format(FormatTypes.full),
      address: pool.address,
      transactionHash: pool.deployTransaction.hash,
    }
  );
  
  // 4. If on external network, verify contracts
  if (network.name === "polygon" || network.name === "mumbai") {
    console.log("Verifyiyng on Etherscan...");
    await hre.run("verify:verify", {
      address: pool,
      constructorArguments: [],
    });

    await hre.run("verify:verify", {
        address: policyLib,
        constructorArguments: [],
      });
  }
};
// TODO Break into two deploys scripts. One for lib, one for pool
deployDependencies.tags = ['Dependencies'];
export default deployDependencies;
