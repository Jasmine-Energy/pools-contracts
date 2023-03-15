import { ethers, deployments } from "hardhat";
import { JasminePoolFactory, PoolPolicy } from "@/typechain";
import { Contracts, Libraries, colouredLog, LogColours } from "@/utils";

async function main() {
  // 1. Connect to contract
//   const deployedFactory = await deployments.get(Contracts.factory);
//   const poolFactory = (await ethers.getContractAt(
//     Contracts.factory,
//     deployedFactory.address
//   )) as JasminePoolFactory;

  ethers.getContract(Libraries.poolPolicy);
  console.log(await deployments.all())

  const deployedPolicyLib = await deployments.get(Libraries.poolPolicy);
  const poolPolicyLib = (await ethers.getContractAt(
    Libraries.poolPolicy,
    deployedPolicyLib.address
  )) as PoolPolicy;

  const abiCoder = new ethers.utils.AbiCoder();

  const policyData = abiCoder.encode(
    poolPolicyLib.interface.structs["DepositPolicy"],
    [
      [new Date().toString(), `${new Date().toString() + 100_000}`],
      [],
      [],
      [],
      [],
    ]
  );
  console.log(policyData);

//   const newPoolTx = await poolFactory.deployNewPool(
//     policyData, "Any Tech 2023 Front Half Pool", "a23JLT"
//   );

  //   const newPoolTx = await poolFactory.deployNewPool(
  //     abiCoder.encode(
  //         ["uint256[2]", "uint256[]", "uint256[]", "uint256[]", "uint256[]"],
  //         [
  //             [new Date().toString(), `${new Date().toString() + 100_000}`],
  //             [],
  //             [],
  //             [],
  //             []
  //         ]
  //     ), "Any Tech 2023 Front Half Pool", "a23JLT"
  //   );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
