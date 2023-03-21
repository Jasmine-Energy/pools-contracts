import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contracts, Libraries, colouredLog, LogColours } from "@/utils";
import { JasminePoolFactory } from "@/typechain";

const deployFactory: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  colouredLog(LogColours.yellow, `deploying Pool Factory to: ${hre.network.name}`);

  const { ethers, deployments, network, getNamedAccounts } = hre;
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
    },
    log: hre.hardhatArguments.verbose
  });

  colouredLog(LogColours.blue, `Deployed factory to: ${factory.address}`);

  // 3. If on external network, verify contracts
  if (network.tags["public"]) {
    console.log("Verifyiyng on Etherscan...");
    await hre.run("verify:verify", {
        address: factory,
        constructorArguments: [pool.address],
    });
  }

  // 4. If not prod, create test pool
  if (!network.tags['public']) {
    const factoryContract = await ethers.getContractAt(Contracts.factory, factory.address) as JasminePoolFactory;
    await factoryContract.deployNewPool({
      vintagePeriod: [
        Math.ceil(new Date().valueOf() / 1_000),
        Math.ceil(new Date().valueOf() + 100_000  / 1_000)
      ],
      techTypes: [],
      registries: [],
      certificationTypes: [],
      endorsements: []
    }, "Any Tech '23", "a23JLT");
  }
};
deployFactory.tags = ['Factory', 'all'];
deployFactory.dependencies = ['Libraries', 'Pool', 'Core'];
export default deployFactory;
