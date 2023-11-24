import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { colouredLog, Contracts, tryRequire } from "../utils";

task("freeze", "Freezes transfers of an EAT")
  .addPositionalParam("token", "EAT token ID to freeze")
  .setAction(
    async (
      taskArgs: TaskArguments,
      {
        ethers,
        deployments,
        network,
        getNamedAccounts,
        run,
        hardhatArguments,
      }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      // 1. Check if typechain exists. If not, compile and explicitly generate typings
      if (!tryRequire("@/typechain")) {
        await run("compile");
        await run("typechain");
      }
      // @ts-ignore
      const { JasmineEAT__factory } = await import("@/typechain");

      // 1. Load required accounts, contracts and info
      const accounts = await ethers.getSigners();
      const { eat } = await getNamedAccounts();
      let eatSavedAddress;
      try {
        eatSavedAddress = (await deployments.get(Contracts.eat)).address;
      } catch {
        eatSavedAddress = eat;
      }
      const ownerAddress = await JasmineEAT__factory.connect(
        eatSavedAddress,
        accounts[0]
      ).owner();
      let signer;
      try {
        if (
          network.tags["local"] &&
          !accounts.find((acc) => acc.address === ownerAddress)
        ) {
          console.log("Impersonating signer: ", ownerAddress);
          ethers.provider = new ethers.providers.JsonRpcProvider(
            ethers.provider.connection.url
          );
          await ethers.provider.send("hardhat_impersonateAccount", [
            ownerAddress,
          ]);
        }
        signer = ethers.provider.getSigner(ownerAddress);
      } catch {
        colouredLog.red(
          `Error: Could not load signer of EAT owner. Address: ${ownerAddress}`
        );
        return;
      }
      const eatContract = JasmineEAT__factory.connect(eatSavedAddress, signer);

      const tx = await eatContract.freeze(taskArgs.token);

      const result = await tx.wait();

      colouredLog.blue(`Froze tokens of ID ${taskArgs.token} . Tx: ${tx.hash}`);

      if (hardhatArguments.verbose) {
        console.log("Result: ", result);
      }
    }
  );

task("unfreeze", "Unfreezes transfers of an EAT")
  .addPositionalParam("token", "EAT token ID to freeze")
  .setAction(
    async (
      taskArgs: TaskArguments,
      {
        ethers,
        deployments,
        network,
        getNamedAccounts,
        run,
        hardhatArguments,
      }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      // 1. Check if typechain exists. If not, compile and explicitly generate typings
      if (!tryRequire("@/typechain")) {
        await run("compile");
        await run("typechain");
      }
      // @ts-ignore
      const { JasmineEAT__factory } = await import("@/typechain");

      // 1. Load required accounts, contracts and info
      const accounts = await ethers.getSigners();
      const { eat } = await getNamedAccounts();
      let eatSavedAddress;
      try {
        eatSavedAddress = (await deployments.get(Contracts.eat)).address;
      } catch {
        eatSavedAddress = eat;
      }
      const ownerAddress = await JasmineEAT__factory.connect(
        eatSavedAddress,
        accounts[0]
      ).owner();
      let signer;
      try {
        if (
          network.tags["local"] &&
          !accounts.find((acc) => acc.address === ownerAddress)
        ) {
          console.log("Impersonating signer: ", ownerAddress);
          ethers.provider = new ethers.providers.JsonRpcProvider(
            ethers.provider.connection.url
          );
          await ethers.provider.send("hardhat_impersonateAccount", [
            ownerAddress,
          ]);
        }
        signer = ethers.provider.getSigner(ownerAddress);
      } catch {
        colouredLog.red(
          `Error: Could not load signer of EAT owner. Address: ${ownerAddress}`
        );
        return;
      }
      const eatContract = JasmineEAT__factory.connect(eatSavedAddress, signer);

      const tx = await eatContract.thaw(taskArgs.token);

      const result = await tx.wait();

      colouredLog.blue(
        `Unfroze tokens of ID ${taskArgs.token} . Tx: ${tx.hash}`
      );

      if (hardhatArguments.verbose) {
        console.log("Result: ", result);
      }
    }
  );
