import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { colouredLog, Contracts } from "@/utils";
import { JasminePoolFactory } from "@/typechain";
import * as Permit2 from "@uniswap/permit2-sdk";

task("permit", "Create a Permit2 signature for token authorization")
  .addPositionalParam<string>("recipient", "Address to permit")
  .addPositionalParam<string>("amount", "Number of JLTs to permit", "1")
  .addPositionalParam<string>("pool", "Pool address or index", "0")
  .addOptionalParam<string>("spender", "The account's address")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, deployments, hardhatArguments }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      let poolAddress: string;
      if (taskArgs.pool.length === 42) {
        poolAddress = taskArgs.pool;
      } else {
        const poolFactoryDeployment = await deployments.get(Contracts.factory);
        const poolFactory = (await ethers.getContractAt(
          Contracts.factory,
          poolFactoryDeployment.address
        )) as JasminePoolFactory;
        poolAddress = await poolFactory.getPoolAtIndex(parseInt(taskArgs.pool));
      }
      // TODO: attach signer
      const signer = taskArgs.spender
        ? await ethers.getSigner(taskArgs.spender)
        : (await ethers.getSigners())[0];
      const chainId = await signer.getChainId();

      const permit = Permit2.AllowanceTransfer.getPermitData(
        {
          details: [
            {
              token: poolAddress,
              amount: BigInt(parseInt(taskArgs.amount)) * 10n ** 18n,
              expiration: "0",
              nonce: 0,
            },
          ],
          spender: signer.address,
          sigDeadline: "0",
        },
        Permit2.PERMIT2_ADDRESS,
        chainId
      );

      const signature = await signer._signTypedData(
        permit.domain,
        permit.types,
        permit.values
      );

      colouredLog.yellow("Permit typed data: ");
      console.log(permit);
      colouredLog.blue(`Permit is: ${signature}`);
    }
  );
