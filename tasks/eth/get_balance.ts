import { BigNumber, utils } from "ethers"
import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";

task("balance", "Prints an account's balance")
    .addParam("account", "The account's address")
    .setAction(async (taskArgs: TaskArguments, { ethers }: HardhatRuntimeEnvironment): Promise<void> => {
        const account: string = utils.getAddress(taskArgs.account)
        const balance: BigNumber = await ethers.getDefaultProvider().getBalance(account)

        console.log(`${utils.formatEther(balance)} ETH`)
    });
