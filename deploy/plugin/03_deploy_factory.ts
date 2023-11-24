import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { blue, yellow } from "@colors/colors";
import { Contracts, AnyField } from "../../utils";
import { deployProxy, proxyBytecode } from "../utils/proxy";
import { JasminePoolFactory__factory } from "../../typechain";
import {
  CertificateEndorsement,
  CertificateEndorsementArr,
  CertificateArr,
  EnergyCertificateType,
} from "../../types";

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

  // 3. If not prod, create test pool
  if (
    network.name === "hardhat" &&
    process.env.SKIP_DEPLOY_TEST_POOL !== "true"
  ) {
    const managerSigner = await ethers.getSigner(poolManager);
    const factoryContract = JasminePoolFactory__factory.connect(
      factory.address,
      managerSigner
    );
    const frontHalfPool = await factoryContract.deployNewBasePool(
      {
        vintagePeriod: [
          1672531200, // Jan 01 2023 00:00:00 GMT
          1688083200, // Jun 30 2023 00:00:00 GMT
        ] as [number, number],
        techType: AnyField,
        registry: AnyField,
        certificateType:
          BigInt(CertificateArr.indexOf(EnergyCertificateType.REC)) &
          BigInt(2 ** 32 - 1),
        endorsement:
          BigInt(
            CertificateEndorsementArr.indexOf(CertificateEndorsement.GREEN_E)
          ) & BigInt(2 ** 32 - 1),
      },
      "Any Tech Fronthalf '23",
      "aF23JLT",
      177159557114295710296101716160n
    );
    const frontHalfDeployedPool = await frontHalfPool.wait();
    const frontHalfPoolAddress = frontHalfDeployedPool.events
      ?.find((e) => e.event === "PoolCreated")
      ?.args?.at(1);
    if (hardhatArguments.verbose)
      console.log(blue(`Deployed front half pool to: ${frontHalfPoolAddress}`));

    const backHalfPool = await factoryContract.deployNewBasePool(
      {
        vintagePeriod: [
          1688169600, // Jul 01 2023 00:00:00 GMT
          1703980800, // Dec 31 2023 00:00:00 GMT
        ] as [number, number],
        techType: AnyField,
        registry: AnyField,
        certificateType:
          BigInt(CertificateArr.indexOf(EnergyCertificateType.REC)) &
          BigInt(2 ** 32 - 1),
        endorsement:
          BigInt(
            CertificateEndorsementArr.indexOf(CertificateEndorsement.GREEN_E)
          ) & BigInt(2 ** 32 - 1),
      },
      "Any Tech Backhalf '23",
      "aB23JLT",
      177159557114295710296101716160n
    );
    const backHalfDeployedPool = await backHalfPool.wait();
    const backHalfPoolAddress = backHalfDeployedPool.events
      ?.find((e) => e.event === "PoolCreated")
      ?.args?.at(1);
    if (hardhatArguments.verbose)
      console.log(blue(`Deployed back half pool to: ${backHalfPoolAddress}`));
  } else if (
    network.name === "hardhat" &&
    process.env.SKIP_DEPLOY_TEST_POOL === "true"
  ) {
    if (hardhatArguments.verbose)
      console.log(yellow("Skipping test pool deployment"));
  }
};
deployFactory.tags = ["Factory", "JasminePools", "all"];
deployFactory.dependencies = ["Libraries", "Pool", "Core"];
deployFactory.runAtTheEnd = true;
export default deployFactory;
