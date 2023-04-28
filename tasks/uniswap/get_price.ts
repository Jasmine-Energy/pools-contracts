import { task } from "hardhat/config";
import type { TaskArguments, HardhatRuntimeEnvironment } from "hardhat/types";
import { colouredLog, Contracts } from "@/utils";
import { tryRequire } from "@/utils/safe_import";
import { DEFAULT_DECIMAL_MULTIPLE } from "@/utils/constants";
import Table from "cli-table3";

task("uniswap:price", "Gets address of JLT to USDC pool")
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
      const { JasminePoolFactory__factory, IJasminePool__factory, IUniswapV3Factory__factory, IUniswapV3Pool__factory } =
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
      const uniPool = IUniswapV3Pool__factory.connect(uniPoolAddress, signer);

      const { sqrtPriceX96 } = await uniPool.slot0();
      console.log(1, sqrtPriceX96.toBigInt())
      const pricex192 = sqrtPriceX96.mul(sqrtPriceX96);
      console.log(2, pricex192.toBigInt())
      const rawPrice = pricex192.div(2n**192n);
      console.log(3, rawPrice.toBigInt())
      const price = rawPrice.div(DEFAULT_DECIMAL_MULTIPLE);
      console.log(4, price.toString())
      //4999999999999999999

      colouredLog.blue(`${price.toString()} USDC/${poolSymbol} for pool: ${uniPoolAddress}`);

    //   const head = ["Index", "Name", "Forked", "Pool ID"];
    //   var table = new Table({
    //     head,
    //     style: {
    //       head: ["yellow"],
    //       border: [],
    //     },
    //     wordWrap: true,
    //     wrapOnWordBoundary: false,
    //   });

    //   var forks = forksFile.forks;

    //   if (taskArgs.fork) {
    //     forks = forks.filter((fork) => fork.forked === taskArgs.fork);
    //   }

    //   for (var i = 0; i < forks.length; i++) {
    //     const fork = forks[i];
    //     const indexOfFork = forksFile.forks.indexOf(fork);
    //     const row = [indexOfFork.toString(), fork.name, fork.forked, { content: fork.id, href: `${TENDERLY_FORK_DASHBOARD}/${fork.id}` }];
    //     table.push(
    //         indexOfFork == forksFile.defaultFork ?
    //         row.map(cell => typeof cell == 'string' ? colors.green(cell) : { content: colors.green(cell.content), href: cell.href }) :
    //         row
    //     );
    //   }

    //   console.log(table.toString());
    }
  );
