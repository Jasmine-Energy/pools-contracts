import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";

task("send", "send eth to an address")
  .addPositionalParam<string>("address", "address to send eth to")
  .addOptionalParam<string>("amount", "amount of eth to send", "1")
  .addOptionalParam<string>("index", "index of signer to send from", "0")
  .setAction(async (args: TaskArguments, { ethers }: HardhatRuntimeEnvironment) => {
    const { address, amount, index } = args;
    const signers = await ethers.getSigners();
    const primarySigner = signers[parseInt(index) ?? 0];
    const value = ethers.utils.parseEther(amount);
    const sendTx = await primarySigner.sendTransaction({
      to: address,
      value,
    });
    console.log(`Sending ${value}${ethers.constants.EtherSymbol} from ${primarySigner.address} to ${address} on chain: ${sendTx.chainId}`);
    const result = await sendTx.wait();
    console.log("Tx: ", result);
  });