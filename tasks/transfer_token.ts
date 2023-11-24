import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import {
  colouredLog,
  Contracts,
  tryRequire,
  DEFAULT_DECIMAL_MULTIPLE,
} from "../utils";

task("transfer", "Transfers an EAT")
  .addPositionalParam<string>("recipient", "The account to receive token")
  .addParam<string>("token", "Token ID to transfer")
  .addParam<string>("quantity", "Number of tokens to transfer", "1")
  .addOptionalParam<string>(
    "sender",
    "Account to transfer token from. Default is ether's default signer"
  )
  .addOptionalParam<string>(
    "contract",
    "Address of ERC-1155 contract to interact with"
  )
  .addOptionalParam<string>(
    "data",
    "Optional data to include in transfer call",
    ""
  )
  .setAction(
    async (
      taskArgs: TaskArguments,
      {
        ethers,
        deployments,
        getNamedAccounts,
        run,
        tracer,
      }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      tracer.enabled = true;
      // 1. Check if typechain exists. If not, compile and explicitly generate typings
      if (!tryRequire("@/typechain")) {
        await run("compile");
        await run("typechain");
      }
      // @ts-ignore
      const { IERC1155Upgradeable__factory, JasminePool__factory } =
        await import("@/typechain");

      // 2. Load required accounts, contracts and info
      const { eat } = await getNamedAccounts();
      const sender = taskArgs.sender
        ? await ethers.getSigner(taskArgs.sender)
        : (await ethers.getSigners())[0];
      let eatDeployment;
      try {
        eatDeployment = await deployments.get(Contracts.eat);
      } catch {}
      const contractAddress =
        taskArgs.contract ?? eatDeployment?.address ?? eat;
      const { recipient, data } = taskArgs;
      const tokenId = BigInt(taskArgs.token);
      const quantity = BigInt(taskArgs.quantity);
      const contract = IERC1155Upgradeable__factory.connect(
        contractAddress,
        sender
      );

      // 3. Verify ownership of token
      const tokenBalance = await contract.balanceOf(sender.address, tokenId);
      if (tokenBalance.lt(quantity)) {
        colouredLog.red(
          `Error: Insufficient balance. Sender (${
            sender.address
          }) has ${tokenBalance.toString()} of ${tokenId}`
        );
        return;
      }

      // 4. Initiate transfer
      const sendTx = await contract.safeTransferFrom(
        sender.address,
        recipient,
        tokenId,
        quantity,
        data.length == 0 ? [] : ethers.utils.hexValue(data)
      );
      await sendTx.wait();

      colouredLog.blue(
        `Sent ${quantity} of token ID ${tokenId} to ${recipient} from ${sender.address} in Tx: ${sendTx.hash}`
      );

      // 5. Check if pool, if so, log balance
      try {
        const pool = JasminePool__factory.connect(recipient, sender);
        const balance = await pool.balanceOf(sender.address);
        const poolName = await pool.name();
        const symbol = await pool.symbol();
        colouredLog.blue(
          `\nBalance in "${poolName}" is now: ${balance.div(
            DEFAULT_DECIMAL_MULTIPLE
          )} ${symbol}`
        );
      } catch {}
      tracer.enabled = false;
    }
  );
