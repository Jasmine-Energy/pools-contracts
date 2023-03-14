import { ethers, deployments } from "hardhat";
import { JasminePoolFactory } from "@/typechain";
import { Contracts, colouredLog, LogColours } from "@/utils";

async function main() {
  // 1. Connect to contract
  const deployedFactory = await deployments.get(Contracts.factory);
  const poolFactory = await ethers.getContractAt(Contracts.factory, deployedFactory.address) as JasminePoolFactory;
  

  const abiCoder = new ethers.utils.AbiCoder();

  const newPoolTx = await poolFactory.deployNewPool(
    abiCoder.encode(
        ["uint256[2]", "uint256[]", "uint256[]", "uint256[]", "uint256[]"],
        [
            [new Date().toString(), `${new Date().toString() + 100_000}`],
            [],
            [],
            [],
            []
        ]
    ), "Any Tech 2023 Front Half Pool", "a23JLT"
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});