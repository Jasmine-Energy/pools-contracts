import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { colouredLog, Contracts } from "@/utils";
import { JasminePoolFactory } from "@/typechain";
import * as Permit2 from "@uniswap/permit2-sdk";
import { createPermit2 } from "@/utils/permit2";
import { DEFAULT_DECIMAL_MULTIPLE } from "@/utils/constants";

task("permit:transfer", "Transfers using permit2")
  .addPositionalParam<string>("signature", "Permit signature of transfer")
  .addPositionalParam<string>("spender", "The account's address")
  .addPositionalParam<string>("amount", "Number of JLTs to permit", "1")
  .addPositionalParam<string>("pool", "Pool address or index", "0")
  .addOptionalParam<string>("from", "Account issuing permit")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, deployments }: HardhatRuntimeEnvironment
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
      const signer = taskArgs.from
        ? await ethers.getSigner(taskArgs.from)
        : (await ethers.getSigners())[0];
      const chainId = await signer.getChainId();

      const amount = BigInt(parseInt(taskArgs.amount)) * DEFAULT_DECIMAL_MULTIPLE;
      const expiration = "0";
      const nonce = 0;
      const { spender } = taskArgs;

      const permit = Permit2.AllowanceTransfer.getPermitData(
        {
          details: [
            {
              token: poolAddress,
              amount,
              expiration,
              nonce,
            },
          ],
          spender,
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

      const permit2Contract = createPermit2(signer);
      
      const tx = await permit2Contract[
        "permit(address,((address,uint160,uint48,uint48),address,uint256),bytes)"
      ](
        signer.address,
        {
            // @ts-ignore
            details: permit.values.details[0],
            spender: permit.values.spender,
            sigDeadline: permit.values.sigDeadline
        },
        signature,
        {
            gasLimit: 25_000_000
        }
      );
      console.log(tx);
    }
  );
