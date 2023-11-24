import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { yellow, blue } from "@colors/colors";
import { Contracts } from "../../utils";
import { JasmineRetirementService__factory } from "../../typechain";
import { deployProxy, proxyBytecode } from "../utils/proxy";

const deployRetirementService: DeployFunction = async function ({
  deployments,
  ethers,
  network,
  getNamedAccounts,
  hardhatArguments,
}: HardhatRuntimeEnvironment) {
  if (hardhatArguments.verbose)
    console.log(yellow(`deploying Retirement Service to: ${network.name}`));

  const { save, getOrNull } = deployments;
  const namedAccounts = await getNamedAccounts();
  const { deployer, owner } = namedAccounts;

  // 1. Get deployements
  let eat = (await getOrNull(Contracts.eat))?.address ?? namedAccounts.eat;
  let minter =
    (await getOrNull(Contracts.minter))?.address ?? namedAccounts.minter;
  let oracle =
    (await getOrNull(Contracts.oracle))?.address ?? namedAccounts.oracle;

  // 2. Preflight check
  if (!deployer || !owner || !eat || !minter || !oracle)
    throw new Error("Required addresses not found");

  // 3. Deploy Retirement Service Contract
  const deployerSigner = await ethers.getSigner(deployer);
  const Retirer = new JasmineRetirementService__factory(deployerSigner);
  const retirerImpl = await Retirer.deploy(minter, eat);
  await retirerImpl.deployed();

  let {
    contract: retirer,
    tx,
    receipt,
    constructorArgs: proxyConstructorArgs,
  } = await deployProxy(
    retirerImpl as any,
    {
      functionName: Retirer.interface.functions["initialize(address)"],
      args: [owner],
    },
    deployerSigner
  );

  if (hardhatArguments.verbose)
    console.log("deployed proxy", Contracts.retirementService);

  await save(Contracts.retirementService, {
    abi: JasmineRetirementService__factory.abi as unknown as any[],
    bytecode: proxyBytecode,
    address: retirer.address,
    transactionHash: tx.hash,
    implementation: retirerImpl.address,
    args: proxyConstructorArgs,
    receipt,
    deployedBytecode: tx.data,
  });

  console.log(blue(`Deployed Retirement Service to: ${retirer.address}`));
};
deployRetirementService.tags = ["Retirer", "JasminePools", "all"];
deployRetirementService.dependencies = ["Core"];
export default deployRetirementService;
