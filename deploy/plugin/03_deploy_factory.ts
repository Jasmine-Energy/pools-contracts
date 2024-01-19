import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { blue, yellow } from "@colors/colors";
import { Contracts } from "../../utils";
import { deployProxy, proxyBytecode } from "../utils/proxy";
import { JasminePoolFactory__factory } from "../../typechain/factories/contracts";

const deployFactory: DeployFunction = async function ({
  ethers,
  deployments,
  network,
  getNamedAccounts,
  hardhatArguments,
}: HardhatRuntimeEnvironment) {
  if (hardhatArguments.verbose)
    console.log(yellow(`deploying Pool Factory to: ${network.name}`));

  // 1. Get deployments, accounts and constructor args
  const { save } = deployments;
  const {
    owner,
    deployer,
    poolManager,
    feeManager,
    feeBeneficiary,
    uniswapPoolFactory,
    USDC,
  } = await getNamedAccounts();
  const deployerSigner = await ethers.getSigner(deployer);

  let tokenBaseURI: string;
  if (network.name === "polygon") {
    tokenBaseURI = "https://api.jasmine.energy/v1/pool/";
  } else if (network.name === "mumbai") {
    tokenBaseURI = "https://api.jazzmine.xyz/v1/pool/";
  } else {
    tokenBaseURI = "https://localhost:8964/v1/pool/";
  }

  const pool = await deployments.get(Contracts.pool);
  const constructorArgs = [uniswapPoolFactory, USDC];
  const initializerArgs = [
    owner,
    pool.address,
    poolManager,
    feeManager,
    feeBeneficiary,
    tokenBaseURI,
  ];

  // 2. Deploy Pool Factory Contract
  const Factory = new JasminePoolFactory__factory(deployerSigner);
  const factoryImpl = await Factory.deploy(
    constructorArgs[0],
    constructorArgs[1]
  );
  await factoryImpl.deployed();
  if (hardhatArguments.verbose)
    console.log("deployed factoryImpl to: ", factoryImpl.address);

  let {
    contract: factory,
    tx,
    receipt,
    constructorArgs: proxyConstructorArgs,
  } = await deployProxy(
    factoryImpl as any,
    {
      functionName:
        Factory.interface.functions[
          "initialize(address,address,address,address,address,string)"
        ],
      args: initializerArgs,
    },
    deployerSigner
  );

  if (hardhatArguments.verbose)
    console.log("deployed proxy to: ", Contracts.factory);

  await save(Contracts.factory, {
    abi: JasminePoolFactory__factory.abi as unknown as any[],
    bytecode: proxyBytecode,
    address: factory.address,
    transactionHash: tx.hash,
    implementation: factoryImpl.address,
    args: proxyConstructorArgs,
    receipt,
    deployedBytecode: tx.data,
  });

  console.log(blue(`Deployed Pool Factory to: ${factory.address}`));
};
deployFactory.tags = ["Factory", "JasminePools", "all"];
deployFactory.dependencies = ["Libraries", "Pool", "Core"];
deployFactory.runAtTheEnd = true;
export default deployFactory;
