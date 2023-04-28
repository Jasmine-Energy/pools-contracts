import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { colouredLog, Contracts } from "@/utils";
import { tryRequire } from "@/utils/safe_import";

task("uniswap:pool", "Gets address of JLT to USDC pool")
  .addPositionalParam<number>("index", "Pool index to get from factory")
  .addOptionalParam<string>("factory", "Address of Jasmine pool factory")
  .setAction(
    async (
      taskArgs: TaskArguments,
      { ethers, getNamedAccounts, deployments, run }: HardhatRuntimeEnvironment
    ): Promise<void> => {
      // 1. Check if typechain exists. If not, compile and explicitly generate typings
      if (!tryRequire("@/typechain")) {
        await run("compile");
        await run("typechain");
      }
      // @ts-ignore
      const { JasminePoolFactory__factory, IJasminePool__factory, IUniswapV3Factory__factory } =
        await import("@/typechain");

      const { USDC, uniswapPoolFactory } = await getNamedAccounts();
      const signer = (await ethers.getSigners())[0];

      // 2. Load contracts
      const factoryDeployment = await deployments.get(Contracts.factory);
      const factory = JasminePoolFactory__factory.connect(
        taskArgs.factory ?? factoryDeployment.address,
        signer
      );

      let pool;
      try {
        const poolAddress = await factory.getPoolAtIndex(taskArgs.index);
        pool = IJasminePool__factory.connect(poolAddress, signer);
      } catch {
        colouredLog.red("Pool does not exist");
        return;
      }
      const uniFactory = IUniswapV3Factory__factory.connect(
        uniswapPoolFactory,
        signer
      );

      const poolSymbol = await pool.symbol();

      const uniPoolAddress =
        Math.min(parseInt(pool.address, 16), parseInt(USDC, 16)) === parseInt(pool.address, 16)
          ? await uniFactory.getPool(pool.address, USDC, 3_000)
          : await uniFactory.getPool(USDC, pool.address, 3_000);

      colouredLog.blue(`${poolSymbol}-USDC pool: ${uniPoolAddress}`);
    }
  );
