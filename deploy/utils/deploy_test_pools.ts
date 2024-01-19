import { HardhatRuntimeEnvironment } from "hardhat/types";
import { blue } from "@colors/colors";
import { Contracts, AnyField } from "../../utils";
import { JasminePoolFactory__factory } from "../../typechain/factories/contracts";
import {
  CertificateEndorsement,
  CertificateEndorsementArr,
  CertificateArr,
  EnergyCertificateType,
} from "../../types";

export const deployTestPools = async ({
  ethers,
  deployments,
  getNamedAccounts,
  hardhatArguments,
}: HardhatRuntimeEnvironment) => {
  const { poolManager } = await getNamedAccounts();
  if (!poolManager) throw new Error("poolManager not defined");
  const managerSigner = await ethers.getSigner(poolManager);

  const { address: factoryAddress } = await deployments.get(Contracts.factory);
  const poolFactory = JasminePoolFactory__factory.connect(
    factoryAddress,
    managerSigner
  );

  const frontHalfPool = await poolFactory.deployNewBasePool(
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
  console.log(blue(`Deployed front half pool to: ${frontHalfPoolAddress}`));

  const backHalfPool = await poolFactory.deployNewBasePool(
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
  console.log(blue(`Deployed back half pool to: ${backHalfPoolAddress}`));
};
