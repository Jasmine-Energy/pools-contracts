import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { blue, green, yellow, red } from "@colors/colors";
import { Contracts, delay } from "../../utils";
import { JasminePool__factory } from "../../typechain";

const deployPoolImplementation: DeployFunction = async function ({
  ethers,
  deployments,
  network,
  run,
  hardhatArguments,
  getNamedAccounts,
}: HardhatRuntimeEnvironment) {
  console.log(yellow(`deploying Pool implementation to: ${network.name}`));

  // 1. Get deployments, accounts and constructor args
  const { save, get } = deployments;
  const namedAccounts = await getNamedAccounts();
  const { deployer } = namedAccounts;
  const deployerSigner = await ethers.getSigner(deployer);
  const deployerNonce = await deployerSigner.getTransactionCount();
  const poolFactoryFutureAddress = ethers.utils.getContractAddress({
    from: deployer,
    nonce: deployerNonce + 2,
  });

  const retirer = await get(Contracts.retirementService);
  let eat: string;
  let oracle: string;
  try {
    eat = (await get(Contracts.eat)).address;
    oracle = (await get(Contracts.oracle)).address;
  } catch {
    eat = namedAccounts.eat;
    oracle = namedAccounts.oracle;
  }

  const constructorArgs = [
    eat,
    oracle,
    poolFactoryFutureAddress,
    retirer.address,
  ];

  // 2. Deploy Pool Contract
  const Pool = new ethers.ContractFactory(
    JasminePool__factory.abi,
    JasminePool__factory.bytecode,
    deployerSigner
  );
  const pool = await Pool.deploy(...constructorArgs);

  await save(Contracts.pool, {
    abi: JasminePool__factory.abi as unknown as any[],
    address: pool.address,
    transactionHash: pool.deployTransaction.hash,
    args: constructorArgs,
  });

  if (hardhatArguments.verbose)
    console.log(blue(`Deployed Pool impl to: ${pool.address}`));
};
deployPoolImplementation.tags = ["Pool", "JasminePools", "all"];
deployPoolImplementation.dependencies = ["Core", "Retirer"];
export default deployPoolImplementation;
